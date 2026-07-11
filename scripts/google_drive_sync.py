#!/usr/bin/env python3
"""Publish repository documentation to an application-managed Google Drive tree."""

from __future__ import annotations

import hashlib
import mimetypes
import os
from pathlib import Path
import sys
import time
from typing import Any, Callable, TypeVar

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from googleapiclient.http import MediaFileUpload


# Constants
DRIVE_SCOPE = "https://www.googleapis.com/auth/drive.file"
TOKEN_URI = "https://oauth2.googleapis.com/token"
MANAGED_BY_KEY = "managed_by"
MANAGED_BY_VALUE = "eaira_github_actions"
SHA256_KEY = "sha256"
FOLDER_MIME_TYPE = "application/vnd.google-apps.folder"
DEFAULT_SOURCE = "docs"
DEFAULT_ROOT_NAME = "EAIRA_GITHUB_SYNC"
MAX_ATTEMPTS = 5
TRANSIENT_HTTP_STATUSES = frozenset({429, 500, 502, 503, 504})
REQUIRED_ENV_NAMES = (
    "GOOGLE_CLIENT_ID",
    "GOOGLE_CLIENT_SECRET",
    "GOOGLE_REFRESH_TOKEN",
)

T = TypeVar("T")


def required_env() -> dict[str, str]:
    """Return required environment values, failing without exposing their contents."""
    missing = [name for name in REQUIRED_ENV_NAMES if not os.environ.get(name)]
    if missing:
        raise RuntimeError(
            "Missing required environment variables: " + ", ".join(missing)
        )
    return {name: os.environ[name] for name in REQUIRED_ENV_NAMES}


def sha256_file(path: Path) -> str:
    """Calculate a file's SHA-256 digest without loading the full file into memory."""
    digest = hashlib.sha256()
    with path.open("rb") as source_file:
        for chunk in iter(lambda: source_file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def execute_with_retry(operation: Callable[[], T]) -> T:
    """Execute a Drive API operation with bounded retries for transient statuses."""
    for attempt in range(1, MAX_ATTEMPTS + 1):
        try:
            return operation()
        except HttpError as error:
            status = getattr(error.resp, "status", None)
            if status not in TRANSIENT_HTTP_STATUSES or attempt == MAX_ATTEMPTS:
                raise
            time.sleep(2 ** (attempt - 1))
    raise RuntimeError("Drive API retry limit reached")


def build_drive_service() -> Any:
    """Construct refreshed OAuth credentials and a Google Drive v3 service."""
    environment = required_env()
    credentials = Credentials(
        token=None,
        refresh_token=environment["GOOGLE_REFRESH_TOKEN"],
        token_uri=TOKEN_URI,
        client_id=environment["GOOGLE_CLIENT_ID"],
        client_secret=environment["GOOGLE_CLIENT_SECRET"],
        scopes=[DRIVE_SCOPE],
    )
    credentials.refresh(Request())
    return build("drive", "v3", credentials=credentials, cache_discovery=False)


def escape_query(value: str) -> str:
    """Escape a string for use inside a quoted Drive API query value."""
    return value.replace("\\", "\\\\").replace("'", "\\'")


def list_matching_items(service: Any, query: str) -> list[dict[str, Any]]:
    """List all Drive items matching a query."""
    items: list[dict[str, Any]] = []
    page_token: str | None = None
    while True:
        request = service.files().list(
            q=query,
            spaces="drive",
            fields="nextPageToken, files(id, name, mimeType, appProperties)",
            orderBy="createdTime",
            pageToken=page_token,
        )
        response = execute_with_retry(lambda: request.execute(num_retries=0))
        items.extend(response.get("files", []))
        page_token = response.get("nextPageToken")
        if not page_token:
            return items


def find_managed_child(
    service: Any,
    name: str,
    parent_id: str | None,
    mime_type: str | None = None,
) -> dict[str, Any] | None:
    """Find one non-trashed application-managed item by name and parent."""
    clauses = [
        f"name = '{escape_query(name)}'",
        "trashed = false",
        (
            "appProperties has "
            f"{{ key='{MANAGED_BY_KEY}' and value='{MANAGED_BY_VALUE}' }}"
        ),
    ]
    if parent_id is not None:
        clauses.append(f"'{escape_query(parent_id)}' in parents")
    if mime_type is not None:
        clauses.append(f"mimeType = '{escape_query(mime_type)}'")
    matches = list_matching_items(service, " and ".join(clauses))
    return matches[0] if matches else None


def ensure_root_folder(service: Any, root_name: str) -> str:
    """Create or reuse the application-managed synchronization root folder."""
    existing = find_managed_child(service, root_name, "root", FOLDER_MIME_TYPE)
    if existing:
        return str(existing["id"])

    body = {
        "name": root_name,
        "mimeType": FOLDER_MIME_TYPE,
        "parents": ["root"],
        "appProperties": {MANAGED_BY_KEY: MANAGED_BY_VALUE},
    }
    request = service.files().create(body=body, fields="id")
    created = execute_with_retry(lambda: request.execute(num_retries=0))
    print("Created managed root folder")
    return str(created["id"])


def ensure_folder(service: Any, parent_id: str, name: str, relative_path: Path) -> str:
    """Create or reuse one application-managed folder under a known parent."""
    existing = find_managed_child(service, name, parent_id, FOLDER_MIME_TYPE)
    if existing:
        return str(existing["id"])

    body = {
        "name": name,
        "mimeType": FOLDER_MIME_TYPE,
        "parents": [parent_id],
        "appProperties": {MANAGED_BY_KEY: MANAGED_BY_VALUE},
    }
    request = service.files().create(body=body, fields="id")
    created = execute_with_retry(lambda: request.execute(num_retries=0))
    print(f"Created folder: {relative_path.as_posix()}")
    return str(created["id"])


def ensure_directory_tree(service: Any, root_id: str, directory: Path) -> str:
    """Create or reuse every folder in a repository-relative directory path."""
    parent_id = root_id
    traversed = Path()
    for part in directory.parts:
        traversed /= part
        parent_id = ensure_folder(service, parent_id, part, traversed)
    return parent_id


def upload_or_update_file(
    service: Any,
    local_path: Path,
    relative_path: Path,
    parent_id: str,
) -> str:
    """Create, update, or skip one application-managed Drive file."""
    checksum = sha256_file(local_path)
    existing = find_managed_child(service, local_path.name, parent_id)

    if existing and existing.get("mimeType") == FOLDER_MIME_TYPE:
        raise RuntimeError("A managed folder conflicts with the local file path")
    if existing and existing.get("appProperties", {}).get(SHA256_KEY) == checksum:
        print(f"Unchanged: {relative_path.as_posix()}")
        return "unchanged"

    mime_type = mimetypes.guess_type(local_path.name)[0] or "application/octet-stream"
    media = MediaFileUpload(str(local_path), mimetype=mime_type, resumable=False)
    app_properties = {MANAGED_BY_KEY: MANAGED_BY_VALUE, SHA256_KEY: checksum}

    if existing:
        request = service.files().update(
            fileId=existing["id"],
            body={"appProperties": app_properties},
            media_body=media,
            fields="id",
        )
        execute_with_retry(lambda: request.execute(num_retries=0))
        print(f"Updated: {relative_path.as_posix()}")
        return "updated"

    request = service.files().create(
        body={
            "name": local_path.name,
            "parents": [parent_id],
            "appProperties": app_properties,
        },
        media_body=media,
        fields="id",
    )
    execute_with_retry(lambda: request.execute(num_retries=0))
    print(f"Created: {relative_path.as_posix()}")
    return "created"


def _safe_error_description(error: Exception) -> str:
    if isinstance(error, HttpError):
        status = getattr(error.resp, "status", "unknown")
        return f"Drive API HTTP status {status}"
    return type(error).__name__


def main() -> int:
    """Synchronize local documentation without performing any remote deletion."""
    print("Remote deletion is disabled by design.")
    source = Path(os.environ.get("EAIRA_SYNC_SOURCE", DEFAULT_SOURCE))
    root_name = os.environ.get("EAIRA_DRIVE_ROOT_NAME", DEFAULT_ROOT_NAME)

    if not source.is_dir():
        print("Error: source directory does not exist", file=sys.stderr)
        return 1

    try:
        service = build_drive_service()
        root_id = ensure_root_folder(service, root_name)
    except Exception as error:
        print(
            f"Error: authentication or Drive initialization failed ({_safe_error_description(error)})",
            file=sys.stderr,
        )
        return 1

    counts = {"created": 0, "updated": 0, "unchanged": 0, "failed": 0}
    source_root = source.resolve()
    files = sorted(path for path in source.rglob("*") if path.is_file())

    for local_path in files:
        relative_path = local_path.relative_to(source)
        try:
            if not local_path.resolve().is_relative_to(source_root):
                raise RuntimeError("Source file resolves outside the source directory")
            parent_id = ensure_directory_tree(service, root_id, relative_path.parent)
            outcome = upload_or_update_file(
                service, local_path, relative_path, parent_id
            )
            counts[outcome] += 1
        except Exception as error:
            counts["failed"] += 1
            print(
                f"Failed: {relative_path.as_posix()} ({_safe_error_description(error)})",
                file=sys.stderr,
            )

    print(
        f"created={counts['created']} updated={counts['updated']} "
        f"unchanged={counts['unchanged']} failed={counts['failed']}"
    )
    return 1 if counts["failed"] else 0


if __name__ == "__main__":
    sys.exit(main())
