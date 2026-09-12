# EAIRA M5 Slice 1 Exact Implementation Design R3R1 — Bound Input Count Correction

## Control

- Design ID: `EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_V1R3R1`
- Date: `2026-09-12`
- State: `CORRECTION_READY_FOR_INDEPENDENT_REVIEW_WITH_R3`
- Corrects: R3 section 4 only
- Next Gate: `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R3R1_REVIEW`

R3 section 4 incorrectly stated count 25. Adding both the previously omitted V1 design and the new R3 design to R2's 24 inputs yields 26; adding this normative correction yields a final exact count of 27. This correction replaces R3 section 4 in full.

The exact ordered `localOperator.boundRepositoryInputs` is:

1. `docs/project/milestones/EAIRA_M5_INTEGRATED_LOCAL_RUNTIME_AND_OPERATOR_WORKFLOW_PROJECT_CHARTER.md`
2. `docs/project/planning/EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE.md`
3. `docs/project/planning/EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE_R1.md`
4. `docs/project/planning/EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE_R2.md`
5. `docs/project/planning/EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE_R3.md`
6. `docs/project/strategy/EAIRA_M5_SLICE1_SCOPE_DECISION.md`
7. `docs/project/planning/EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN.md`
8. `docs/project/planning/EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R2.md`
9. `docs/project/planning/EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R3.md`
10. `docs/project/planning/EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R3R1.md`
11. `apps/agent-services/README.md`
12. `apps/agent-services/contracts/EAIRA_LOCAL_OPERATOR_V1.md`
13. `apps/agent-services/src/ContractCodec.cs`
14. `apps/agent-services/src/AgentCore.cs`
15. `apps/agent-services/src/ModelProviders.cs`
16. `apps/agent-services/src/LocalTaskIntake.cs`
17. `apps/agent-services/src/LocalModelProvider.cs`
18. `apps/agent-services/src/OllamaLoopbackTransport.cs`
19. `apps/agent-services/src/ProjectReadOnlyPlatform.cs`
20. `apps/agent-services/src/ProjectContext.cs`
21. `apps/agent-services/src/ProjectKnowledge.cs`
22. `apps/agent-services/src/ProjectQa.cs`
23. `apps/agent-services/src/ProjectQaHost.cs`
24. `apps/agent-services/src/LocalOperator.cs`
25. `apps/agent-services/src/LocalOperatorHost.cs`
26. `apps/agent-services/tests/LocalOperatorHarness.cs`
27. `apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1`

Discovery requires exact count/order 27 and may bypass only hashes. Final mode requires all 27 hashes. The profile remains excluded from its own list and is bound before parsing by `ExpectedReleaseProfileSha256`.

No other R3 requirement changes. This correction grants no implementation, staging, commit or push authority.
