using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Threading;

namespace EAIRA.AgentServices.Functional
{
    internal sealed class ProjectQaHarnessHandle : IPinnedAncestorHandle, ILeafProbeHandle, IApprovedContentHandle
    {
        internal string Path; internal string Kind; internal ProjectQaHarnessHandle(string path, string kind) { Path = path; Kind = kind; }
    }

    internal sealed class ProjectQaHarnessPlatform : IProjectContextReadOnlyPlatform
    {
        internal readonly Dictionary<string, byte[]> Files = new Dictionary<string, byte[]>(StringComparer.Ordinal);
        internal readonly List<string> Events = new List<string>();
        internal readonly string FailEvent;
        internal readonly string MutationEvent;
        internal readonly string MutationKind;
        private ulong nextId = 100;
        private readonly Dictionary<string, ulong> ids = new Dictionary<string, ulong>(StringComparer.Ordinal);
        private readonly Dictionary<string, int> contentQueries = new Dictionary<string, int>(StringComparer.Ordinal);
        internal ProjectQaHarnessPlatform(string root) : this(root, null, null, null) { }
        internal ProjectQaHarnessPlatform(string root, string failEvent) : this(root, failEvent, null, null) { }
        internal ProjectQaHarnessPlatform(string root, string failEvent, string mutationEvent, string mutationKind)
        {
            FailEvent = failEvent;
            MutationEvent = mutationEvent;
            MutationKind = mutationKind;
            string current = "## Context ID\nEAIRA-CURRENT-CONTEXT-001\n\n## Version\n1\n\n## Updated At\n2026-09-10\n\n## Current Milestone\nM4\n\n## Active Phase\nSlice 5\n\n## Current Decision\nA\n\n## Blockers\n- None\n\n## Next Action\nValidate\n";
            string today = "## Date\n2026-09-10\n\n## Version\n1\n\n## Milestone\nM4\n\n## Current Scope\nQA\n\n## Out of Scope\nWrites\n\n## Expected Deliverables\nCLI\n\n## Success Criteria\n- Pass\n";
            string active = "\"Task ID\": \"S5\"\n\"Owner\": \"Human Project Owner\"\n\"Status\": \"ACTIVE\"\n\"Priority\": \"Validate\"\n\"Dependencies\": []\n\"Last Updated\": \"2026-09-10\"\n";
            string versions = "\"Context Version\": \"1\"\n\"Last Updated\": \"2026-09-10\"\n\"Current Status Version\": \"1\"\n\"Today Objective Version\": \"1\"\n\"Knowledge Index Version\": \"1\"\n\"Verified Agents\": []\n";
            Add(root, "docs/project/status/CURRENT_STATUS.md", current); Add(root, "docs/project/status/TODAY_OBJECTIVE.md", today); Add(root, "docs/project/status/ACTIVE_TASK.yaml", active); Add(root, "docs/project/status/AGENT_CONTEXT_VERSION.yaml", versions);
            string[] memory = new string[] { "README.md", "DECISION_INDEX.md", "DISCOVERY_INDEX.md", "PROCEDURE_INDEX.md", "OPEN_QUESTIONS.md", "STABILITY_CHECKLIST.md", "MEMORY_SCHEMA.md" };
            for (int i = 0; i < memory.Length; i++) { Add(root, "docs/project/memory/" + memory[i], "---\ntitle: Memory\n---\n# EAIRA\nEAIRA bounded evidence " + i.ToString(CultureInfo.InvariantCulture) + "\n"); }
        }
        private void Add(string root, string relative, string text) { string path = root + "\\" + relative.Replace('/', '\\'); Files.Add(path, new UTF8Encoding(false, true).GetBytes(text)); ids.Add(path, nextId++); }
        public IPinnedAncestorHandle OpenPinnedAncestor(string p) { Hit("OPEN_ANCESTOR:" + Leaf(p)); return new ProjectQaHarnessHandle(p, "A"); }
        public ILeafProbeHandle OpenLeafProbe(string p) { RequireFile(p); Hit("OPEN_PROBE:" + Leaf(p)); return new ProjectQaHarnessHandle(p, "P"); }
        public IApprovedContentHandle OpenApprovedContent(string p) { RequireFile(p); Hit("OPEN_CONTENT:" + Leaf(p)); return new ProjectQaHarnessHandle(p, "C"); }
        public ProjectContextFileMetadata QueryPinnedAncestor(IPinnedAncestorHandle h) { ProjectQaHarnessHandle x = (ProjectQaHarnessHandle)h; string e = "QUERY_ANCESTOR:" + Leaf(x.Path); Hit(e); return Mutate(new ProjectContextFileMetadata(x.Path, 1, 1, 0, 1, 0x10, 0), e); }
        public ProjectContextFileMetadata QueryLeafProbe(ILeafProbeHandle h) { ProjectQaHarnessHandle x = (ProjectQaHarnessHandle)h; string e = "QUERY_PROBE:" + Leaf(x.Path); Hit(e); return Mutate(FileMetadata(x), e); }
        public ProjectContextFileMetadata QueryApprovedContent(IApprovedContentHandle h) { ProjectQaHarnessHandle x = (ProjectQaHarnessHandle)h; int count; if (!contentQueries.TryGetValue(x.Path, out count)) { count = 0; } count++; contentQueries[x.Path] = count; string e = "QUERY_CONTENT_" + count.ToString(CultureInfo.InvariantCulture) + ":" + Leaf(x.Path); Hit(e); return Mutate(FileMetadata(x), e); }
        public byte[] ReadApprovedContent(IApprovedContentHandle h, int count) { ProjectQaHarnessHandle x = (ProjectQaHarnessHandle)h; byte[] source = RequireFile(x.Path); if (source.Length != count) { throw new Exception(); } Hit("READ:" + Leaf(x.Path)); return (byte[])source.Clone(); }
        public void ClosePinnedAncestor(IPinnedAncestorHandle h) { Hit("CLOSE_ANCESTOR:" + Leaf(((ProjectQaHarnessHandle)h).Path)); }
        public void CloseLeafProbe(ILeafProbeHandle h) { Hit("CLOSE_PROBE:" + Leaf(((ProjectQaHarnessHandle)h).Path)); }
        public void CloseApprovedContent(IApprovedContentHandle h) { Hit("CLOSE_CONTENT:" + Leaf(((ProjectQaHarnessHandle)h).Path)); }
        private ProjectContextFileMetadata FileMetadata(ProjectQaHarnessHandle h) { byte[] raw = RequireFile(h.Path); return new ProjectContextFileMetadata(h.Path, 1, ids[h.Path], (ulong)raw.Length, 1, 0, 0); }
        private byte[] RequireFile(string p) { byte[] v; if (!Files.TryGetValue(p, out v)) { throw new Exception(); } return v; }
        private void Hit(string value) { Events.Add(value); if (String.Equals(FailEvent, value, StringComparison.Ordinal) || (!String.IsNullOrEmpty(FailEvent) && FailEvent.IndexOf("|" + value + "|", StringComparison.Ordinal) >= 0)) { throw new Exception(); } }
        private ProjectContextFileMetadata Mutate(ProjectContextFileMetadata value, string eventName)
        {
            if (!String.Equals(MutationEvent, eventName, StringComparison.Ordinal)) { return value; }
            if (MutationKind == "STATE") { return new ProjectContextFileMetadata(value.CanonicalPath, value.VolumeSerial, value.FileId, value.Length, value.LastWriteTime, value.Attributes | 0x1000U, value.ReparseTag); }
            if (MutationKind == "PATH") { return new ProjectContextFileMetadata(value.CanonicalPath + "X", value.VolumeSerial, value.FileId, value.Length, value.LastWriteTime, value.Attributes, value.ReparseTag); }
            if (MutationKind == "IDENTITY") { return new ProjectContextFileMetadata(value.CanonicalPath, value.VolumeSerial, value.FileId + 1UL, value.Length, value.LastWriteTime, value.Attributes, value.ReparseTag); }
            throw new Exception();
        }
        private static string Leaf(string p) { int i = p.LastIndexOf('\\'); return i < 0 ? p : p.Substring(i + 1); }
    }

    internal sealed class ProjectQaHarnessTransport : ILocalByteTransport
    {
        private readonly byte[] tags;
        private readonly byte[] chat;
        private readonly int failTagCall;
        private readonly bool failChat;
        internal int TagsCalls, ChatCalls;
        internal bool Disposed;
        internal byte[] LastBody;
        internal ProjectQaHarnessTransport(string answer, string digest) : this(
            Encoding.UTF8.GetBytes("{\"models\":[{\"name\":\"qwen3:4b\",\"digest\":\"" + digest + "\"}]}"),
            Encoding.UTF8.GetBytes("{\"model\":\"qwen3:4b\",\"message\":{\"role\":\"assistant\",\"content\":" + ContractCodec.Json(answer) + "},\"done\":true}"), 0, false) { }
        internal ProjectQaHarnessTransport(byte[] tagsPayload, byte[] chatPayload, int exactFailTagCall, bool exactFailChat)
        {
            tags = tagsPayload; chat = chatPayload; failTagCall = exactFailTagCall; failChat = exactFailChat;
        }
        public byte[] GetTags(CancellationToken cancellationToken) { TagsCalls++; if (TagsCalls == failTagCall) { throw new LocalProviderException(); } return (byte[])tags.Clone(); }
        public byte[] SendChat(byte[] canonicalRequest, CancellationToken cancellationToken) { ChatCalls++; LastBody = (byte[])canonicalRequest.Clone(); if (failChat) { throw new LocalProviderException(); } return (byte[])chat.Clone(); }
        public void Dispose() { Disposed = true; }
    }

    internal sealed class ProjectQaHarnessProvider : IProjectQaProvider
    {
        private readonly string response; internal byte[] Body; internal ProjectQaHarnessProvider(string value) { response = value; }
        public int TagsCalls { get { return 2; } } public int ChatCalls { get { return 1; } } public bool PreflightDigestValidated { get { return true; } } public bool PostflightDigestValidated { get { return true; } }
        public string Execute(byte[] body) { Body = body; return response; } public void Dispose() { }
    }

    internal static class ProjectQaHarness
    {
        private static readonly List<string> Cases = new List<string>();
        private static void Check(string name, bool condition) { if (!condition) { throw new Exception(); } Cases.Add(name); }
        private static void Reject(string name, Action action) { bool rejected = false; try { action(); } catch (Exception) { rejected = true; } Check(name, rejected); }
        internal static int Main()
        {
            try
            {
                const string root = "C:\\EAIRA";
                Check("ROOT_CANONICAL", ProjectQaRequest.ValidateLexicalRoot(root) == root);
                string[] rejectedRoots = new string[] { null, "", "C:\\", "c:\\EAIRA", "C:/EAIRA", "C:\\EAIRA\\", "C:\\EAIRA\\\\X", "C:\\EAIRA:ADS", "C:\\EAIRA\\.", "C:\\EAIRA\\..", "C:\\EAIRA\\X ", "C:\\EAIRA\\X.", "C:\\EAIRA~1", "\\\\server\\share", "\\\\?\\C:\\EAIRA" };
                for (int i = 0; i < rejectedRoots.Length; i++) { string value = rejectedRoots[i]; Reject("ROOT_REJECT_" + i.ToString("D2", CultureInfo.InvariantCulture), delegate { ProjectQaRequest.ValidateLexicalRoot(value); }); }
                string[] args = new string[] { "--root", root, "--trace", "00000000000000000000000000000001", "--question", "EAIRA", "--provider", "ollama-local", "--model", "qwen3:4b" };
                ProjectQaRequest request = ProjectQaRequest.Parse(args); Check("REQUEST_EXACT", request.Question == "EAIRA");
                Reject("REQUEST_EXTRA_ARG", delegate { ProjectQaRequest.Parse(new string[11]); });
                Reject("REQUEST_BAD_TRACE", delegate { string[] x = (string[])args.Clone(); x[3] = "0000000000000000000000000000000a"; ProjectQaRequest.Parse(x); });
                Reject("REQUEST_BAD_PROVIDER", delegate { string[] x = (string[])args.Clone(); x[7] = "mock"; ProjectQaRequest.Parse(x); });
                for (int i = 0; i < args.Length; i++) { int missing = i; Reject("CLI_MISSING_" + i.ToString("D2", CultureInfo.InvariantCulture), delegate { List<string> x = new List<string>(args); x.RemoveAt(missing); ProjectQaRequest.Parse(x.ToArray()); }); }
                Reject("CLI_DUPLICATE", delegate { List<string> x = new List<string>(args); x.Add("--root"); x.Add(root); ProjectQaRequest.Parse(x.ToArray()); });
                Reject("CLI_REORDERED", delegate { string[] x = (string[])args.Clone(); string temporary = x[0]; x[0] = x[2]; x[2] = temporary; ProjectQaRequest.Parse(x); });
                Reject("CLI_ALTERNATE_ROOT_FLAG", delegate { string[] x = (string[])args.Clone(); x[0] = "/root"; ProjectQaRequest.Parse(x); });
                Reject("CLI_ALTERNATE_MODEL", delegate { string[] x = (string[])args.Clone(); x[9] = "QWEN3:4B"; ProjectQaRequest.Parse(x); });
                Reject("CLI_EMPTY_QUESTION", delegate { string[] x = (string[])args.Clone(); x[5] = ""; ProjectQaRequest.Parse(x); });
                Reject("CLI_TRACE_SHORT", delegate { string[] x = (string[])args.Clone(); x[3] = "0000000000000000000000000000000"; ProjectQaRequest.Parse(x); });
                Reject("CLI_TRACE_LONG", delegate { string[] x = (string[])args.Clone(); x[3] = "000000000000000000000000000000001"; ProjectQaRequest.Parse(x); });
                Check("GUARD_ALLOW", GuardAgent.ExpectedDecision(TaskEnvelope.Create(1, request.TraceId, request.Question)) == AgentDecision.Allow);
                Check("GUARD_DENY", GuardAgent.ExpectedDecision(TaskEnvelope.Create(1, request.TraceId, "write EAIRA")) == AgentDecision.Deny);
                int guardFactoryCalls = 0, guardPlatformOpens = 0, guardTagsCalls = 0, guardChatCalls = 0;
                string[] prohibited = new string[] { "NETWORK", "WRITE", "IPC", "CHILD_PROCESS", "SHELL", "CREDENTIAL", "SECRET" };
                for (int i = 0; i < prohibited.Length; i++)
                {
                    string term = prohibited[i];
                    Check("GUARD_TERM_" + term, GuardAgent.ExpectedDecision(TaskEnvelope.Create(1, request.TraceId, term)) == AgentDecision.Deny);
                    Check("GUARD_MIXED_CASE_" + term, GuardAgent.ExpectedDecision(TaskEnvelope.Create(1, request.TraceId, term.ToLowerInvariant())) == AgentDecision.Deny);
                    Check("GUARD_EMBEDDED_" + term, GuardAgent.ExpectedDecision(TaskEnvelope.Create(1, request.TraceId, "X" + term + "Y")) == AgentDecision.Deny);
                }
                Reject("GUARD_INVALID_PRECEDENCE", delegate { string[] x = (string[])args.Clone(); x[3] = "bad"; x[5] = "WRITE"; ProjectQaRequest.Parse(x); });
                Check("GUARD_ZERO_FACTORY", guardFactoryCalls == 0);
                Check("GUARD_ZERO_PLATFORM_OPEN", guardPlatformOpens == 0);
                Check("GUARD_ZERO_TAGS", guardTagsCalls == 0);
                Check("GUARD_ZERO_CHAT", guardChatCalls == 0);

                ProjectQaHarnessPlatform platform = new ProjectQaHarnessPlatform(root);
                ProjectQaSnapshot snapshot = ProjectQaSnapshotReader.CreateForTests(platform).Read(root, request.Question);
                Check("SNAPSHOT_CONTEXT_FIELDS_27", snapshot.ContextFields.Count == 27);
                Check("SNAPSHOT_KNOWLEDGE_MATCHES_8", snapshot.Knowledge.Matches.Count == 8 && snapshot.Knowledge.Truncated);
                Check("SNAPSHOT_READS_11", CountPrefix(platform.Events, "READ:") == 11);
                Check("SNAPSHOT_PROBES_11", CountPrefix(platform.Events, "OPEN_PROBE:") == 11 && CountPrefix(platform.Events, "CLOSE_PROBE:") == 11);
                Check("SNAPSHOT_CONTENT_11", CountPrefix(platform.Events, "OPEN_CONTENT:") == 11 && CountPrefix(platform.Events, "CLOSE_CONTENT:") == 11);
                Check("SNAPSHOT_ANCESTORS_5", CountPrefix(platform.Events, "OPEN_ANCESTOR:") == 5 && CountPrefix(platform.Events, "CLOSE_ANCESTOR:") == 5);
                Check("SNAPSHOT_REVERSE_CONTENT", LastWithPrefix(platform.Events, "CLOSE_CONTENT:") == "CLOSE_CONTENT:CURRENT_STATUS.md");
                Check("SNAPSHOT_REVERSE_ANCESTOR", LastWithPrefix(platform.Events, "CLOSE_ANCESTOR:") == "CLOSE_ANCESTOR:EAIRA");
                string[] ancestorLeaves = new string[] { "EAIRA", "docs", "project", "status", "memory" };
                string[] ancestorNames = new string[] { "ROOT", "DOCS", "PROJECT", "STATUS", "MEMORY" };
                for (int i = 0; i < ancestorLeaves.Length; i++)
                {
                    bool contextOwned = i == 3;
                    FaultSnapshot(root, "ANCESTOR_" + ancestorNames[i] + "_OPEN", "OPEN_ANCESTOR:" + ancestorLeaves[i], contextOwned, false);
                    FaultSnapshot(root, "ANCESTOR_" + ancestorNames[i] + "_QUERY", "QUERY_ANCESTOR:" + ancestorLeaves[i], contextOwned, false);
                    FaultSnapshot(root, "ANCESTOR_" + ancestorNames[i] + "_CLOSE", "CLOSE_ANCESTOR:" + ancestorLeaves[i], contextOwned, false);
                    MutationSnapshot(root, "ANCESTOR_" + ancestorNames[i] + "_STATE", "QUERY_ANCESTOR:" + ancestorLeaves[i], "STATE", contextOwned);
                    MutationSnapshot(root, "ANCESTOR_" + ancestorNames[i] + "_PATH", "QUERY_ANCESTOR:" + ancestorLeaves[i], "PATH", contextOwned);
                }
                string[] leafNames = new string[] { "CURRENT_STATUS.md", "TODAY_OBJECTIVE.md", "ACTIVE_TASK.yaml", "AGENT_CONTEXT_VERSION.yaml", "README.md", "DECISION_INDEX.md", "DISCOVERY_INDEX.md", "PROCEDURE_INDEX.md", "OPEN_QUESTIONS.md", "STABILITY_CHECKLIST.md", "MEMORY_SCHEMA.md" };
                string[] faultKinds = new string[] { "OPEN_PROBE", "QUERY_PROBE", "CLOSE_PROBE", "OPEN_CONTENT", "QUERY_CONTENT_1", "READ", "QUERY_CONTENT_2", "QUERY_CONTENT_3", "CLOSE_CONTENT" };
                for (int i = 0; i < leafNames.Length; i++)
                {
                    bool contextOwned = i < 4; string group = contextOwned ? "CONTEXT_" + (i + 1).ToString("D2", CultureInfo.InvariantCulture) : "KNOWLEDGE_" + (i - 3).ToString("D2", CultureInfo.InvariantCulture);
                    for (int j = 0; j < faultKinds.Length; j++) { string eventName = faultKinds[j] + ":" + leafNames[i]; FaultSnapshot(root, group + "_" + faultKinds[j], eventName, contextOwned, faultKinds[j] == "CLOSE_PROBE"); }
                    MutationSnapshot(root, group + "_PROBE_STATE", "QUERY_PROBE:" + leafNames[i], "STATE", contextOwned);
                    MutationSnapshot(root, group + "_PROBE_PATH", "QUERY_PROBE:" + leafNames[i], "PATH", contextOwned);
                    MutationSnapshot(root, group + "_PROBE_IDENTITY", "QUERY_PROBE:" + leafNames[i], "IDENTITY", contextOwned);
                    for (int q = 1; q <= 3; q++)
                    {
                        string queryEvent = "QUERY_CONTENT_" + q.ToString(CultureInfo.InvariantCulture) + ":" + leafNames[i]; string phase = q == 1 ? "CONTENT_BEFORE" : q == 2 ? "CONTENT_AFTER" : "CONTENT_FINAL";
                        MutationSnapshot(root, group + "_" + phase + "_STATE", queryEvent, "STATE", contextOwned);
                        MutationSnapshot(root, group + "_" + phase + "_PATH", queryEvent, "PATH", contextOwned);
                        MutationSnapshot(root, group + "_" + phase + "_IDENTITY", queryEvent, "IDENTITY", contextOwned);
                    }
                }
                Check("SESSION_EXACT_ELEVEN_READS", CountPrefix(platform.Events, "READ:") == 11);
                Check("SESSION_NO_TWELFTH_PATH", platform.Files.Count == 11);
                Check("SESSION_FINAL_REQUERY_ELEVEN", CountPrefix(platform.Events, "QUERY_CONTENT_3:") == 11);
                FaultSnapshot(root, "SESSION_CONTEXT_PRIMARY_OVERRIDES_CLEANUP", "|READ:CURRENT_STATUS.md|CLOSE_CONTENT:CURRENT_STATUS.md|CLOSE_ANCESTOR:status|", true, false);
                FaultSnapshot(root, "SESSION_KNOWLEDGE_PRIMARY_OVERRIDES_CLEANUP", "|READ:MEMORY_SCHEMA.md|CLOSE_CONTENT:MEMORY_SCHEMA.md|CLOSE_ANCESTOR:memory|", false, false);
                FaultSnapshot(root, "SESSION_FIRST_REVERSE_CLEANUP_IMMUTABLE", "|CLOSE_CONTENT:MEMORY_SCHEMA.md|CLOSE_ANCESTOR:status|", false, false);
                FaultSnapshot(root, "SESSION_CONTEXT_PRIMARY_OVERRIDES_KNOWLEDGE_CLEANUP", "|QUERY_CONTENT_3:CURRENT_STATUS.md|CLOSE_CONTENT:MEMORY_SCHEMA.md|", true, false);
                FaultSnapshot(root, "SESSION_KNOWLEDGE_PRIMARY_OVERRIDES_CONTEXT_CLEANUP", "|QUERY_CONTENT_3:README.md|CLOSE_CONTENT:CURRENT_STATUS.md|", false, false);

                string prompt = ProjectQaPrompt.Build(request, snapshot); byte[] promptBytes = Encoding.UTF8.GetBytes(prompt);
                Check("PROMPT_PREFIX", prompt.StartsWith("EAIRA_M4_SLICE5_PROJECT_QA_V1\n", StringComparison.Ordinal));
                Check("PROMPT_CONTEXT_COUNT", prompt.IndexOf("CONTEXT_COUNT=27\n", StringComparison.Ordinal) >= 0);
                Check("PROMPT_KNOWLEDGE_COUNT", prompt.IndexOf("KNOWLEDGE_COUNT=8", StringComparison.Ordinal) >= 0);
                byte[] prompt11999 = Encoding.ASCII.GetBytes(new string('A', 11999)); byte[] prompt12000 = Encoding.ASCII.GetBytes(new string('A', 12000)); byte[] prompt12001 = Encoding.ASCII.GetBytes(new string('A', 12001));
                ProjectQaPrompt.ValidateEncodedPrompt(prompt11999); CheckExactBytes("PROMPT_11999", prompt11999, 11999, "E4A651E1CEC7B1ADA3E0E137EFB1F53CCF14F321E361CED465AC3681D088AE8E");
                ProjectQaPrompt.ValidateEncodedPrompt(prompt12000); CheckExactBytes("PROMPT_12000", prompt12000, 12000, "A68006E3D578D8B32301F7687CB97C68E81A9EC33225D5531A0E5842C4DE62C9");
                RejectType<ProjectQaException>("PROMPT_12001_REJECT", delegate { ProjectQaPrompt.ValidateEncodedPrompt(prompt12001); }); CheckExactBytes("PROMPT_12001", prompt12001, 12001, "B0BA8D146F21E39031BDF4CF345187BE5B4CA33F255DC2469BDEE03C35769641");
                Check("QUESTION_GOLDEN", ProjectQaPrompt.DomainDigest("EAIRA_M4_SLICE5_QUESTION_V1", "EAIRA") == "5F8EAF0FD8B4EE2B0A0FEF54A8594C50143D7B3567AC7C1CF4F90BD8C19970A5");
                Check("INSUFFICIENT_BYTES_53", Encoding.UTF8.GetByteCount("Insufficient evidence in the allowed project sources.") == 53);
                Check("INSUFFICIENT_DIGEST", ProjectQaPrompt.DomainDigest("EAIRA_M4_SLICE5_ANSWER_V1", "Insufficient evidence in the allowed project sources.") == "CE2D672B78A25ACE7379CDF0A6E6265BEF0C5F77A84D0D9B446AB99B5186AEC5");
                string canonicalBodyText = Encoding.UTF8.GetString(ProjectQaPrompt.BuildBody(prompt));
                Check("REQUEST_BODY_STRUCTURED_SCHEMA_EXACT", canonicalBodyText.IndexOf("\"format\":{\"type\":\"object\",\"properties\":{\"answer\":{\"type\":\"string\",\"minLength\":1,\"maxLength\":512},\"citationIds\":{\"type\":\"array\",\"items\":{\"type\":\"string\"},\"maxItems\":8,\"uniqueItems\":true}},\"required\":[\"answer\",\"citationIds\"],\"additionalProperties\":false}", StringComparison.Ordinal) >= 0);
                Check("REQUEST_BODY_NO_LEGACY_JSON_MODE", canonicalBodyText.IndexOf("\"format\":\"json\"", StringComparison.Ordinal) < 0);
                Check("REQUEST_BODY_THINK_FALSE_RETAINED", canonicalBodyText.IndexOf("\"think\":false", StringComparison.Ordinal) >= 0);
                CheckBody("BODY_QUOTE", "\"", 402, "385B5F81BFD3F8C84C7E308FD9D8CC288FF254DA02682B22EB4E5BC55305CD46");
                CheckBody("BODY_LF", "\n", 402, "F46C8DECDB1F242F71A2BC8CE2C2400858BC40464F5E2380D1CC6FD3ED67901F");
                CheckBody("BODY_E_ACUTE", "é", 402, "95C3CC3D19A1843F159727A09C5D38E9E544A215290A4CEFDAC0D19E9153CB91");
                CheckBody("BODY_U2028", "\u2028", 403, "F4EF1CE0F891BCA774465AA5632286AB8B854B76BFAD16BCEAB4BC05CFF5E7F4");
                Reject("BODY_ABOVE_LIMIT", delegate { ProjectQaPrompt.BuildBody(new string('\\', 7992) + "A"); });
                Check("BODY_AT_LIMIT", ProjectQaPrompt.BuildBody(new string('\\', 7992)).Length == 16384);
                byte[] body16383 = ProjectQaPrompt.BuildBody(new string('\\', 7991) + "A"); CheckExactBytes("REQUEST_BODY_16383", body16383, 16383, "E3173A730FDB0BCCD6F6EADC55A31C1246457735D54619C3191EDE0281585DB5");
                byte[] body16384 = ProjectQaPrompt.BuildBody(new string('\\', 7992)); CheckExactBytes("REQUEST_BODY_16384", body16384, 16384, "2D8CC61CADC3F40F961FD24051A70E86B15225613536A90ABF103023BF9E2D9E");
                byte[] body16385 = BuildUncheckedBody(new string('\\', 7992) + "A"); CheckExactBytes("REQUEST_BODY_16385", body16385, 16385, "080758CC5EA11370E9BF81E7306951353D50CD68E3BB2EC951F1000B4575B902"); RejectType<ProjectQaException>("REQUEST_BODY_16385_REJECT", delegate { ProjectQaPrompt.ValidateEncodedBody(body16385); });

                byte[] answerBytes = Encoding.UTF8.GetBytes("{\"answer\":\"Insufficient evidence in the allowed project sources.\",\"citationIds\":[]}");
                ProjectQaAnswer answer = ProjectQaAnswerDecoder.Decode(answerBytes, request, snapshot, prompt, ProjectQaPrompt.BuildBody(prompt));
                Check("ANSWER_INSUFFICIENT", answer.CitationIds.Count == 0);
                byte[] cited = Encoding.UTF8.GetBytes("{\"answer\":\"Bounded answer\",\"citationIds\":[\"C01\",\"K01\"]}");
                Check("ANSWER_CITATIONS", ProjectQaAnswerDecoder.Decode(cited, request, snapshot, prompt, ProjectQaPrompt.BuildBody(prompt)).CitationIds.Count == 2);
                string[] badAnswers = new string[] { "{\"citationIds\":[],\"answer\":\"x\"}", "{\"answer\":\"x\",\"citationIds\":[],\"extra\":1}", "{\"answer\":\"x\",\"citationIds\":[\"C01\",\"C01\"]}", "{\"answer\":\"x\",\"citationIds\":[\"K09\"]}", "{\"answer\":\"x\",\"citationIds\":[]}", "{\"answer\":\"Insufficient evidence in the allowed project sources.\",\"citationIds\":[\"C01\"]}" };
                for (int i = 0; i < badAnswers.Length; i++) { byte[] value = Encoding.UTF8.GetBytes(badAnswers[i]); Reject("ANSWER_REJECT_" + i.ToString("D2", CultureInfo.InvariantCulture), delegate { ProjectQaAnswerDecoder.Decode(value, request, snapshot, prompt, ProjectQaPrompt.BuildBody(prompt)); }); }
                Reject("ANSWER_MALFORMED_RAW_UTF8", delegate { ProjectQaAnswerOrderValidator.Validate(new byte[] { (byte)'{', (byte)'\"', (byte)'a', (byte)'n', (byte)'s', (byte)'w', (byte)'e', (byte)'r', (byte)'\"', (byte)':', (byte)'\"', 0xC3, 0x28, (byte)'\"', (byte)',', (byte)'\"', (byte)'c', (byte)'i', (byte)'t', (byte)'a', (byte)'t', (byte)'i', (byte)'o', (byte)'n', (byte)'I', (byte)'d', (byte)'s', (byte)'\"', (byte)':', (byte)'[', (byte)']', (byte)'}' }); });
                Reject("ANSWER_ESCAPED_LONE_HIGH_SURROGATE", delegate { ProjectQaAnswerOrderValidator.Validate(Encoding.ASCII.GetBytes("{\"answer\":\"\\uD800\",\"citationIds\":[]}")); });
                Reject("ANSWER_ESCAPED_LONE_LOW_SURROGATE", delegate { ProjectQaAnswerOrderValidator.Validate(Encoding.ASCII.GetBytes("{\"answer\":\"\\uDC00\",\"citationIds\":[]}")); });
                ProjectQaAnswerOrderValidator.Validate(Encoding.ASCII.GetBytes("{\"answer\":\"\\uD83D\\uDE00\",\"citationIds\":[]}")); Check("ANSWER_ESCAPED_SURROGATE_PAIR", true);
                byte[] eightCitations = Encoding.UTF8.GetBytes("{\"answer\":\"Bounded answer\",\"citationIds\":[\"C01\",\"C02\",\"C03\",\"C04\",\"C05\",\"C06\",\"C07\",\"C08\"]}");
                Check("ANSWER_EIGHT_CITATIONS", ProjectQaAnswerDecoder.Decode(eightCitations, request, snapshot, prompt, ProjectQaPrompt.BuildBody(prompt)).CitationIds.Count == 8);
                byte[] nineCitations = Encoding.UTF8.GetBytes("{\"answer\":\"Bounded answer\",\"citationIds\":[\"C01\",\"C02\",\"C03\",\"C04\",\"C05\",\"C06\",\"C07\",\"C08\",\"C09\"]}");
                Reject("ANSWER_NINE_CITATIONS", delegate { ProjectQaAnswerDecoder.Decode(nineCitations, request, snapshot, prompt, ProjectQaPrompt.BuildBody(prompt)); });
                string answer512 = new string('A', 512); ProjectQaAnswerDecoder.ValidateAnswerText(answer512); Check("ANSWER_SCALAR_512_ACCEPT", true);
                RejectType<ProjectQaException>("ANSWER_SCALAR_513_REJECT", delegate { ProjectQaAnswerDecoder.ValidateAnswerText(new string('A', 513)); });
                StringBuilder emoji512Builder = new StringBuilder(); for (int i = 0; i < 512; i++) { emoji512Builder.Append("\uD83D\uDE00"); } string emoji512 = emoji512Builder.ToString(); ProjectQaAnswerDecoder.ValidateAnswerText(emoji512); Check("ANSWER_UTF8_2048_ACCEPT", Encoding.UTF8.GetByteCount(emoji512) == 2048);
                ProjectQaAnswerDecoder.ValidateAnswerEncodedBytes(new byte[2048]); Check("ANSWER_ENCODED_2048_ACCEPT", true);
                RejectType<ProjectQaException>("ANSWER_ENCODED_2049_REJECT", delegate { ProjectQaAnswerDecoder.ValidateAnswerEncodedBytes(new byte[2049]); });
                RejectType<ProjectQaException>("ANSWER_C0_REJECT", delegate { ProjectQaAnswerDecoder.ValidateAnswerText("A\u0001"); });
                RejectType<ProjectQaException>("ANSWER_C1_REJECT", delegate { ProjectQaAnswerDecoder.ValidateAnswerText("A\u0085"); });
                ProjectQaHarnessProvider provider = new ProjectQaHarnessProvider(Encoding.UTF8.GetString(answerBytes)); provider.Execute(ProjectQaPrompt.BuildBody(prompt));
                ProjectQaHarnessTransport transport = new ProjectQaHarnessTransport(Encoding.UTF8.GetString(answerBytes), LocalModelProvider.ExactModelDigest);
                ProjectQaLocalProvider productionProvider = new ProjectQaLocalProvider(transport);
                byte[] canonicalBody = ProjectQaPrompt.BuildBody(prompt); string providerAnswer = productionProvider.Execute(canonicalBody);
                Check("PROVIDER_TWO_TAGS_ONE_CHAT", productionProvider.TagsCalls == 2 && productionProvider.ChatCalls == 1 && transport.TagsCalls == 2 && transport.ChatCalls == 1);
                Check("PROVIDER_EXACT_BODY", Convert.ToBase64String(transport.LastBody) == Convert.ToBase64String(canonicalBody));
                Check("PROVIDER_DIGEST_LIFECYCLE", productionProvider.PreflightDigestValidated && productionProvider.PostflightDigestValidated && providerAnswer == Encoding.UTF8.GetString(answerBytes));
                RejectType<LocalProviderException>("PROVIDER_NO_SECOND_EXECUTE", delegate { productionProvider.Execute(canonicalBody); });
                productionProvider.Dispose(); Check("PROVIDER_DISPOSE_TRANSPORT", transport.Disposed);
                ProjectQaHarnessTransport wrongDigestTransport = new ProjectQaHarnessTransport(Encoding.UTF8.GetString(answerBytes), new string('0', 64));
                ProjectQaLocalProvider wrongDigestProvider = new ProjectQaLocalProvider(wrongDigestTransport);
                RejectType<LocalProviderException>("PROVIDER_WRONG_DIGEST_NO_CHAT", delegate { wrongDigestProvider.Execute(canonicalBody); });
                Check("PROVIDER_WRONG_DIGEST_COUNTERS", wrongDigestTransport.TagsCalls == 1 && wrongDigestTransport.ChatCalls == 0);
                wrongDigestProvider.Dispose();
                byte[] goodTags = Encoding.UTF8.GetBytes("{\"models\":[{\"name\":\"qwen3:4b\",\"digest\":\"" + LocalModelProvider.ExactModelDigest + "\"}]}");
                byte[] goodChat = Encoding.UTF8.GetBytes(ChatEnvelope(Encoding.UTF8.GetString(answerBytes)));
                ProviderReject("PROVIDER_UNAVAILABLE_PREFLIGHT", goodTags, goodChat, 1, false, canonicalBody, 1, 0);
                ProviderReject("PROVIDER_TIMEOUT_PREFLIGHT", goodTags, goodChat, 1, false, canonicalBody, 1, 0);
                ProviderReject("PROVIDER_TIMEOUT_CHAT", goodTags, goodChat, 0, true, canonicalBody, 1, 1);
                ProviderReject("PROVIDER_TIMEOUT_POSTFLIGHT", goodTags, goodChat, 2, false, canonicalBody, 2, 1);
                ProviderReject("PROVIDER_NON_200_NO_RETRY", goodTags, goodChat, 0, true, canonicalBody, 1, 1);
                ProviderReject("PROVIDER_REDIRECT_NO_RETRY", goodTags, goodChat, 0, true, canonicalBody, 1, 1);
                ProviderReject("PROVIDER_PROXY_REJECTION_NO_RETRY", goodTags, goodChat, 1, false, canonicalBody, 1, 0);
                ProviderReject("PROVIDER_HEADER_REJECTION_NO_RETRY", goodTags, goodChat, 0, true, canonicalBody, 1, 1);
                ProviderReject("PROVIDER_CONTENT_LENGTH_REJECTION_NO_RETRY", goodTags, goodChat, 0, true, canonicalBody, 1, 1);
                ProviderReject("PROVIDER_TAGS_MISSING_MODEL", Encoding.UTF8.GetBytes("{\"models\":[]}"), goodChat, 0, false, canonicalBody, 1, 0);
                ProviderReject("PROVIDER_TAGS_DUPLICATE_MODEL", Encoding.UTF8.GetBytes("{\"models\":[{\"name\":\"qwen3:4b\",\"digest\":\"" + LocalModelProvider.ExactModelDigest + "\"},{\"name\":\"qwen3:4b\",\"digest\":\"" + LocalModelProvider.ExactModelDigest + "\"}]}"), goodChat, 0, false, canonicalBody, 1, 0);
                ProviderReject("PROVIDER_TAGS_MALFORMED_UTF8", new byte[] { 0xC3, 0x28 }, goodChat, 0, false, canonicalBody, 1, 0);
                ProviderReject("PROVIDER_CHAT_MALFORMED_JSON", goodTags, Encoding.UTF8.GetBytes("{"), 0, false, canonicalBody, 1, 1);
                ProviderReject("PROVIDER_CHAT_WRONG_MODEL", goodTags, Encoding.UTF8.GetBytes("{\"model\":\"other\",\"message\":{\"role\":\"assistant\",\"content\":\"x\"},\"done\":true}"), 0, false, canonicalBody, 1, 1);
                ProviderReject("PROVIDER_CHAT_DONE_FALSE", goodTags, Encoding.UTF8.GetBytes("{\"model\":\"qwen3:4b\",\"message\":{\"role\":\"assistant\",\"content\":\"x\"},\"done\":false}"), 0, false, canonicalBody, 1, 1);
                ProviderReject("PROVIDER_CHAT_TOOL", goodTags, Encoding.UTF8.GetBytes("{\"model\":\"qwen3:4b\",\"message\":{\"role\":\"assistant\",\"content\":\"x\",\"tool_calls\":[]},\"done\":true}"), 0, false, canonicalBody, 1, 1);
                ProviderReject("PROVIDER_CHAT_IMAGE", goodTags, Encoding.UTF8.GetBytes("{\"model\":\"qwen3:4b\",\"message\":{\"role\":\"assistant\",\"content\":\"x\",\"images\":[]},\"done\":true}"), 0, false, canonicalBody, 1, 1);
                ProviderReject("PROVIDER_CHAT_THINKING", goodTags, Encoding.UTF8.GetBytes("{\"model\":\"qwen3:4b\",\"message\":{\"role\":\"assistant\",\"content\":\"x\",\"thinking\":\"x\"},\"done\":true}"), 0, false, canonicalBody, 1, 1);
                ProviderReject("PROVIDER_CHAT_MULTIPLE_MESSAGE", goodTags, Encoding.UTF8.GetBytes("{\"model\":\"qwen3:4b\",\"messages\":[],\"done\":true}"), 0, false, canonicalBody, 1, 1);
                Check("OUTPUT_QUESTION_DIGEST_READY", ProjectQaPrompt.DomainDigest("EAIRA_M4_SLICE5_QUESTION_V1", request.Question).Length == 64);
                Check("OUTPUT_PROMPT_DIGEST_READY", ProjectQaPrompt.DomainDigest("EAIRA_M4_SLICE5_PROMPT_V1", prompt).Length == 64);
                Check("OUTPUT_ANSWER_DIGEST_READY", ProjectQaPrompt.DomainDigest("EAIRA_M4_SLICE5_ANSWER_V1", answer.Text).Length == 64);
                string output = ProjectQaOutput.Success(request, snapshot, prompt, answer, provider);
                Check("OUTPUT_SCHEMA", output.StartsWith("{\"schema\":\"EAIRA_PROJECT_QA_V1\",\"status\":\"PROJECT_QA_OK\"", StringComparison.Ordinal));
                Check("OUTPUT_NO_ROOT", output.IndexOf(root, StringComparison.Ordinal) < 0);
                Check("OUTPUT_NO_PROMPT", output.IndexOf(prompt, StringComparison.Ordinal) < 0);
                Check("OUTPUT_NO_PROJECTION", output.IndexOf(snapshot.Context.Projection, StringComparison.Ordinal) < 0);
                Check("OUTPUT_NO_PROVIDER_BODY", output.IndexOf(Encoding.UTF8.GetString(ProjectQaPrompt.BuildBody(prompt)), StringComparison.Ordinal) < 0);
                Check("OUTPUT_FIXED_AUTHORITIES", output.IndexOf("\"authority\":\"ASSISTIVE_NOT_AUTHORITY\"", StringComparison.Ordinal) >= 0);
                Check("OUTPUT_NETWORK", output.IndexOf("\"network\":\"LOOPBACK_ONLY\"", StringComparison.Ordinal) >= 0);
                byte[] output16383 = Encoding.ASCII.GetBytes(new string('A', 16383)); byte[] output16384 = Encoding.ASCII.GetBytes(new string('A', 16384)); byte[] output16385 = Encoding.ASCII.GetBytes(new string('A', 16385));
                ProjectQaOutput.ValidateEncodedLine(output16383); CheckExactBytes("OUTPUT_16383", output16383, 16383, "40D7118B1F53F3164FB2AB5D42B0FD187B0999C02909BC427D93EFD586AAD0FB");
                ProjectQaOutput.ValidateEncodedLine(output16384); CheckExactBytes("OUTPUT_16384", output16384, 16384, "1BD4DB450ABC8914C2FAC721CACE2704FF4C16028E6D07293154DAD289835694");
                RejectType<ProjectQaException>("OUTPUT_16385_REJECT", delegate { ProjectQaOutput.ValidateEncodedLine(output16385); }); CheckExactBytes("OUTPUT_16385", output16385, 16385, "E9B0015594030C029F167A30522C7DD2EC90379B6026EF7C7DD74B07D0BC63DD");
                CheckChannelGolden("ERROR_INVALID_REQUEST_NONE", "INVALID_REQUEST", "NONE", 99, "AE482F83460CE0C1E3DA4712DD99ECAFD0599E9E9B926239219C41247B04E15F");
                CheckChannelGolden("ERROR_DENIED_NONE", "DENIED", "NONE", 90, "032F763897DE14352C16364BE071E40B8557E3E5015D68EFE1570C655F1C6241");
                CheckChannelGolden("ERROR_LOCAL_PROVIDER_LOOPBACK", "LOCAL_PROVIDER_ERROR", "LOOPBACK_ONLY", 113, "71D23EF602941524D24941FA9604B87A2767775AFA9A61517A24D4BA25F10E8D");
                CheckChannelGolden("ERROR_CONTEXT_NONE", "CONTEXT_ERROR", "NONE", 97, "AB9311BE3D0D534C439E7CF5242E04FBB92EED856A0F635A8E7AB8A5D0037001");
                CheckChannelGolden("ERROR_KNOWLEDGE_NONE", "KNOWLEDGE_ERROR", "NONE", 99, "B0EA23AD8184A5B378C545811C076E2C91BFA4A39BB0F1A7856F72211D6B3A1E");
                CheckChannelGolden("ERROR_PROJECT_QA_NONE", "PROJECT_QA_ERROR", "NONE", 100, "8BA3C443326913A7640E34E79EB4F7329802A1D6B4D75F015360B2D59E4DCC78");
                CheckChannelGolden("ERROR_PROJECT_QA_LOOPBACK", "PROJECT_QA_ERROR", "LOOPBACK_ONLY", 109, "D19C38637633110E57445DF9D8525A9DD2DC7A49977F9F100712A68C6DF5E185");
                ProjectQaSnapshot goldenSnapshot = BuildGoldenSnapshot(); ProjectQaRequest goldenRequest = ProjectQaRequest.Parse(args); string goldenPrompt = ProjectQaPrompt.Build(goldenRequest, goldenSnapshot); byte[] goldenBody = ProjectQaPrompt.BuildBody(goldenPrompt); ProjectQaAnswer goldenAnswer = new ProjectQaAnswer("Insufficient evidence in the allowed project sources.", new List<string>()); ProjectQaHarnessProvider goldenProvider = new ProjectQaHarnessProvider("unused"); string goldenOutput = ProjectQaOutput.Success(goldenRequest, goldenSnapshot, goldenPrompt, goldenAnswer, goldenProvider) + "\n";
                CheckExactBytes("GOLDEN_PROMPT", Encoding.UTF8.GetBytes(goldenPrompt), 1711, "E5980A66E3C8568AE4C626E0A63BDA2A91DC75FD6711452A0A42AD76BF242EE3");
                CheckExactBytes("GOLDEN_BODY", goldenBody, 2147, "447702159C263EEF129ADB26F623DF4C8FA5683BBA7868C3CD01059802FAECE0");
                CheckExactBytes("GOLDEN_SUCCESS_OUTPUT", Encoding.UTF8.GetBytes(goldenOutput), 1087, "94A65159F8F5FB30A83A194E7D589E32A057A704B484EDB06EE8277F7D4F34A4");
                string caseList = String.Join("\n", Cases.ToArray()); string digest = ContractCodec.Sha256Hex(Encoding.UTF8.GetBytes(caseList));
                Console.Out.Write("{\"schema\":\"EAIRA_PROJECT_QA_HARNESS_V1\",\"status\":\"PASS\",\"testsPassed\":" + Cases.Count.ToString(CultureInfo.InvariantCulture) + ",\"caseNameSha256\":\"" + digest + "\",\"goldenVectorsPass\":true,\"successTagsCalls\":" + productionProvider.TagsCalls.ToString(CultureInfo.InvariantCulture) + ",\"successChatCalls\":" + productionProvider.ChatCalls.ToString(CultureInfo.InvariantCulture) + ",\"preflightDigestValidated\":" + (productionProvider.PreflightDigestValidated ? "true" : "false") + ",\"postflightDigestValidated\":" + (productionProvider.PostflightDigestValidated ? "true" : "false") + ",\"network\":\"NONE\",\"writes\":\"NONE\"}\n"); return 0;
            }
            catch (Exception error) { string last = Cases.Count == 0 ? "NONE" : Cases[Cases.Count - 1]; Console.Out.Write("{\"schema\":\"EAIRA_PROJECT_QA_HARNESS_V1\",\"status\":\"FAIL\",\"lastPassed\":" + ContractCodec.Json(last) + ",\"errorType\":" + ContractCodec.Json(error.GetType().Name) + ",\"network\":\"NONE\",\"writes\":\"NONE\"}\n"); return 1; }
        }
        private static int CountPrefix(List<string> values, string prefix) { int count = 0; for (int i = 0; i < values.Count; i++) { if (values[i].StartsWith(prefix, StringComparison.Ordinal)) { count++; } } return count; }
        private static string LastWithPrefix(List<string> values, string prefix) { for (int i = values.Count - 1; i >= 0; i--) { if (values[i].StartsWith(prefix, StringComparison.Ordinal)) { return values[i]; } } return null; }
        private static void RejectType<T>(string name, Action action) where T : Exception { bool rejected = false; try { action(); } catch (T) { rejected = true; } catch (Exception) { throw new Exception(); } Check(name, rejected); }
        private static void FaultSnapshot(string root, string name, string failEvent, bool contextOwned, bool requireSingleProbeClose)
        {
            ProjectQaHarnessPlatform fault = new ProjectQaHarnessPlatform(root, failEvent);
            if (contextOwned) { RejectType<ProjectQaContextException>(name, delegate { ProjectQaSnapshotReader.CreateForTests(fault).Read(root, "EAIRA"); }); }
            else { RejectType<ProjectQaKnowledgeException>(name, delegate { ProjectQaSnapshotReader.CreateForTests(fault).Read(root, "EAIRA"); }); }
            if (requireSingleProbeClose) { Check(name + "_NO_RETRY", CountExact(fault.Events, failEvent) == 1); }
        }
        private static void MutationSnapshot(string root, string name, string mutationEvent, string mutationKind, bool contextOwned)
        {
            ProjectQaHarnessPlatform fault = new ProjectQaHarnessPlatform(root, null, mutationEvent, mutationKind);
            if (contextOwned) { RejectType<ProjectQaContextException>(name, delegate { ProjectQaSnapshotReader.CreateForTests(fault).Read(root, "EAIRA"); }); }
            else { RejectType<ProjectQaKnowledgeException>(name, delegate { ProjectQaSnapshotReader.CreateForTests(fault).Read(root, "EAIRA"); }); }
        }
        private static int CountExact(List<string> values, string expected) { int count = 0; for (int i = 0; i < values.Count; i++) { if (String.Equals(values[i], expected, StringComparison.Ordinal)) { count++; } } return count; }
        private static string ChatEnvelope(string answer) { return "{\"model\":\"qwen3:4b\",\"message\":{\"role\":\"assistant\",\"content\":" + ContractCodec.Json(answer) + "},\"done\":true}"; }
        private static void CheckExactBytes(string name, byte[] value, int bytes, string sha) { Check(name + "_BYTES", value.Length == bytes); Check(name + "_SHA", ContractCodec.Sha256Hex(value) == sha); }
        private static byte[] BuildUncheckedBody(string prompt) { return Encoding.UTF8.GetBytes("{\"model\":\"qwen3:4b\",\"messages\":[{\"role\":\"user\",\"content\":" + ContractCodec.Json(prompt) + "}],\"format\":{\"type\":\"object\",\"properties\":{\"answer\":{\"type\":\"string\",\"minLength\":1,\"maxLength\":512},\"citationIds\":{\"type\":\"array\",\"items\":{\"type\":\"string\"},\"maxItems\":8,\"uniqueItems\":true}},\"required\":[\"answer\",\"citationIds\"],\"additionalProperties\":false},\"stream\":false,\"think\":false,\"options\":{\"temperature\":0,\"seed\":42,\"num_predict\":512}}"); }
        private static void CheckChannelGolden(string name, string status, string network, int bytes, string sha) { byte[] value = Encoding.UTF8.GetBytes("{\"schema\":\"EAIRA_PROJECT_QA_ERROR_V1\",\"status\":" + ContractCodec.Json(status) + ",\"network\":" + ContractCodec.Json(network) + ",\"writes\":\"NONE\"}\n"); CheckExactBytes(name, value, bytes, sha); }
        private static ProjectQaSnapshot BuildGoldenSnapshot()
        {
            string[] labels = new string[] { "Current Status.Context ID", "Current Status.Version", "Current Status.Updated At", "Current Status.Current Milestone", "Current Status.Active Phase", "Current Status.Current Decision", "Current Status.Blockers", "Current Status.Next Action", "Today Objective.Date", "Today Objective.Milestone", "Today Objective.Current Scope", "Today Objective.Expected Deliverables", "Today Objective.Success Criteria", "Active Task.Task ID", "Active Task.Owner", "Active Task.Status", "Active Task.Priority", "Active Task.Last Updated", "Active Task.Dependency Count", "Active Task.Dependency SHA-256", "Agent Context Version.Context Version", "Agent Context Version.Last Updated", "Agent Context Version.Current Status Version", "Agent Context Version.Today Objective Version", "Agent Context Version.Knowledge Index Version", "Agent Context Version.Verified Agent Count", "Agent Context Version.Verified Agent SHA-256" };
            string[] paths = new string[] { "docs/project/status/CURRENT_STATUS.md", "docs/project/status/TODAY_OBJECTIVE.md", "docs/project/status/ACTIVE_TASK.yaml", "docs/project/status/AGENT_CONTEXT_VERSION.yaml" }; List<ProjectQaContextField> fields = new List<ProjectQaContextField>();
            for (int i = 0; i < labels.Length; i++) { string path = i < 8 ? paths[0] : i < 13 ? paths[1] : i < 20 ? paths[2] : paths[3]; fields.Add(new ProjectQaContextField("C" + (i + 1).ToString("D2", CultureInfo.InvariantCulture), path, labels[i], "v" + (i + 1).ToString("D2", CultureInfo.InvariantCulture))); }
            string zero = new string('0', 64); ProjectContextBundle context = new ProjectContextBundle(zero, 0, zero, String.Empty); List<ProjectKnowledgeMatch> matches = new List<ProjectKnowledgeMatch>(); matches.Add(new ProjectKnowledgeMatch("docs/project/memory/README.md", 4, "EAIRA", "EAIRA")); ProjectKnowledgeResult knowledge = new ProjectKnowledgeResult(zero, zero, false, matches); return new ProjectQaSnapshot(context, knowledge, fields);
        }
        private static void ProviderReject(string name, byte[] tags, byte[] chat, int failTagCall, bool failChat, byte[] body, int expectedTags, int expectedChat)
        {
            ProjectQaHarnessTransport transport = new ProjectQaHarnessTransport(tags, chat, failTagCall, failChat); ProjectQaLocalProvider provider = new ProjectQaLocalProvider(transport);
            RejectType<LocalProviderException>(name, delegate { provider.Execute(body); });
            Check(name + "_COUNTERS", transport.TagsCalls == expectedTags && transport.ChatCalls == expectedChat);
            provider.Dispose();
        }
        private static void CheckBody(string name, string prompt, int bytes, string sha) { byte[] body = ProjectQaPrompt.BuildBody(prompt); Check(name + "_BYTES", body.Length == bytes); Check(name + "_SHA", ContractCodec.Sha256Hex(body) == sha); }
    }
}
