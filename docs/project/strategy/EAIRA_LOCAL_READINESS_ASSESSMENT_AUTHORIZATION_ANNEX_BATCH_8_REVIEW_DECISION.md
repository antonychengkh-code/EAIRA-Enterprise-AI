# EAIRA Local Readiness Assessment Authorization Annex — Batch 8 Review Decision

**Repository path:** `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_8_REVIEW_DECISION.md`

## 1. Decision Identification

| Field | Value |
| --- | --- |
| Title | EAIRA Local Readiness Assessment Authorization Annex — Batch 8 Review Decision |
| Document Type | Strategy-owned Project Layer Project Owner decision record |
| Layer | Project Layer |
| Status | `APPROVED_AS_PLANNING_EVIDENCE` |
| Reviewed Package | `docs/project/planning/BATCH_8_ASSESSMENT_SCOPE_MINIMIZATION_AND_COMMAND_MANIFEST_CLOSURE_PLANNING_PACKAGE.md` |
| Reviewed-Package Commit | `17d03c080e22b3dab9df13043358418a25a3b55a`; stabilized at `fec0436da1941576c3a322291ec9dca2b03ba6b0` |
| Decision | `APPROVE_BATCH_8_AND_SELECT_MODEL_A_WITH_MANDATORY_SEPARATE_EXTENSION_AND_LIMITED_READINESS_CLAIM_WITHOUT_EXECUTION_AUTHORITY` |
| Decision Authority | Project Owner |
| Decision Date | `2026-07-16` |
| Classification | `PROJECT_OWNER_DECISION` |
| Execution Marker | `PROPOSED_NOT_AUTHORIZED_FOR_EXECUTION` |
| Underlying Package Decision | `DEFER_PENDING_ADDITIONAL_PLANNING_EVIDENCE`（`EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE_DECISION.md` §2；此決策不取代該記錄） |

This document records the Project Owner's adopted bounded documentary decision. Creation of this record was separately authorized as a Project Layer repository artifact. Staging, commit, push, and synchronization are separate repository lifecycle actions requiring separate explicit Project Owner authorization and direct evidence. It selects Model A only as the initial documentary scope model. It does not resolve a Field or authorize assessment execution, evidence collection, or any other operational activity.

## 2. Batch 8 Package Disposition

This decision accepts the following artifact **only as bounded documentary planning evidence**:

`docs/project/planning/BATCH_8_ASSESSMENT_SCOPE_MINIMIZATION_AND_COMMAND_MANIFEST_CLOSURE_PLANNING_PACKAGE.md`

Acceptance does **not** constitute approval of every option, recommendation, assumption, model, row disposition, or proposed conclusion contained in that package. Each disposition below is separately and explicitly recorded.

## 3. Selected Model

| Model | Disposition |
| --- | --- |
| Model A — Minimal Core Assessment Scope | `SELECTED_AS_INITIAL_DOCUMENTARY_SCOPE_MODEL` |
| Model B — Minimal Core Plus Docker Context Equality | `REVIEWED_NOT_SELECTED` |
| Model C — Extended Local AI Assessment Scope | `REVIEWED_NOT_SELECTED` |

Models A, B, and C are cited exactly as defined in the Batch 8 package (§9–§11 of that package), not in the main Annex, which does not currently define them.

No "Model A+" is created as a separate fourth package model. The additional protections in Sections 9 and 10 below are recorded only as mandatory conditions attached to the selected Model A documentary decision itself.

## 4. Selected Targets

The initial selected documentary scope contains only:

- `TGT-REPO-001`
- `TGT-WSL-001`
- `TGT-GIT-WIN-001`
- `TGT-GIT-WSL-001`
- `TGT-DOCKER-001`, limited strictly to the Docker client-version planning row `B2-MAN-010`

This selection does not imply Docker Engine contact, runtime inspection, execution authority, or interaction authority beyond the documentary planning inclusion expressly bounded in Section 6.

## 5. Retained Command-Manifest Rows

The following are retained within the selected documentary scope:

- `B2-MAN-001` through `B2-MAN-010`
- `B2-MAN-013`

`B2-BLK-001` is retained only as:

`RETAINED_AS_SUPPORTING_TRACEABILITY_RECORD_NOT_AS_EXECUTABLE_MANIFEST_ROW`

`B2-BLK-001` is explicitly **not** a command, **not** an interaction, and does **not** increase either the executable-command count or the documentary-interaction count. It records the previously approved Windows Git executable-identity input supporting `B2-MAN-013` only.

## 6. Retained Interaction Allowlist

Model A retains only the following five documentary interaction records:

- `B2-INT-001`
- `B2-INT-002`
- `B2-INT-003`
- `B2-INT-004`, narrowed strictly to `B2-MAN-010`
- `B2-INT-006`

The retained boundary for `B2-INT-004`:

- includes only the Docker client-version planning interaction associated with `B2-MAN-010`;
- excludes `B2-MAN-011`;
- excludes Docker context equality handling;
- excludes context-name retention;
- excludes context inspection;
- excludes Docker Engine contact;
- grants no interaction or execution authority.

The retained interaction count is exactly five documentary interaction records. `B2-BLK-001` is a supporting traceability record only and is not classified or counted as an interaction.

## 7. Excluded Initial-Scope Records

The following are excluded from the selected initial documentary scope:

- `B2-MAN-011`
- `B2-MAN-012`
- `B2-BLK-002`
- `B2-BLK-003`
- `B2-BLK-004`
- `B2-BLK-005`
- `B2-BLK-006`
- `B2-INT-005`
- `B2-INT-007`
- `B2-INT-008`
- `B2-INT-009`
- `B2-INT-010`
- `B2-INT-011`

`B2-INT-004` is retained **only** after documentary narrowing to `B2-MAN-010`. As narrowed, it includes only the Docker client-version planning interaction associated with `B2-MAN-010` and explicitly does **not** include `B2-MAN-011`, Docker context equality handling, context-name retention, context inspection, Docker Engine contact, or any interaction or execution authority.

## 8. Exclusion Semantics (Mandatory)

Every excluded item above is classified only as:

`NOT_INCLUDED_IN_SELECTED_INITIAL_ASSESSMENT_SCOPE`

Exclusion under this classification does **not**:

- delete historical planning evidence recorded in the Batch 8 package or the main Annex;
- prove that a target, service, or command does not exist;
- prove that a target or command is unsafe;
- permanently reject a target;
- authorize a substitute command;
- authorize any later interaction;
- automatically approve any future extension.

## 9. Mandatory Separate-Extension Rule

Docker Engine, Ollama, Hermes, OpenWebUI, and LM Studio may return to assessment scope **only** through a separately proposed and separately Project Owner-authorized Annex extension.

Any such future extension would need to independently define, review, and receive separate approval for, at minimum:

- exact targets;
- exact commands and arguments;
- exact executables or process identities;
- exact working directories;
- exact endpoints, addresses, and ports where applicable;
- service-contact and network boundaries;
- output-field restrictions;
- mutation-risk determinations;
- evidence classifications;
- Field 8 and Field 9 controls;
- reproduction procedures;
- criteria-to-evidence mappings;
- stop conditions;
- review authority;
- synchronization authority.

No excluded target, interaction, command, endpoint, or port is treated as implicitly reserved, pre-approved, or fast-tracked by this decision.

## 10. Limited Readiness-Claim Boundary

Any future readiness conclusion derived only from the selected Model A scope must be described as:

`INITIAL_MINIMAL_CORE_SCOPE_READINESS`

It must **not** be represented, described, or implied as:

- complete EAIRA local-AI-platform readiness;
- Docker Engine readiness;
- Ollama readiness;
- Hermes readiness;
- OpenWebUI readiness;
- LM Studio readiness;
- complete runtime readiness;
- implementation readiness;
- milestone readiness;
- Platform Foundation readiness.

## 11. Fields 1–4 Effect

Excluded Model B and Model C rows are excluded from the Fields 1–4 **initial-scope readiness evaluation only** for the selected Model A initial assessment.

This does **not** delete or resolve those same rows as historical blockers for any future Annex extension covering Model B, Model C, or an equivalent expanded scope.

The retained Model A target set, retained command-manifest rows, `B2-BLK-001` supporting traceability record, and retained interaction allowlist are determined to constitute the complete closed documentary inventory for the initial Model A assessment scope.

That complete closed documentary inventory includes:

1. the selected targets in Section 4;
2. the retained command-manifest rows in Section 5;
3. `B2-BLK-001` as supporting traceability only in Section 5;
4. the five retained documentary interaction records in Section 6;
5. the excluded and deferred records and their dispositions in Sections 3 and 7–9;
6. the execution and evidence-collection boundaries in Section 14.

This determination is classified only as:

`DOCUMENTARY_INITIAL_SCOPE_COMPLETENESS_DETERMINATION_ONLY`

It does **not** establish:

- executable or command existence;
- executable availability;
- independently verified command semantics;
- operational evidence controls;
- target-environment readiness;
- criterion satisfaction;
- Field 1–4 resolution;
- gate satisfaction;
- execution authority;
- evidence-collection authority.

Exact Annex synchronization and direct review remain required before any Field-state modification. That later review must verify faithful synchronization and satisfaction of retained requirements. It must not leave the selected initial documentary scope itself unclosed or unselected.

## 12. Field-State Boundary

This decision supports a **future** documentary revision of Fields 1–4. It does **not**, by itself, automatically modify any current Annex Field state.

Any later Field-state revision would require, in order:

1. exact Annex synchronization faithfully reflecting the adopted complete closed documentary inventory;
2. direct review of the synchronized Annex content;
3. objective verification that every retained Model A requirement is addressed and satisfied;
4. separate Project Owner approval of the resulting Field classifications.

That later review would verify faithful synchronization and satisfaction of retained requirements; it would not reopen or leave unclosed or unselected the initial documentary scope determined in Section 11.

Until that sequence is separately completed, the following states remain controlling and unchanged by this decision:

| Field | Current state (unchanged) |
| --- | --- |
| Field 1 | `PARTIALLY_RESOLVED_WITH_COMMAND_LEVEL_CONTROLS_PENDING` |
| Field 2 | `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS` |
| Field 3 | `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS` |
| Field 4 | `PARTIALLY_RESOLVED_WITH_BLOCKERS` |
| Field 8 | `PARTIALLY_RESOLVED_WITH_REQUIRED_IMPLEMENTATION_DETAILS` |
| Field 9 | `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS` |
| Field 10 | `APPROVED_AS_PLANNING_CONTROL_WITH_FIELD_8_AND_9_DEPENDENCIES` |
| Field 11 | `APPROVED_AS_PLANNING_CONTROL_WITH_EVIDENCE_DEPENDENCIES` |
| All-fields-resolved gate | `BLOCKED` |

This decision does not claim Fields 1–4 are resolved and does not claim the gate is satisfied.

## 13. Synchronization Boundary

The separate Project Owner execution authorization for this task authorizes only creation of this decision record in the current local working tree. This bounded documentary decision does **not** authorize:

- modification of the Batch 8 planning package;
- modification of the main Annex;
- modification of `ACTIVE_TASK.yaml`;
- modification of `CURRENT_STATUS.md`;
- modification of `TODAY_OBJECTIVE.md`;
- modification of `CURRENT_CONTEXT.md`;
- modification of `AGENT_CONTEXT_VERSION.yaml`;
- staging;
- commit;
- push;
- synchronization.

Every further repository mutation requires **separate, explicit** Project Owner authorization identifying the exact path and the exact permitted change.

## 14. Execution Boundary

This decision grants **no** authority for:

- Local Readiness Assessment execution;
- command execution;
- target-environment inspection;
- service or endpoint interaction;
- connectivity testing;
- port probing;
- evidence collection;
- evidence-file or evidence-directory creation;
- identity, group, ACL, or access configuration;
- encryption configuration;
- hashing;
- redaction;
- quarantine;
- incident notification;
- retention;
- disposal;
- implementation;
- remediation;
- runtime activity;
- deployment;
- database mutation;
- production mutation;
- governance modification;
- milestone establishment;
- M4;
- Platform Foundation;
- a formal EAIRA Execution Layer;
- a successor task.

The following remain controlling:

- Assessment execution: `UNAUTHORIZED`
- Assessment-evidence collection: `UNAUTHORIZED`

## 15. Evidence Classification Summary

| Item | Classification |
| --- | --- |
| Batch 8 package content, field states, model definitions cited above | `VERIFIED_REPOSITORY_FACT` (read directly from commit `fec0436`) |
| Non-synchronization of Batch 8 into Annex/status/context/task artifacts | `VERIFIED_REPOSITORY_FACT` |
| Model A selection, target/row/interaction dispositions, documentary initial-scope completeness determination, extension rule, readiness-claim boundary in Sections 3–14 above | `PROJECT_OWNER_DECISION — APPROVED_AS_PLANNING_EVIDENCE; NO_EXECUTION_AUTHORITY` |
| Prior conversational summaries describing Claude/Copilot/ChatGPT review outcomes | Non-authoritative review inputs; not repository facts; not relied upon for any disposition in this record |
| Batch 1–7 decisions cited for traceability | `VERIFIED_REPOSITORY_FACT`, referenced not reproduced |

## 16. Traceability References (Existing, Unmodified)

- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE_DECISION.md` — `DEFER_PENDING_ADDITIONAL_PLANNING_EVIDENCE`
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_4_REVIEW_DECISION.md`
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_5_REVIEW_DECISION.md`
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_6_REVIEW_DECISION.md`
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_7_REVIEW_DECISION.md`
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX.md` (Version `0.13.0`, does not yet contain Batch 8)
- `docs/project/status/CURRENT_STATUS.md` (Version `0.10.0`, does not yet reflect Batch 8)
- `docs/project/status/TODAY_OBJECTIVE.md` (Version `0.9.0`, does not yet reflect Batch 8)
- `docs/project/status/ACTIVE_TASK.yaml` (dependencies list does not yet include Batch 8)

## 17. Decision Boundary Statement

This record documents only the adopted bounded documentary decision: (a) acceptance of the Batch 8 package as bounded planning evidence; (b) selection of Model A as the initial documentary scope model; and (c) the complete closed documentary inventory comprising the selected targets, retained command-manifest rows, `B2-BLK-001` as supporting traceability only, five retained documentary interaction records, excluded and deferred records, and execution and evidence-collection boundaries, subject to the mandatory extension rule and readiness-claim boundary above. It does not authorize execution, evidence collection, milestone establishment, M4, Platform Foundation, a formal Execution Layer, implementation, runtime work, deployment, automation, database mutation, governance modification, production change, or a successor task. Authority beyond documentary scope selection requires a future, separate, explicit Project Owner decision.

---

## Next-Step Sequence

1. Review the direct read-back, exact changed-file list, and path-scoped diff for this working-tree file.
2. Separately authorize staging and commit.
3. Separately authorize push.
4. Perform a read-only Annex synchronization impact review.
5. Separately authorize exact Annex synchronization faithfully reflecting the complete closed documentary inventory.
6. Only after Annex synchronization review, evaluate status, objective, context, task, and context-version synchronization.

No later step in this sequence is authorized by this record or by the working-tree creation authorization.

---

# 驗證報告

- **完整 adopted source 是否已提供並使用**：是。完整 adopted Batch 8 Project Owner decision-record source 已由 Project Owner 提供，並作為本次 working-tree file creation 的唯一 decision-content source。
- **是否只套用 authorized lifecycle conversion**：是。僅移除 response-only wrapper material、轉換 title、path line、Decision Identification metadata、adoption-dependent wording、Evidence Classification Summary、Decision Boundary Statement、Next-Step Sequence 與 lifecycle-dependent validation statements；未改變 substantive scope。
- **是否保留獨立的 `Retained Interaction Allowlist` 章節**：是。
- **保留的 documentary interaction records 是否恰為五項**：是。僅保留 `B2-INT-001`、`B2-INT-002`、`B2-INT-003`、經嚴格限縮的 `B2-INT-004`，以及 `B2-INT-006`。
- **`B2-INT-004` 是否嚴格限縮至與 `B2-MAN-010` 關聯的 Docker client-version planning interaction**：是。
- **限縮後的 `B2-INT-004` 是否排除指定邊界**：是。其明確排除 `B2-MAN-011`、Docker context equality handling、context-name retention、context inspection 與 Docker Engine contact，且不授予 interaction 或 execution authority。
- **`B2-BLK-001` 是否僅作為 supporting traceability record**：是。它未被分類或計入 interaction，也不增加 executable-command count 或 documentary-interaction count。
- **documentary initial-scope completeness determination 是否已明確記錄**：是。Retained Model A target set、retained command-manifest rows、`B2-BLK-001` supporting traceability record 與 retained interaction allowlist 構成 initial Model A assessment scope 的 complete closed documentary inventory。
- **該 determination 是否標記為 `DOCUMENTARY_INITIAL_SCOPE_COMPLETENESS_DETERMINATION_ONLY`**：是。
- **complete closed documentary inventory 是否包含所有指定類別**：是。其包括 selected targets、retained command-manifest rows、僅作 supporting traceability 的 `B2-BLK-001`、五項 retained interaction records、excluded and deferred records，以及 execution and evidence-collection boundaries。
- **該 determination 是否避免建立超出 documentary scope 的結論**：是。它不建立 executable 或 command existence、executable availability、independently verified command semantics、operational evidence controls、target-environment readiness、criterion satisfaction、Field 1–4 resolution、gate satisfaction、execution authority 或 evidence-collection authority。
- **Field-state modification 前是否仍要求 exact Annex synchronization 與 direct review**：是。
- **later review 的邊界是否已明確限制**：是。Later review 僅驗證 faithful synchronization 與 retained requirements 的 satisfaction，不會使已選定的 initial documentary scope 處於 unclosed 或 unselected 狀態。
- **local-clone validation wording 是否避免錯誤宣稱未發生 filesystem write**：是。此記錄未宣稱執行 `git clone` 時沒有 filesystem write。
- **local repository clone 與 authoritative repository mutation 的關係是否準確記錄**：是。先前建立的 local repository clone 僅用於 read-only repository verification；該 clone operation 未修改 authoritative GitHub repository、repository history、remote branch、tracked authoritative source files、staging index 或 authoritative working tree。本次另行授權的 creation task 僅建立此一 untracked local working-tree file。
- **是否收集 Local Readiness Assessment evidence**：否。未收集任何 Local Readiness Assessment evidence。
- **repository documents 的使用是否準確分類**：是。Repository documents 僅被擷取及讀取，作為 documentary review 的 Project Layer source evidence。
- **是否執行 assessment 或環境／服務活動**：否。未執行 assessment command、target-environment inspection、Docker interaction、Ollama interaction、Hermes interaction、OpenWebUI interaction、LM Studio interaction、assessment-evidence file 或 directory creation、configuration、runtime、deployment、database、production 或 governance mutation。
- **本次 working-tree creation task 是否變更 repository file**：是，但僅建立一個 authorized untracked file：`docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_8_REVIEW_DECISION.md`。未修改任何其他 repository file；該 working-tree creation task 未執行 stage、commit、push 或 synchronize，且在該 task 完成時 repository history 尚未包含此記錄。後續 repository lifecycle 狀態須由各自的 separate authorization 與 direct evidence 判定。
- **Model A 是否僅被表述為已選定的 initial documentary scope model**：是。Model A 僅以 `SELECTED_AS_INITIAL_DOCUMENTARY_SCOPE_MODEL` 被選定，不構成 executable、operational、runtime、environment-readiness、criterion-satisfaction、Field-resolution 或 gate-satisfaction decision。
- **Project Owner 決策是否僅被表述為已採用的 bounded documentary decision**：是。此記錄的 Decision Authority 為 `Project Owner`，Decision Date 為 `2026-07-16`，Classification 為 `PROJECT_OWNER_DECISION`，Status 為 `APPROVED_AS_PLANNING_EVIDENCE`；該採用不授予任何 operational authority。
- **Execution 與 assessment-evidence collection 是否維持未授權**：是。兩者均維持 `UNAUTHORIZED`。
