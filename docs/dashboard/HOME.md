# EAIRA Dashboard

## Current Context

- [[docs/project/context/CURRENT_CONTEXT]]

## Project Status

```dataview
LIST
FROM "docs/project/status"
SORT file.mtime DESC
```

## Latest Engineering Logs

```dataview
TABLE file.mtime AS Updated
FROM "docs/project/logs"
SORT file.mtime DESC
LIMIT 10
```

## Latest Milestones

```dataview
TABLE file.mtime AS Updated
FROM "docs/project/milestones"
SORT file.mtime DESC
LIMIT 10
```

## Latest Validation

```dataview
TABLE file.mtime AS Updated
FROM "docs/project/validation"
SORT file.mtime DESC
LIMIT 10
```