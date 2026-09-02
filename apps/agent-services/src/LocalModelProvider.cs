using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Threading;

namespace EAIRA.AgentServices.Functional
{
    internal sealed class LocalProviderException : Exception
    {
        internal LocalProviderException() : base("Local provider failed.") { }
    }

    internal interface ILocalByteTransport : IDisposable
    {
        byte[] GetTags(CancellationToken cancellationToken);
        byte[] SendChat(byte[] canonicalRequest, CancellationToken cancellationToken);
    }

    internal sealed class LocalModelProvider : IModelProvider, IRequestLifecycleModelProvider, ILocalProviderObservations, IDisposable
    {
        internal const string ExactModelName = "qwen3:4b";
        internal const string ExactModelDigest = "359d7dd4bcdab3d86b87d73ac27966f4dbb9f5efdfcc75d34a8764a09474fae7";
        private const int MaximumRequestBytes = 16384;
        private const int MaximumOutputCodeUnits = 512;

        private readonly ILocalByteTransport transport;
        private readonly string modelName;
        private readonly string modelDigest;
        private readonly Dictionary<string, string> cache;
        private CancellationTokenSource deadline;
        private bool began;
        private bool ended;
        private bool disposed;

        public int TagsCalls { get; private set; }
        public int ChatCalls { get; private set; }
        public bool PreflightDigestValidated { get; private set; }
        public bool PostflightDigestValidated { get; private set; }

        internal LocalModelProvider(ILocalByteTransport byteTransport, string exactModelName, string exactModelDigest)
        {
            if (byteTransport == null ||
                !String.Equals(exactModelName, ExactModelName, StringComparison.Ordinal) ||
                !String.Equals(exactModelDigest, ExactModelDigest, StringComparison.Ordinal))
            {
                if (byteTransport != null) { byteTransport.Dispose(); }
                throw new LocalProviderException();
            }
            transport = byteTransport;
            modelName = exactModelName;
            modelDigest = exactModelDigest;
            cache = new Dictionary<string, string>(StringComparer.Ordinal);
        }

        public string ProviderId { get { return "ollama-loopback-v1"; } }
        public bool IsExternal { get { return false; } }
        public bool IsExecutionEnabled { get { return true; } }

        public void BeginRequest()
        {
            RequireUsable();
            if (began || ended || deadline != null) { throw new LocalProviderException(); }
            deadline = new CancellationTokenSource(TimeSpan.FromSeconds(60));
            TagsCalls++;
            ValidateTags(transport.GetTags(deadline.Token));
            PreflightDigestValidated = true;
            began = true;
        }

        public string Complete(AgentRole role, string prompt)
        {
            RequireUsable();
            if (!began || ended || deadline == null || deadline.IsCancellationRequested || prompt == null)
            {
                throw new LocalProviderException();
            }
            if (role != AgentRole.Planning && role != AgentRole.Operations)
            {
                throw new LocalProviderException();
            }
            RequireLocalWellFormed(prompt);

            string key = ContractCodec.Field(ProviderId) +
                         ContractCodec.Field(modelName) +
                         ContractCodec.Field(modelDigest) +
                         ContractCodec.Field(role.ToString()) +
                         ContractCodec.Field(prompt);
            string cached;
            if (cache.TryGetValue(key, out cached)) { return cached; }
            if (cache.Count >= 2) { throw new LocalProviderException(); }

            byte[] request = BuildCanonicalRequest(role, prompt);
            ChatCalls++;
            byte[] response = transport.SendChat(request, deadline.Token);
            string content = StrictLocalJson.ReadChatContent(response, modelName);
            string normalized = NormalizeOutput(content);
            cache.Add(key, normalized);
            return normalized;
        }

        public void EndRequest()
        {
            RequireUsable();
            if (!began || ended || deadline == null) { throw new LocalProviderException(); }
            ended = true;
            if (deadline.IsCancellationRequested) { throw new LocalProviderException(); }
            TagsCalls++;
            ValidateTags(transport.GetTags(deadline.Token));
            PostflightDigestValidated = true;
            if (deadline.IsCancellationRequested) { throw new LocalProviderException(); }
        }

        public void Dispose()
        {
            if (disposed) { return; }
            disposed = true;
            if (deadline != null) { deadline.Dispose(); }
            transport.Dispose();
        }

        internal static byte[] BuildCanonicalRequest(AgentRole role, string prompt)
        {
            if ((role != AgentRole.Planning && role != AgentRole.Operations) || prompt == null)
            {
                throw new LocalProviderException();
            }
            RequireLocalWellFormed(prompt);
            string content = "EAIRA_OUTPUT_POLICY=PLAIN_TEXT_MAX_128_UTF16_NO_EXPLANATION\n" +
                             "EAIRA_AGENT_ROLE=" + role.ToString() + "\nPROMPT=" + prompt;
            string json = "{\"model\":\"qwen3:4b\",\"messages\":[{\"role\":\"user\",\"content\":" +
                          ContractCodec.Json(content) +
                          "}],\"stream\":false,\"think\":false,\"options\":{\"temperature\":0,\"seed\":42,\"num_predict\":32}}";
            byte[] bytes = new UTF8Encoding(false, true).GetBytes(json);
            if (bytes.Length > MaximumRequestBytes) { throw new LocalProviderException(); }
            return bytes;
        }

        internal static string NormalizeOutput(string value)
        {
            if (value == null) { throw new LocalProviderException(); }
            RequireLocalWellFormed(value);
            StringBuilder builder = new StringBuilder(value.Length);
            bool pendingSpace = false;
            for (int index = 0; index < value.Length; index++)
            {
                char character = value[index];
                if (character == ' ' || character == '\t' || character == '\r' || character == '\n')
                {
                    if (builder.Length > 0) { pendingSpace = true; }
                    if (character == '\r' && index + 1 < value.Length && value[index + 1] == '\n') { index++; }
                    continue;
                }
                if (character < 0x20 || (character >= 0x7F && character <= 0x9F))
                {
                    throw new LocalProviderException();
                }
                if (pendingSpace)
                {
                    builder.Append(' ');
                    pendingSpace = false;
                }
                builder.Append(character);
                if (Char.IsHighSurrogate(character))
                {
                    index++;
                    builder.Append(value[index]);
                }
                if (builder.Length > MaximumOutputCodeUnits) { throw new LocalProviderException(); }
            }
            if (builder.Length == 0 || builder.Length > MaximumOutputCodeUnits) { throw new LocalProviderException(); }
            return builder.ToString();
        }

        private void ValidateTags(byte[] response)
        {
            IList<LocalTagIdentity> tags = StrictLocalJson.ReadTags(response);
            int matches = 0;
            for (int index = 0; index < tags.Count; index++)
            {
                if (String.Equals(tags[index].Name, modelName, StringComparison.Ordinal))
                {
                    matches++;
                    if (!String.Equals(tags[index].Digest, modelDigest, StringComparison.Ordinal))
                    {
                        throw new LocalProviderException();
                    }
                }
            }
            if (matches != 1) { throw new LocalProviderException(); }
        }

        private void RequireUsable()
        {
            if (disposed) { throw new LocalProviderException(); }
        }

        private static void RequireLocalWellFormed(string value)
        {
            if (value == null) { throw new LocalProviderException(); }
            for (int index = 0; index < value.Length; index++)
            {
                if (Char.IsHighSurrogate(value[index]))
                {
                    if (index + 1 >= value.Length || !Char.IsLowSurrogate(value[index + 1]))
                    {
                        throw new LocalProviderException();
                    }
                    index++;
                }
                else if (Char.IsLowSurrogate(value[index]))
                {
                    throw new LocalProviderException();
                }
            }
        }
    }

    internal sealed class StrictJsonNode
    {
        internal string Kind { get; private set; }
        internal string StringValue { get; private set; }
        internal bool BooleanValue { get; private set; }
        internal IDictionary<string, StrictJsonNode> ObjectValue { get; private set; }
        internal IList<StrictJsonNode> ArrayValue { get; private set; }

        private StrictJsonNode(string kind) { Kind = kind; }

        internal static StrictJsonNode String(string value)
        {
            StrictJsonNode node = new StrictJsonNode("string");
            node.StringValue = value;
            return node;
        }

        internal static StrictJsonNode Boolean(bool value)
        {
            StrictJsonNode node = new StrictJsonNode("boolean");
            node.BooleanValue = value;
            return node;
        }

        internal static StrictJsonNode Number() { return new StrictJsonNode("number"); }
        internal static StrictJsonNode Null() { return new StrictJsonNode("null"); }

        internal static StrictJsonNode Object(IDictionary<string, StrictJsonNode> value)
        {
            StrictJsonNode node = new StrictJsonNode("object");
            node.ObjectValue = value;
            return node;
        }

        internal static StrictJsonNode Array(IList<StrictJsonNode> value)
        {
            StrictJsonNode node = new StrictJsonNode("array");
            node.ArrayValue = value;
            return node;
        }
    }

    internal sealed class StrictJsonParser
    {
        private const int MaximumDepth = 8;
        private const int MaximumNodes = 512;
        private const int MaximumStringCodeUnits = 32768;
        private readonly string text;
        private int position;
        private int nodes;

        private StrictJsonParser(string value) { text = value; }

        internal static StrictJsonNode Parse(byte[] bytes)
        {
            if (bytes == null || bytes.Length == 0 || bytes.Length > 65536) { throw new LocalProviderException(); }
            if (bytes.Length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF)
            {
                throw new LocalProviderException();
            }
            string decoded;
            try { decoded = new UTF8Encoding(false, true).GetString(bytes); }
            catch (DecoderFallbackException) { throw new LocalProviderException(); }
            RequireWellFormed(decoded);
            StrictJsonParser parser = new StrictJsonParser(decoded);
            StrictJsonNode result = parser.ReadValue(1);
            parser.SkipWhitespace();
            if (parser.position != decoded.Length) { throw new LocalProviderException(); }
            return result;
        }

        private StrictJsonNode ReadValue(int depth)
        {
            if (depth > MaximumDepth) { throw new LocalProviderException(); }
            SkipWhitespace();
            if (position >= text.Length) { throw new LocalProviderException(); }
            nodes++;
            if (nodes > MaximumNodes) { throw new LocalProviderException(); }
            char current = text[position];
            if (current == '{') { return ReadObject(depth); }
            if (current == '[') { return ReadArray(depth); }
            if (current == '"') { return StrictJsonNode.String(ReadString()); }
            if (current == 't') { ReadLiteral("true"); return StrictJsonNode.Boolean(true); }
            if (current == 'f') { ReadLiteral("false"); return StrictJsonNode.Boolean(false); }
            if (current == 'n') { ReadLiteral("null"); return StrictJsonNode.Null(); }
            if (current == '-' || (current >= '0' && current <= '9'))
            {
                ReadNumber();
                return StrictJsonNode.Number();
            }
            throw new LocalProviderException();
        }

        private StrictJsonNode ReadObject(int depth)
        {
            position++;
            Dictionary<string, StrictJsonNode> value = new Dictionary<string, StrictJsonNode>(StringComparer.Ordinal);
            SkipWhitespace();
            if (Take('}')) { return StrictJsonNode.Object(value); }
            while (true)
            {
                SkipWhitespace();
                if (position >= text.Length || text[position] != '"') { throw new LocalProviderException(); }
                string name = ReadString();
                if (value.ContainsKey(name)) { throw new LocalProviderException(); }
                SkipWhitespace();
                Require(':');
                value.Add(name, ReadValue(depth + 1));
                SkipWhitespace();
                if (Take('}')) { return StrictJsonNode.Object(value); }
                Require(',');
            }
        }

        private StrictJsonNode ReadArray(int depth)
        {
            position++;
            List<StrictJsonNode> value = new List<StrictJsonNode>();
            SkipWhitespace();
            if (Take(']')) { return StrictJsonNode.Array(value); }
            while (true)
            {
                value.Add(ReadValue(depth + 1));
                SkipWhitespace();
                if (Take(']')) { return StrictJsonNode.Array(value); }
                Require(',');
            }
        }

        private string ReadString()
        {
            Require('"');
            StringBuilder builder = new StringBuilder();
            while (position < text.Length)
            {
                char current = text[position++];
                if (current == '"')
                {
                    string result = builder.ToString();
                    RequireWellFormed(result);
                    return result;
                }
                if (current < 0x20) { throw new LocalProviderException(); }
                if (current != '\\')
                {
                    builder.Append(current);
                }
                else
                {
                    if (position >= text.Length) { throw new LocalProviderException(); }
                    char escape = text[position++];
                    switch (escape)
                    {
                        case '"': builder.Append('"'); break;
                        case '\\': builder.Append('\\'); break;
                        case '/': builder.Append('/'); break;
                        case 'b': builder.Append('\b'); break;
                        case 'f': builder.Append('\f'); break;
                        case 'n': builder.Append('\n'); break;
                        case 'r': builder.Append('\r'); break;
                        case 't': builder.Append('\t'); break;
                        case 'u': builder.Append(ReadUnicodeEscape()); break;
                        default: throw new LocalProviderException();
                    }
                }
                if (builder.Length > MaximumStringCodeUnits) { throw new LocalProviderException(); }
            }
            throw new LocalProviderException();
        }

        private string ReadUnicodeEscape()
        {
            int first = ReadHexQuad();
            char firstCharacter = (char)first;
            if (Char.IsLowSurrogate(firstCharacter)) { throw new LocalProviderException(); }
            if (!Char.IsHighSurrogate(firstCharacter)) { return new string(firstCharacter, 1); }
            if (position + 6 > text.Length || text[position] != '\\' || text[position + 1] != 'u')
            {
                throw new LocalProviderException();
            }
            position += 2;
            char secondCharacter = (char)ReadHexQuad();
            if (!Char.IsLowSurrogate(secondCharacter)) { throw new LocalProviderException(); }
            return new string(new char[] { firstCharacter, secondCharacter });
        }

        private int ReadHexQuad()
        {
            if (position + 4 > text.Length) { throw new LocalProviderException(); }
            int result = 0;
            for (int index = 0; index < 4; index++)
            {
                char value = text[position++];
                int digit;
                if (value >= '0' && value <= '9') { digit = value - '0'; }
                else if (value >= 'A' && value <= 'F') { digit = value - 'A' + 10; }
                else if (value >= 'a' && value <= 'f') { digit = value - 'a' + 10; }
                else { throw new LocalProviderException(); }
                result = (result * 16) + digit;
            }
            return result;
        }

        private void ReadNumber()
        {
            if (Take('-') && position >= text.Length) { throw new LocalProviderException(); }
            if (Take('0'))
            {
                if (position < text.Length && Char.IsDigit(text[position])) { throw new LocalProviderException(); }
            }
            else
            {
                if (position >= text.Length || text[position] < '1' || text[position] > '9') { throw new LocalProviderException(); }
                while (position < text.Length && text[position] >= '0' && text[position] <= '9') { position++; }
            }
            if (Take('.'))
            {
                int start = position;
                while (position < text.Length && text[position] >= '0' && text[position] <= '9') { position++; }
                if (position == start) { throw new LocalProviderException(); }
            }
            if (position < text.Length && (text[position] == 'e' || text[position] == 'E'))
            {
                position++;
                if (position < text.Length && (text[position] == '+' || text[position] == '-')) { position++; }
                int start = position;
                while (position < text.Length && text[position] >= '0' && text[position] <= '9') { position++; }
                if (position == start) { throw new LocalProviderException(); }
            }
        }

        private void ReadLiteral(string expected)
        {
            if (position + expected.Length > text.Length ||
                !String.Equals(text.Substring(position, expected.Length), expected, StringComparison.Ordinal))
            {
                throw new LocalProviderException();
            }
            position += expected.Length;
        }

        private void SkipWhitespace()
        {
            while (position < text.Length)
            {
                char value = text[position];
                if (value != ' ' && value != '\t' && value != '\r' && value != '\n') { return; }
                position++;
            }
        }

        private bool Take(char expected)
        {
            if (position < text.Length && text[position] == expected) { position++; return true; }
            return false;
        }

        private void Require(char expected)
        {
            if (!Take(expected)) { throw new LocalProviderException(); }
        }

        private static void RequireWellFormed(string value)
        {
            for (int index = 0; index < value.Length; index++)
            {
                if (Char.IsHighSurrogate(value[index]))
                {
                    if (index + 1 >= value.Length || !Char.IsLowSurrogate(value[index + 1])) { throw new LocalProviderException(); }
                    index++;
                }
                else if (Char.IsLowSurrogate(value[index])) { throw new LocalProviderException(); }
            }
        }
    }

    internal static class StrictLocalJson
    {
        internal static IList<LocalTagIdentity> ReadTags(byte[] response)
        {
            StrictJsonNode root = StrictJsonParser.Parse(response);
            IDictionary<string, StrictJsonNode> top = RequireObject(root);
            RequireMembers(top, new string[] { "models" }, new string[] { "models" });
            IList<StrictJsonNode> models = RequireArray(top["models"]);
            List<LocalTagIdentity> identities = new List<LocalTagIdentity>();
            for (int index = 0; index < models.Count; index++)
            {
                IDictionary<string, StrictJsonNode> model = RequireObject(models[index]);
                RequireMembers(
                    model,
                    new string[] { "name", "digest" },
                    new string[] { "name", "model", "modified_at", "size", "digest", "details", "capabilities" });
                string name = RequireString(model["name"]);
                string digest = RequireString(model["digest"]);
                StrictJsonNode optional;
                if (model.TryGetValue("model", out optional)) { RequireString(optional); }
                if (model.TryGetValue("modified_at", out optional)) { RequireString(optional); }
                if (model.TryGetValue("size", out optional)) { RequireKind(optional, "number"); }
                if (model.TryGetValue("details", out optional)) { ValidateDetails(optional); }
                if (model.TryGetValue("capabilities", out optional))
                {
                    IList<StrictJsonNode> capabilities = RequireArray(optional);
                    for (int capabilityIndex = 0; capabilityIndex < capabilities.Count; capabilityIndex++)
                    {
                        RequireString(capabilities[capabilityIndex]);
                    }
                }
                identities.Add(new LocalTagIdentity(name, digest));
            }
            return identities;
        }

        internal static string ReadChatContent(byte[] response, string exactModelName)
        {
            StrictJsonNode root = StrictJsonParser.Parse(response);
            IDictionary<string, StrictJsonNode> top = RequireObject(root);
            string[] allowed = new string[]
            {
                "model", "created_at", "message", "done", "done_reason", "total_duration",
                "load_duration", "prompt_eval_count", "prompt_eval_duration", "eval_count", "eval_duration"
            };
            RequireMembers(top, new string[] { "model", "message", "done" }, allowed);
            if (!String.Equals(RequireString(top["model"]), exactModelName, StringComparison.Ordinal))
            {
                throw new LocalProviderException();
            }
            if (top["done"].Kind != "boolean" || !top["done"].BooleanValue) { throw new LocalProviderException(); }

            IDictionary<string, StrictJsonNode> message = RequireObject(top["message"]);
            RequireMembers(message, new string[] { "role", "content" }, new string[] { "role", "content" });
            if (!String.Equals(RequireString(message["role"]), "assistant", StringComparison.Ordinal))
            {
                throw new LocalProviderException();
            }
            string content = RequireString(message["content"]);

            StrictJsonNode optional;
            if (top.TryGetValue("created_at", out optional)) { RequireString(optional); }
            if (top.TryGetValue("done_reason", out optional) && optional.Kind != "null") { RequireString(optional); }
            string[] numeric = new string[]
            {
                "total_duration", "load_duration", "prompt_eval_count", "prompt_eval_duration",
                "eval_count", "eval_duration"
            };
            for (int index = 0; index < numeric.Length; index++)
            {
                if (top.TryGetValue(numeric[index], out optional)) { RequireKind(optional, "number"); }
            }
            return content;
        }

        private static void ValidateDetails(StrictJsonNode node)
        {
            IDictionary<string, StrictJsonNode> details = RequireObject(node);
            string[] allowed = new string[]
            {
                "parent_model", "format", "family", "families", "parameter_size", "quantization_level",
                "context_length", "embedding_length"
            };
            RequireMembers(details, new string[0], allowed);
            StrictJsonNode value;
            string[] scalar = new string[]
            {
                "parent_model", "format", "family", "parameter_size", "quantization_level"
            };
            for (int index = 0; index < scalar.Length; index++)
            {
                if (details.TryGetValue(scalar[index], out value) && value.Kind != "null") { RequireString(value); }
            }
            if (details.TryGetValue("families", out value) && value.Kind != "null")
            {
                IList<StrictJsonNode> families = RequireArray(value);
                for (int index = 0; index < families.Count; index++) { RequireString(families[index]); }
            }
            if (details.TryGetValue("context_length", out value)) { RequireKind(value, "number"); }
            if (details.TryGetValue("embedding_length", out value)) { RequireKind(value, "number"); }
        }

        private static void RequireMembers(
            IDictionary<string, StrictJsonNode> value,
            string[] required,
            string[] allowed)
        {
            for (int index = 0; index < required.Length; index++)
            {
                if (!value.ContainsKey(required[index])) { throw new LocalProviderException(); }
            }
            foreach (string member in value.Keys)
            {
                bool found = false;
                for (int index = 0; index < allowed.Length; index++)
                {
                    if (String.Equals(member, allowed[index], StringComparison.Ordinal)) { found = true; break; }
                }
                if (!found) { throw new LocalProviderException(); }
            }
        }

        private static IDictionary<string, StrictJsonNode> RequireObject(StrictJsonNode node)
        {
            RequireKind(node, "object");
            return node.ObjectValue;
        }

        private static IList<StrictJsonNode> RequireArray(StrictJsonNode node)
        {
            RequireKind(node, "array");
            return node.ArrayValue;
        }

        private static string RequireString(StrictJsonNode node)
        {
            RequireKind(node, "string");
            return node.StringValue;
        }

        private static void RequireKind(StrictJsonNode node, string kind)
        {
            if (node == null || !String.Equals(node.Kind, kind, StringComparison.Ordinal))
            {
                throw new LocalProviderException();
            }
        }
    }

    internal sealed class LocalTagIdentity
    {
        internal string Name { get; private set; }
        internal string Digest { get; private set; }

        internal LocalTagIdentity(string name, string digest)
        {
            Name = name;
            Digest = digest;
        }
    }
}
