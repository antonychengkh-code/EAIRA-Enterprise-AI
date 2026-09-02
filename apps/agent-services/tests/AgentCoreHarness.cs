using System;
using System.Reflection;
using EAIRA.AgentServices.Functional;

namespace EAIRA.AgentServices.Tests
{
    internal static class AgentCoreHarness
    {
        private static int passed;

        private static void Require(bool condition, string name)
        {
            if (!condition) { throw new ContractException("Test failed: " + name); }
            passed++;
        }

        private static void RequireContractFailure(Action action, string name)
        {
            bool failedClosed = false;
            try { action(); }
            catch (ContractException) { failedClosed = true; }
            Require(failedClosed, name);
        }

        private static void Tamper(AgentResult result, string propertyName, object value)
        {
            FieldInfo field = typeof(AgentResult).GetField("<" + propertyName + ">k__BackingField", BindingFlags.Instance | BindingFlags.NonPublic);
            if (field == null) { throw new ContractException("Test backing field was not found: " + propertyName); }
            field.SetValue(result, value);
        }

        private static void TamperTask(TaskEnvelope task, string propertyName, object value)
        {
            FieldInfo field = typeof(TaskEnvelope).GetField("<" + propertyName + ">k__BackingField", BindingFlags.Instance | BindingFlags.NonPublic);
            if (field == null) { throw new ContractException("Task test backing field was not found: " + propertyName); }
            field.SetValue(task, value);
        }

        private static void AdversariallyRehash(AgentResult result)
        {
            MethodInfo method = typeof(AgentResult).GetMethod("ComputeDigest", BindingFlags.Instance | BindingFlags.NonPublic);
            if (method == null) { throw new ContractException("Result digest method was not found."); }
            Tamper(result, "ResultDigest", (string)method.Invoke(result, null));
        }

        private static void RunAll()
        {
            TaskEnvelope task = TaskEnvelope.Create(1, "00112233445566778899AABBCCDDEEFF", "prepare bounded release plan");
            MinimumFunctionalPipeline pipeline = new MinimumFunctionalPipeline();
            PipelineResult first = pipeline.Execute(task);
            PipelineResult second = pipeline.Execute(task);

            Require(first.Outcome == "PASS", "positive outcome");
            Require(first.Results.Count == 5, "five role results");
            Require(first.Results[0].Role == AgentRole.Planning, "planning order");
            Require(first.Results[1].Role == AgentRole.Guard, "guard order");
            Require(first.Results[2].Role == AgentRole.Operations, "operations order");
            Require(first.Results[3].Role == AgentRole.Verification, "verification order");
            Require(first.Results[4].Role == AgentRole.Audit, "audit order");
            Require(first.ToCanonicalJson() == second.ToCanonicalJson(), "deterministic canonical output");
            MinimumFunctionalPipeline.ValidateChain(task, first.Results);
            passed++;

            TaskEnvelope deniedTask = TaskEnvelope.Create(1, "FFEEDDCCBBAA99887766554433221100", "write file");
            PipelineResult denied = pipeline.Execute(deniedTask);
            Require(denied.Outcome == "DENIED", "guard denial outcome");
            Require(denied.Results.Count == 3, "denial skips operations and verification");
            Require(denied.Results[1].Role == AgentRole.Guard && denied.Results[1].Decision == AgentDecision.Deny, "guard denial decision");
            Require(denied.Results[2].Role == AgentRole.Audit, "denial audit candidate");
            MinimumFunctionalPipeline.ValidateChain(deniedTask, denied.Results);
            passed++;

            RequireContractFailure(
                delegate { TaskEnvelope.Create(2, "00112233445566778899AABBCCDDEEFF", "prepare bounded release plan"); },
                "unknown schema rejected");
            RequireContractFailure(
                delegate { TaskEnvelope.Create(1, "invalid-trace", "prepare bounded release plan"); },
                "invalid trace rejected");
            RequireContractFailure(
                delegate { TaskEnvelope.Create(1, "00112233445566778899AABBCCDDEEFF", "bad\ncontrol"); },
                "control character rejected");
            RequireContractFailure(
                delegate { TaskEnvelope.Create(1, "00112233445566778899AABBCCDDEEFF", new string((char)0xD800, 1)); },
                "unpaired high surrogate rejected");
            RequireContractFailure(
                delegate { TaskEnvelope.Create(1, "00112233445566778899AABBCCDDEEFF", new string((char)0xDC00, 1)); },
                "unpaired low surrogate rejected");
            TaskEnvelope scalarTask = TaskEnvelope.Create(1, "00112233445566778899AABBCCDDEEFF", Char.ConvertFromUtf32(0x1F600));
            TaskEnvelope replacementTask = TaskEnvelope.Create(1, "00112233445566778899AABBCCDDEEFF", "\uFFFD");
            Require(scalarTask.TaskDigest != replacementTask.TaskDigest, "valid supplementary scalar remains distinct from replacement character");

            DeterministicMockModel model = new DeterministicMockModel();
            AgentResult planning = new PlanningAgent(model).Execute(task);
            AgentResult guard = new GuardAgent(model).Execute(task, planning);
            RequireContractFailure(
                delegate { new OperationsAgent(model).Execute(task, planning, planning); },
                "role boundary rejects planning to operations bypass");

            TaskEnvelope otherTask = TaskEnvelope.Create(1, "11112222333344445555666677778888", "prepare bounded release plan");
            RequireContractFailure(
                delegate { new OperationsAgent(model).Execute(otherTask, planning, guard); },
                "task digest mismatch rejected");

            RequireContractFailure(
                delegate { new AgentResult(AgentRole.Planning, AgentDecision.Candidate, task.TaskDigest, "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", 0, "FORGED_PLAN"); },
                "planning forged previous digest rejected");

            AgentResult tamperedPayload = new PlanningAgent(model).Execute(task);
            Tamper(tamperedPayload, "Payload", "TAMPERED_PAYLOAD");
            RequireContractFailure(
                delegate { new GuardAgent(model).Execute(task, tamperedPayload); },
                "tampered payload digest rejected");

            AgentResult tamperedDigest = new PlanningAgent(model).Execute(task);
            Tamper(tamperedDigest, "ResultDigest", "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB");
            RequireContractFailure(
                delegate { new GuardAgent(model).Execute(task, tamperedDigest); },
                "tampered result digest rejected");

            AgentResult forgedOperations = new AgentResult(
                AgentRole.Operations,
                AgentDecision.Candidate,
                task.TaskDigest,
                "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC",
                2,
                "FORGED_OPERATIONS|MUTATION=NONE");
            RequireContractFailure(
                delegate { new VerificationAgent(model).Execute(task, planning, guard, forgedOperations); },
                "forged operations handoff rejected");

            TaskEnvelope postGuardTamperTask = TaskEnvelope.Create(1, "22223333444455556666777788889999", "prepare bounded release plan");
            AgentResult postGuardPlanning = new PlanningAgent(model).Execute(postGuardTamperTask);
            AgentResult postGuardAllow = new GuardAgent(model).Execute(postGuardTamperTask, postGuardPlanning);
            TamperTask(postGuardTamperTask, "Goal", "write file");
            RequireContractFailure(
                delegate { new OperationsAgent(model).Execute(postGuardTamperTask, postGuardPlanning, postGuardAllow); },
                "post-guard task goal tamper rejected");

            TaskEnvelope unsafeTask = TaskEnvelope.Create(1, "3333444455556666777788889999AAAA", "write file");
            AgentResult unsafePlanning = new PlanningAgent(model).Execute(unsafeTask);
            AgentResult forgedGuardAllow = new AgentResult(
                AgentRole.Guard,
                AgentDecision.Allow,
                unsafeTask.TaskDigest,
                unsafePlanning.ResultDigest,
                1,
                "POLICY_ALLOW|NOWRITE_A");
            RequireContractFailure(
                delegate { new OperationsAgent(model).Execute(unsafeTask, unsafePlanning, forgedGuardAllow); },
                "forged guard allow on unsafe goal rejected");

            TaskEnvelope semanticTask = TaskEnvelope.Create(1, "444455556666777788889999AAAABBBB", "prepare bounded release plan");
            AgentResult semanticPlanning = new PlanningAgent(model).Execute(semanticTask);
            AgentResult semanticGuard = new GuardAgent(model).Execute(semanticTask, semanticPlanning);
            AgentResult tamperedOperations = new OperationsAgent(model).Execute(semanticTask, semanticPlanning, semanticGuard);
            Tamper(tamperedOperations, "Payload", "ACTION_CANDIDATE|REHASHED_ATTACK|MUTATION=WRITE");
            AdversariallyRehash(tamperedOperations);
            RequireContractFailure(
                delegate { new VerificationAgent(model).Execute(semanticTask, semanticPlanning, semanticGuard, tamperedOperations); },
                "operations payload tamper plus rehash rejected");

            Require(FunctionalSliceSelfTest.ForRole("Planning"), "planning role self-test");
            Require(FunctionalSliceSelfTest.ForRole("Operations"), "operations role self-test");
            Require(FunctionalSliceSelfTest.ForRole("Verification"), "verification role self-test");
            Require(FunctionalSliceSelfTest.ForRole("Guard"), "guard role self-test");
            Require(FunctionalSliceSelfTest.ForRole("Audit"), "audit role self-test");
        }

        internal static int Main(string[] args)
        {
            if (args == null || args.Length != 1 || !String.Equals(args[0], "--self-test", StringComparison.Ordinal))
            {
                return 64;
            }

            try
            {
                RunAll();
                Console.WriteLine("{\"status\":\"PASS\",\"contract\":\"EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1\",\"testsPassed\":" + passed + ",\"network\":\"NONE\",\"ipc\":\"NONE\",\"writes\":\"NONE\",\"childProcess\":\"NONE\"}");
                return 0;
            }
            catch (Exception exception)
            {
                Console.WriteLine("{\"status\":\"FAIL\",\"errorType\":\"" + exception.GetType().Name + "\"}");
                return 70;
            }
        }
    }
}
