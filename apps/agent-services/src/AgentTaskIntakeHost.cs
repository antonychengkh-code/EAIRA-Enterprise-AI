using System;
using EAIRA.AgentServices.Functional;

namespace EAIRA.AgentServices.TaskIntake
{
    internal static class AgentTaskIntakeHost
    {
        internal static int Main(string[] args)
        {
            try
            {
                TaskIntakeResponse response = new LocalTaskIntake().Execute(args);
                Console.WriteLine(response.ToCanonicalJson());
                return response.ExitCode;
            }
            catch (ContractException exception)
            {
                Console.WriteLine("{\"schemaVersion\":1,\"status\":\"INVALID_REQUEST\",\"errorType\":" + ContractCodec.Json(exception.GetType().Name) + ",\"network\":\"NONE\",\"writes\":\"NONE\"}");
                return 64;
            }
        }
    }
}
