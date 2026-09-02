using System;

namespace EAIRA.AgentServices.Functional
{
    internal sealed class LocalTaskRequest
    {
        internal string ProviderName { get; private set; }
        internal string TraceId { get; private set; }
        internal string Goal { get; private set; }

        private LocalTaskRequest(string providerName, string traceId, string goal)
        {
            ProviderName = providerName;
            TraceId = traceId;
            Goal = goal;
        }

        internal static LocalTaskRequest Parse(string[] args)
        {
            if (args == null || args.Length != 6) { throw new ContractException("Local task intake requires exactly six arguments."); }
            if (!String.Equals(args[0], "--provider", StringComparison.Ordinal) ||
                !String.Equals(args[2], "--trace", StringComparison.Ordinal) ||
                !String.Equals(args[4], "--goal", StringComparison.Ordinal))
            {
                throw new ContractException("Local task intake argument order is invalid.");
            }
            if (String.IsNullOrEmpty(args[1]) || String.IsNullOrEmpty(args[3]) || String.IsNullOrEmpty(args[5]))
            {
                throw new ContractException("Local task intake values cannot be empty.");
            }
            return new LocalTaskRequest(args[1], args[3], args[5]);
        }
    }

    internal sealed class TaskIntakeResponse
    {
        internal string Status { get; private set; }
        internal string ProviderId { get; private set; }
        internal string TraceId { get; private set; }
        internal string Outcome { get; private set; }
        internal PipelineResult Pipeline { get; private set; }
        internal int ExitCode { get; private set; }

        internal TaskIntakeResponse(string status, string providerId, string traceId, string outcome, PipelineResult pipeline, int exitCode)
        {
            Status = status;
            ProviderId = providerId;
            TraceId = traceId;
            Outcome = outcome;
            Pipeline = pipeline;
            ExitCode = exitCode;
        }

        internal string ToCanonicalJson()
        {
            return "{\"schemaVersion\":1,\"status\":" + ContractCodec.Json(Status) +
                   ",\"provider\":" + ContractCodec.Json(ProviderId) +
                   ",\"traceId\":" + ContractCodec.Json(TraceId) +
                   ",\"outcome\":" + ContractCodec.Json(Outcome) +
                   ",\"network\":\"NONE\",\"writes\":\"NONE\",\"result\":" +
                   (Pipeline == null ? "null" : Pipeline.ToCanonicalJson()) + "}";
        }
    }

    internal sealed class LocalTaskIntake
    {
        internal TaskIntakeResponse Execute(string[] args)
        {
            LocalTaskRequest request = LocalTaskRequest.Parse(args);
            TaskEnvelope task = TaskEnvelope.Create(TaskEnvelope.CurrentSchemaVersion, request.TraceId, request.Goal);
            IModelProvider provider = ModelProviderSelector.Select(request.ProviderName);

            if (!provider.IsExecutionEnabled || provider.IsExternal)
            {
                return new TaskIntakeResponse("PROVIDER_BLOCKED", provider.ProviderId, task.TraceId, "NONE", null, 78);
            }

            PipelineResult result = new MinimumFunctionalPipeline(provider).Execute(task);
            if (String.Equals(result.Outcome, "DENIED", StringComparison.Ordinal))
            {
                return new TaskIntakeResponse("DENIED", provider.ProviderId, task.TraceId, result.Outcome, result, 77);
            }
            return new TaskIntakeResponse("PASS", provider.ProviderId, task.TraceId, result.Outcome, result, 0);
        }
    }
}
