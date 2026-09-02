using System;

namespace EAIRA.AgentServices.Functional
{
    internal static class LocalProviderFailureContract
    {
        internal const int ExitCode = 79;
        internal const string CanonicalJson = "{\"schemaVersion\":1,\"status\":\"LOCAL_PROVIDER_ERROR\",\"errorType\":\"LocalProviderException\",\"network\":\"LOOPBACK_ONLY\",\"writes\":\"NONE\"}";
    }

    internal interface ILocalModelProviderFactory
    {
        IModelProvider Create(string exactModelName);
    }

    internal sealed class LocalTaskRequest
    {
        internal string ProviderName { get; private set; }
        internal string ModelName { get; private set; }
        internal string TraceId { get; private set; }
        internal string Goal { get; private set; }

        private LocalTaskRequest(string providerName, string modelName, string traceId, string goal)
        {
            ProviderName = providerName;
            ModelName = modelName;
            TraceId = traceId;
            Goal = goal;
        }

        internal static LocalTaskRequest Parse(string[] args)
        {
            if (args == null) { throw new ContractException("Local task intake arguments are required."); }
            if (args.Length == 6 &&
                String.Equals(args[0], "--provider", StringComparison.Ordinal) &&
                String.Equals(args[2], "--trace", StringComparison.Ordinal) &&
                String.Equals(args[4], "--goal", StringComparison.Ordinal))
            {
                if (String.IsNullOrEmpty(args[1]) || String.IsNullOrEmpty(args[3]) || String.IsNullOrEmpty(args[5]))
                {
                    throw new ContractException("Local task intake values cannot be empty.");
                }
                if (String.Equals(args[1], "ollama-local", StringComparison.Ordinal))
                {
                    throw new ContractException("The local provider requires an exact model argument.");
                }
                return new LocalTaskRequest(args[1], null, args[3], args[5]);
            }

            if (args.Length == 8 &&
                String.Equals(args[0], "--provider", StringComparison.Ordinal) &&
                String.Equals(args[2], "--model", StringComparison.Ordinal) &&
                String.Equals(args[4], "--trace", StringComparison.Ordinal) &&
                String.Equals(args[6], "--goal", StringComparison.Ordinal))
            {
                if (!String.Equals(args[1], "ollama-local", StringComparison.Ordinal) ||
                    !String.Equals(args[3], "qwen3:4b", StringComparison.Ordinal) ||
                    String.IsNullOrEmpty(args[5]) || String.IsNullOrEmpty(args[7]))
                {
                    throw new ContractException("Local-provider arguments are invalid.");
                }
                return new LocalTaskRequest(args[1], args[3], args[5], args[7]);
            }

            throw new ContractException("Local task intake argument count or order is invalid.");
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
        internal string Network { get; private set; }
        internal int? TagsCalls { get; private set; }
        internal int? ChatCalls { get; private set; }
        internal bool? PreflightDigestValidated { get; private set; }
        internal bool? PostflightDigestValidated { get; private set; }

        internal TaskIntakeResponse(string status, string providerId, string traceId, string outcome, PipelineResult pipeline, int exitCode, string network)
            : this(status, providerId, traceId, outcome, pipeline, exitCode, network, null)
        {
        }

        internal TaskIntakeResponse(string status, string providerId, string traceId, string outcome, PipelineResult pipeline, int exitCode, string network, ILocalProviderObservations observations)
        {
            Status = status;
            ProviderId = providerId;
            TraceId = traceId;
            Outcome = outcome;
            Pipeline = pipeline;
            ExitCode = exitCode;
            Network = network;
            if (observations != null)
            {
                TagsCalls = observations.TagsCalls;
                ChatCalls = observations.ChatCalls;
                PreflightDigestValidated = observations.PreflightDigestValidated;
                PostflightDigestValidated = observations.PostflightDigestValidated;
            }
        }

        internal string ToCanonicalJson()
        {
            string observationJson = TagsCalls.HasValue
                ? ",\"providerObservations\":{\"tagsCalls\":" + TagsCalls.Value +
                  ",\"chatCalls\":" + ChatCalls.Value +
                  ",\"preflightDigestValidated\":" + PreflightDigestValidated.Value.ToString().ToLowerInvariant() +
                  ",\"postflightDigestValidated\":" + PostflightDigestValidated.Value.ToString().ToLowerInvariant() + "}"
                : String.Empty;
            return "{\"schemaVersion\":1,\"status\":" + ContractCodec.Json(Status) +
                   ",\"provider\":" + ContractCodec.Json(ProviderId) +
                   ",\"traceId\":" + ContractCodec.Json(TraceId) +
                   ",\"outcome\":" + ContractCodec.Json(Outcome) +
                   ",\"network\":" + ContractCodec.Json(Network) + ",\"writes\":\"NONE\",\"result\":" +
                   (Pipeline == null ? "null" : Pipeline.ToCanonicalJson()) + observationJson + "}";
        }
    }

    internal sealed class LocalTaskIntake
    {
        private readonly ILocalModelProviderFactory localFactory;

        internal LocalTaskIntake() : this(null) { }

        internal LocalTaskIntake(ILocalModelProviderFactory factory)
        {
            localFactory = factory;
        }

        internal TaskIntakeResponse Execute(string[] args)
        {
            LocalTaskRequest request = LocalTaskRequest.Parse(args);
            TaskEnvelope task = TaskEnvelope.Create(TaskEnvelope.CurrentSchemaVersion, request.TraceId, request.Goal);
            bool localSelection = String.Equals(request.ProviderName, "ollama-local", StringComparison.Ordinal);
            IModelProvider provider;

            if (localSelection)
            {
                if (localFactory == null) { throw new ContractException("Local provider construction is unavailable."); }
                provider = localFactory.Create(request.ModelName);
                if (provider == null ||
                    !String.Equals(provider.ProviderId, "ollama-loopback-v1", StringComparison.Ordinal) ||
                    !provider.IsExecutionEnabled || provider.IsExternal ||
                    !(provider is IRequestLifecycleModelProvider))
                {
                    throw new ContractException("Local provider construction violated policy.");
                }
            }
            else
            {
                provider = ModelProviderSelector.Select(request.ProviderName);
            }

            if (!provider.IsExecutionEnabled || provider.IsExternal)
            {
                return new TaskIntakeResponse("PROVIDER_BLOCKED", provider.ProviderId, task.TraceId, "NONE", null, 78, "NONE");
            }

            IDisposable disposable = provider as IDisposable;
            IRequestLifecycleModelProvider lifecycle = provider as IRequestLifecycleModelProvider;
            ILocalProviderObservations observations = provider as ILocalProviderObservations;
            try
            {
                if (lifecycle != null) { lifecycle.BeginRequest(); }
                PipelineResult result;
                try
                {
                    result = new MinimumFunctionalPipeline(provider).Execute(task);
                }
                finally
                {
                    if (lifecycle != null) { lifecycle.EndRequest(); }
                }
                string network = localSelection ? "LOOPBACK_ONLY" : "NONE";
                if (String.Equals(result.Outcome, "DENIED", StringComparison.Ordinal))
                {
                    return new TaskIntakeResponse("DENIED", provider.ProviderId, task.TraceId, result.Outcome, result, 77, network, observations);
                }
                return new TaskIntakeResponse("PASS", provider.ProviderId, task.TraceId, result.Outcome, result, 0, network, observations);
            }
            finally
            {
                if (disposable != null) { disposable.Dispose(); }
            }
        }
    }
}
