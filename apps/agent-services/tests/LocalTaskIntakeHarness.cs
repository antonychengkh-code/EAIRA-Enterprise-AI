using System;
using EAIRA.AgentServices.Functional;

namespace EAIRA.AgentServices.Tests
{
    internal static class LocalTaskIntakeHarness
    {
        private static int passed;

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

        private static void RunAll()
        {
            LocalTaskIntake intake = new LocalTaskIntake();
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
                intake.Execute(new string[]
                {
                    "--provider", "ollama-local", "--model", "qwen3:4b",
                    "--trace", trace, "--goal", "prepare bounded release plan"
                });
            }, "local provider requires injected CLI factory");
            RequireContractFailure(delegate { intake.Execute(new string[] { "--provider", "mock" }); }, "incomplete arguments rejected");
            RequireContractFailure(delegate { intake.Execute(new string[] { "--goal", "x", "--trace", trace, "--provider", "mock" }); }, "argument reordering rejected");
            RequireContractFailure(delegate { intake.Execute(Request("mock", trace, new string((char)0xD800, 1))); }, "unpaired high surrogate rejected");
            RequireContractFailure(delegate { intake.Execute(Request("mock", trace, new string((char)0xDC00, 1))); }, "unpaired low surrogate rejected");
        }

        internal static int Main(string[] args)
        {
            if (args == null || args.Length != 1 || !String.Equals(args[0], "--self-test", StringComparison.Ordinal)) { return 64; }
            try
            {
                RunAll();
                Console.WriteLine("{\"status\":\"PASS\",\"contract\":\"EAIRA_LOCAL_TASK_INTAKE_V1\",\"testsPassed\":" + passed + ",\"network\":\"NONE\",\"writes\":\"NONE\",\"realProvider\":\"BLOCKED\"}");
                return 0;
            }
            catch (Exception exception)
            {
                Console.WriteLine("{\"status\":\"FAIL\",\"errorType\":" + ContractCodec.Json(exception.GetType().Name) + "}");
                return 70;
            }
        }
    }
}
