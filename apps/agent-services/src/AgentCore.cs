using System;
using System.Collections.Generic;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;

namespace EAIRA.AgentServices.Functional
{
    internal enum AgentRole
    {
        Planning = 1,
        Guard = 2,
        Operations = 3,
        Verification = 4,
        Audit = 5
    }

    internal enum AgentDecision
    {
        Candidate = 1,
        Allow = 2,
        Deny = 3,
        Verified = 4,
        RecordedCandidate = 5
    }

    internal sealed class TaskEnvelope
    {
        internal const int CurrentSchemaVersion = 1;

        internal int SchemaVersion { get; private set; }
        internal string TraceId { get; private set; }
        internal string Goal { get; private set; }
        internal string TaskDigest { get; private set; }

        private TaskEnvelope(int schemaVersion, string traceId, string goal)
        {
            SchemaVersion = schemaVersion;
            TraceId = traceId;
            Goal = goal;
            ValidateFields();
            TaskDigest = ComputeDigest();
        }

        private void ValidateFields()
        {
            if (SchemaVersion != CurrentSchemaVersion) { throw new ContractException("Unsupported task schema."); }
            if (TraceId == null || TraceId.Length != 32) { throw new ContractException("Trace ID must be 32 uppercase hexadecimal characters."); }
            for (int index = 0; index < TraceId.Length; index++)
            {
                char character = TraceId[index];
                bool valid = (character >= '0' && character <= '9') || (character >= 'A' && character <= 'F');
                if (!valid) { throw new ContractException("Trace ID must be uppercase hexadecimal."); }
            }
            if (String.IsNullOrWhiteSpace(Goal) || Goal.Length > 512) { throw new ContractException("Goal must contain 1 to 512 characters."); }
            ContractCodec.RequireWellFormedUtf16(Goal, "Goal");
            for (int index = 0; index < Goal.Length; index++)
            {
                if (Char.IsControl(Goal[index])) { throw new ContractException("Goal contains a prohibited control character."); }
            }
        }

        private string ComputeDigest()
        {
            return ContractCodec.Sha256Hex(
                "EAIRA_TASK_ENVELOPE_V1\0" +
                ContractCodec.Field(SchemaVersion.ToString(CultureInfo.InvariantCulture)) +
                ContractCodec.Field(TraceId) +
                ContractCodec.Field(Goal));
        }

        internal void ValidateIntegrity()
        {
            ValidateFields();
            ContractCodec.RequireHash(TaskDigest, "Task digest");
            if (!String.Equals(TaskDigest, ComputeDigest(), StringComparison.Ordinal))
            {
                throw new ContractException("Task digest does not match canonical task fields.");
            }
        }

        internal static TaskEnvelope Create(int schemaVersion, string traceId, string goal)
        {
            return new TaskEnvelope(schemaVersion, traceId, goal);
        }
    }

    internal sealed class AgentResult
    {
        internal AgentRole Role { get; private set; }
        internal AgentDecision Decision { get; private set; }
        internal string TaskDigest { get; private set; }
        internal string PreviousResultDigest { get; private set; }
        internal int ChainDepth { get; private set; }
        internal string Payload { get; private set; }
        internal string ResultDigest { get; private set; }

        internal AgentResult(AgentRole role, AgentDecision decision, string taskDigest, string previousResultDigest, int chainDepth, string payload)
        {
            Role = role;
            Decision = decision;
            TaskDigest = taskDigest;
            PreviousResultDigest = previousResultDigest;
            ChainDepth = chainDepth;
            Payload = payload;
            ValidateFields();
            ResultDigest = ComputeDigest();
        }

        private string ComputeDigest()
        {
            return ContractCodec.Sha256Hex(
                "EAIRA_AGENT_RESULT_V1\0" +
                ContractCodec.Field(((int)Role).ToString(CultureInfo.InvariantCulture)) +
                ContractCodec.Field(((int)Decision).ToString(CultureInfo.InvariantCulture)) +
                ContractCodec.Field(TaskDigest) +
                ContractCodec.Field(PreviousResultDigest) +
                ContractCodec.Field(ChainDepth.ToString(CultureInfo.InvariantCulture)) +
                ContractCodec.Field(Payload));
        }

        private void ValidateFields()
        {
            ContractCodec.RequireHash(TaskDigest, "Task digest");
            ContractCodec.RequireHash(PreviousResultDigest, "Previous result digest");
            if (String.IsNullOrEmpty(Payload) || Payload.Length > 1024) { throw new ContractException("Result payload must contain 1 to 1024 characters."); }
            ContractCodec.RequireWellFormedUtf16(Payload, "Result payload");
            for (int index = 0; index < Payload.Length; index++)
            {
                if (Char.IsControl(Payload[index])) { throw new ContractException("Result payload contains a prohibited control character."); }
            }

            bool roleDecisionValid =
                (Role == AgentRole.Planning && Decision == AgentDecision.Candidate && ChainDepth == 0) ||
                (Role == AgentRole.Guard && (Decision == AgentDecision.Allow || Decision == AgentDecision.Deny) && ChainDepth == 1) ||
                (Role == AgentRole.Operations && Decision == AgentDecision.Candidate && ChainDepth == 2) ||
                (Role == AgentRole.Verification && Decision == AgentDecision.Verified && ChainDepth == 3) ||
                (Role == AgentRole.Audit && Decision == AgentDecision.RecordedCandidate && (ChainDepth == 2 || ChainDepth == 4));
            if (!roleDecisionValid) { throw new ContractException("Role, decision and chain depth are inconsistent."); }
            if (Role == AgentRole.Planning && PreviousResultDigest != ContractCodec.ZeroHash)
            {
                throw new ContractException("Planning must start at the zero previous-result digest.");
            }
            if (Role != AgentRole.Planning && PreviousResultDigest == ContractCodec.ZeroHash)
            {
                throw new ContractException("Non-planning results require a non-zero previous-result digest.");
            }
        }

        internal void ValidateIntegrity()
        {
            ValidateFields();
            ContractCodec.RequireHash(ResultDigest, "Result digest");
            if (!String.Equals(ResultDigest, ComputeDigest(), StringComparison.Ordinal))
            {
                throw new ContractException("Result digest does not match canonical result fields.");
            }
        }

        internal string ToCanonicalJson()
        {
            return "{\"role\":" + ContractCodec.Json(Role.ToString()) +
                   ",\"decision\":" + ContractCodec.Json(Decision.ToString()) +
                   ",\"taskDigest\":" + ContractCodec.Json(TaskDigest) +
                   ",\"previousResultDigest\":" + ContractCodec.Json(PreviousResultDigest) +
                   ",\"chainDepth\":" + ChainDepth.ToString(CultureInfo.InvariantCulture) +
                   ",\"payload\":" + ContractCodec.Json(Payload) +
                   ",\"resultDigest\":" + ContractCodec.Json(ResultDigest) + "}";
        }
    }

    internal sealed class PlanningAgent
    {
        private readonly IModelProvider model;

        internal PlanningAgent(IModelProvider model) { this.model = ModelProviderPolicy.RequireEnabled(model); }

        internal AgentResult Execute(TaskEnvelope task)
        {
            if (task == null) { throw new ContractException("Planning task is required."); }
            task.ValidateIntegrity();
            string payload = ExpectedPayload(task, model);
            return new AgentResult(AgentRole.Planning, AgentDecision.Candidate, task.TaskDigest, ContractCodec.ZeroHash, 0, payload);
        }

        internal AgentResult Execute(TaskEnvelope task, string exactPlanningPrompt)
        {
            if (task == null) { throw new ContractException("Planning task is required."); }
            task.ValidateIntegrity();
            string payload = ExpectedPayload(task, model, exactPlanningPrompt);
            return new AgentResult(AgentRole.Planning, AgentDecision.Candidate, task.TaskDigest, ContractCodec.ZeroHash, 0, payload);
        }

        internal static string ExpectedPayload(TaskEnvelope task, IModelProvider deterministicModel)
        {
            if (task == null || deterministicModel == null) { throw new ContractException("Planning semantic inputs are required."); }
            return "PLAN_CANDIDATE|" + deterministicModel.Complete(AgentRole.Planning, task.Goal) + "|STEPS=3";
        }

        internal static string ExpectedPayload(TaskEnvelope task, IModelProvider deterministicModel, string exactPlanningPrompt)
        {
            if (task == null || deterministicModel == null || exactPlanningPrompt == null)
            {
                throw new ContractException("Context Planning semantic inputs are required.");
            }
            ContractCodec.RequireWellFormedUtf16(exactPlanningPrompt, "Context Planning prompt");
            string providerOutput = deterministicModel.Complete(AgentRole.Planning, exactPlanningPrompt);
            string outputDigest = ContractCodec.Sha256Hex(
                "EAIRA_CONTEXT_PLANNING_OUTPUT_V1\0" + ContractCodec.Field(providerOutput));
            providerOutput = null;
            return "PLAN_CANDIDATE_CONTEXT_REDACTED|OUTPUT_SHA256=" + outputDigest + "|STEPS=3";
        }
    }

    internal sealed class GuardAgent
    {
        private readonly IModelProvider model;

        private static readonly string[] ProhibitedTerms = new string[]
        {
            "NETWORK", "WRITE", "IPC", "CHILD_PROCESS", "SHELL", "CREDENTIAL", "SECRET"
        };

        internal GuardAgent(IModelProvider model) { this.model = ModelProviderPolicy.RequireEnabled(model); }

        internal AgentResult Execute(TaskEnvelope task, AgentResult planning)
        {
            MinimumFunctionalPipeline.ValidateSemanticPrefix(task, new AgentResult[] { planning }, model);
            AgentDecision decision = ExpectedDecision(task);
            string payload = ExpectedPayload(task, decision);
            return new AgentResult(AgentRole.Guard, decision, task.TaskDigest, planning.ResultDigest, 1, payload);
        }

        internal AgentResult Execute(
            TaskEnvelope task,
            AgentResult planning,
            ContextPlanningSeal contextSeal,
            AgentDecision sealedPreauthorization)
        {
            MinimumFunctionalPipeline.ValidateContextSemanticPrefix(
                task,
                new AgentResult[] { planning },
                model,
                contextSeal);
            AgentDecision decision = ExpectedDecision(task);
            if (sealedPreauthorization != decision)
            {
                throw new ContractException("Context preauthorization does not match replayed Guard policy.");
            }
            string payload = ExpectedPayload(task, decision);
            return new AgentResult(AgentRole.Guard, decision, task.TaskDigest, planning.ResultDigest, 1, payload);
        }

        internal static AgentDecision ExpectedDecision(TaskEnvelope task)
        {
            if (task == null) { throw new ContractException("Guard task is required."); }
            string upperGoal = task.Goal.ToUpperInvariant();
            for (int index = 0; index < ProhibitedTerms.Length; index++)
            {
                if (upperGoal.IndexOf(ProhibitedTerms[index], StringComparison.Ordinal) >= 0)
                {
                    return AgentDecision.Deny;
                }
            }
            return AgentDecision.Allow;
        }

        internal static string ExpectedPayload(TaskEnvelope task, AgentDecision decision)
        {
            if (decision == AgentDecision.Allow) { return "POLICY_ALLOW|NOWRITE_A"; }
            string upperGoal = task.Goal.ToUpperInvariant();
            for (int index = 0; index < ProhibitedTerms.Length; index++)
            {
                if (upperGoal.IndexOf(ProhibitedTerms[index], StringComparison.Ordinal) >= 0)
                {
                    return "POLICY_DENY|PROHIBITED_" + ProhibitedTerms[index];
                }
            }
            throw new ContractException("Guard deny payload has no matching prohibited term.");
        }
    }

    internal sealed class OperationsAgent
    {
        private readonly IModelProvider model;

        internal OperationsAgent(IModelProvider model) { this.model = ModelProviderPolicy.RequireEnabled(model); }

        internal AgentResult Execute(TaskEnvelope task, AgentResult planning, AgentResult guard)
        {
            MinimumFunctionalPipeline.ValidateSemanticPrefix(task, new AgentResult[] { planning, guard }, model);
            if (guard.Decision != AgentDecision.Allow) { throw new ContractException("Operations requires a Guard allow result."); }
            string payload = ExpectedPayload(guard, model);
            return new AgentResult(AgentRole.Operations, AgentDecision.Candidate, task.TaskDigest, guard.ResultDigest, 2, payload);
        }

        internal AgentResult Execute(
            TaskEnvelope task,
            AgentResult planning,
            AgentResult guard,
            ContextPlanningSeal contextSeal)
        {
            MinimumFunctionalPipeline.ValidateContextSemanticPrefix(
                task,
                new AgentResult[] { planning, guard },
                model,
                contextSeal);
            if (guard.Decision != AgentDecision.Allow) { throw new ContractException("Operations requires a Guard allow result."); }
            string payload = ExpectedPayload(guard, model);
            return new AgentResult(AgentRole.Operations, AgentDecision.Candidate, task.TaskDigest, guard.ResultDigest, 2, payload);
        }

        internal static string ExpectedPayload(AgentResult guard, IModelProvider deterministicModel)
        {
            if (guard == null || deterministicModel == null) { throw new ContractException("Operations semantic inputs are required."); }
            return "ACTION_CANDIDATE|" + deterministicModel.Complete(AgentRole.Operations, guard.ResultDigest) + "|MUTATION=NONE";
        }
    }

    internal sealed class VerificationAgent
    {
        private readonly IModelProvider model;

        internal VerificationAgent(IModelProvider model) { this.model = ModelProviderPolicy.RequireEnabled(model); }

        internal AgentResult Execute(TaskEnvelope task, AgentResult planning, AgentResult guard, AgentResult operations)
        {
            MinimumFunctionalPipeline.ValidateSemanticPrefix(task, new AgentResult[] { planning, guard, operations }, model);
            string payload = ExpectedPayload(operations);
            return new AgentResult(AgentRole.Verification, AgentDecision.Verified, task.TaskDigest, operations.ResultDigest, 3, payload);
        }

        internal AgentResult Execute(
            TaskEnvelope task,
            AgentResult planning,
            AgentResult guard,
            AgentResult operations,
            ContextPlanningSeal contextSeal)
        {
            MinimumFunctionalPipeline.ValidateContextSemanticPrefix(
                task,
                new AgentResult[] { planning, guard, operations },
                model,
                contextSeal);
            string payload = ExpectedPayload(operations);
            return new AgentResult(AgentRole.Verification, AgentDecision.Verified, task.TaskDigest, operations.ResultDigest, 3, payload);
        }

        internal static string ExpectedPayload(AgentResult operations)
        {
            if (operations == null) { throw new ContractException("Verification semantic input is required."); }
            return "VERIFIED_CANDIDATE|SOURCE=" + operations.ResultDigest + "|SIDE_EFFECTS=NONE";
        }
    }

    internal sealed class AuditAgent
    {
        private readonly IModelProvider model;

        internal AuditAgent(IModelProvider model) { this.model = ModelProviderPolicy.RequireEnabled(model); }

        internal AgentResult Execute(TaskEnvelope task, IList<AgentResult> priorResults, string outcome)
        {
            MinimumFunctionalPipeline.ValidateSemanticPrefix(task, priorResults, model);
            if (outcome != "PASS" && outcome != "DENIED") { throw new ContractException("Audit outcome is invalid."); }
            AgentResult prior = priorResults[priorResults.Count - 1];
            if (outcome == "PASS" && (priorResults.Count != 4 || prior.Role != AgentRole.Verification || prior.Decision != AgentDecision.Verified))
            {
                throw new ContractException("PASS audit requires verification.");
            }
            if (outcome == "DENIED" && (priorResults.Count != 2 || prior.Role != AgentRole.Guard || prior.Decision != AgentDecision.Deny))
            {
                throw new ContractException("DENIED audit requires a Guard denial.");
            }

            string payload = ExpectedPayload(outcome);
            return new AgentResult(AgentRole.Audit, AgentDecision.RecordedCandidate, task.TaskDigest, prior.ResultDigest, prior.ChainDepth + 1, payload);
        }

        internal AgentResult Execute(
            TaskEnvelope task,
            IList<AgentResult> priorResults,
            string outcome,
            ContextPlanningSeal contextSeal)
        {
            MinimumFunctionalPipeline.ValidateContextSemanticPrefix(task, priorResults, model, contextSeal);
            if (outcome != "PASS" && outcome != "DENIED") { throw new ContractException("Audit outcome is invalid."); }
            AgentResult prior = priorResults[priorResults.Count - 1];
            if (outcome == "PASS" && (priorResults.Count != 4 || prior.Role != AgentRole.Verification || prior.Decision != AgentDecision.Verified))
            {
                throw new ContractException("PASS audit requires verification.");
            }
            if (outcome == "DENIED" && (priorResults.Count != 2 || prior.Role != AgentRole.Guard || prior.Decision != AgentDecision.Deny))
            {
                throw new ContractException("DENIED audit requires a Guard denial.");
            }

            string payload = ExpectedPayload(outcome);
            return new AgentResult(AgentRole.Audit, AgentDecision.RecordedCandidate, task.TaskDigest, prior.ResultDigest, prior.ChainDepth + 1, payload);
        }

        internal static string ExpectedPayload(string outcome)
        {
            if (outcome != "PASS" && outcome != "DENIED") { throw new ContractException("Audit outcome is invalid."); }
            return "AUDIT_EVENT_CANDIDATE|OUTCOME=" + outcome + "|PERSISTED=NO";
        }
    }

    internal sealed class PipelineResult
    {
        private readonly List<AgentResult> results;

        internal string TraceId { get; private set; }
        internal string Outcome { get; private set; }
        internal IList<AgentResult> Results { get { return results.AsReadOnly(); } }

        internal PipelineResult(string traceId, string outcome, List<AgentResult> results)
        {
            TraceId = traceId;
            Outcome = outcome;
            this.results = results;
        }

        internal string ToCanonicalJson()
        {
            StringBuilder builder = new StringBuilder();
            builder.Append("{\"schemaVersion\":1,\"traceId\":");
            builder.Append(ContractCodec.Json(TraceId));
            builder.Append(",\"outcome\":");
            builder.Append(ContractCodec.Json(Outcome));
            builder.Append(",\"results\":[");
            for (int index = 0; index < results.Count; index++)
            {
                if (index != 0) { builder.Append(','); }
                builder.Append(results[index].ToCanonicalJson());
            }
            builder.Append("]}");
            return builder.ToString();
        }
    }

    internal sealed class ContextPlanningSeal
    {
        internal string TaskDigest { get; private set; }
        internal string PlanningResultDigest { get; private set; }
        internal string ProviderId { get; private set; }

        private ContextPlanningSeal(string taskDigest, string planningResultDigest, string providerId)
        {
            TaskDigest = taskDigest;
            PlanningResultDigest = planningResultDigest;
            ProviderId = providerId;
        }

        internal static ContextPlanningSeal Create(
            TaskEnvelope task,
            AgentResult planning,
            IModelProvider semanticModel,
            string exactPlanningPrompt)
        {
            if (task == null || planning == null || semanticModel == null || exactPlanningPrompt == null)
            {
                throw new ContractException("Context Planning seal inputs are required.");
            }
            ModelProviderPolicy.RequireEnabled(semanticModel);
            MinimumFunctionalPipeline.ValidatePrefix(task, new AgentResult[] { planning });
            string expectedPayload = PlanningAgent.ExpectedPayload(task, semanticModel, exactPlanningPrompt);
            if (!String.Equals(planning.Payload, expectedPayload, StringComparison.Ordinal))
            {
                throw new ContractException("Context Planning result does not match its exact prompt.");
            }
            return new ContextPlanningSeal(task.TaskDigest, planning.ResultDigest, semanticModel.ProviderId);
        }

        internal void Validate(TaskEnvelope task, AgentResult planning, IModelProvider semanticModel)
        {
            if (task == null || planning == null || semanticModel == null)
            {
                throw new ContractException("Context Planning seal validation inputs are required.");
            }
            ContractCodec.RequireHash(TaskDigest, "Context seal task digest");
            ContractCodec.RequireHash(PlanningResultDigest, "Context seal Planning digest");
            if (!String.Equals(TaskDigest, task.TaskDigest, StringComparison.Ordinal) ||
                !String.Equals(PlanningResultDigest, planning.ResultDigest, StringComparison.Ordinal) ||
                !String.Equals(ProviderId, semanticModel.ProviderId, StringComparison.Ordinal))
            {
                throw new ContractException("Context Planning seal binding failed.");
            }
        }
    }

    internal sealed class MinimumFunctionalPipeline
    {
        private readonly IModelProvider model;

        internal MinimumFunctionalPipeline() : this(new DeterministicMockModel()) { }

        internal MinimumFunctionalPipeline(IModelProvider modelProvider)
        {
            model = ModelProviderPolicy.RequireEnabled(modelProvider);
        }

        internal PipelineResult Execute(TaskEnvelope task)
        {
            if (task == null) { throw new ContractException("Pipeline task is required."); }
            task.ValidateIntegrity();
            List<AgentResult> results = new List<AgentResult>();
            AgentResult planning = new PlanningAgent(model).Execute(task);
            results.Add(planning);
            AgentResult guard = new GuardAgent(model).Execute(task, planning);
            results.Add(guard);

            if (guard.Decision == AgentDecision.Deny)
            {
                results.Add(new AuditAgent(model).Execute(task, results, "DENIED"));
                ValidateChain(task, results, model);
                return new PipelineResult(task.TraceId, "DENIED", results);
            }

            AgentResult operations = new OperationsAgent(model).Execute(task, planning, guard);
            results.Add(operations);
            AgentResult verification = new VerificationAgent(model).Execute(task, planning, guard, operations);
            results.Add(verification);
            results.Add(new AuditAgent(model).Execute(task, results, "PASS"));
            ValidateChain(task, results, model);
            return new PipelineResult(task.TraceId, "PASS", results);
        }

        internal PipelineResult Execute(
            TaskEnvelope task,
            string exactPlanningPrompt,
            AgentDecision sealedPreauthorization)
        {
            if (task == null || exactPlanningPrompt == null)
            {
                throw new ContractException("Context pipeline inputs are required.");
            }
            if (sealedPreauthorization != AgentDecision.Allow)
            {
                throw new ContractException("Context pipeline requires an Allow preauthorization.");
            }
            task.ValidateIntegrity();
            List<AgentResult> results = new List<AgentResult>();
            AgentResult planning = new PlanningAgent(model).Execute(task, exactPlanningPrompt);
            results.Add(planning);
            ContextPlanningSeal contextSeal = ContextPlanningSeal.Create(task, planning, model, exactPlanningPrompt);
            exactPlanningPrompt = null;

            AgentResult guard = new GuardAgent(model).Execute(task, planning, contextSeal, sealedPreauthorization);
            results.Add(guard);
            if (guard.Decision != AgentDecision.Allow)
            {
                throw new ContractException("Context pipeline cannot continue after a Guard denial.");
            }

            AgentResult operations = new OperationsAgent(model).Execute(task, planning, guard, contextSeal);
            results.Add(operations);
            AgentResult verification = new VerificationAgent(model).Execute(task, planning, guard, operations, contextSeal);
            results.Add(verification);
            results.Add(new AuditAgent(model).Execute(task, results, "PASS", contextSeal));
            ValidateContextChain(task, results, model, contextSeal);
            return new PipelineResult(task.TraceId, "PASS", results);
        }

        internal static void ValidatePrefix(TaskEnvelope task, IList<AgentResult> results)
        {
            if (task == null || results == null || results.Count < 1 || results.Count > 5) { throw new ContractException("Pipeline prefix is invalid."); }
            task.ValidateIntegrity();
            string previous = ContractCodec.ZeroHash;
            for (int index = 0; index < results.Count; index++)
            {
                AgentResult result = results[index];
                if (result == null) { throw new ContractException("Pipeline result is missing."); }
                result.ValidateIntegrity();
                if (result.TaskDigest != task.TaskDigest || result.PreviousResultDigest != previous || result.ChainDepth != index)
                {
                    throw new ContractException("Pipeline chain binding failed.");
                }
                previous = result.ResultDigest;
            }

            RequireRoleDecision(results[0], AgentRole.Planning, AgentDecision.Candidate);
            if (results.Count >= 2)
            {
                if (results[1].Role != AgentRole.Guard ||
                    (results[1].Decision != AgentDecision.Allow && results[1].Decision != AgentDecision.Deny))
                {
                    throw new ContractException("Pipeline requires Guard allow or deny after Planning.");
                }
            }
            if (results.Count >= 3)
            {
                if (results[1].Decision == AgentDecision.Deny)
                {
                    if (results.Count != 3) { throw new ContractException("Denied pipeline cannot continue after Audit."); }
                    RequireRoleDecision(results[2], AgentRole.Audit, AgentDecision.RecordedCandidate);
                }
                else
                {
                    RequireRoleDecision(results[2], AgentRole.Operations, AgentDecision.Candidate);
                }
            }
            if (results.Count >= 4)
            {
                if (results[1].Decision != AgentDecision.Allow) { throw new ContractException("Denied pipeline cannot reach Verification."); }
                RequireRoleDecision(results[3], AgentRole.Verification, AgentDecision.Verified);
            }
            if (results.Count == 5)
            {
                RequireRoleDecision(results[4], AgentRole.Audit, AgentDecision.RecordedCandidate);
            }
        }

        internal static void ValidateSemanticPrefix(TaskEnvelope task, IList<AgentResult> results, IModelProvider semanticModel)
        {
            ValidatePrefix(task, results);
            ModelProviderPolicy.RequireEnabled(semanticModel);
            RequirePayload(results[0], PlanningAgent.ExpectedPayload(task, semanticModel));

            if (results.Count >= 2)
            {
                AgentDecision expectedGuardDecision = GuardAgent.ExpectedDecision(task);
                if (results[1].Decision != expectedGuardDecision)
                {
                    throw new ContractException("Guard decision does not match replayed policy.");
                }
                RequirePayload(results[1], GuardAgent.ExpectedPayload(task, expectedGuardDecision));
            }
            if (results.Count >= 3)
            {
                if (results[1].Decision == AgentDecision.Deny)
                {
                    RequirePayload(results[2], AuditAgent.ExpectedPayload("DENIED"));
                }
                else
                {
                    RequirePayload(results[2], OperationsAgent.ExpectedPayload(results[1], semanticModel));
                }
            }
            if (results.Count >= 4)
            {
                RequirePayload(results[3], VerificationAgent.ExpectedPayload(results[2]));
            }
            if (results.Count == 5)
            {
                RequirePayload(results[4], AuditAgent.ExpectedPayload("PASS"));
            }
        }

        internal static void ValidateContextSemanticPrefix(
            TaskEnvelope task,
            IList<AgentResult> results,
            IModelProvider semanticModel,
            ContextPlanningSeal contextSeal)
        {
            ValidatePrefix(task, results);
            ModelProviderPolicy.RequireEnabled(semanticModel);
            if (contextSeal == null) { throw new ContractException("Context Planning seal is required."); }
            contextSeal.Validate(task, results[0], semanticModel);

            if (results.Count >= 2)
            {
                AgentDecision expectedGuardDecision = GuardAgent.ExpectedDecision(task);
                if (results[1].Decision != expectedGuardDecision)
                {
                    throw new ContractException("Guard decision does not match replayed policy.");
                }
                RequirePayload(results[1], GuardAgent.ExpectedPayload(task, expectedGuardDecision));
            }
            if (results.Count >= 3)
            {
                if (results[1].Decision == AgentDecision.Deny)
                {
                    RequirePayload(results[2], AuditAgent.ExpectedPayload("DENIED"));
                }
                else
                {
                    RequirePayload(results[2], OperationsAgent.ExpectedPayload(results[1], semanticModel));
                }
            }
            if (results.Count >= 4)
            {
                RequirePayload(results[3], VerificationAgent.ExpectedPayload(results[2]));
            }
            if (results.Count == 5)
            {
                RequirePayload(results[4], AuditAgent.ExpectedPayload("PASS"));
            }
        }

        internal static void ValidateChain(TaskEnvelope task, IList<AgentResult> results)
        {
            ValidateChain(task, results, new DeterministicMockModel());
        }

        internal static void ValidateChain(TaskEnvelope task, IList<AgentResult> results, IModelProvider semanticModel)
        {
            ValidateSemanticPrefix(task, results, semanticModel);
            bool deniedComplete = results.Count == 3 && results[1].Decision == AgentDecision.Deny;
            bool allowedComplete = results.Count == 5 && results[1].Decision == AgentDecision.Allow;
            if (!deniedComplete && !allowedComplete) { throw new ContractException("Pipeline chain is incomplete."); }
        }

        internal static void ValidateContextChain(
            TaskEnvelope task,
            IList<AgentResult> results,
            IModelProvider semanticModel,
            ContextPlanningSeal contextSeal)
        {
            ValidateContextSemanticPrefix(task, results, semanticModel, contextSeal);
            bool deniedComplete = results.Count == 3 && results[1].Decision == AgentDecision.Deny;
            bool allowedComplete = results.Count == 5 && results[1].Decision == AgentDecision.Allow;
            if (!deniedComplete && !allowedComplete) { throw new ContractException("Context pipeline chain is incomplete."); }
        }

        private static void RequireRoleDecision(AgentResult result, AgentRole role, AgentDecision decision)
        {
            if (result.Role != role || result.Decision != decision)
            {
                throw new ContractException("Pipeline role or decision sequence is invalid.");
            }
        }

        private static void RequirePayload(AgentResult result, string expectedPayload)
        {
            if (!String.Equals(result.Payload, expectedPayload, StringComparison.Ordinal))
            {
                throw new ContractException("Agent payload does not match deterministic semantic replay.");
            }
        }
    }

#if EAIRA_LOCAL_OPERATOR_NATIVE || EAIRA_LOCAL_OPERATOR_TEST_SEAM
    internal enum OrchestrationRole { Planning = 1, Guard = 2, Operations = 3, Verification = 4, Audit = 5 }
    internal enum OrchestrationDecision { Candidate = 1, Allow = 2, Deny = 3, Completed = 4, Verified = 5, Failed = 6, Recorded = 7 }

    internal sealed class OrchestrationRoleResult
    {
        internal OrchestrationRole Role { get; private set; }
        internal OrchestrationDecision Decision { get; private set; }
        internal string RequestDigest { get; private set; }
        internal string RouteDigest { get; private set; }
        internal string PreviousResultDigest { get; private set; }
        internal int Depth { get; private set; }
        internal string EvidenceDigest { get; private set; }
        internal string ResultDigest { get; private set; }

        internal OrchestrationRoleResult(OrchestrationRole role, OrchestrationDecision decision, string requestDigest, string routeDigest, string previous, int depth, string evidence)
        {
            Role = role; Decision = decision; RequestDigest = requestDigest; RouteDigest = routeDigest;
            PreviousResultDigest = previous; Depth = depth; EvidenceDigest = evidence;
            ValidateFields(); ResultDigest = ComputeDigest();
        }
        private void ValidateFields()
        {
            ContractCodec.RequireHash(RequestDigest, "Orchestration request digest");
            ContractCodec.RequireHash(RouteDigest, "Orchestration route digest");
            ContractCodec.RequireHash(PreviousResultDigest, "Orchestration previous digest");
            ContractCodec.RequireHash(EvidenceDigest, "Orchestration evidence digest");
            if (Depth < 0 || Depth > 4) { throw new ContractException("Orchestration depth is invalid."); }
            if (Depth == 0 && PreviousResultDigest != ContractCodec.ZeroHash) { throw new ContractException("Planning must start at zero."); }
            if (Depth != 0 && PreviousResultDigest == ContractCodec.ZeroHash) { throw new ContractException("Non-planning result requires a predecessor."); }
        }
        private string ComputeDigest()
        {
            return ContractCodec.Sha256Hex("EAIRA_M5_SLICE1_ROLE_RESULT_V1\0" +
                ContractCodec.Field(((int)Role).ToString(CultureInfo.InvariantCulture)) + ContractCodec.Field(((int)Decision).ToString(CultureInfo.InvariantCulture)) +
                ContractCodec.Field(RequestDigest) + ContractCodec.Field(RouteDigest) + ContractCodec.Field(PreviousResultDigest) +
                ContractCodec.Field(Depth.ToString(CultureInfo.InvariantCulture)) + ContractCodec.Field(EvidenceDigest));
        }
        internal void ValidateIntegrity()
        {
            ValidateFields(); ContractCodec.RequireHash(ResultDigest, "Orchestration result digest");
            if (!String.Equals(ResultDigest, ComputeDigest(), StringComparison.Ordinal)) { throw new ContractException("Orchestration result digest mismatch."); }
        }
    }

    internal sealed class OrchestrationChain
    {
        private readonly List<OrchestrationRoleResult> results;
        internal IList<OrchestrationRoleResult> Results { get { return results.AsReadOnly(); } }
        internal string ChainDigest { get { return results[results.Count - 1].ResultDigest; } }
        private OrchestrationChain(List<OrchestrationRoleResult> value) { results = value; Validate(); }

        private static string Evidence(string domain, string request, string route, string previous, string status, string subject)
        {
            return ContractCodec.Sha256Hex(domain + "\0" + ContractCodec.Field(request) + ContractCodec.Field(route) +
                ContractCodec.Field(previous) + ContractCodec.Field(status) + ContractCodec.Field(subject));
        }
        private static void Add(List<OrchestrationRoleResult> list, OrchestrationRole role, OrchestrationDecision decision,
            string request, string route, string domain, string status, string subject)
        {
            string previous = list.Count == 0 ? ContractCodec.ZeroHash : list[list.Count - 1].ResultDigest;
            string evidence = Evidence(domain, request, route, previous, status, subject);
            list.Add(new OrchestrationRoleResult(role, decision, request, route, previous, list.Count, evidence));
        }
        private static List<OrchestrationRoleResult> Prefix(string request, string route, bool allow)
        {
            ContractCodec.RequireHash(request, "Orchestration request digest"); ContractCodec.RequireHash(route, "Orchestration route digest");
            List<OrchestrationRoleResult> list = new List<OrchestrationRoleResult>();
            Add(list, OrchestrationRole.Planning, OrchestrationDecision.Candidate, request, route,
                "EAIRA_M5_SLICE1_PLANNING_EVIDENCE_V1", "CANDIDATE", route);
            Add(list, OrchestrationRole.Guard, allow ? OrchestrationDecision.Allow : OrchestrationDecision.Deny, request, route,
                "EAIRA_M5_SLICE1_GUARD_EVIDENCE_V1", allow ? "ALLOW" : "DENY", request);
            return list;
        }
        private static void Audit(List<OrchestrationRoleResult> list, string request, string route, string status)
        {
            string prior = list[list.Count - 1].ResultDigest;
            Add(list, OrchestrationRole.Audit, OrchestrationDecision.Recorded, request, route,
                "EAIRA_M5_SLICE1_AUDIT_EVIDENCE_V1", status, prior);
        }
        internal static OrchestrationChain Denied(string request, string route)
        {
            List<OrchestrationRoleResult> list = Prefix(request, route, false); Audit(list, request, route, "DENIED"); return new OrchestrationChain(list);
        }
        internal static OrchestrationChain Success(string request, string route, string payload)
        {
            ContractCodec.RequireHash(payload, "Payload digest"); List<OrchestrationRoleResult> list = Prefix(request, route, true);
            Add(list, OrchestrationRole.Operations, OrchestrationDecision.Completed, request, route,
                "EAIRA_M5_SLICE1_OPERATIONS_EVIDENCE_V1", "COMPLETED", payload);
            Add(list, OrchestrationRole.Verification, OrchestrationDecision.Verified, request, route,
                "EAIRA_M5_SLICE1_VERIFICATION_EVIDENCE_V1", "VERIFIED", payload);
            Audit(list, request, route, "PASS"); return new OrchestrationChain(list);
        }

        internal static OrchestrationChain OperationFailure(string request, string route, string status)
        {
            RequireFailureStatus(status); List<OrchestrationRoleResult> list = Prefix(request, route, true);
            Add(list, OrchestrationRole.Operations, OrchestrationDecision.Failed, request, route,
                "EAIRA_M5_SLICE1_OPERATIONS_EVIDENCE_V1", status, "NONE");
            Audit(list, request, route, status); return new OrchestrationChain(list);
        }
        internal static OrchestrationChain VerificationFailure(string request, string route, string status, string payload)
        {
            if (status != "QA_VALIDATION_ERROR" && status != "OUTPUT_ERROR") { throw new ContractException("Verification failure status is invalid."); }
            string subject = payload == null ? "NONE" : payload; if (payload != null) { ContractCodec.RequireHash(payload, "Payload digest"); }
            List<OrchestrationRoleResult> list = Prefix(request, route, true);
            Add(list, OrchestrationRole.Operations, OrchestrationDecision.Completed, request, route,
                "EAIRA_M5_SLICE1_OPERATIONS_EVIDENCE_V1", "COMPLETED", subject);
            Add(list, OrchestrationRole.Verification, OrchestrationDecision.Failed, request, route,
                "EAIRA_M5_SLICE1_VERIFICATION_EVIDENCE_V1", status, subject);
            Audit(list, request, route, status); return new OrchestrationChain(list);
        }
        internal static OrchestrationChain Emergency(string request, string route)
        {
            List<OrchestrationRoleResult> list = Prefix(request, route, true); Audit(list, request, route, "ORCHESTRATION_ERROR"); return new OrchestrationChain(list);
        }
        private static void RequireFailureStatus(string status)
        {
            if (status != "PROVIDER_ERROR" && status != "CONTEXT_ERROR" && status != "KNOWLEDGE_ERROR" && status != "QA_VALIDATION_ERROR")
            { throw new ContractException("Operation failure status is invalid."); }
        }
        internal void Validate()
        {
            if (results == null || (results.Count != 3 && results.Count != 4 && results.Count != 5)) { throw new ContractException("Orchestration chain length is invalid."); }
            string previous = ContractCodec.ZeroHash;
            for (int i = 0; i < results.Count; i++)
            {
                OrchestrationRoleResult r = results[i]; r.ValidateIntegrity();
                if (r.Depth != i || r.PreviousResultDigest != previous) { throw new ContractException("Orchestration chain link mismatch."); }
                previous = r.ResultDigest;
            }
            if (results[0].Role != OrchestrationRole.Planning || results[0].Decision != OrchestrationDecision.Candidate ||
                results[1].Role != OrchestrationRole.Guard) { throw new ContractException("Orchestration prefix is invalid."); }
            if (results[1].Decision == OrchestrationDecision.Deny)
            {
                if (results.Count != 3 || results[2].Role != OrchestrationRole.Audit) { throw new ContractException("Denied chain is invalid."); }
                return;
            }
            if (results[1].Decision != OrchestrationDecision.Allow || results[results.Count - 1].Role != OrchestrationRole.Audit) { throw new ContractException("Allowed chain is invalid."); }
            if (results.Count == 3) { return; }
            if (results[2].Role != OrchestrationRole.Operations) { throw new ContractException("Operations role is absent."); }
            if (results.Count == 4 && results[2].Decision != OrchestrationDecision.Failed) { throw new ContractException("Operation failure chain is invalid."); }
            if (results.Count == 5 && (results[3].Role != OrchestrationRole.Verification ||
                (results[3].Decision != OrchestrationDecision.Verified && results[3].Decision != OrchestrationDecision.Failed)))
            { throw new ContractException("Verification chain is invalid."); }
        }

        internal void ValidateFor(string request, string route, string status, string payload)
        {
            Validate();
            ContractCodec.RequireHash(request, "Orchestration request digest");
            ContractCodec.RequireHash(route, "Orchestration route digest");
            for (int i = 0; i < results.Count; i++)
            {
                if (!String.Equals(results[i].RequestDigest, request, StringComparison.Ordinal) ||
                    !String.Equals(results[i].RouteDigest, route, StringComparison.Ordinal))
                { throw new ContractException("Orchestration request or route binding mismatch."); }
            }

            OrchestrationChain expected;
            if (status == "PASS") { expected = Success(request, route, payload); }
            else if (status == "DENIED") { expected = Denied(request, route); }
            else if (status == "ORCHESTRATION_ERROR") { expected = Emergency(request, route); }
            else if (status == "OUTPUT_ERROR") { expected = VerificationFailure(request, route, status, payload); }
            else if (status == "QA_VALIDATION_ERROR" && results.Count == 5) { expected = VerificationFailure(request, route, status, payload); }
            else { expected = OperationFailure(request, route, status); }

            if (results.Count != expected.results.Count) { throw new ContractException("Orchestration terminal binding mismatch."); }
            for (int i = 0; i < results.Count; i++)
            {
                if (!String.Equals(results[i].ResultDigest, expected.results[i].ResultDigest, StringComparison.Ordinal))
                { throw new ContractException("Orchestration terminal digest mismatch."); }
            }
        }
    }
#endif

    internal static class FunctionalSliceSelfTest
    {
        internal static bool ForRole(string roleName)
        {
            TaskEnvelope task = TaskEnvelope.Create(1, "00112233445566778899AABBCCDDEEFF", "prepare bounded release plan");
            PipelineResult first = new MinimumFunctionalPipeline().Execute(task);
            PipelineResult second = new MinimumFunctionalPipeline().Execute(task);
            if (first.Outcome != "PASS" || first.ToCanonicalJson() != second.ToCanonicalJson() || first.Results.Count != 5) { return false; }
            for (int index = 0; index < first.Results.Count; index++)
            {
                if (String.Equals(first.Results[index].Role.ToString(), roleName, StringComparison.Ordinal)) { return true; }
            }
            return false;
        }
    }
}
