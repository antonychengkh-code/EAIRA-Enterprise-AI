using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;

namespace EAIRA.AgentServices.Functional
{
    internal sealed class LocalOperatorException : Exception { internal LocalOperatorException() : base(String.Empty) { } }
    internal enum LocalOperatorCapability { Task = 1, Knowledge = 2, ProjectQa = 3, Health = 4, Preflight = 5 }

    internal sealed class LocalOperatorRequest
    {
        internal LocalOperatorCapability Capability { get; private set; }
        internal string TraceId { get; private set; }
        internal string Provider { get; private set; }
        internal string Model { get; private set; }
        internal string Root { get; private set; }
        internal string InputKind { get; private set; }
        internal string Input { get; private set; }
        internal string RootDigest { get; private set; }
        internal string InputDigest { get; private set; }
        internal string RequestDigest { get; private set; }
        internal TaskEnvelope Task { get; private set; }

        private LocalOperatorRequest(LocalOperatorCapability capability, string trace, string provider, string model, string root, string kind, string input)
        {
            Capability = capability; TraceId = trace; Provider = provider; Model = model; Root = root; InputKind = kind; Input = input;
            if (root != null) { ProjectQaRequest.ValidateLexicalRoot(root); }
            if (kind == "QUERY" || kind == "QUESTION") { Input = ProjectKnowledgeQuery.NormalizeQueryOrThrowRequest(input); }
            Task = TaskEnvelope.Create(TaskEnvelope.CurrentSchemaVersion, trace, capability == LocalOperatorCapability.Preflight ? "EXPLAIN COMPILED ROUTE POLICY" : Input);
            RootDigest = root == null ? "NONE" : DomainDigest("EAIRA_M5_SLICE1_ROOT_V1", root);
            InputDigest = DomainDigest("EAIRA_M5_SLICE1_" + kind + "_V1", Input);
            RequestDigest = ContractCodec.Sha256Hex("EAIRA_M5_SLICE1_REQUEST_V1\0" +
                ContractCodec.Field(CapabilityName) + ContractCodec.Field(TraceId) + ContractCodec.Field(Provider) + ContractCodec.Field(Model) +
                ContractCodec.Field(root == null ? "FALSE" : "TRUE") + ContractCodec.Field(RootDigest) +
                ContractCodec.Field(InputKind) + ContractCodec.Field(InputDigest));
        }

        internal string CapabilityName { get { return Capability == LocalOperatorCapability.Task ? "TASK" : Capability == LocalOperatorCapability.Knowledge ? "KNOWLEDGE" : Capability == LocalOperatorCapability.ProjectQa ? "PROJECT_QA" : Capability == LocalOperatorCapability.Health ? "HEALTH" : "PREFLIGHT"; } }
        private static string DomainDigest(string domain, string value) { return ContractCodec.Sha256Hex(domain + "\0" + ContractCodec.Field(value)); }

        internal static LocalOperatorRequest Parse(string[] args)
        {
            try
            {
                if (args == null || args.Length < 1) { throw new LocalOperatorException(); }
                if (args[0] == "task")
                {
                    if (args.Length == 7 && args[1] == "--provider" && args[2] == "mock" && args[3] == "--trace" && args[5] == "--goal")
                        return new LocalOperatorRequest(LocalOperatorCapability.Task, args[4], "MOCK", "NONE", null, "GOAL", args[6]);
                    if (args.Length == 9 && args[1] == "--provider" && args[2] == "mock" && args[3] == "--trace" && args[5] == "--goal" && args[7] == "--context-root")
                        return new LocalOperatorRequest(LocalOperatorCapability.Task, args[4], "MOCK", "NONE", args[8], "GOAL", args[6]);
                    if (args.Length == 9 && args[1] == "--provider" && args[2] == "ollama-local" && args[3] == "--model" && args[4] == "qwen3:4b" && args[5] == "--trace" && args[7] == "--goal")
                        return new LocalOperatorRequest(LocalOperatorCapability.Task, args[6], "OLLAMA_LOOPBACK_V1", "qwen3:4b", null, "GOAL", args[8]);
                    if (args.Length == 11 && args[1] == "--provider" && args[2] == "ollama-local" && args[3] == "--model" && args[4] == "qwen3:4b" && args[5] == "--trace" && args[7] == "--goal" && args[9] == "--context-root")
                        return new LocalOperatorRequest(LocalOperatorCapability.Task, args[6], "OLLAMA_LOOPBACK_V1", "qwen3:4b", args[10], "GOAL", args[8]);
                    throw new LocalOperatorException();
                }
                if (args[0] == "knowledge" && args.Length == 7 && args[1] == "--root" && args[3] == "--trace" && args[5] == "--query")
                    return new LocalOperatorRequest(LocalOperatorCapability.Knowledge, args[4], "NONE", "NONE", args[2], "QUERY", args[6]);
                if (args[0] == "project-qa" && args.Length == 11 && args[1] == "--root" && args[3] == "--trace" && args[5] == "--question" && args[7] == "--provider" && args[8] == "ollama-local" && args[9] == "--model" && args[10] == "qwen3:4b")
                    return new LocalOperatorRequest(LocalOperatorCapability.ProjectQa, args[4], "OLLAMA_LOOPBACK_V1", "qwen3:4b", args[2], "QUESTION", args[6]);
                if (args[0] == "health" && args.Length == 3 && args[1] == "--trace")
                    return new LocalOperatorRequest(LocalOperatorCapability.Health, args[2], "NONE", "NONE", null, "HEALTH", "COMPILED CONTRACT STATUS");
                if (args[0] == "preflight" && args.Length == 5 && args[1] == "--trace" && args[3] == "--route" && LocalOperatorPreflight.IsKnownRouteId(args[4]))
                    return new LocalOperatorRequest(LocalOperatorCapability.Preflight, args[2], "NONE", "NONE", null, "PREFLIGHT_ROUTE", args[4]);
                throw new LocalOperatorException();
            }
            catch (LocalOperatorException) { throw; }
            catch (Exception) { throw new LocalOperatorException(); }
        }
    }

    internal sealed class LocalOperatorRoute
    {
        internal string Digest { get; private set; }
        internal string Capability { get; private set; }
        internal string Network { get; private set; }
        internal string Authority { get; private set; }
        internal string PayloadContract { get; private set; }
        internal string CallBudget { get; private set; }
        private LocalOperatorRoute(LocalOperatorRequest r, string context, string knowledge, string policy, string network, string authority, string contract, string budget)
        {
            Capability = r.CapabilityName; Network = network; Authority = authority; PayloadContract = contract; CallBudget = budget;
            const string allowed = "PLANNING_CANDIDATE>GUARD_ALLOW>OPERATIONS_COMPLETED>VERIFICATION_VERIFIED>AUDIT_RECORDED";
            const string denied = "PLANNING_CANDIDATE>GUARD_DENY>AUDIT_RECORDED";
            Digest = ContractCodec.Sha256Hex("EAIRA_M5_SLICE1_ROUTE_V1\0" + ContractCodec.Field(r.RequestDigest) + ContractCodec.Field(Capability) +
                ContractCodec.Field(context) + ContractCodec.Field(knowledge) + ContractCodec.Field(policy) + ContractCodec.Field(network) + ContractCodec.Field("NONE") +
                ContractCodec.Field(contract) + ContractCodec.Field(allowed) + ContractCodec.Field(denied) + ContractCodec.Field(budget));
        }
        internal static LocalOperatorRoute Create(LocalOperatorRequest r)
        {
            if (r.Capability == LocalOperatorCapability.Preflight) return new LocalOperatorRoute(r, "NONE", "NONE", "EAIRA_STATIC_OPERATOR_PREFLIGHT_V1", "NONE", "EXPLANATORY_NOT_AUTHORITY", "EAIRA_OPERATOR_PREFLIGHT_V1", "MODEL_COMPLETE=0;READS=0;TAGS=0;CHAT=0;FACTORIES=0");
            if (r.Capability == LocalOperatorCapability.Health) return new LocalOperatorRoute(r, "NONE", "NONE", "EAIRA_STATIC_OPERATOR_HEALTH_V1", "NONE", "OBSERVATIONAL_NOT_AUTHORITY", "EAIRA_OPERATOR_HEALTH_V1", "MODEL_COMPLETE=0;READS=0;TAGS=0;CHAT=0;FACTORIES=0");
            if (r.Capability == LocalOperatorCapability.Knowledge) return new LocalOperatorRoute(r, "NONE", "EAIRA_M4_SLICE4_KNOWLEDGE_SEVEN_FILE_ALLOWLIST_V1", "NONE", "NONE", "NAVIGATIONAL_NOT_AUTHORITY", "EAIRA_PROJECT_KNOWLEDGE_QUERY_V1", "MODEL_COMPLETE=0;TAGS=0;CHAT=0");
            if (r.Capability == LocalOperatorCapability.ProjectQa) return new LocalOperatorRoute(r, "EAIRA_M4_SLICE3_CONTEXT_ALLOWLIST_V1", "EAIRA_M4_SLICE4_KNOWLEDGE_SEVEN_FILE_ALLOWLIST_V1", "EAIRA_BOUNDED_LOCAL_PROJECT_QA_V1", "LOOPBACK_ONLY", "ASSISTIVE_NOT_AUTHORITY", "EAIRA_PROJECT_QA_V1", "MODEL_COMPLETE=0;TAGS=2;CHAT=1");
            bool local = r.Provider == "OLLAMA_LOOPBACK_V1", context = r.Root != null;
            string budget = "COMPLETE_INVOCATIONS=" + (context ? "6" : "10") + ";UNIQUE_COMPLETIONS=2;TAGS=" + (local ? "2" : "0") + ";CHAT=" + (local ? "2" : "0");
            return new LocalOperatorRoute(r, context ? "EAIRA_M4_SLICE3_CONTEXT_ALLOWLIST_V1" : "NONE", "NONE", local ? "EAIRA_LOCAL_MODEL_PROVIDER_V1" : "EAIRA_DETERMINISTIC_MOCK_V1", local ? "LOOPBACK_ONLY" : "NONE", "BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY", "EAIRA_LOCAL_TASK_INTAKE_V1", budget);
        }
    }

    internal sealed class LocalOperatorAdapterResult
    {
        private readonly TaskIntakeResponse task;
        private readonly ProjectKnowledgeResult knowledge;
        private readonly ProjectQaRunResult qa;
        internal string Status { get; private set; }
        internal string Network { get; private set; }
        internal string Payload { get; private set; }
        internal int ExitCode { get; private set; }
        private LocalOperatorAdapterResult(string status, int exit, string network, string payload, TaskIntakeResponse taskValue, ProjectKnowledgeResult knowledgeValue, ProjectQaRunResult qaValue)
        { Status = status; ExitCode = exit; Network = network; Payload = payload; task = taskValue; knowledge = knowledgeValue; qa = qaValue; }
        internal static LocalOperatorAdapterResult Error(string status, int exit, string network)
        { return new LocalOperatorAdapterResult(status, exit, network, null, null, null, null); }
        internal static LocalOperatorAdapterResult FromTask(TaskIntakeResponse value)
        { if (value == null) { throw new LocalOperatorException(); } return new LocalOperatorAdapterResult(value.Status == "PASS" ? "PASS" : value.Status == "DENIED" ? "DENIED" : "PROVIDER_ERROR", value.ExitCode, value.Network, value.Status == "PASS" ? value.ToCanonicalJson() : null, value, null, null); }
        internal static LocalOperatorAdapterResult FromKnowledge(ProjectKnowledgeResult value)
        { if (value == null) { throw new LocalOperatorException(); } return new LocalOperatorAdapterResult("PASS", 0, "NONE", ProjectKnowledgeQuery.CanonicalJsonOrThrow(value), null, value, null); }
        internal static LocalOperatorAdapterResult FromProjectQa(ProjectQaRunResult value)
        {
            if (value == null) { throw new LocalOperatorException(); }
            string status = value.ExitCode == 0 ? "PASS" : value.ExitCode == 79 ? "PROVIDER_ERROR" : value.ExitCode == 80 ? "CONTEXT_ERROR" : value.ExitCode == 81 ? "KNOWLEDGE_ERROR" : value.ExitCode == 82 ? "QA_VALIDATION_ERROR" : value.ExitCode == 77 ? "DENIED" : "ORCHESTRATION_ERROR";
            return new LocalOperatorAdapterResult(status, value.ExitCode, value.Network, value.ExitCode == 0 ? value.CanonicalSuccessObject : null, null, null, value);
        }
#if EAIRA_LOCAL_OPERATOR_TEST_SEAM
        internal static LocalOperatorAdapterResult RawForTests(string status, int exit, string network, string payload)
        { return new LocalOperatorAdapterResult(status, exit, network, payload, null, null, null); }
#endif
        internal void ValidateEnvelope(LocalOperatorRoute route)
        {
            if (route == null || Status == null || Network == null) { throw new LocalOperatorException(); }
            if (Status == "PASS")
            {
                if (ExitCode != 0 || Network != route.Network || Payload == null) { throw new LocalOperatorException(); }
                return;
            }
            int expected = Status == "DENIED" ? 77 : Status == "PROVIDER_ERROR" ? 79 : Status == "CONTEXT_ERROR" ? 80 : Status == "KNOWLEDGE_ERROR" ? 81 : Status == "QA_VALIDATION_ERROR" ? 82 : -1;
            if (expected < 0 || ExitCode != expected || Payload != null) { throw new LocalOperatorException(); }
            if (Status == "PROVIDER_ERROR" && Network != route.Network) { throw new LocalOperatorException(); }
            if ((Status == "DENIED" || Status == "CONTEXT_ERROR" || Status == "KNOWLEDGE_ERROR") && Network != "NONE") { throw new LocalOperatorException(); }
            if (Status == "QA_VALIDATION_ERROR" && Network != "NONE" && Network != route.Network) { throw new LocalOperatorException(); }
        }
        internal void ValidateSuccessFor(LocalOperatorRequest request, LocalOperatorRoute route)
        {
            if (request == null || route == null || Status != "PASS" || ExitCode != 0 || Network != route.Network || Payload == null) { throw new LocalOperatorException(); }
            if (request.Capability == LocalOperatorCapability.Task)
            {
                if (task == null || knowledge != null || qa != null || task.Status != "PASS" || task.ExitCode != 0 || task.Network != route.Network || task.TraceId != request.TraceId || task.Outcome != "PASS" || task.Pipeline == null || task.Pipeline.TraceId != request.TraceId || task.Pipeline.Outcome != "PASS" || task.Pipeline.Results.Count != 5 || !String.Equals(Payload, task.ToCanonicalJson(), StringComparison.Ordinal)) { throw new LocalOperatorException(); }
                MinimumFunctionalPipeline.ValidatePrefix(request.Task, task.Pipeline.Results);
                string provider = request.Provider == "MOCK" ? "mock-v1" : "ollama-loopback-v1";
                if (task.ProviderId != provider || (request.Root == null) != (task.ContextMetadata == null)) { throw new LocalOperatorException(); }
                if (request.Provider == "MOCK") { if (task.TagsCalls.HasValue || task.ChatCalls.HasValue || task.PreflightDigestValidated.HasValue || task.PostflightDigestValidated.HasValue) { throw new LocalOperatorException(); } }
                else if (task.TagsCalls != 2 || task.ChatCalls != 2 || task.PreflightDigestValidated != true || task.PostflightDigestValidated != true) { throw new LocalOperatorException(); }
                return;
            }
            if (request.Capability == LocalOperatorCapability.Knowledge)
            {
                if (knowledge == null || task != null || qa != null || knowledge.Matches == null || knowledge.Matches.Count > 8 || !String.Equals(Payload, ProjectKnowledgeQuery.CanonicalJsonOrThrow(knowledge), StringComparison.Ordinal)) { throw new LocalOperatorException(); }
                byte[] queryBytes = ContractCodec.Utf8Strict("Knowledge query").GetBytes(request.Input);
                string queryDigest = ContractCodec.Sha256Hex(ContractCodec.Concat(Encoding.ASCII.GetBytes("EAIRA-KNOWLEDGE-QUERY-V1"), new byte[] { 0 }, LocalOperatorU32((uint)queryBytes.Length), queryBytes));
                if (!String.Equals(knowledge.QuerySha256, queryDigest, StringComparison.Ordinal) || !String.Equals(knowledge.ResultSetSha256, KnowledgeResultDigest(knowledge), StringComparison.Ordinal)) { throw new LocalOperatorException(); }
                return;
            }
            if (qa == null || task != null || knowledge != null || qa.ExitCode != 0 || qa.Status != "PROJECT_QA_OK" || qa.Network != "LOOPBACK_ONLY" || qa.LastStage != ProjectQaExecutionStage.OutputReady ||
                qa.SnapshotFactoryCalls != 1 || qa.SnapshotReadCalls != 1 || qa.ProviderFactoryCalls != 1 || qa.TagsCalls != 2 || qa.ChatCalls != 1 || !qa.PreflightDigestValidated || !qa.PostflightDigestValidated || qa.CitationCount < 0 || qa.CitationCount > 8 ||
                !String.Equals(Payload, qa.CanonicalSuccessObject, StringComparison.Ordinal) || Payload.IndexOf("\"traceId\":" + ContractCodec.Json(request.TraceId), StringComparison.Ordinal) < 0) { throw new LocalOperatorException(); }
            ContractCodec.RequireHash(qa.ContextAggregateSha256, "QA context aggregate"); ContractCodec.RequireHash(qa.ContextProjectionSha256, "QA context projection"); ContractCodec.RequireHash(qa.KnowledgeResultSetSha256, "QA knowledge result set"); ContractCodec.RequireHash(qa.PromptSha256, "QA prompt"); ContractCodec.RequireHash(qa.AnswerSha256, "QA answer");
        }
        private static byte[] LocalOperatorU32(uint value)
        { unchecked { return new byte[] { (byte)(value >> 24), (byte)(value >> 16), (byte)(value >> 8), (byte)value }; } }
        private static string KnowledgeResultDigest(ProjectKnowledgeResult value)
        {
            List<byte[]> frames = new List<byte[]>(); frames.Add(Encoding.ASCII.GetBytes("EAIRA-KNOWLEDGE-RESULTSET-V1")); frames.Add(new byte[] { 0 }); frames.Add(LocalOperatorU32((uint)value.Matches.Count)); frames.Add(new byte[] { value.Truncated ? (byte)1 : (byte)0 });
            for (int i = 0; i < value.Matches.Count; i++) { ProjectKnowledgeMatch m = value.Matches[i]; AddFrame(frames, m.Path); frames.Add(LocalOperatorU32((uint)m.Line)); AddFrame(frames, m.Heading); AddFrame(frames, m.Excerpt); AddFrame(frames, "NAVIGATIONAL_NOT_AUTHORITY"); }
            return ContractCodec.Sha256Hex(ContractCodec.Concat(frames.ToArray()));
        }
        private static void AddFrame(List<byte[]> frames, string value) { byte[] bytes = ContractCodec.Utf8Strict("Knowledge result").GetBytes(value); frames.Add(LocalOperatorU32((uint)bytes.Length)); frames.Add(bytes); }
    }
    internal interface ILocalOperatorAdapter { LocalOperatorAdapterResult Execute(LocalOperatorRequest request); }
    internal interface ILocalOperatorAdapterFactory
    {
        ILocalOperatorAdapter CreateTask(); ILocalOperatorAdapter CreateKnowledge(); ILocalOperatorAdapter CreateProjectQa();
    }

    internal sealed class LocalOperatorExecutionResult
    {
        internal int ExitCode { get; private set; } internal byte[] Bytes { get; private set; }
        internal LocalOperatorExecutionResult(int exit, byte[] bytes) { ExitCode = exit; Bytes = (byte[])bytes.Clone(); }
    }

    internal static class LocalOperatorConnectAttemptMonitor
    {
        private static int count;
        internal static void Record(string channel) { if (channel != "TAGS" && channel != "CHAT") throw new LocalOperatorException(); System.Threading.Interlocked.Increment(ref count); }
        internal static int Snapshot() { return System.Threading.Interlocked.CompareExchange(ref count, 0, 0); }
#if EAIRA_LOCAL_OPERATOR_TEST_SEAM
        internal static void ResetForTests() { System.Threading.Interlocked.Exchange(ref count, 0); }
        internal static void RecordForTests(string channel) { Record(channel); }
#endif
    }

    internal static class LocalOperatorHealth
    {
        internal const string CanonicalPayload = "{\"schema\":\"EAIRA_OPERATOR_HEALTH_V1\",\"status\":\"POLICY_READY\",\"observationScope\":\"COMPILED_CONTRACT_ONLY\",\"operatorSchema\":\"EAIRA_LOCAL_OPERATOR_V1\",\"capabilities\":[\"TASK\",\"KNOWLEDGE\",\"PROJECT_QA\",\"HEALTH\"],\"guardPosture\":\"REQUIRED_BEFORE_EFFECT\",\"network\":\"NONE\",\"reads\":\"NONE\",\"writes\":\"NONE\",\"providerConstruction\":\"NONE\",\"authority\":\"OBSERVATIONAL_NOT_AUTHORITY\"}";
        internal static void Validate(LocalOperatorRequest request, LocalOperatorRoute route, string payload, string digest)
        {
            if (request == null || route == null || request.Capability != LocalOperatorCapability.Health || request.Provider != "NONE" || request.Model != "NONE" || request.Root != null || request.InputKind != "HEALTH" || request.Input != "COMPILED CONTRACT STATUS") throw new LocalOperatorException();
            if (route.Capability != "HEALTH" || route.Network != "NONE" || route.Authority != "OBSERVATIONAL_NOT_AUTHORITY" || route.PayloadContract != "EAIRA_OPERATOR_HEALTH_V1" || route.CallBudget != "MODEL_COMPLETE=0;READS=0;TAGS=0;CHAT=0;FACTORIES=0") throw new LocalOperatorException();
            if (!String.Equals(payload, CanonicalPayload, StringComparison.Ordinal) || Encoding.UTF8.GetByteCount(payload) != 366 || digest != "9E3EFCDB24B49E2C27254772DFF72DEF88968ECF0A76C60D4E6724AE90E2E181") throw new LocalOperatorException();
        }
    }

    internal sealed class LocalOperatorPreflightPolicy
    {
        internal string RouteId { get; private set; }
        internal string Capability { get; private set; }
        internal string SourceClass { get; private set; }
        internal string ProviderPolicy { get; private set; }
        internal string RouteNetwork { get; private set; }
        internal string RouteAuthority { get; private set; }
        internal LocalOperatorPreflightPolicy(string routeId, string capability, string sourceClass, string providerPolicy, string routeNetwork, string routeAuthority)
        { RouteId = routeId; Capability = capability; SourceClass = sourceClass; ProviderPolicy = providerPolicy; RouteNetwork = routeNetwork; RouteAuthority = routeAuthority; }
    }

    internal static class LocalOperatorPreflight
    {
#if EAIRA_LOCAL_OPERATOR_TEST_SEAM
        private static int lookupCount, payloadCount;
        internal static void ResetCountersForTests() { lookupCount = 0; payloadCount = 0; }
        internal static int LookupCountForTests() { return lookupCount; }
        internal static int PayloadCountForTests() { return payloadCount; }
#endif
        internal static bool IsKnownRouteId(string value)
        {
            return value == "TASK_MOCK" || value == "TASK_MOCK_CONTEXT" || value == "TASK_OLLAMA_LOCAL" || value == "TASK_OLLAMA_LOCAL_CONTEXT" || value == "KNOWLEDGE" || value == "PROJECT_QA_OLLAMA_LOCAL" || value == "HEALTH";
        }
        private static LocalOperatorPreflightPolicy CreatePolicy(string value)
        {
            if (value == "TASK_MOCK") return new LocalOperatorPreflightPolicy(value, "TASK", "USER_ARGUMENTS_ONLY", "MOCK", "NONE", "BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY");
            if (value == "TASK_MOCK_CONTEXT") return new LocalOperatorPreflightPolicy(value, "TASK", "CONTROLLED_PROJECT_CONTEXT", "MOCK", "NONE", "BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY");
            if (value == "TASK_OLLAMA_LOCAL") return new LocalOperatorPreflightPolicy(value, "TASK", "USER_ARGUMENTS_ONLY", "OLLAMA_LOCAL_QWEN3_4B", "LOOPBACK_ONLY", "BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY");
            if (value == "TASK_OLLAMA_LOCAL_CONTEXT") return new LocalOperatorPreflightPolicy(value, "TASK", "CONTROLLED_PROJECT_CONTEXT", "OLLAMA_LOCAL_QWEN3_4B", "LOOPBACK_ONLY", "BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY");
            if (value == "KNOWLEDGE") return new LocalOperatorPreflightPolicy(value, "KNOWLEDGE", "CONTROLLED_PROJECT_MEMORY", "NONE", "NONE", "NAVIGATIONAL_NOT_AUTHORITY");
            if (value == "PROJECT_QA_OLLAMA_LOCAL") return new LocalOperatorPreflightPolicy(value, "PROJECT_QA", "CONTROLLED_CONTEXT_AND_PROJECT_MEMORY", "OLLAMA_LOCAL_QWEN3_4B", "LOOPBACK_ONLY", "ASSISTIVE_NOT_AUTHORITY");
            if (value == "HEALTH") return new LocalOperatorPreflightPolicy(value, "HEALTH", "COMPILED_CONTRACT_ONLY", "NONE", "NONE", "OBSERVATIONAL_NOT_AUTHORITY");
            throw new LocalOperatorException();
        }
        internal static LocalOperatorPreflightPolicy Lookup(string value)
        {
#if EAIRA_LOCAL_OPERATOR_TEST_SEAM
            lookupCount++;
#endif
            return CreatePolicy(value);
        }
        private static string CanonicalPayloadCore(LocalOperatorPreflightPolicy policy)
        {
            if (policy == null) throw new LocalOperatorException();
            return "{\"schema\":\"EAIRA_OPERATOR_PREFLIGHT_V1\",\"status\":\"POLICY_EXPLAINED\",\"observationScope\":\"COMPILED_CONTRACT_ONLY\",\"routeId\":" + ContractCodec.Json(policy.RouteId) +
                ",\"capability\":" + ContractCodec.Json(policy.Capability) + ",\"guardRequirement\":\"REQUIRED_BEFORE_EFFECT\",\"guardEvaluation\":\"ALLOW_PREFLIGHT_ONLY\",\"sourceClass\":" + ContractCodec.Json(policy.SourceClass) +
                ",\"providerPolicy\":" + ContractCodec.Json(policy.ProviderPolicy) + ",\"routeNetwork\":" + ContractCodec.Json(policy.RouteNetwork) + ",\"preflightNetwork\":\"NONE\",\"writes\":\"NONE\",\"routeAuthority\":" + ContractCodec.Json(policy.RouteAuthority)
                + ",\"authority\":\"EXPLANATORY_NOT_AUTHORITY\"}";
        }
        internal static string CanonicalPayload(LocalOperatorPreflightPolicy policy)
        {
#if EAIRA_LOCAL_OPERATOR_TEST_SEAM
            payloadCount++;
#endif
            return CanonicalPayloadCore(policy);
        }
        private static bool SamePolicy(LocalOperatorPreflightPolicy left, LocalOperatorPreflightPolicy right)
        {
            return left != null && right != null && left.RouteId == right.RouteId && left.Capability == right.Capability && left.SourceClass == right.SourceClass && left.ProviderPolicy == right.ProviderPolicy && left.RouteNetwork == right.RouteNetwork && left.RouteAuthority == right.RouteAuthority;
        }
        internal static void Validate(LocalOperatorRequest request, LocalOperatorRoute route, LocalOperatorPreflightPolicy policy, string payload, string digest)
        {
            if (request == null || route == null || policy == null || request.Capability != LocalOperatorCapability.Preflight || request.Provider != "NONE" || request.Model != "NONE" || request.Root != null || request.InputKind != "PREFLIGHT_ROUTE" || !IsKnownRouteId(request.Input) || request.Task == null || request.Task.Goal != "EXPLAIN COMPILED ROUTE POLICY") throw new LocalOperatorException();
            request.Task.ValidateIntegrity();
            if (route.Capability != "PREFLIGHT" || route.Network != "NONE" || route.Authority != "EXPLANATORY_NOT_AUTHORITY" || route.PayloadContract != "EAIRA_OPERATOR_PREFLIGHT_V1" || route.CallBudget != "MODEL_COMPLETE=0;READS=0;TAGS=0;CHAT=0;FACTORIES=0") throw new LocalOperatorException();
            LocalOperatorRoute expectedRoute = LocalOperatorRoute.Create(request);
            if (!String.Equals(route.Digest, expectedRoute.Digest, StringComparison.Ordinal)) throw new LocalOperatorException();
            LocalOperatorPreflightPolicy expected = CreatePolicy(request.Input);
            if (!SamePolicy(policy, expected) || !String.Equals(payload, CanonicalPayloadCore(expected), StringComparison.Ordinal) || !String.Equals(digest, LocalOperatorResponse.ComputePayloadDigest(Encoding.UTF8.GetBytes(payload)), StringComparison.Ordinal)) throw new LocalOperatorException();
        }
    }

    internal static class LocalOperatorResponse
    {
        internal const int MaximumPayloadBytes = 16383, MaximumWrapperBytes = 587, MaximumLineBytes = 16970;
        internal static LocalOperatorExecutionResult Invalid()
        {
            return Encode(64, "{\"schema\":\"EAIRA_LOCAL_OPERATOR_V1\",\"status\":\"INVALID_REQUEST\",\"traceId\":null,\"capability\":null,\"network\":\"NONE\",\"writes\":\"NONE\",\"authority\":\"NONE\",\"requestSha256\":null,\"routeSha256\":null,\"payloadSha256\":null,\"payload\":null,\"audit\":null}\n");
        }
        internal static LocalOperatorExecutionResult Build(LocalOperatorRequest r, LocalOperatorRoute route, string status, int exit, string network, string payload, string payloadDigest, OrchestrationChain chain)
        { return Build(r, route, status, exit, network, payload, payloadDigest, chain, payloadDigest); }
        internal static LocalOperatorExecutionResult Build(LocalOperatorRequest r, LocalOperatorRoute route, string status, int exit, string network, string payload, string payloadDigest, OrchestrationChain chain, string chainPayloadDigest)
        {
            bool pass = status == "PASS";
            if ((pass && (payload == null || payloadDigest == null)) || (!pass && (payload != null || payloadDigest != null)) || chain == null) throw new LocalOperatorException();
            if (exit != ExitFor(status) || (network != "NONE" && network != "LOOPBACK_ONLY") || (pass && network != route.Network)) throw new LocalOperatorException();
            if (pass)
            {
                if (route.PayloadContract == "EAIRA_OPERATOR_PREFLIGHT_V1") LocalOperatorPreflight.Validate(r, route, LocalOperatorPreflight.Lookup(r.Input), payload, payloadDigest);
                byte[] verifiedPayload = ContractCodec.Utf8Strict("Operator payload").GetBytes(payload);
                string verifiedDigest = ComputePayloadDigest(verifiedPayload);
                if (!String.Equals(payloadDigest, verifiedDigest, StringComparison.Ordinal) || !HasExpectedPayloadPrefix(route.PayloadContract, payload)) throw new LocalOperatorException();
            }
            chain.ValidateFor(r.RequestDigest, route.Digest, status, chainPayloadDigest);
            string json = "{\"schema\":\"EAIRA_LOCAL_OPERATOR_V1\",\"status\":" + ContractCodec.Json(status) + ",\"traceId\":" + ContractCodec.Json(r.TraceId) +
                ",\"capability\":" + ContractCodec.Json(r.CapabilityName) + ",\"network\":" + ContractCodec.Json(network) + ",\"writes\":\"NONE\",\"authority\":" + ContractCodec.Json(route.Authority) +
                ",\"requestSha256\":" + ContractCodec.Json(r.RequestDigest) + ",\"routeSha256\":" + ContractCodec.Json(route.Digest) + ",\"payloadSha256\":" + ContractCodec.Json(payloadDigest) +
                ",\"payload\":" + (payload ?? "null") + ",\"audit\":{\"outcome\":" + ContractCodec.Json(status) + ",\"chainSha256\":" + ContractCodec.Json(chain.ChainDigest) + "}}\n";
            byte[] bytes = ContractCodec.Utf8Strict("Operator output").GetBytes(json);
            int payloadBytes = payload == null ? 0 : ContractCodec.Utf8Strict("Operator payload").GetByteCount(payload);
            if (payloadBytes > MaximumPayloadBytes || bytes.Length > MaximumLineBytes || bytes.Length - payloadBytes > MaximumWrapperBytes) throw new LocalOperatorException();
            return new LocalOperatorExecutionResult(exit, bytes);
        }
        internal static string ComputePayloadDigest(byte[] payloadBytes)
        {
            if (payloadBytes == null) throw new LocalOperatorException();
            uint value = (uint)payloadBytes.Length; byte[] length;
            unchecked { length = new byte[] { (byte)(value >> 24), (byte)(value >> 16), (byte)(value >> 8), (byte)value }; }
            return ContractCodec.Sha256Hex(ContractCodec.Concat(Encoding.ASCII.GetBytes("EAIRA_M5_SLICE1_PAYLOAD_V1"), new byte[] { 0 }, length, payloadBytes));
        }
        private static int ExitFor(string status)
        {
            if (status == "PASS") return 0; if (status == "DENIED") return 77; if (status == "PROVIDER_ERROR") return 79;
            if (status == "CONTEXT_ERROR") return 80; if (status == "KNOWLEDGE_ERROR") return 81; if (status == "QA_VALIDATION_ERROR") return 82;
            if (status == "ORCHESTRATION_ERROR") return 83; if (status == "OUTPUT_ERROR") return 84; throw new LocalOperatorException();
        }
        private static bool HasExpectedPayloadPrefix(string contract, string payload)
        {
            if (contract == "EAIRA_LOCAL_TASK_INTAKE_V1") return payload.IndexOf("{\"schemaVersion\":1,\"status\":\"PASS\",", StringComparison.Ordinal) == 0;
            if (contract == "EAIRA_PROJECT_KNOWLEDGE_QUERY_V1") return payload.IndexOf("{\"schema\":\"EAIRA_PROJECT_KNOWLEDGE_QUERY_V1\",\"status\":\"KNOWLEDGE_QUERY_OK\",", StringComparison.Ordinal) == 0;
            if (contract == "EAIRA_PROJECT_QA_V1") return payload.IndexOf("{\"schema\":\"EAIRA_PROJECT_QA_V1\",\"status\":\"PROJECT_QA_OK\",", StringComparison.Ordinal) == 0;
            if (contract == "EAIRA_OPERATOR_HEALTH_V1") return String.Equals(payload, LocalOperatorHealth.CanonicalPayload, StringComparison.Ordinal);
            if (contract == "EAIRA_OPERATOR_PREFLIGHT_V1") return payload.IndexOf("{\"schema\":\"EAIRA_OPERATOR_PREFLIGHT_V1\",\"status\":\"POLICY_EXPLAINED\",", StringComparison.Ordinal) == 0;
            return false;
        }
        private static LocalOperatorExecutionResult Encode(int exit, string value) { return new LocalOperatorExecutionResult(exit, ContractCodec.Utf8Strict("Operator error").GetBytes(value)); }
    }

    internal sealed class LocalOperatorRunner
    {
        private readonly ILocalOperatorAdapterFactory factory;
#if EAIRA_LOCAL_OPERATOR_TEST_SEAM
        internal delegate AgentDecision LocalOperatorGuardEvaluator(TaskEnvelope task);
        private readonly LocalOperatorGuardEvaluator testGuard;
#endif
        internal LocalOperatorRunner(ILocalOperatorAdapterFactory value) { if (value == null) throw new LocalOperatorException(); factory = value;
#if EAIRA_LOCAL_OPERATOR_TEST_SEAM
            testGuard = null;
#endif
        }
#if EAIRA_LOCAL_OPERATOR_TEST_SEAM
        private LocalOperatorRunner(ILocalOperatorAdapterFactory value, LocalOperatorGuardEvaluator guard) { if (value == null || guard == null) throw new LocalOperatorException(); factory = value; testGuard = guard; }
        internal static LocalOperatorRunner CreateForTests(ILocalOperatorAdapterFactory value, LocalOperatorGuardEvaluator guard) { return new LocalOperatorRunner(value, guard); }
#endif
        internal LocalOperatorExecutionResult Execute(string[] args)
        {
            LocalOperatorRequest request;
            try { request = LocalOperatorRequest.Parse(args); } catch (Exception) { return LocalOperatorResponse.Invalid(); }
            int attemptsBefore = LocalOperatorConnectAttemptMonitor.Snapshot();
            LocalOperatorRoute route = LocalOperatorRoute.Create(request);
            AgentDecision decision = GuardAgent.ExpectedDecision(request.Task);
#if EAIRA_LOCAL_OPERATOR_TEST_SEAM
            if (testGuard != null) decision = testGuard(request.Task);
#endif
            if (decision != AgentDecision.Allow)
            {
                int attemptsAfter = LocalOperatorConnectAttemptMonitor.Snapshot();
                if (attemptsAfter < attemptsBefore || attemptsAfter - attemptsBefore != 0) return LocalOperatorResponse.Build(request, route, "ORCHESTRATION_ERROR", 83, "NONE", null, null, OrchestrationChain.Emergency(request.RequestDigest, route.Digest));
                return LocalOperatorResponse.Build(request, route, "DENIED", 77, "NONE", null, null, OrchestrationChain.Denied(request.RequestDigest, route.Digest));
            }
            if (request.Capability == LocalOperatorCapability.Preflight)
            {
                LocalOperatorExecutionResult preflight = ExecutePreflightAllowed(request, route);
                int attemptsAfter = LocalOperatorConnectAttemptMonitor.Snapshot();
                if (attemptsAfter < attemptsBefore || attemptsAfter - attemptsBefore != 0) return LocalOperatorResponse.Build(request, route, "OUTPUT_ERROR", 84, "NONE", null, null, OrchestrationChain.VerificationFailure(request.RequestDigest, route.Digest, "OUTPUT_ERROR", null));
                return preflight;
            }
            if (request.Capability == LocalOperatorCapability.Health)
            {
                LocalOperatorExecutionResult health = ExecuteHealthAllowed(request, route);
                int attemptsAfter = LocalOperatorConnectAttemptMonitor.Snapshot();
                if (attemptsAfter < attemptsBefore || attemptsAfter - attemptsBefore != 0) return LocalOperatorResponse.Build(request, route, "OUTPUT_ERROR", 84, "NONE", null, null, OrchestrationChain.VerificationFailure(request.RequestDigest, route.Digest, "OUTPUT_ERROR", null));
                return health;
            }
            return ExecuteLegacy(request, route);
        }
        private LocalOperatorExecutionResult ExecuteLegacy(LocalOperatorRequest request, LocalOperatorRoute route)
        {
            LocalOperatorAdapterResult result;
            try
            {
                ILocalOperatorAdapter adapter = request.Capability == LocalOperatorCapability.Task ? factory.CreateTask() : request.Capability == LocalOperatorCapability.Knowledge ? factory.CreateKnowledge() : factory.CreateProjectQa();
                if (adapter == null) throw new LocalOperatorException(); result = adapter.Execute(request); if (result == null) throw new LocalOperatorException();
                result.ValidateEnvelope(route);
            }
            catch (Exception) { return LocalOperatorResponse.Build(request, route, "ORCHESTRATION_ERROR", 83, "NONE", null, null, OrchestrationChain.Emergency(request.RequestDigest, route.Digest)); }
            if (result.Status != "PASS")
            {
                OrchestrationChain chain = OrchestrationChain.OperationFailure(request.RequestDigest, route.Digest, result.Status);
                return LocalOperatorResponse.Build(request, route, result.Status, result.ExitCode, result.Network, null, null, chain);
            }
            string digest = null;
            try { if (result.Payload != null) { digest = PayloadDigest(result.Payload); } result.ValidateSuccessFor(request, route); ValidatePayload(result.Payload); }
            catch (Exception) { return LocalOperatorResponse.Build(request, route, "OUTPUT_ERROR", 84, result.Network, null, null, OrchestrationChain.VerificationFailure(request.RequestDigest, route.Digest, "OUTPUT_ERROR", digest), digest); }
            try { return LocalOperatorResponse.Build(request, route, "PASS", 0, result.Network, result.Payload, digest, OrchestrationChain.Success(request.RequestDigest, route.Digest, digest)); }
            catch (Exception) { return LocalOperatorResponse.Build(request, route, "OUTPUT_ERROR", 84, result.Network, null, null, OrchestrationChain.VerificationFailure(request.RequestDigest, route.Digest, "OUTPUT_ERROR", digest), digest); }
        }
        private LocalOperatorExecutionResult ExecuteHealthAllowed(LocalOperatorRequest request, LocalOperatorRoute route)
        {
            string payload = LocalOperatorHealth.CanonicalPayload;
            string digest = PayloadDigest(payload);
            try
            {
                LocalOperatorHealth.Validate(request, route, payload, digest); ValidatePayload(payload);
                return LocalOperatorResponse.Build(request, route, "PASS", 0, "NONE", payload, digest, OrchestrationChain.Success(request.RequestDigest, route.Digest, digest));
            }
            catch (Exception) { return LocalOperatorResponse.Build(request, route, "OUTPUT_ERROR", 84, "NONE", null, null, OrchestrationChain.VerificationFailure(request.RequestDigest, route.Digest, "OUTPUT_ERROR", digest), digest); }
        }
        private LocalOperatorExecutionResult ExecutePreflightAllowed(LocalOperatorRequest request, LocalOperatorRoute route)
        {
            LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.Input);
            string payload = LocalOperatorPreflight.CanonicalPayload(policy);
            string digest = PayloadDigest(payload);
            try
            {
                LocalOperatorPreflight.Validate(request, route, policy, payload, digest); ValidatePayload(payload);
                return LocalOperatorResponse.Build(request, route, "PASS", 0, "NONE", payload, digest, OrchestrationChain.Success(request.RequestDigest, route.Digest, digest));
            }
            catch (Exception) { return LocalOperatorResponse.Build(request, route, "OUTPUT_ERROR", 84, "NONE", null, null, OrchestrationChain.VerificationFailure(request.RequestDigest, route.Digest, "OUTPUT_ERROR", digest), digest); }
        }
        private static void ValidatePayload(string value)
        {
            if (String.IsNullOrEmpty(value) || value[0] != '{' || value[value.Length - 1] != '}' || value.IndexOf('\r') >= 0 || value.IndexOf('\n') >= 0) throw new LocalOperatorException();
            byte[] b = ContractCodec.Utf8Strict("Operator payload").GetBytes(value); if (b.Length > LocalOperatorResponse.MaximumPayloadBytes) throw new LocalOperatorException();
        }
        private static string PayloadDigest(string value)
        {
            byte[] b = ContractCodec.Utf8Strict("Operator payload").GetBytes(value);
            return LocalOperatorResponse.ComputePayloadDigest(b);
        }
    }

    internal static class LocalOperatorOllamaResponseCompatibility
    {
        internal static byte[] Normalize(byte[] response)
        {
            StrictJsonNode root = StrictJsonParser.Parse(response);
            if (root.Kind != "object" || root.ObjectValue == null) { throw new LocalProviderException(); }
            StrictJsonNode telemetry;
            if (!root.ObjectValue.TryGetValue("prompt_eval_cached_count", out telemetry)) { return response; }
            if (telemetry == null || telemetry.Kind != "number") { throw new LocalProviderException(); }
            string json;
            try { json = new UTF8Encoding(false, true).GetString(response); }
            catch (Exception) { throw new LocalProviderException(); }
            const string marker = ",\"prompt_eval_cached_count\":";
            int start = json.IndexOf(marker, StringComparison.Ordinal);
            if (start < 0 || json.IndexOf(marker, start + marker.Length, StringComparison.Ordinal) >= 0) { throw new LocalProviderException(); }
            int valueStart = start + marker.Length;
            int end = valueStart;
            while (end < json.Length && "-+0123456789.eE".IndexOf(json[end]) >= 0) { end++; }
            if (end == valueStart || end >= json.Length || (json[end] != ',' && json[end] != '}')) { throw new LocalProviderException(); }
            return new UTF8Encoding(false, true).GetBytes(json.Remove(start, end - start));
        }
    }

#if EAIRA_LOCAL_OPERATOR_NATIVE
    internal sealed class LocalOperatorCompatibleLoopbackTransport : ILocalByteTransport
    {
        private readonly OllamaLoopbackTransport inner = new OllamaLoopbackTransport();
        public byte[] GetTags(System.Threading.CancellationToken token) { LocalOperatorConnectAttemptMonitor.Record("TAGS"); return inner.GetTags(token); }
        public byte[] SendChat(byte[] request, System.Threading.CancellationToken token) { LocalOperatorConnectAttemptMonitor.Record("CHAT"); return LocalOperatorOllamaResponseCompatibility.Normalize(inner.SendChat(request, token)); }
        public void Dispose() { inner.Dispose(); }
    }
    internal sealed class LocalOperatorLocalModelProviderFactory : ILocalModelProviderFactory
    {
        public IModelProvider Create(string model) { if (model != LocalModelProvider.ExactModelName) throw new ContractException("Invalid model."); return new LocalModelProvider(new LocalOperatorCompatibleLoopbackTransport(), LocalModelProvider.ExactModelName, LocalModelProvider.ExactModelDigest); }
    }
    internal sealed class LocalOperatorProjectQaProviderFactory : IProjectQaProviderFactory
    {
        public IProjectQaProvider Create() { return new ProjectQaLocalProvider(new LocalOperatorCompatibleLoopbackTransport()); }
    }
    internal sealed class LocalOperatorTaskAdapter : ILocalOperatorAdapter
    {
        public LocalOperatorAdapterResult Execute(LocalOperatorRequest r)
        {
            try
            {
                string[] a = r.Provider == "MOCK" ? (r.Root == null ? new string[] { "--provider", "mock", "--trace", r.TraceId, "--goal", r.Input } : new string[] { "--provider", "mock", "--trace", r.TraceId, "--goal", r.Input, "--context-root", r.Root }) : (r.Root == null ? new string[] { "--provider", "ollama-local", "--model", "qwen3:4b", "--trace", r.TraceId, "--goal", r.Input } : new string[] { "--provider", "ollama-local", "--model", "qwen3:4b", "--trace", r.TraceId, "--goal", r.Input, "--context-root", r.Root });
                TaskIntakeResponse x = LocalTaskIntake.CreateNative(new LocalOperatorLocalModelProviderFactory()).Execute(a);
                return LocalOperatorAdapterResult.FromTask(x);
            }
            catch (LocalProviderException) { return LocalOperatorAdapterResult.Error("PROVIDER_ERROR", 79, "LOOPBACK_ONLY"); }
            catch (ProjectContextException) { return LocalOperatorAdapterResult.Error("CONTEXT_ERROR", 80, "NONE"); }
            catch (Exception) { return LocalOperatorAdapterResult.Error("QA_VALIDATION_ERROR", 82, "NONE"); }
        }
    }
    internal sealed class LocalOperatorKnowledgeAdapter : ILocalOperatorAdapter
    {
        public LocalOperatorAdapterResult Execute(LocalOperatorRequest r)
        {
            try { return LocalOperatorAdapterResult.FromKnowledge(ProjectKnowledgeQuery.CreateNative().Execute(r.Root, r.Input)); }
            catch (Exception) { return LocalOperatorAdapterResult.Error("KNOWLEDGE_ERROR", 81, "NONE"); }
        }
    }
    internal sealed class LocalOperatorQaAdapter : ILocalOperatorAdapter
    {
        public LocalOperatorAdapterResult Execute(LocalOperatorRequest r)
        {
            string[] a = new string[] { "--root", r.Root, "--trace", r.TraceId, "--question", r.Input, "--provider", "ollama-local", "--model", "qwen3:4b" };
            ProjectQaExecutionObserver observer = new ProjectQaExecutionObserver();
            try { return LocalOperatorAdapterResult.FromProjectQa(ProjectQaRunner.ExecuteNative(a, new LocalOperatorProjectQaProviderFactory(), observer)); }
            catch (Exception)
            {
                if ((int)observer.LastStage >= (int)ProjectQaExecutionStage.ProviderFactoryCalled) { return LocalOperatorAdapterResult.Error("PROVIDER_ERROR", 79, "LOOPBACK_ONLY"); }
                return LocalOperatorAdapterResult.Error("ORCHESTRATION_ERROR", 83, "NONE");
            }
        }
    }
    internal sealed class LocalOperatorNativeAdapterFactory : ILocalOperatorAdapterFactory
    {
        public ILocalOperatorAdapter CreateTask() { return new LocalOperatorTaskAdapter(); }
        public ILocalOperatorAdapter CreateKnowledge() { return new LocalOperatorKnowledgeAdapter(); }
        public ILocalOperatorAdapter CreateProjectQa() { return new LocalOperatorQaAdapter(); }
    }
#endif
}
