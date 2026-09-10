using System;
using System.IO;
using System.Text;
using EAIRA.AgentServices.Functional;

namespace EAIRA.AgentServices.ProjectKnowledge
{
    internal static class ProjectKnowledgeHost
    {
        private const string Invalid = "{\"schema\":\"EAIRA_PROJECT_KNOWLEDGE_ERROR_V1\",\"status\":\"INVALID_REQUEST\",\"network\":\"NONE\",\"writes\":\"NONE\"}\n";
        private const string Failure = "{\"schema\":\"EAIRA_PROJECT_KNOWLEDGE_ERROR_V1\",\"status\":\"KNOWLEDGE_ERROR\",\"network\":\"NONE\",\"writes\":\"NONE\"}\n";
#if EAIRA_PROJECT_KNOWLEDGE_NATIVE
        internal static int Main(string[] args)
        {
            return RunCore(args, delegate { return ProjectKnowledgeQuery.CreateNative(); }, Write);
        }
#endif

        internal static int RunCore(string[] args, Func<ProjectKnowledgeQuery> factory, Action<string> write)
        {
            try
            {
                if (args == null || args.Length != 4 || args[0] != "--root" || args[2] != "--query") { write(Invalid); return 64; }
                string query = ProjectKnowledgeQuery.NormalizeQueryOrThrowRequest(args[3]);
                ProjectKnowledgeResult result = factory().Execute(args[1], query);
                write(ProjectKnowledgeQuery.CanonicalJsonOrThrow(result) + "\n"); return 0;
            }
            catch (ProjectKnowledgeRequestException) { write(Invalid); return 64; }
            catch (ProjectKnowledgeException) { write(Failure); return 81; }
            catch (Exception) { write(Failure); return 81; }
        }
#if EAIRA_PROJECT_KNOWLEDGE_NATIVE
        private static void Write(string value) { byte[] bytes = new UTF8Encoding(false, true).GetBytes(value); Stream output = Console.OpenStandardOutput(); output.Write(bytes, 0, bytes.Length); }
#endif
    }
}
