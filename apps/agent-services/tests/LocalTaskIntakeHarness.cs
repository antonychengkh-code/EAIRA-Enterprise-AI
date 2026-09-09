using System;
using EAIRA.AgentServices.Functional;

namespace EAIRA.AgentServices.Tests
{
    internal static class LocalTaskIntakeHarness
    {
        private static int passed;
        private static FakeCoordinator contextCoordinator;
        private static FakeLocalFactory localFactory;

        private sealed class FakeCoordinator : IProjectContextRequestCoordinator
        {
            internal FakeCoordinator() { }

            internal int Calls { get; private set; }
            public ProjectContextPreparedRequest Prepare(string absoluteRoot, string exactGoal)
            {
                Calls++;
                if (!String.Equals(absoluteRoot, "C:\\EAIRA-CONTEXT-FIXTURE", StringComparison.Ordinal) || String.IsNullOrEmpty(exactGoal)) { throw new ProjectContextException(); }
                ProjectContextBundle bundle = new ProjectContextBundle(
                    "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                    8,
                    "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB",
                    "1:X1:Y\n");
                return new ProjectContextPreparedRequest(ProjectContextPrompt.Build(exactGoal, bundle), new ProjectContextResultMetadata(bundle));
            }
        }

        private sealed class FakeLocalFactory : ILocalModelProviderFactory
        {
            internal int Calls { get; private set; }
            internal FakeLocalProvider Last { get; private set; }
            public IModelProvider Create(string exactModelName)
            {
                Calls++;
                if (!String.Equals(exactModelName, "qwen3:4b", StringComparison.Ordinal)) { throw new ContractException("Unexpected model."); }
                Last = new FakeLocalProvider();
                return Last;
            }
        }

        private sealed class FakeLocalProvider : IModelProvider, IRequestLifecycleModelProvider, ILocalProviderObservations, IDisposable
        {
            internal int BeginCalls { get; private set; }
            internal int EndCalls { get; private set; }
            internal int DisposeCalls { get; private set; }
            internal int CompleteCalls { get; private set; }
            private string planningPrompt;
            private string planningResult;
            private string operationsPrompt;
            private string operationsResult;
            public string ProviderId { get { return "ollama-loopback-v1"; } }
            public bool IsExternal { get { return false; } }
            public bool IsExecutionEnabled { get { return true; } }
            public int TagsCalls { get { return 1; } }
            public int ChatCalls { get; private set; }
            public bool PreflightDigestValidated { get { return true; } }
            public bool PostflightDigestValidated { get { return true; } }
            public void BeginRequest() { BeginCalls++; }
            public void EndRequest() { EndCalls++; }
            public void Dispose() { DisposeCalls++; }
            public string Complete(AgentRole role, string prompt)
            {
                CompleteCalls++;
                if (role == AgentRole.Planning && String.Equals(prompt, planningPrompt, StringComparison.Ordinal)) { return planningResult; }
                if (role == AgentRole.Operations && String.Equals(prompt, operationsPrompt, StringComparison.Ordinal)) { return operationsResult; }
                ChatCalls++;
                if (role == AgentRole.Planning && prompt.IndexOf("RAW_CONTEXT_SENTINEL_DO_NOT_EMIT", StringComparison.Ordinal) >= 0)
                {
                    string echoed = "RAW_CONTEXT_SENTINEL_DO_NOT_EMIT";
                    planningPrompt = prompt; planningResult = echoed;
                    return echoed;
                }
                string digest = ContractCodec.Sha256Hex("EAIRA_FAKE_LOCAL_V1\0" + ContractCodec.Field(role.ToString()) + ContractCodec.Field(prompt));
                string result = "LOCAL_" + role.ToString().ToUpperInvariant() + "_" + digest.Substring(0, 24);
                if (role == AgentRole.Planning) { planningPrompt = prompt; planningResult = result; }
                else if (role == AgentRole.Operations) { operationsPrompt = prompt; operationsResult = result; }
                else { throw new ContractException("Unexpected role."); }
                return result;
            }
        }

        private static void Require(bool condition, string name)
        {
            if (!condition) { throw new ContractException("Task-intake test failed: " + name); }
            passed++;
        }

        private static void RequireContractFailure(Action action, string name)
        {
            bool failedClosed = false;
            try { action(); }
            catch (ContractException) { failedClosed = true; }
            Require(failedClosed, name);
        }

        private static string[] Request(string provider, string traceId, string goal)
        {
            return new string[] { "--provider", provider, "--trace", traceId, "--goal", goal };
        }

        private static string[] ContextRequest(string provider, string traceId, string goal)
        {
            return new string[] { "--provider", provider, "--trace", traceId, "--goal", goal, "--context-root", "C:\\EAIRA-CONTEXT-FIXTURE" };
        }

        private static string[] LocalContextRequest(string traceId, string goal)
        {
            return new string[] { "--provider", "ollama-local", "--model", "qwen3:4b", "--trace", traceId, "--goal", goal, "--context-root", "C:\\EAIRA-CONTEXT-FIXTURE" };
        }

        private static LocalTaskIntake CreateIntakeForTests()
        {
            contextCoordinator = new FakeCoordinator();
            localFactory = new FakeLocalFactory();
            return LocalTaskIntake.CreateForTests(localFactory, contextCoordinator);
        }

        private static void RunAll(LocalTaskIntake intake)
        {
            string trace = "ABCDEF0123456789ABCDEF0123456789";
            TaskIntakeResponse allowed = intake.Execute(Request("mock", trace, "prepare bounded release plan"));
            TaskIntakeResponse repeated = intake.Execute(Request("mock", trace, "prepare bounded release plan"));
            Require(allowed.ExitCode == 0 && allowed.Status == "PASS" && allowed.Outcome == "PASS", "mock allowed request");
            Require(allowed.ProviderId == "mock-v1", "mock provider selected");
            Require(allowed.Pipeline != null && allowed.Pipeline.Results.Count == 5, "five-role pipeline returned");
            Require(allowed.ToCanonicalJson() == repeated.ToCanonicalJson(), "task-intake output deterministic");
            Require(allowed.ToCanonicalJson().IndexOf("\"network\":\"NONE\"", StringComparison.Ordinal) >= 0, "network boundary emitted");
            Require(allowed.ToCanonicalJson().IndexOf("\"writes\":\"NONE\"", StringComparison.Ordinal) >= 0, "write boundary emitted");

            TaskIntakeResponse denied = intake.Execute(Request("mock", "1234567890ABCDEF1234567890ABCDEF", "write file"));
            Require(denied.ExitCode == 77 && denied.Status == "DENIED" && denied.Pipeline.Results.Count == 3, "Guard denial returned");

            TaskIntakeResponse real = intake.Execute(Request("real", "11111111222222223333333344444444", "prepare bounded release plan"));
            Require(real.ExitCode == 78 && real.Status == "PROVIDER_BLOCKED" && real.Pipeline == null, "real provider fails closed");
            Require(real.ProviderId == "real-disabled-v1", "disabled real-provider identity emitted");

            RequireContractFailure(delegate { intake.Execute(Request("unknown", trace, "prepare bounded release plan")); }, "unknown provider rejected");
            RequireContractFailure(delegate
            {
                new LocalTaskIntake().Execute(new string[]
                {
                    "--provider", "ollama-local", "--model", "qwen3:4b",
                    "--trace", trace, "--goal", "prepare bounded release plan"
                });
            }, "local provider requires injected CLI factory");
            RequireContractFailure(delegate { intake.Execute(new string[] { "--provider", "mock" }); }, "incomplete arguments rejected");
            RequireContractFailure(delegate { intake.Execute(new string[] { "--goal", "x", "--trace", trace, "--provider", "mock" }); }, "argument reordering rejected");
            RequireContractFailure(delegate { intake.Execute(Request("mock", trace, new string((char)0xD800, 1))); }, "unpaired high surrogate rejected");
            RequireContractFailure(delegate { intake.Execute(Request("mock", trace, new string((char)0xDC00, 1))); }, "unpaired low surrogate rejected");

            TaskIntakeResponse contextMock = intake.Execute(ContextRequest("mock", trace, "prepare bounded release plan"));
            string contextMockJson = contextMock.ToCanonicalJson();
            Require(contextMock.ExitCode == 0 && contextMock.Pipeline.Results.Count == 5, "context mock allowed request");
            Require(contextCoordinator.Calls == 1 && localFactory.Calls == 0, "context prepared before mock without local factory");
            Require(contextMock.ContextMetadata != null && contextMockJson.IndexOf("\"context\":{\"allowlistId\":", StringComparison.Ordinal) > contextMockJson.IndexOf("\"result\":", StringComparison.Ordinal), "sanitized context metadata emitted after result");

            TaskIntakeResponse contextLocal = intake.Execute(LocalContextRequest("AAAABBBBCCCCDDDDEEEEFFFF00001111", "RAW_CONTEXT_SENTINEL_DO_NOT_EMIT"));
            Require(contextLocal.ExitCode == 0 && contextLocal.ProviderId == "ollama-loopback-v1" && contextLocal.Network == "LOOPBACK_ONLY" && contextLocal.ToCanonicalJson().IndexOf("RAW_CONTEXT_SENTINEL_DO_NOT_EMIT", StringComparison.Ordinal) < 0, "fake local context allowed request with provider echo isolated");
            Require(contextCoordinator.Calls == 2 && localFactory.Calls == 1, "context prepared and local factory called once");
            Require(localFactory.Last.BeginCalls == 1 && localFactory.Last.EndCalls == 1 && localFactory.Last.DisposeCalls == 1 && localFactory.Last.CompleteCalls == 6 && localFactory.Last.ChatCalls == 2, "fake local lifecycle and cache bounded");
            Require(contextLocal.ToCanonicalJson().IndexOf("\"context\":", StringComparison.Ordinal) < contextLocal.ToCanonicalJson().IndexOf("\"providerObservations\":", StringComparison.Ordinal), "context precedes provider observations");

            int contextCallsBeforeDeny = contextCoordinator.Calls;
            int factoryCallsBeforeDeny = localFactory.Calls;
            TaskIntakeResponse contextDeniedMock = intake.Execute(ContextRequest("mock", "9999AAAABBBBCCCCDDDDEEEEFFFF0000", "write file"));
            Require(contextDeniedMock.ToCanonicalJson() == "{\"schemaVersion\":1,\"status\":\"DENIED\",\"provider\":\"mock-v1\",\"traceId\":\"9999AAAABBBBCCCCDDDDEEEEFFFF0000\",\"outcome\":\"DENIED\",\"network\":\"NONE\",\"writes\":\"NONE\",\"result\":null,\"context\":{\"state\":\"NOT_READ_GUARD_DENY\"}}", "mock context deny exact bytes");
            TaskIntakeResponse contextDeniedLocal = intake.Execute(LocalContextRequest("88889999AAAABBBBCCCCDDDDEEEEFFFF", "write file"));
            Require(contextDeniedLocal.ProviderId == "ollama-loopback-v1" && contextDeniedLocal.ExitCode == 77 && contextDeniedLocal.ContextGuardDenied, "local context deny static identity");
            Require(contextCoordinator.Calls == contextCallsBeforeDeny && localFactory.Calls == factoryCallsBeforeDeny, "deny performs zero context and provider construction");

            RequireContractFailure(delegate { intake.Execute(new string[] { "--provider", "real", "--trace", trace, "--goal", "prepare bounded release plan", "--context-root", "C:\\EAIRA-CONTEXT-FIXTURE" }); }, "real context rejected");
            RequireContractFailure(delegate { intake.Execute(new string[] { "--provider", "mock", "--trace", trace, "--context-root", "C:\\EAIRA-CONTEXT-FIXTURE", "--goal", "prepare bounded release plan" }); }, "context argument order rejected");
        }

        internal static int Main(string[] args)
        {
            if (args == null || args.Length != 1 || !String.Equals(args[0], "--self-test", StringComparison.Ordinal)) { return 64; }
            try
            {
                LocalTaskIntake intake = CreateIntakeForTests();
                RunAll(intake);
                Console.WriteLine("{\"status\":\"PASS\",\"contract\":\"EAIRA_LOCAL_TASK_INTAKE_V1\",\"testsPassed\":" + passed + ",\"network\":\"NONE\",\"writes\":\"NONE\",\"realProvider\":\"BLOCKED\"}");
                return 0;
            }
            catch (Exception)
            {
                Console.WriteLine("{\"status\":\"FAIL\",\"errorType\":\"HarnessFailure\"}");
                return 70;
            }
        }
    }
}
