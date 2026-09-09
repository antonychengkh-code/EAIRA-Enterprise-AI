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
                TaskIntakeResponse response = LocalTaskIntake.CreateNative(new CliLocalModelProviderFactory()).Execute(args);
                Console.WriteLine(response.ToCanonicalJson());
                return response.ExitCode;
            }
            catch (LocalProviderException)
            {
                Console.WriteLine(LocalProviderFailureContract.CanonicalJson);
                return LocalProviderFailureContract.ExitCode;
            }
            catch (ProjectContextException)
            {
                Console.WriteLine("{\"schemaVersion\":1,\"status\":\"CONTEXT_ERROR\",\"errorType\":\"ProjectContextException\",\"network\":\"NONE\",\"writes\":\"NONE\",\"context\":null}");
                return 80;
            }
            catch (ContractException)
            {
                Console.WriteLine("{\"schemaVersion\":1,\"status\":\"INVALID_REQUEST\",\"errorType\":\"ContractException\",\"network\":\"NONE\",\"writes\":\"NONE\"}");
                return 64;
            }
        }
    }
}
