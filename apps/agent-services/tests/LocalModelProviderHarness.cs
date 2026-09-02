using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using EAIRA.AgentServices.Functional;

namespace EAIRA.AgentServices.Tests
{
    internal sealed class FakeByteTransport : ILocalByteTransport
    {
        private readonly Queue<byte[]> tags;
        private readonly Queue<byte[]> chats;
        internal int TagsCalls { get; private set; }
        internal int ChatCalls { get; private set; }
        internal bool Disposed { get; private set; }
        internal byte[] LastRequest { get; private set; }
        internal IList<CancellationToken> Tokens { get; private set; }

        internal FakeByteTransport(IEnumerable<byte[]> tagResponses, IEnumerable<byte[]> chatResponses)
        {
            tags = new Queue<byte[]>(tagResponses);
            chats = new Queue<byte[]>(chatResponses);
            Tokens = new List<CancellationToken>();
        }

        public byte[] GetTags(CancellationToken cancellationToken)
        {
            cancellationToken.ThrowIfCancellationRequested();
            Tokens.Add(cancellationToken);
            TagsCalls++;
            if (tags.Count == 0) { throw new LocalProviderException(); }
            return tags.Dequeue();
        }

        public byte[] SendChat(byte[] canonicalRequest, CancellationToken cancellationToken)
        {
            cancellationToken.ThrowIfCancellationRequested();
            Tokens.Add(cancellationToken);
            ChatCalls++;
            LastRequest = canonicalRequest;
            if (chats.Count == 0) { throw new LocalProviderException(); }
            return chats.Dequeue();
        }

        public void Dispose() { Disposed = true; }
    }

    internal sealed class FakeLocalModelProviderFactory : ILocalModelProviderFactory
    {
        private readonly FakeByteTransport transport;
        internal LocalModelProvider Created { get; private set; }

        internal FakeLocalModelProviderFactory(FakeByteTransport fakeTransport) { transport = fakeTransport; }

        public IModelProvider Create(string exactModelName)
        {
            Created = new LocalModelProvider(
                transport,
                exactModelName,
                LocalModelProvider.ExactModelDigest);
            return Created;
        }
    }

    internal static class LocalModelProviderHarness
    {
        private static int passed;

        private static readonly string ExactDigest = LocalModelProvider.ExactModelDigest;

        private static byte[] Json(string value) { return new UTF8Encoding(false, true).GetBytes(value); }
        private static byte[] Tags()
        {
            return Json("{\"models\":[{\"name\":\"qwen3:4b\",\"digest\":\"" + ExactDigest + "\"}]}");
        }
        private static byte[] TagsDigest(string digest)
        {
            return Json("{\"models\":[{\"name\":\"qwen3:4b\",\"digest\":\"" + digest + "\"}]}");
        }
        private static byte[] Chat(string content)
        {
            return Json("{\"model\":\"qwen3:4b\",\"message\":{\"role\":\"assistant\",\"content\":" +
                        ContractCodec.Json(content) + "},\"done\":true}");
        }
        private static string[] LocalRequest(string trace, string goal)
        {
            return new string[] { "--provider", "ollama-local", "--model", "qwen3:4b", "--trace", trace, "--goal", goal };
        }
        private static void Require(bool condition, string name)
        {
            if (!condition) { throw new ContractException("Local-provider test failed: " + name); }
            passed++;
        }
        private static void RequireLocalFailure(Action action, string name)
        {
            bool failed = false;
            try { action(); }
            catch (LocalProviderException) { failed = true; }
            Require(failed, name);
        }
        private static LocalModelProvider Provider(FakeByteTransport transport)
        {
            return new LocalModelProvider(transport, LocalModelProvider.ExactModelName, ExactDigest);
        }

        private static void TestCanonicalRequests()
        {
            string planning = Encoding.UTF8.GetString(LocalModelProvider.BuildCanonicalRequest(
                AgentRole.Planning, "prepare bounded release plan"));
            Require(planning == "{\"model\":\"qwen3:4b\",\"messages\":[{\"role\":\"user\",\"content\":\"EAIRA_OUTPUT_POLICY=PLAIN_TEXT_MAX_128_UTF16_NO_EXPLANATION\\nEAIRA_AGENT_ROLE=Planning\\nPROMPT=prepare bounded release plan\"}],\"stream\":false,\"think\":false,\"options\":{\"temperature\":0,\"seed\":42,\"num_predict\":32}}",
                "Planning golden request bytes");

            string operations = Encoding.UTF8.GetString(LocalModelProvider.BuildCanonicalRequest(
                AgentRole.Operations, "ABCDEF"));
            Require(operations == "{\"model\":\"qwen3:4b\",\"messages\":[{\"role\":\"user\",\"content\":\"EAIRA_OUTPUT_POLICY=PLAIN_TEXT_MAX_128_UTF16_NO_EXPLANATION\\nEAIRA_AGENT_ROLE=Operations\\nPROMPT=ABCDEF\"}],\"stream\":false,\"think\":false,\"options\":{\"temperature\":0,\"seed\":42,\"num_predict\":32}}",
                "Operations golden request bytes");

            string escaped = Encoding.UTF8.GetString(LocalModelProvider.BuildCanonicalRequest(
                AgentRole.Planning, "a\"b\\c\t"));
            Require(escaped.IndexOf("PROMPT=a\\\"b\\\\c\\t", StringComparison.Ordinal) >= 0,
                "canonical JSON escaping");
            string supplementary = Encoding.UTF8.GetString(LocalModelProvider.BuildCanonicalRequest(
                AgentRole.Planning, "ok " + Char.ConvertFromUtf32(0x1F680)));
            Require(supplementary.IndexOf(Char.ConvertFromUtf32(0x1F680), StringComparison.Ordinal) >= 0,
                "supplementary Unicode preserved");
            RequireLocalFailure(
                delegate { LocalModelProvider.BuildCanonicalRequest(AgentRole.Guard, "x"); },
                "unsupported role rejected");
            int emptyLength = LocalModelProvider.BuildCanonicalRequest(AgentRole.Planning, String.Empty).Length;
            int exactPromptLength = 16384 - emptyLength;
            Require(LocalModelProvider.BuildCanonicalRequest(
                AgentRole.Planning, new string('x', exactPromptLength)).Length == 16384,
                "request exact 16 KiB accepted");
            RequireLocalFailure(
                delegate { LocalModelProvider.BuildCanonicalRequest(AgentRole.Planning, new string('x', exactPromptLength + 1)); },
                "request byte limit enforced");
        }

        private static void TestLifecycleFlows()
        {
            FakeByteTransport passTransport = new FakeByteTransport(
                new byte[][] { Tags(), Tags() },
                new byte[][] { Chat("plan"), Chat("action") });
            TaskIntakeResponse pass = new LocalTaskIntake(
                new FakeLocalModelProviderFactory(passTransport)).Execute(
                    LocalRequest("ABCDEF0123456789ABCDEF0123456789", "prepare bounded release plan"));
            Require(pass.ExitCode == 0 && pass.Status == "PASS" && pass.Network == "LOOPBACK_ONLY",
                "local PASS response");
            Require(passTransport.TagsCalls == 2 && passTransport.ChatCalls == 2,
                "PASS request counts four");
            Require(pass.TagsCalls == 2 && pass.ChatCalls == 2 &&
                    pass.PreflightDigestValidated == true && pass.PostflightDigestValidated == true &&
                    pass.ToCanonicalJson().IndexOf("\"providerObservations\":{\"tagsCalls\":2,\"chatCalls\":2,\"preflightDigestValidated\":true,\"postflightDigestValidated\":true}", StringComparison.Ordinal) >= 0,
                "PASS observations are canonical and verified");
            Require(passTransport.Tokens.Count == 4 &&
                    passTransport.Tokens[0].CanBeCanceled &&
                    passTransport.Tokens[0].Equals(passTransport.Tokens[1]) &&
                    passTransport.Tokens[0].Equals(passTransport.Tokens[2]) &&
                    passTransport.Tokens[0].Equals(passTransport.Tokens[3]),
                "single shared deadline token");
            Require(passTransport.Disposed, "PASS transport disposed");

            FakeByteTransport deniedTransport = new FakeByteTransport(
                new byte[][] { Tags(), Tags() },
                new byte[][] { Chat("plan") });
            TaskIntakeResponse denied = new LocalTaskIntake(
                new FakeLocalModelProviderFactory(deniedTransport)).Execute(
                    LocalRequest("1234567890ABCDEF1234567890ABCDEF", "write file"));
            Require(denied.ExitCode == 77 && denied.Status == "DENIED" && denied.Network == "LOOPBACK_ONLY",
                "local DENIED response");
            Require(deniedTransport.TagsCalls == 2 && deniedTransport.ChatCalls == 1,
                "DENIED request counts three");
            Require(denied.TagsCalls == 2 && denied.ChatCalls == 1 &&
                    denied.PreflightDigestValidated == true && denied.PostflightDigestValidated == true,
                "DENIED observations are verified");
            Require(deniedTransport.Disposed, "DENIED transport disposed");
            Require(LocalProviderFailureContract.ExitCode == 79 &&
                    LocalProviderFailureContract.CanonicalJson ==
                    "{\"schemaVersion\":1,\"status\":\"LOCAL_PROVIDER_ERROR\",\"errorType\":\"LocalProviderException\",\"network\":\"LOOPBACK_ONLY\",\"writes\":\"NONE\"}",
                "sanitized local-provider exit 79 contract");
        }

        private static void TestCacheAndTagFailures()
        {
            FakeByteTransport cacheTransport = new FakeByteTransport(
                new byte[][] { Tags(), Tags() },
                new byte[][] { Chat("one"), Chat("two") });
            using (LocalModelProvider provider = Provider(cacheTransport))
            {
                provider.BeginRequest();
                string first = provider.Complete(AgentRole.Planning, "a");
                string replay = provider.Complete(AgentRole.Planning, "a");
                provider.Complete(AgentRole.Operations, "b");
                Require(first == replay && cacheTransport.ChatCalls == 2, "two-entry request cache replay");
                RequireLocalFailure(
                    delegate { provider.Complete(AgentRole.Planning, "c"); },
                    "third distinct cache key rejected");
                provider.EndRequest();
            }
            Require(cacheTransport.TagsCalls == 2, "preflight and postflight exactly once");

            RequireLocalFailure(delegate
            {
                using (LocalModelProvider provider = Provider(new FakeByteTransport(
                    new byte[][] { Json("{\"models\":[]}"), Tags() }, new byte[0][])))
                {
                    provider.BeginRequest();
                }
            }, "missing selected tag rejected");

            RequireLocalFailure(delegate
            {
                byte[] duplicate = Json("{\"models\":[{\"name\":\"qwen3:4b\",\"digest\":\"" + ExactDigest +
                    "\"},{\"name\":\"qwen3:4b\",\"digest\":\"" + ExactDigest + "\"}]}");
                using (LocalModelProvider provider = Provider(new FakeByteTransport(
                    new byte[][] { duplicate }, new byte[0][]))) { provider.BeginRequest(); }
            }, "duplicate selected tag rejected");

            RequireLocalFailure(delegate
            {
                using (LocalModelProvider provider = Provider(new FakeByteTransport(
                    new byte[][] { TagsDigest(new string('0', 64)) }, new byte[0][]))) { provider.BeginRequest(); }
            }, "digest mismatch rejected");

            RequireLocalFailure(delegate
            {
                using (LocalModelProvider provider = Provider(new FakeByteTransport(
                    new byte[][] { Tags(), TagsDigest(new string('0', 64)) },
                    new byte[][] { Chat("one") })))
                {
                    provider.BeginRequest();
                    provider.Complete(AgentRole.Planning, "a");
                    provider.EndRequest();
                }
            }, "postflight digest change rejected");
        }

        private static void TestResponseFailures()
        {
            RequireChatFailure("{\"model\":\"wrong\",\"message\":{\"role\":\"assistant\",\"content\":\"x\"},\"done\":true}", "wrong response model");
            RequireChatFailure("{\"model\":\"qwen3:4b\",\"message\":{\"role\":\"user\",\"content\":\"x\"},\"done\":true}", "wrong response role");
            RequireChatFailure("{\"model\":\"qwen3:4b\",\"message\":{\"role\":\"assistant\",\"content\":\"x\"},\"done\":false}", "incomplete response");
            RequireChatFailure("{\"model\":\"qwen3:4b\",\"message\":{\"role\":\"assistant\",\"content\":\"\"},\"done\":true}", "empty output");
            RequireChatFailure("{\"model\":\"qwen3:4b\",\"model\":\"qwen3:4b\",\"message\":{\"role\":\"assistant\",\"content\":\"x\"},\"done\":true}", "duplicate JSON member");
            RequireChatFailure("{\"model\":\"qwen3:4b\",\"message\":{\"role\":\"assistant\",\"content\":\"x\",\"extra\":0},\"done\":true}", "unknown message member");
            RequireChatFailure("{\"model\":\"qwen3:4b\",\"message\":{\"role\":\"assistant\",\"content\":\"\\uD800\"},\"done\":true}", "unpaired surrogate escape");
            RequireChatFailureBytes(new byte[] { 0xEF, 0xBB, 0xBF, 0x7B, 0x7D }, "UTF-8 BOM rejected");
            RequireChatFailureBytes(new byte[] { 0x7B, 0x22, 0x78, 0x22, 0x3A, 0xC3, 0x28, 0x7D }, "invalid UTF-8 rejected");
            RequireChatFailureBytes(new byte[65537], "parser byte limit enforced");
        }

        private static void RequireChatFailure(string response, string name)
        {
            RequireChatFailureBytes(Json(response), name);
        }

        private static void RequireChatFailureBytes(byte[] response, string name)
        {
            RequireLocalFailure(delegate
            {
                using (LocalModelProvider provider = Provider(new FakeByteTransport(
                    new byte[][] { Tags(), Tags() }, new byte[][] { response })))
                {
                    provider.BeginRequest();
                    provider.Complete(AgentRole.Planning, "a");
                }
            }, name);
        }

        private static void TestNormalization()
        {
            Require(LocalModelProvider.NormalizeOutput("  a\t\r\n b  ") == "a b", "whitespace normalization");
            Require(LocalModelProvider.NormalizeOutput("x" + Char.ConvertFromUtf32(0x1F680)) ==
                    "x" + Char.ConvertFromUtf32(0x1F680), "valid surrogate pair preserved");
            RequireLocalFailure(delegate { LocalModelProvider.NormalizeOutput("a\u0001b"); }, "C0 control rejected");
            RequireLocalFailure(delegate { LocalModelProvider.NormalizeOutput("a\u0085b"); }, "C1 control rejected");
            Require(LocalModelProvider.NormalizeOutput(new string('x', 512)).Length == 512, "output exact 512 UTF-16 accepted");
            RequireLocalFailure(delegate { LocalModelProvider.NormalizeOutput(new string('x', 513)); }, "output limit enforced");
            RequireLocalFailure(delegate { LocalModelProvider.NormalizeOutput("   \r\n\t"); }, "empty normalized output rejected");
        }

        private static void RunAll()
        {
            TestCanonicalRequests();
            TestLifecycleFlows();
            TestCacheAndTagFailures();
            TestResponseFailures();
            TestNormalization();
        }

        internal static int Main(string[] args)
        {
            if (args == null || args.Length != 1 || !String.Equals(args[0], "--self-test", StringComparison.Ordinal)) { return 64; }
            try
            {
                RunAll();
                Console.WriteLine("{\"status\":\"PASS\",\"contract\":\"EAIRA_LOCAL_MODEL_PROVIDER_V1\",\"testsPassed\":" +
                    passed + ",\"network\":\"NONE\",\"writes\":\"NONE\",\"transport\":\"FAKE\"}");
                return 0;
            }
            catch (Exception exception)
            {
                Console.WriteLine("{\"status\":\"FAIL\",\"errorType\":" + ContractCodec.Json(exception.GetType().Name) + "}");
                return 70;
            }
        }
    }
}
