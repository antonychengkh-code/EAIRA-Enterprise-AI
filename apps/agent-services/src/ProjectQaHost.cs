using System;
using System.Text;

namespace EAIRA.AgentServices.Functional
{
#if EAIRA_PROJECT_QA_NATIVE
    internal sealed class ProjectQaNativeProviderFactory : IProjectQaProviderFactory
    {
        public IProjectQaProvider Create() { return new ProjectQaLocalProvider(new OllamaLoopbackTransport()); }
    }

    internal static class ProjectQaHost
    {
        internal static int Main(string[] args)
        {
            string output; int exit;
            try
            {
                ProjectQaRequest request = ProjectQaRequest.Parse(args);
                TaskEnvelope task;
                try { task = TaskEnvelope.Create(TaskEnvelope.CurrentSchemaVersion, request.TraceId, request.Question); }
                catch (Exception) { throw new ProjectQaException(); }
                if (GuardAgent.ExpectedDecision(task) != AgentDecision.Allow) { return EmitError("DENIED", "NONE", 77); }
                ProjectQaSnapshot snapshot = ProjectQaSnapshotReader.CreateNative().Read(request.Root, request.Question);
                string prompt;
                byte[] body;
                try
                {
                    prompt = ProjectQaPrompt.Build(request, snapshot);
                    body = ProjectQaPrompt.BuildBody(prompt);
                }
                catch (ProjectQaException) { return EmitError("PROJECT_QA_ERROR", "NONE", 82); }
                IProjectQaProvider provider = null;
                try
                {
                    provider = new ProjectQaNativeProviderFactory().Create();
                    string assistant = provider.Execute(body);
                    ProjectQaAnswer answer = ProjectQaAnswerDecoder.Decode(new UTF8Encoding(false, true).GetBytes(assistant), request, snapshot, prompt, body);
                    output = ProjectQaOutput.Success(request, snapshot, prompt, answer, provider);
                    exit = 0;
                }
                catch (ProjectQaException) { return EmitError("PROJECT_QA_ERROR", "LOOPBACK_ONLY", 82); }
                catch (Exception) { return EmitError("LOCAL_PROVIDER_ERROR", "LOOPBACK_ONLY", 79); }
                finally { if (provider != null) { try { provider.Dispose(); } catch (Exception) { } } }
            }
            catch (ProjectQaContextException) { return EmitError("CONTEXT_ERROR", "NONE", 80); }
            catch (ProjectQaKnowledgeException) { return EmitError("KNOWLEDGE_ERROR", "NONE", 81); }
            catch (ProjectQaException) { return EmitError("INVALID_REQUEST", "NONE", 64); }
            catch (ProjectKnowledgeRequestException) { return EmitError("INVALID_REQUEST", "NONE", 64); }
            Console.Out.Write(output); Console.Out.Write('\n'); return exit;
        }

        private static int EmitError(string status, string network, int exit)
        {
            Console.Out.Write("{\"schema\":\"EAIRA_PROJECT_QA_ERROR_V1\",\"status\":" + ContractCodec.Json(status) + ",\"network\":" + ContractCodec.Json(network) + ",\"writes\":\"NONE\"}\n"); return exit;
        }
    }
#endif
}
