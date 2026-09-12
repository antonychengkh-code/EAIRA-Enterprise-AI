using System;
using System.IO;

namespace EAIRA.AgentServices.Functional
{
#if EAIRA_LOCAL_OPERATOR_NATIVE
    internal static class LocalOperatorHost
    {
        internal static int Main(string[] args)
        {
            LocalOperatorExecutionResult result = new LocalOperatorRunner(new LocalOperatorNativeAdapterFactory()).Execute(args);
            byte[] bytes = result.Bytes;
            Stream output = Console.OpenStandardOutput();
            output.Write(bytes, 0, bytes.Length);
            return result.ExitCode;
        }
    }
#endif
}
