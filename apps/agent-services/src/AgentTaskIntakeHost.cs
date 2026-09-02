using System;
using EAIRA.AgentServices.Functional;

namespace EAIRA.AgentServices.TaskIntake
{
    internal sealed class CliLocalModelProviderFactory : ILocalModelProviderFactory
    {
        public IModelProvider Create(string exactModelName)
        {
            if (!String.Equals(exactModelName, LocalModelProvider.ExactModelName, StringComparison.Ordinal))
            {
                throw new ContractException("Local model selection is invalid.");
            }
            return new LocalModelProvider(
                new OllamaLoopbackTransport(),
                LocalModelProvider.ExactModelName,
                LocalModelProvider.ExactModelDigest);
        }
    }

    internal static class AgentTaskIntakeHost
    {
        internal static int Main(string[] args)
        {
            try
            {
                TaskIntakeResponse response = new LocalTaskIntake(new CliLocalModelProviderFactory()).Execute(args);
                Console.WriteLine(response.ToCanonicalJson());
                return response.ExitCode;
            }
            catch (LocalProviderException)
            {
                Console.WriteLine(LocalProviderFailureContract.CanonicalJson);
                return LocalProviderFailureContract.ExitCode;
            }
            catch (ContractException exception)
            {
                Console.WriteLine("{\"schemaVersion\":1,\"status\":\"INVALID_REQUEST\",\"errorType\":" + ContractCodec.Json(exception.GetType().Name) + ",\"network\":\"NONE\",\"writes\":\"NONE\"}");
                return 64;
            }
        }
    }
}
