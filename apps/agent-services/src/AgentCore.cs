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

    internal sealed class ContractException : Exception
    {
        internal ContractException(string message) : base(message) { }
    }

    internal static class ContractCodec
    {
        internal const string ZeroHash = "0000000000000000000000000000000000000000000000000000000000000000";

        internal static string Sha256Hex(string value)
        {
            using (SHA256 algorithm = SHA256.Create())
            {
                byte[] digest = algorithm.ComputeHash(Encoding.UTF8.GetBytes(value));
                StringBuilder builder = new StringBuilder(64);
                for (int index = 0; index < digest.Length; index++)
                {
                    builder.Append(digest[index].ToString("X2", CultureInfo.InvariantCulture));
                }
                return builder.ToString();
            }
        }

        internal static string Field(string value)
        {
            if (value == null) { throw new ContractException("Canonical field cannot be null."); }
            return value.Length.ToString(CultureInfo.InvariantCulture) + ":" + value;
        }

        internal static string Json(string value)
        {
            if (value == null) { return "null"; }
            StringBuilder builder = new StringBuilder(value.Length + 2);
            builder.Append('"');
            for (int index = 0; index < value.Length; index++)
            {
                char character = value[index];
                switch (character)
                {
                    case '"': builder.Append("\\\""); break;
                    case '\\': builder.Append("\\\\"); break;
                    case '\b': builder.Append("\\b"); break;
                    case '\f': builder.Append("\\f"); break;
                    case '\n': builder.Append("\\n"); break;
                    case '\r': builder.Append("\\r"); break;
                    case '\t': builder.Append("\\t"); break;
                    default:
                        if (character < 0x20)
                        {
                            builder.Append("\\u");
                            builder.Append(((int)character).ToString("X4", CultureInfo.InvariantCulture));
                        }
                        else
                        {
                            builder.Append(character);
                        }
                        break;
                }
            }
            builder.Append('"');
            return builder.ToString();
        }

        internal static void RequireHash(string value, string fieldName)
        {
            if (value == null || value.Length != 64) { throw new ContractException(fieldName + " must be SHA-256 hex."); }
            for (int index = 0; index < value.Length; index++)
            {
                char character = value[index];
                bool valid = (character >= '0' && character <= '9') || (character >= 'A' && character <= 'F');
                if (!valid) { throw new ContractException(fieldName + " must use uppercase SHA-256 hex."); }
            }
        }
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

    internal sealed class DeterministicMockModel
    {
        internal string Complete(AgentRole role, string prompt)
        {
            if (String.IsNullOrEmpty(prompt)) { throw new ContractException("Mock prompt cannot be empty."); }
            string digest = ContractCodec.Sha256Hex("EAIRA_DETERMINISTIC_MOCK_V1\0" + ContractCodec.Field(role.ToString()) + ContractCodec.Field(prompt));
            return "MOCK_" + role.ToString().ToUpperInvariant() + "_" + digest.Substring(0, 24);
        }
    }

    internal sealed class PlanningAgent
    {
        private readonly DeterministicMockModel model;

        internal PlanningAgent(DeterministicMockModel model) { this.model = model; }

        internal AgentResult Execute(TaskEnvelope task)
        {
            if (task == null) { throw new ContractException("Planning task is required."); }
            task.ValidateIntegrity();
            string payload = ExpectedPayload(task, model);
            return new AgentResult(AgentRole.Planning, AgentDecision.Candidate, task.TaskDigest, ContractCodec.ZeroHash, 0, payload);
        }

        internal static string ExpectedPayload(TaskEnvelope task, DeterministicMockModel deterministicModel)
        {
            if (task == null || deterministicModel == null) { throw new ContractException("Planning semantic inputs are required."); }
            return "PLAN_CANDIDATE|" + deterministicModel.Complete(AgentRole.Planning, task.Goal) + "|STEPS=3";
        }
    }

    internal sealed class GuardAgent
    {
        private static readonly string[] ProhibitedTerms = new string[]
        {
            "NETWORK", "WRITE", "IPC", "CHILD_PROCESS", "SHELL", "CREDENTIAL", "SECRET"
        };

        internal AgentResult Execute(TaskEnvelope task, AgentResult planning)
        {
            MinimumFunctionalPipeline.ValidateSemanticPrefix(task, new AgentResult[] { planning });
            AgentDecision decision = ExpectedDecision(task);
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
        private readonly DeterministicMockModel model;

        internal OperationsAgent(DeterministicMockModel model) { this.model = model; }

        internal AgentResult Execute(TaskEnvelope task, AgentResult planning, AgentResult guard)
        {
            MinimumFunctionalPipeline.ValidateSemanticPrefix(task, new AgentResult[] { planning, guard });
            if (guard.Decision != AgentDecision.Allow) { throw new ContractException("Operations requires a Guard allow result."); }
            string payload = ExpectedPayload(guard, model);
            return new AgentResult(AgentRole.Operations, AgentDecision.Candidate, task.TaskDigest, guard.ResultDigest, 2, payload);
        }

        internal static string ExpectedPayload(AgentResult guard, DeterministicMockModel deterministicModel)
        {
            if (guard == null || deterministicModel == null) { throw new ContractException("Operations semantic inputs are required."); }
            return "ACTION_CANDIDATE|" + deterministicModel.Complete(AgentRole.Operations, guard.ResultDigest) + "|MUTATION=NONE";
        }
    }

    internal sealed class VerificationAgent
    {
        internal AgentResult Execute(TaskEnvelope task, AgentResult planning, AgentResult guard, AgentResult operations)
        {
            MinimumFunctionalPipeline.ValidateSemanticPrefix(task, new AgentResult[] { planning, guard, operations });
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
        internal AgentResult Execute(TaskEnvelope task, IList<AgentResult> priorResults, string outcome)
        {
            MinimumFunctionalPipeline.ValidateSemanticPrefix(task, priorResults);
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

    internal sealed class MinimumFunctionalPipeline
    {
        private readonly DeterministicMockModel model = new DeterministicMockModel();

        internal PipelineResult Execute(TaskEnvelope task)
        {
            if (task == null) { throw new ContractException("Pipeline task is required."); }
            task.ValidateIntegrity();
            List<AgentResult> results = new List<AgentResult>();
            AgentResult planning = new PlanningAgent(model).Execute(task);
            results.Add(planning);
            AgentResult guard = new GuardAgent().Execute(task, planning);
            results.Add(guard);

            if (guard.Decision == AgentDecision.Deny)
            {
                results.Add(new AuditAgent().Execute(task, results, "DENIED"));
                ValidateChain(task, results);
                return new PipelineResult(task.TraceId, "DENIED", results);
            }

            AgentResult operations = new OperationsAgent(model).Execute(task, planning, guard);
            results.Add(operations);
            AgentResult verification = new VerificationAgent().Execute(task, planning, guard, operations);
            results.Add(verification);
            results.Add(new AuditAgent().Execute(task, results, "PASS"));
            ValidateChain(task, results);
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

        internal static void ValidateSemanticPrefix(TaskEnvelope task, IList<AgentResult> results)
        {
            ValidatePrefix(task, results);
            DeterministicMockModel semanticModel = new DeterministicMockModel();
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

        internal static void ValidateChain(TaskEnvelope task, IList<AgentResult> results)
        {
            ValidateSemanticPrefix(task, results);
            bool deniedComplete = results.Count == 3 && results[1].Decision == AgentDecision.Deny;
            bool allowedComplete = results.Count == 5 && results[1].Decision == AgentDecision.Allow;
            if (!deniedComplete && !allowedComplete) { throw new ContractException("Pipeline chain is incomplete."); }
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
