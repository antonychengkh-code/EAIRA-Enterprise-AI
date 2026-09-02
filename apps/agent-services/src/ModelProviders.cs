using System;

namespace EAIRA.AgentServices.Functional
{
    internal interface IModelProvider
    {
        string ProviderId { get; }
        bool IsExternal { get; }
        bool IsExecutionEnabled { get; }
        string Complete(AgentRole role, string prompt);
    }

    internal interface IRequestLifecycleModelProvider
    {
        void BeginRequest();
        void EndRequest();
    }

    internal interface ILocalProviderObservations
    {
        int TagsCalls { get; }
        int ChatCalls { get; }
        bool PreflightDigestValidated { get; }
        bool PostflightDigestValidated { get; }
    }

    internal static class ModelProviderPolicy
    {
        internal static IModelProvider RequireEnabled(IModelProvider provider)
        {
            if (provider == null) { throw new ContractException("Model provider is required."); }
            if (!provider.IsExecutionEnabled) { throw new ContractException("Selected model provider is disabled by policy."); }
            if (provider.IsExternal) { throw new ContractException("External model-provider execution is not authorized."); }
            return provider;
        }
    }

    internal sealed class DeterministicMockModel : IModelProvider
    {
        public string ProviderId { get { return "mock-v1"; } }
        public bool IsExternal { get { return false; } }
        public bool IsExecutionEnabled { get { return true; } }

        public string Complete(AgentRole role, string prompt)
        {
            if (String.IsNullOrEmpty(prompt)) { throw new ContractException("Mock prompt cannot be empty."); }
            string digest = ContractCodec.Sha256Hex("EAIRA_DETERMINISTIC_MOCK_V1\0" + ContractCodec.Field(role.ToString()) + ContractCodec.Field(prompt));
            return "MOCK_" + role.ToString().ToUpperInvariant() + "_" + digest.Substring(0, 24);
        }
    }

    internal sealed class DisabledExternalModelProvider : IModelProvider
    {
        public string ProviderId { get { return "real-disabled-v1"; } }
        public bool IsExternal { get { return true; } }
        public bool IsExecutionEnabled { get { return false; } }

        public string Complete(AgentRole role, string prompt)
        {
            throw new ContractException("External model-provider execution is not authorized.");
        }
    }

    internal static class ModelProviderSelector
    {
        internal static IModelProvider Select(string providerName)
        {
            if (String.Equals(providerName, "mock", StringComparison.Ordinal)) { return new DeterministicMockModel(); }
            if (String.Equals(providerName, "real", StringComparison.Ordinal)) { return new DisabledExternalModelProvider(); }
            throw new ContractException("Unknown model provider.");
        }
    }
}
