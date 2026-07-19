# B2-MAN-010 Official-Source Documentary Review

## 1. Metadata

| Field | Value |
| --- | --- |
| Title | B2-MAN-010 Official-Source Documentary Review |
| Document Type | Project Layer version-scoped official-source documentary planning input |
| Layer | Project Layer |
| Repository-Record Classification | `ADOPTED_VERSION_SCOPED_DOCUMENTARY_PLANNING_INPUT_WITH_RECORDED_LIMITATIONS` |
| Version | 0.1.0 |
| Date | 2026-07-19 |
| Planning Task | `LOCAL-READINESS-ASSESSMENT-AUTHORIZATION-ANNEX-PLANNING-001` |
| Decision Authority | Project Owner |
| Assessment Execution | `UNAUTHORIZED` |
| Assessment Evidence Collection | `UNAUTHORIZED` |
| Command Execution | `UNAUTHORIZED` |
| Local Inspection | `UNAUTHORIZED` |

## 2. Purpose and authority boundary

This artifact is the repository record of the completed response-only B2-MAN-010
official-source documentary review that the Project Owner accepted on 2026-07-19 with a
required classification correction, and whose specific narrower conclusion the Project
Owner adopted as version-scoped documentary planning input under the ratified Field 2
`B2-MAN-010` high-level direction Option B (require version-scoped primary documentation).

This artifact evidences the accepted review in the committed repository state. The
response-only completion and acceptance of the review and the repository evidencing of
that acceptance are distinct lifecycle events; this artifact does not itself create the
Project Owner adoption decision, which is recorded in
`docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_B2_MAN_010_OPTION_B_ADOPTION_DECISION.md`.
The commit identity of the repository evidencing is established by Git evidence.

This artifact grants no assessment-execution, command-execution, local-inspection, Gate B,
or evidence-collection authority. It establishes no local configuration, auth, credential,
plugin, endpoint, telemetry, network, or Engine fact, satisfies no criterion, establishes
no readiness, and removes no blocker.

## 3. Exact EAIRA repository baseline

Repository: `antonychengkh-code/EAIRA-Enterprise-AI`

Exact reviewed commit: `bd5103c527c0730501189e3a1f5a982078c136d1`
(`docs(project): record Field 2 Stage 1 Area 8 Option 8a selection`)

Classification: `VERIFIED_REPOSITORY_FACT`

The review retrieved the mandatory repository baseline (bootstrap, current context,
current status, today objective, active-task metadata, Main Annex, Field 2 package,
Field 2 adoption decision, Area 8 Option 8a selection decision) and the bootstrap-required
follow-up sources at that exact commit. At that baseline, `B2-MAN-010` is recorded as
`docker --version` against `TGT-DOCKER-001` (WSL CLI; WSL path; working directory
`/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI`; privilege `NO_ELEVATION`;
timeout 30 seconds; network action `NONE`; approval state
`APPROVED_AS_MANIFEST_PLANNING_INPUT`) and remains a substantive documentary blocker;
Field 2 and Field 3 are `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`; and the gate is
`BLOCKED`.

## 4. Exact Docker version scope

- Docker CLI tag: `v29.6.1`
- Official tag commit: `8900f1d330cb39e93e16d780a26bff1d7e07ba03`

All version-pinned findings in this artifact apply only to official `docker/cli` source at
this tag and commit. Current Docker documentation cited below was retrieved on 2026-07-19
and is not represented as version-pinned documentation.

## 5. Official-source register

| ID | Owner; title | Version/path and exact location | Classification |
|---|---|---|---|
| D1 | Docker Inc.; **docker version** | Current docs, "Description" ([docker version reference](https://docs.docker.com/reference/cli/docker/version/)) | `EXPLICIT_OFFICIAL_DOCUMENTATION` |
| D2 | Docker Inc.; **docker** base command | Current docs, "Environment variables," "Configuration files," "Credential store options," "CLI plugin options" ([docker base command reference](https://docs.docker.com/reference/cli/docker/#environment-variables)) | `EXPLICIT_OFFICIAL_DOCUMENTATION` |
| D3 | Docker; **Release v29.6.1** | [`v29.6.1`](https://github.com/docker/cli/releases/tag/v29.6.1); tag commit [`8900f1d330cb39e93e16d780a26bff1d7e07ba03`](https://github.com/docker/cli/commit/8900f1d330cb39e93e16d780a26bff1d7e07ba03) | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` |
| S1 | Docker; `docker/cli` **VERSION** | `v29.6.1`, [`VERSION`](https://github.com/docker/cli/blob/v29.6.1/VERSION), line 1 | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` |
| S2 | Docker; root Docker command | `v29.6.1`, [`cmd/docker/docker.go`](https://github.com/docker/cli/blob/v29.6.1/cmd/docker/docker.go), `dockerMain` 82–91; `newDockerCommand` 136–191; `runDocker` 475–550 | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` |
| S3 | Docker; top-level Cobra integration | `v29.6.1`, [`cli/cobra.go`](https://github.com/docker/cli/blob/v29.6.1/cli/cobra.go), `SetupRootCommand` 66–68; `HandleGlobalFlags` 129–159; `TopLevelCommand.Initialize` 163–166 | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` |
| S4 | Docker; build version variables | `v29.6.1`, [`cli/version/version.go`](https://github.com/docker/cli/blob/v29.6.1/cli/version/version.go), lines 3–10 | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` |
| S5 | Docker-vendored Cobra 1.10.2 | [`vendor.mod` lines 50–51](https://github.com/docker/cli/blob/v29.6.1/vendor.mod#L50); [`vendor/github.com/spf13/cobra/command.go` lines 905–974](https://github.com/docker/cli/blob/v29.6.1/vendor/github.com/spf13/cobra/command.go#L905) | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` |
| S6 | Docker; `DockerCli.Initialize` and API initialization | [`cli/command/cli.go` lines 209–280](https://github.com/docker/cli/blob/v29.6.1/cli/command/cli.go#L209), endpoint/client code 303–388, context resolution 402–474, lazy client initialization 528–545 | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` |
| S7 | Docker; configuration loading | [`cli/config/config.go` lines 18–30, 76–89, 118–175](https://github.com/docker/cli/blob/v29.6.1/cli/config/config.go#L18) | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` |
| S8 | Docker; `config.json` structure/parsing | [`cli/config/configfile/file.go` lines 52–75 and 125–151](https://github.com/docker/cli/blob/v29.6.1/cli/config/configfile/file.go#L52) | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` |
| S9 | Docker; default credential-store detection | [`cli/config/credentials/default_store.go` lines 3–29](https://github.com/docker/cli/blob/v29.6.1/cli/config/credentials/default_store.go#L3) | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` |
| S10 | Docker; global option/environment handling | [`cli/flags/options.go` lines 18–55 and 102–165](https://github.com/docker/cli/blob/v29.6.1/cli/flags/options.go#L18) | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` |
| S11 | Docker; aliases/builder preprocessing | [`cmd/docker/aliases.go` lines 21–43](https://github.com/docker/cli/blob/v29.6.1/cmd/docker/aliases.go#L21); [`cmd/docker/builder.go` lines 50–86](https://github.com/docker/cli/blob/v29.6.1/cmd/docker/builder.go#L50) | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` |
| S12 | Docker; telemetry provider and export | [`cli/command/telemetry.go` lines 117–136 and 180–220](https://github.com/docker/cli/blob/v29.6.1/cli/command/telemetry.go#L117) | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` |
| S13 | Docker; Docker OTLP endpoint/exporter | [`cli/command/telemetry_docker.go` lines 23–135](https://github.com/docker/cli/blob/v29.6.1/cli/command/telemetry_docker.go#L23) | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` |
| S14 | Docker; default context metadata | [`cli/command/defaultcontextstore.go` lines 56–91 and 135–143](https://github.com/docker/cli/blob/v29.6.1/cli/command/defaultcontextstore.go#L56) | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` |
| S15 | Docker; persisted context metadata | [`cli/context/store/metadatastore.go` lines 63–99](https://github.com/docker/cli/blob/v29.6.1/cli/context/store/metadatastore.go#L63) | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` |
| S16 | Docker; plugin discovery/execution/hooks | [`manager/cobra.go` lines 18–45](https://github.com/docker/cli/blob/v29.6.1/cli-plugins/manager/cobra.go#L18); [`manager/manager.go` lines 32–60, 100–160, 174–221](https://github.com/docker/cli/blob/v29.6.1/cli-plugins/manager/manager.go#L32); [`manager/hooks.go` lines 35–67](https://github.com/docker/cli/blob/v29.6.1/cli-plugins/manager/hooks.go#L35) | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` |
| S17 | Docker; Cobra instrumentation wrapper | [`cli/command/telemetry_utils.go` lines 29–65](https://github.com/docker/cli/blob/v29.6.1/cli/command/telemetry_utils.go#L29) | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` |

## 6. Closed documentary-question register

### DQ-B210-01 — SUFFICIENT

- Classification: `EXPLICIT_OFFICIAL_DOCUMENTATION`
- Finding: Current Docker documentation defines `docker --version` as outputting the
  version number of the Docker CLI being used, contrasted with `docker version`, which
  displays independently versioned components and client/server sections (D1).
- Classification: `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE`
- Finding: At `v29.6.1`, the root command sets `Version` to
  `"<version>, build <GitCommit>"`, and the template renders
  `Docker version {{.Version}}`. The source-level shape is therefore
  `Docker version <version>, build <GitCommit>` (S2 line 157; S3 lines 66–68).
- Limitation: `Version` and `GitCommit` are build-time variables with defaults
  `unknown-version` and `unknown-commit` (S4). Tag identity alone does not establish the
  values embedded in a particular local executable.

### DQ-B210-02 — SUFFICIENT

- Classification: `EXPLICIT_OFFICIAL_DOCUMENTATION`
- Finding: Docker documentation explicitly defines the displayed `docker --version` value
  as the Docker CLI version (D1).
- Limitation: This is an output-content statement, not an execution-path or
  initialization contract.

### DQ-B210-03 — PARTIALLY_SUFFICIENT (Project Owner corrected classification)

- Controlling corrected result: `PARTIALLY_SUFFICIENT` — official documentation defines
  the displayed output as Docker CLI information, but does not establish the entire
  command execution as client-only. Any stronger execution-path conclusion remains
  limited to version-pinned official source evidence.
- Classification: `EXPLICIT_OFFICIAL_DOCUMENTATION`
- Finding (positive displayed-output statement): The documentation defines the displayed
  `docker --version` output as Docker CLI version information (D1).
- Classification: `EVIDENCE_GAP`
- Finding (absence of an entire-execution guarantee): Official documentation does not
  establish that the entire `docker --version` command execution is client-only. This
  absence is a documentation evidence gap and is not an explicit official-documentation
  statement.
- Classification: `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE`
- Finding (execution-path findings): The pinned source shows substantial initialization
  before Cobra renders the version, including configuration loading, context resolution,
  telemetry setup, alias processing, and credential-store detection pathways (S2, S3,
  S6–S13).
- Conclusion: "CLI-only displayed information" must not be converted into "only
  client-version formatting code executes."

### DQ-B210-04 — SUFFICIENT

- Classification: `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE`
- Finding: `dockerMain` creates a `DockerCli`; `runDocker` constructs the root command,
  handles global flags, and calls `TopLevelCommand.Initialize` before `ExecuteContext`
  prints the version (S2 lines 82–91 and 475–485; S3 lines 129–166).

### DQ-B210-05 — SUFFICIENT

- Classification: `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE`
- Finding:
  - the config directory is resolved;
  - `config.json` is opened and parsed when present;
  - `CurrentContext`, aliases, plugin settings, `credsStore`, `credHelpers`, and `auths`
    are parsed;
  - the current context name is resolved from flags, environment, or `config.json`;
  - a context store is constructed;
  - telemetry consults current-context metadata;
  - a non-default context causes persisted `meta.json` metadata to be read;
  - the default context resolves endpoint metadata from options/environment and may read
    TLS files when TLS is enabled.

  Sources: S6–S8, S10, S13–S15.
- Limitation: Exact files reached depend on flags, environment, config contents, and
  selected context.

### DQ-B210-06 — SUFFICIENT

- Classification: `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE`
- Finding: The pinned path reads or may read at least `DOCKER_CONFIG`, home-directory
  inputs, `DOCKER_CERT_PATH`, `DOCKER_TLS`, `DOCKER_TLS_VERIFY`, `DOCKER_CONTEXT`,
  `DOCKER_HOST`, `DOCKER_BUILDKIT`, `GODEBUG`, `OTEL_RESOURCE_ATTRIBUTES`,
  `DOCKER_CLI_OTEL_EXPORTER_OTLP_ENDPOINT`, `DOCKER_CLI_DISABLE_COMPLETION_DESCRIPTION`,
  and, for Unix-endpoint conversion, `WSL_DISTRO_NAME` (S2, S6, S7, S10–S13).
- Limitation: This is a source-path inventory, not a statement about values on the local
  machine.

### DQ-B210-07 — SUFFICIENT

- Classification: `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE`
- Finding:
  - plugin-related configuration fields may be parsed;
  - normal non-completion plugin command-stub discovery was not reached;
  - plugin directory enumeration was not found in the bounded path;
  - plugin metadata discovery or execution was not found;
  - plugin execution was not reached;
  - plugin hooks were not reached.

  Sources: S2, S5, S11, S16.
- Limitation: Plugin configuration parsing still occurs. This finding is
  source-version-specific and does not apply to wrappers, modified builds, or other CLI
  versions.

### DQ-B210-08 — SUFFICIENT

- Classification: `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE`
- Finding:
  - **Configuration parsing:** yes. `config.json` is parsed.
  - **Auth parsing:** yes, if `auths` entries exist; encoded `auth` values are decoded
    into username/password fields.
  - **Credential-store name parsing:** yes; `credsStore` and `credHelpers` are parsed.
  - **Default-store detection:** conditional. If `ContainsAuth()` is false,
    `DetectDefaultStore` runs.
  - **Helper executable lookup:** conditional. Default-store detection calls
    `exec.LookPath("docker-credential-"+platformDefault)`.
  - **Helper execution:** no call found in the bounded path.
  - **Credential retrieval from a helper:** no call found.
  - **Embedded registry credential material:** may be read and decoded from
    `config.json`.

  Sources: S7–S9.
- Limitation: "No helper execution call found" is not a general Docker contract or proof
  about a modified/local wrapper.

### DQ-B210-09 — SUFFICIENT

- Classification: `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE`
- Finding:
  - **Docker API-client object:** not created in the bounded path.
  - **Docker endpoint metadata:** resolved or consulted for telemetry. The default
    context resolves endpoint metadata from options/environment; a non-default context
    reads context metadata.
  - **Docker Engine Unix socket/named pipe/SSH/TCP transport:** no Engine transport
    construction call found.
  - **API negotiation/Ping:** not reached.
  - **Engine API request:** no call found.
  - **Non-Engine endpoint:** conditional Docker CLI OTLP telemetry is significant. If a
    Docker-specific OTLP endpoint is configured through context metadata or
    `DOCKER_CLI_OTEL_EXPORTER_OTLP_ENDPOINT`, the path constructs OTLP exporters.
    Meter-provider shutdown calls `ForceFlush`, which calls the exporter's `Export`; this
    can attempt communication with a configured HTTP, HTTPS, or Unix OTLP endpoint.

  Sources: S6, S12–S15.
- Limitation: The Annex's unconditional `Network action = NONE` is not established by the
  pinned source without configuration/environment constraints because conditional OTLP
  export exists.

### DQ-B210-10 — PARTIALLY_SUFFICIENT

- Classification: `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE`
- Finding: The bounded stock `v29.6.1` source path contains no Docker API-client
  construction, Engine transport construction, negotiation, Ping, or Engine request.
- Classification: `REASONED_INFERENCE`
- Conclusion: This strongly supports "no explicit Docker Engine API request in the traced
  stock source path."
- Limitation: It is not an explicit contractual prohibition, does not prove all runtime
  side effects absent, does not cover packaging or wrappers, and does not exclude
  conditional non-Engine OTLP endpoint contact.

### DQ-B210-11 — SUFFICIENT

- Classification: `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE`
- Finding: Bounded stdout cannot prove the absence of initialization, configuration
  access, auth parsing, credential-store detection, helper lookup, context metadata
  access, environment processing, endpoint resolution, or telemetry export. These can
  occur before or after the version line while leaving stdout bounded.
- Limitation: Output conformity proves only output conformity.

### DQ-B210-12 — SUFFICIENT

- Classification: `EXPLICIT_OFFICIAL_DOCUMENTATION`
- Stable documented contract: `docker --version` displays the version number of the
  Docker CLI being used.
- Classification: `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE`
- Version-specific observations: exact template, initialization order, config parsing,
  auth decoding, conditional default-helper lookup, context metadata access, the exact
  bounded plugin findings of Section 9, absence of Engine API-client construction, and
  conditional OTLP exporter behavior.
- Limitation: None of the source-code observations may be generalized across Docker CLI
  versions.

### DQ-B210-13 — SUFFICIENT

- Classification: `FUTURE_LOCAL_VERIFICATION_REQUIRED`
- Required local facts:
  - executable path and identity;
  - whether `docker` is a binary, script, alias, wrapper, shim, or launcher;
  - Docker CLI version;
  - embedded version and Git commit/build identifier;
  - package source and provenance;
  - correspondence to official `docker/cli` tag `v29.6.1`;
  - environment variables;
  - config-directory selection;
  - `config.json` existence and applicable fields;
  - current-context selection;
  - context metadata;
  - plugin directories and packaging modifications;
  - `auths`, `credsStore`, and `credHelpers`;
  - platform-default credential-helper name and executable availability;
  - Docker endpoint and TLS configuration;
  - Docker-specific OTLP endpoint configuration;
  - Engine endpoint configuration;
  - whether packaging adds patches, telemetry changes, or startup behavior.

### DQ-B210-14 — SUFFICIENT

- Classification: `VERIFIED_REPOSITORY_FACT`
- Finding: B2-MAN-010 remains a substantive blocker under the repository's controlling
  state.
- Classification: `REASONED_INFERENCE`
- Conclusion: Official-source evidence is not sufficient to remove the blocker without
  future local verification and a separate Project Owner decision.
- Additional reason: the pinned source confirms several previously unresolved
  initialization concerns and adds a material conditional OTLP endpoint/export pathway.

## 7. Version-pinned execution-path analysis

Pinned version: `docker/cli v29.6.1`, commit `8900f1d330cb39e93e16d780a26bff1d7e07ba03`.

| Order | Bounded path | Status |
|---:|---|---|
| 1 | Package initialization reads TLS/certificate-related environment variables used as global defaults. | Definitely occurs |
| 2 | `dockerMain` creates `DockerCli`. | Definitely occurs |
| 3 | `newDockerCommand` constructs the root Cobra command, sets version to `version.Version + ", build " + version.GitCommit`, installs global flags, and registers `--version`. | Definitely occurs |
| 4 | `HandleGlobalFlags` parses `--version`; the flag becomes true and remaining non-flag arguments are empty. | Definitely occurs |
| 5 | `TopLevelCommand.Initialize` calls `SetDefaultOptions`, then `DockerCli.Initialize`. | Definitely occurs |
| 6 | Config directory is resolved; `config.json` open is attempted; if present it is parsed. | Definitely attempted; parsing conditional on file |
| 7 | Config auth, credential, plugin, alias, and current-context fields are populated when present. | Conditional on content |
| 8 | If no auth configuration exists, default credential-store detection and helper `LookPath` occur. | Conditional |
| 9 | Current context is resolved and context store constructed. | Definitely occurs |
| 10 | Telemetry providers are initialized; current-context metadata is consulted for a Docker-specific OTLP endpoint. | Definitely occurs |
| 11 | Default context endpoint metadata is resolved in memory; non-default context metadata is read from its `meta.json`. TLS data can be read if enabled. | Branch-dependent |
| 12 | OTLP metric/tracing exporters are constructed if an endpoint is configured. | Conditional |
| 13 | `processAliases` reads aliases; `processBuilder` reads `DOCKER_BUILDKIT`. With empty command arguments it returns before builder-plugin discovery. | Definitely occurs through early return |
| 14 | Completion-only plugin-stub discovery is skipped. | Definitely not reached |
| 15 | Plugin execution branch is skipped because remaining arguments are empty. | Definitely not reached |
| 16 | Cobra reparses the empty argument list, sees the already-set root version flag, renders `Docker version <version>, build <commit>`, and returns before persistent pre-run and root `RunE`. | Definitely occurs if earlier initialization succeeds |
| 17 | Plugin hooks remain unreachable because no subcommand was selected. | Definitely not reached |
| 18 | Deferred meter-provider shutdown runs. If an OTLP metric exporter was configured, shutdown calls exporter `Export` with a 50 ms timeout. | Shutdown definite; export conditional |
| 19 | `DockerCli.initialize`, which would create the Docker API client and Ping/negotiate with the Engine, has no call in the bounded path. | No call found |

Unproven absent: behavior introduced by a local wrapper, altered binary, downstream
packaging patch, dynamic runtime/library behavior outside the reviewed source, or another
CLI version.

## 8. Configuration and context analysis

Classification: `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE`

For `v29.6.1`:

- `DOCKER_CONFIG` or the default home-based config directory is consulted.
- `config.json` is opened and parsed when present.
- Parsing includes `auths`, `credsStore`, `credHelpers`, `currentContext`,
  `cliPluginsExtraDirs`, `plugins`, and aliases.
- `DOCKER_HOST` and `DOCKER_CONTEXT` participate in current-context selection.
- `DOCKER_CERT_PATH`, `DOCKER_TLS`, and `DOCKER_TLS_VERIFY` affect TLS/endpoint metadata
  and can cause certificate/key file checks or reads.
- A context-store object is always constructed.
- Telemetry always requests current-context metadata:
  - for `default`, endpoint metadata is resolved from flags/environment in memory;
  - for a named context, persisted `contexts/meta/.../meta.json` is read.
- `GODEBUG` and `OTEL_RESOURCE_ATTRIBUTES` are consulted; the latter may be altered in
  process memory.
- Docker-specific OTLP endpoint configuration is read from context metadata or
  `DOCKER_CLI_OTEL_EXPORTER_OTLP_ENDPOINT`.

No local value, file existence, or selected context is established by this review.

## 9. Plugin analysis

Classification: `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE`

All findings in this section are limited to stock Docker CLI `v29.6.1` source and are
distinguished exactly as follows:

| Plugin behavior | `docker --version` at stock `v29.6.1` |
|---|---|
| Plugin-related configuration fields | May be parsed; relevant `config.json` fields are parsed when present |
| Normal non-completion plugin command-stub discovery | Not reached |
| Plugin directory enumeration | Not found in the bounded path |
| Plugin metadata discovery or execution | Not found |
| Plugin execution | Not reached; no subcommand argument remains |
| Plugin hooks | Not reached; no selected subcommand and Cobra version handling returns before pre-runs |
| Completion-only processing | Not reached; `--version` is not a completion request |
| Builder alias processing | Alias config and `DOCKER_BUILDKIT` are read; empty command arguments cause return before builder-plugin discovery |

The bounded findings above are the complete plugin conclusion of this artifact, and none
of them applies to wrappers, modified builds, packaging changes, or other CLI versions.

## 10. Credential analysis

Classification: `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE`

| Credential-related behavior | Finding |
|---|---|
| `config.json` auth parsing | Yes |
| Embedded `auth` decoding | Conditional; present values are decoded into username/password fields |
| `credsStore` parsing | Yes, when field present |
| `credHelpers` parsing | Yes, when field present |
| Default-store detection | Conditional; runs when `ContainsAuth()` is false |
| Helper executable lookup | Conditional; `exec.LookPath` searches for the platform-default helper |
| Configured helper execution | No call found |
| Credential-helper protocol invocation | No call found |
| Credential retrieval from helper | No call found |
| Registry credential material read from `config.json` | Conditional; yes when embedded auth entries exist |
| `DOCKER_AUTH_CONFIG` credential retrieval path | No call found for exact `--version` path |

The correct narrower statement is not "credentials are untouched." Configuration can
expose embedded auth material to the parser, and helper executable lookup can occur.

## 11. Engine, network, and OTLP analysis

Classification: `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE`

| Behavior | Finding |
|---|---|
| Docker API-client object creation | No call found |
| Docker endpoint metadata resolution | Yes, through current-context telemetry lookup |
| Default endpoint resolution | Yes for the default context; uses flags/environment and may read TLS files |
| Named-context metadata read | Conditional; yes for non-default current context |
| Engine Unix socket/named pipe/SSH/TCP connection construction | No call found |
| API negotiation | Not reached |
| Engine Ping | Not reached |
| Engine API request | No call found |
| Non-Engine OTLP endpoint parsing | Conditional |
| OTLP gRPC exporter construction | Conditional |
| OTLP metric export attempt | Conditional at provider shutdown |
| Contractual prohibition on Engine/network contact | Not documented |

Therefore:

- source evidence supports no explicit Engine client/request in the pinned path;
- source evidence does not support an unconditional "no endpoint or network processing"
  statement;
- the recorded `Network action = NONE` remains the requested and prohibited network
  action only; it is not treated as verified absence of network activity, and the
  independent interaction-risk status
  `CONDITIONAL_NON_ENGINE_OTLP_ENDPOINT_PROCESSING_NOT_EXCLUDED` is recorded for
  `B2-MAN-010`.

## 12. Evidence-versus-inference matrix

| Statement | Classification | Boundary |
|---|---|---|
| Docker docs say `docker --version` outputs the CLI version number | `EXPLICIT_OFFICIAL_DOCUMENTATION` | Displayed output only |
| Docker documentation does not establish the entire `docker --version` execution as client-only | `EVIDENCE_GAP` | Documentation absence; not an official documentation statement |
| `v29.6.1` exists and points to commit `8900f1d330cb39e93e16d780a26bff1d7e07ba03` | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` | Official tag/commit |
| Source template is `Docker version <Version>, build <GitCommit>` | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` | Build-time values remain variable |
| `DockerCli.Initialize` runs before the version is printed | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` | Pinned source only |
| Config and current-context processing occur | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` | Exact reached files depend on configuration |
| Embedded auth values can be decoded | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` | Conditional on config contents |
| Default credential-helper lookup can occur | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` | Conditional on absence of configured auth |
| Plugin-related configuration fields may be parsed; normal non-completion plugin command-stub discovery was not reached; plugin directory enumeration was not found in the bounded path; plugin metadata discovery or execution was not found; plugin execution was not reached; plugin hooks were not reached | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` | Exact `--version` path at stock `v29.6.1` only |
| No Docker API-client construction or Engine request call was found | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` | Not a contractual prohibition |
| A configured OTLP endpoint can receive an export attempt | `VERSION_PINNED_OFFICIAL_SOURCE_EVIDENCE` | Conditional |
| No explicit Engine request likely means stock source does not intentionally contact the Engine | `REASONED_INFERENCE` | Not proof of runtime absence |
| The local executable behaves identically | `EVIDENCE_GAP` | Requires local verification |
| Bounded stdout proves no other processing | `EVIDENCE_GAP` | Unsupported and contradicted by reached initialization code |
| Applying the pinned result to the local B2-MAN-010 executable | `FUTURE_LOCAL_VERIFICATION_REQUIRED` | Path, version, provenance, configuration, and environment required |

## 13. Local-applicability boundary

The following apply only to official `docker/cli v29.6.1` source at commit
`8900f1d330cb39e93e16d780a26bff1d7e07ba03`:

- root version template and flag handling;
- initialization-before-output order;
- config/auth parsing;
- context and telemetry behavior;
- conditional credential-helper lookup;
- the exact bounded plugin findings of Section 9;
- absence of Docker API-client construction and Engine request in the traced path;
- conditional OTLP exporter construction/export.

The current documentation statement that `docker --version` displays the CLI version is
current documentation, not a frozen `v29.6.1` execution contract.

Nothing in this review establishes that the local executable:

- is version 29.6.1;
- derives from the reviewed tag;
- embeds the reviewed commit;
- is unmodified;
- has no wrapper or shim;
- uses the same dependencies or build flags;
- has any particular configuration, current context, plugin, credential, endpoint, TLS,
  or OTLP state.

## 14. Adopted Option B conclusion

Adoption status: `ADOPTED_AS_VERSION_SCOPED_DOCUMENTARY_PLANNING_INPUT` (Project Owner
decision issued at the response-only decision layer on 2026-07-19; recorded in
`docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_B2_MAN_010_OPTION_B_ADOPTION_DECISION.md`).
The conclusion is recorded in its Project-Owner-directed corrected form, which states the
plugin findings through the exact bounded distinction of Section 9.

> For official Docker CLI source tag `v29.6.1`, commit
> `8900f1d330cb39e93e16d780a26bff1d7e07ba03`, `docker --version` is a root version flag
> whose displayed output is formatted as Docker CLI version/build information. Before that
> output is produced, the stock source constructs and initializes a Docker CLI object,
> resolves and parses client configuration, resolves the current context, initializes
> telemetry, processes aliases and relevant environment inputs, may decode embedded
> registry-auth material, may detect and search for a default credential-helper
> executable, and may read context or TLS metadata depending on configuration. For the
> exact argument path at stock `v29.6.1`: plugin-related configuration fields may be
> parsed; normal non-completion plugin command-stub discovery was not reached; plugin
> directory enumeration was not found in the bounded path; plugin metadata discovery or
> execution was not found; plugin execution was not reached; plugin hooks were not
> reached; and no Docker API-client construction, API negotiation, Engine Ping, or Engine
> API request call was found. However, Docker endpoint metadata is consulted, and a
> configured Docker-specific OTLP endpoint can cause exporter construction and a
> conditional export attempt. The displayed version line does not prove absence of
> initialization, configuration, credential-related processing, endpoint processing,
> telemetry, or other side effects. These findings apply only to the reviewed official
> tag and do not establish the identity, version, packaging, configuration, environment,
> or behavior of the local B2-MAN-010 executable. B2-MAN-010 therefore remains a
> substantive blocker pending future separately authorized local/version verification and
> a separate Project Owner decision. Field 2 and Field 3 remain
> `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`; the gate remains `BLOCKED`; and no
> execution or evidence-collection authority is granted.

## 15. Exact unresolved dependencies

- Local executable path and invocation resolution.
- Binary identity and cryptographic/provenance identity.
- CLI version and embedded Git commit/build identifier.
- Package/distribution source.
- Wrapper, alias, function, launcher, or shim presence.
- Downstream patches or build-time behavior changes.
- `DOCKER_CONFIG` and home-directory resolution.
- `config.json` existence, readability, validity, and contents.
- Embedded `auths` entries.
- `credsStore` and `credHelpers`.
- Default credential-store selection.
- Credential-helper executable availability.
- Current-context selection.
- Named-context metadata.
- `DOCKER_HOST`, `DOCKER_CONTEXT`, `DOCKER_CERT_PATH`, `DOCKER_TLS`, and
  `DOCKER_TLS_VERIFY`.
- Certificate/key file existence and contents.
- `DOCKER_BUILDKIT`.
- `GODEBUG`.
- `OTEL_RESOURCE_ATTRIBUTES`.
- Docker-specific OTLP endpoint configuration.
- `WSL_DISTRO_NAME` and endpoint-path handling.
- Plugin configuration, extra directories, packaging, and local plugin state.
- Docker endpoint configuration.
- Whether any endpoint corresponds to a Unix socket, named pipe, SSH endpoint, TCP
  endpoint, or remote host.
- Whether conditional OTLP export would occur.
- Whether the local executable actually follows the reviewed source path.
- Whether any local or packaged initialization adds Engine contact or other network
  behavior.

All are `FUTURE_LOCAL_VERIFICATION_REQUIRED`.

## 16. Main Annex impact

Main Annex Version `0.19.0` contains the synchronized adopted conclusion at the following
bounded B2-MAN-010 wording locations only: the B2-MAN-010 command-definition purpose
clarification; the B2-MAN-010 output/risk row's mutation-risk wording; the B2-MAN-010
stop wording; the selected Batch 8 `B2-INT-004` overlay; the Field 2, Field 3, and
Field 4 dispositions in their bounded B2-MAN-010-related wording; the `REP-B2-010`
record-specific precondition / stop cell; the `MAP-B2-010` verifier action, sufficient
result, and non-inference boundary cells; the retained Model A requirements note; the
authorization/traceability and source-path registers; and the final authority boundary.
The B2-MAN-010 blocker state is recorded through the Field 2 row, the B2-MAN-010
mutation-risk row, the stop-condition row, the selected `B2-INT-004` overlay,
`REP-B2-010`, `MAP-B2-010`, the retained Model A requirements, and the synchronized
current-state artifacts; no separate Main Annex blocker-summary anchor exists or is
modified. The Main Annex `Network action` value for `B2-MAN-010` remains `NONE` as the
requested and prohibited network action; the manifest-table header is not renamed; no
other manifest row's semantics are modified; the `REP-B2-010` identity values, including
30 seconds and `NONE`, are unchanged; the `MAP-B2-010` allowed decision use, prohibited
decision use, and approval state are unchanged; and the exact command, arguments, target,
working directory, timeout, privilege, and bounded output purpose are unchanged. The
historical pre-Batch-8 `B2-INT-004` interaction-definition row is unchanged.

## 17. Preserved control state

- B2-MAN-010 remains a substantive blocker.
- B2-MAN-006, B2-MAN-007, and B2-MAN-013 remain substantive blockers.
- Exactly four Field 2 substantive blockers exist: `B2-MAN-006`, `B2-MAN-007`,
  `B2-MAN-010`, and `B2-MAN-013`.
- Field 2 remains `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`.
- Field 3 remains `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`.
- Field 8 remains `PARTIALLY_RESOLVED_WITH_REQUIRED_IMPLEMENTATION_DETAILS`; Field 9
  remains `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`; Field 10 remains
  `APPROVED_AS_PLANNING_CONTROL_WITH_FIELD_8_AND_9_DEPENDENCIES`; Field 11 remains
  `APPROVED_AS_PLANNING_CONTROL_WITH_EVIDENCE_DEPENDENCIES`; Field 12 remains
  `RESOLVED_AS_CONTROL`.
- The gate remains `BLOCKED`; no formal Field 12 gate evaluation occurred.
- Area 8 Option 8a remains selected; Area 8 Option 8b remains
  `NOT_AVAILABLE_WITHOUT_SEPARATE_REOPENING_AND_REVISION_OF_THE_CONTROLLING_HIGH_LEVEL_DIRECTION`;
  Area 8 Option 8c remains available and not selected; all other Stage 1 details remain
  unselected.
- Batch 8 Model A scope remains unchanged.
- Every execution, inspection, Gate B, assessment, evidence, runtime, deployment,
  database, production, governance, milestone, M4, Platform Foundation, and formal EAIRA
  Execution Layer prohibition remains intact.

## 18. Historical-integrity boundary

The completed response-only review of 2026-07-19 carried the conclusion
`OFFICIAL_SOURCE_REVIEW_COMPLETE_CANDIDATE_OPTION_B_CONCLUSION_READY_FOR_PROJECT_OWNER_REVIEW`,
recorded its DQ-B210-03 heading classification as `SUFFICIENT`, and recorded the
candidate conclusion as `PROPOSED_OPTION_B_NARROWER_DOCUMENTARY_CONCLUSION_NOT_YET_ADOPTED`.
The completed response-only review used a broader plugin-summary formulation. The
corrected adopted repository form records only the exact bounded distinctions in
Sections 9, 12, and 14. The Project Owner acceptance decision
`ACCEPTED_WITH_REQUIRED_CLASSIFICATION_CORRECTION` corrected DQ-B210-03 to
`PARTIALLY_SUFFICIENT`, directed the exact bounded plugin distinction, and adopted the
specific narrower conclusion. This artifact records the corrected, adopted form and
preserves the original classifications as historical facts in this section; it does not
retroactively alter any prior decision, prior Annex version, prior commit, or historical
record.
