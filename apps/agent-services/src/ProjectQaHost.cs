using System;

namespace EAIRA.AgentServices.Functional
{
#if EAIRA_PROJECT_QA_NATIVE
    internal static class ProjectQaHost
    {
        internal static int Main(string[] args)
        {
            ProjectQaRunResult result = ProjectQaRunner.ExecuteNative(args);
            byte[] bytes = result.CompleteLegacyLine;
            Console.OpenStandardOutput().Write(bytes, 0, bytes.Length);
            return result.ExitCode;
        }
    }
#endif
}
