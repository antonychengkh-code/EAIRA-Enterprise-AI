using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;

namespace EAIRA.AgentServices.Functional
{
    internal sealed class ProjectKnowledgeRequestException : Exception { internal ProjectKnowledgeRequestException() : base(String.Empty) { } }
    internal sealed class ProjectKnowledgeException : Exception { internal ProjectKnowledgeException() : base(String.Empty) { } }

    internal sealed class ProjectKnowledgeMatch
    {
        internal string Path, Heading, Excerpt;
        internal int Line;
        internal ProjectKnowledgeMatch(string path, int line, string heading, string excerpt) { Path = path; Line = line; Heading = heading; Excerpt = excerpt; }
    }

    internal sealed class ProjectKnowledgeResult
    {
        internal string QuerySha256, ResultSetSha256;
        internal bool Truncated;
        internal List<ProjectKnowledgeMatch> Matches;
        internal ProjectKnowledgeResult(string queryHash, string resultHash, bool truncated, List<ProjectKnowledgeMatch> matches) { QuerySha256 = queryHash; ResultSetSha256 = resultHash; Truncated = truncated; Matches = matches; }

        internal string ToCanonicalJson()
        {
            StringBuilder value = new StringBuilder();
            value.Append("{\"schema\":\"EAIRA_PROJECT_KNOWLEDGE_QUERY_V1\",\"status\":\"KNOWLEDGE_QUERY_OK\",\"querySha256\":");
            value.Append(ContractCodec.Json(QuerySha256)).Append(",\"resultSetSha256\":").Append(ContractCodec.Json(ResultSetSha256));
            value.Append(",\"matchCount\":").Append(Matches.Count.ToString(CultureInfo.InvariantCulture));
            value.Append(",\"truncated\":").Append(Truncated ? "true" : "false");
            value.Append(",\"authority\":\"NAVIGATIONAL_NOT_AUTHORITY\",\"network\":\"NONE\",\"writes\":\"NONE\",\"matches\":[");
            for (int index = 0; index < Matches.Count; index++)
            {
                if (index != 0) { value.Append(','); }
                ProjectKnowledgeMatch item = Matches[index];
                value.Append("{\"path\":").Append(ContractCodec.Json(item.Path));
                value.Append(",\"line\":").Append(item.Line.ToString(CultureInfo.InvariantCulture));
                value.Append(",\"heading\":").Append(ContractCodec.Json(item.Heading));
                value.Append(",\"excerpt\":").Append(ContractCodec.Json(item.Excerpt));
                value.Append(",\"authority\":\"NAVIGATIONAL_NOT_AUTHORITY\"}");
            }
            value.Append("]}");
            return value.ToString();
        }
    }

    internal sealed class ProjectKnowledgeQuery
    {
        private const int MaximumPhysicalBytes = 65539, MaximumContentBytes = 65536, MaximumAggregateBytes = 262144;
        private const uint Directory = 0x10, Reparse = 0x400, Offline = 0x1000, RecallOpen = 0x40000, RecallData = 0x400000, DirectoryTag = 0x9000E01A, FileTag = 0x9000601A;
        private static readonly string[] Paths = new string[] {
            "docs/project/memory/README.md", "docs/project/memory/DECISION_INDEX.md", "docs/project/memory/DISCOVERY_INDEX.md",
            "docs/project/memory/PROCEDURE_INDEX.md", "docs/project/memory/OPEN_QUESTIONS.md",
            "docs/project/memory/STABILITY_CHECKLIST.md", "docs/project/memory/MEMORY_SCHEMA.md"
        };
        private readonly IProjectContextReadOnlyPlatform platform;
        private ProjectKnowledgeQuery(IProjectContextReadOnlyPlatform value) { if (value == null) { throw new ProjectKnowledgeException(); } platform = value; }

#if EAIRA_PROJECT_KNOWLEDGE_NATIVE
        internal static ProjectKnowledgeQuery CreateNative() { return new ProjectKnowledgeQuery(new ProjectContextWin32Platform()); }
#endif
#if EAIRA_PROJECT_KNOWLEDGE_TEST_SEAM
        internal static ProjectKnowledgeQuery CreateForTests(IProjectContextReadOnlyPlatform value) { return new ProjectKnowledgeQuery(value); }
#endif

        internal static string NormalizeQueryOrThrowRequest(string value)
        {
            try
            {
                ContractCodec.RequireWellFormedUtf16(value, "Query");
                string normalized = value.Normalize(NormalizationForm.FormKC);
                int scalars = 0;
                for (int index = 0; index < normalized.Length; index++)
                {
                    int code = normalized[index];
                    if (Char.IsHighSurrogate(normalized[index])) { code = Char.ConvertToUtf32(normalized[index], normalized[++index]); }
                    if (code <= 0x1F || (code >= 0x7F && code <= 0x9F)) { throw new ProjectKnowledgeRequestException(); }
                    scalars++;
                }
                if (scalars < 1 || scalars > 64) { throw new ProjectKnowledgeRequestException(); }
                return normalized;
            }
            catch (ProjectKnowledgeRequestException) { throw; }
            catch (Exception) { throw new ProjectKnowledgeRequestException(); }
        }

        internal ProjectKnowledgeResult Execute(string absoluteRoot, string normalizedQuery)
        {
            List<IPinnedAncestorHandle> pinned = new List<IPinnedAncestorHandle>();
            Exception primary = null;
            try
            {
                string root = ValidateRoot(absoluteRoot);
                string[] ancestors = new string[] { root, root + "\\docs", root + "\\docs\\project", root + "\\docs\\project\\memory" };
                for (int index = 0; index < ancestors.Length; index++)
                {
                    IPinnedAncestorHandle handle = platform.OpenPinnedAncestor(ancestors[index]);
                    if (handle == null) { throw new ProjectKnowledgeException(); }
                    pinned.Add(handle);
                    ValidateMetadata(platform.QueryPinnedAncestor(handle), ancestors[index], true);
                }
                List<byte[]> physicalFiles = new List<byte[]>();
                for (int index = 0; index < Paths.Length; index++)
                {
                    string exact = root + "\\" + Paths[index].Replace('/', '\\');
                    byte[] physical = ReadOne(exact);
                    physicalFiles.Add(physical);
                }
                return BuildResultFromPhysicalFiles(physicalFiles, normalizedQuery);
            }
            catch (Exception error) { primary = error; throw error is ProjectKnowledgeException ? error : new ProjectKnowledgeException(); }
            finally
            {
                bool closeFailed = false;
                for (int index = pinned.Count - 1; index >= 0; index--) { try { platform.ClosePinnedAncestor(pinned[index]); } catch (Exception) { closeFailed = true; } }
                if (primary == null && closeFailed) { throw new ProjectKnowledgeException(); }
            }
        }

        internal static ProjectKnowledgeResult BuildResultFromPhysicalFiles(IList<byte[]> physicalFiles, string normalizedQuery)
        {
            if (physicalFiles == null || physicalFiles.Count != Paths.Length || normalizedQuery == null) { throw new ProjectKnowledgeException(); }
            int aggregate = 0;
            List<ProjectKnowledgeMatch> matches = new List<ProjectKnowledgeMatch>();
            bool truncated = false;
            for (int index = 0; index < Paths.Length; index++)
            {
                byte[] physical = physicalFiles[index];
                if (physical == null || physical.Length > MaximumPhysicalBytes) { throw new ProjectKnowledgeException(); }
                int offset = physical.Length >= 3 && physical[0] == 0xEF && physical[1] == 0xBB && physical[2] == 0xBF ? 3 : 0;
                int contentCount = physical.Length - offset;
                if (contentCount > MaximumContentBytes || checked(aggregate + contentCount) > MaximumAggregateBytes) { throw new ProjectKnowledgeException(); }
                aggregate += contentCount;
                byte[] content = new byte[contentCount];
                Buffer.BlockCopy(physical, offset, content, 0, contentCount);
                Scan(Paths[index], content, normalizedQuery, matches, ref truncated);
            }
            ProjectKnowledgeResult result = new ProjectKnowledgeResult(QueryDigest(normalizedQuery), ResultDigest(matches, truncated), truncated, matches);
            CanonicalJsonOrThrow(result);
            return result;
        }

        private byte[] ReadOne(string exact)
        {
            ILeafProbeHandle probe = null; IApprovedContentHandle content = null; Exception primary = null;
            try
            {
                probe = platform.OpenLeafProbe(exact);
                ProjectContextFileMetadata probeData = platform.QueryLeafProbe(probe);
                ValidateMetadata(probeData, exact, false);
                if (probeData.Length > MaximumPhysicalBytes || probeData.Length > Int32.MaxValue) { throw new ProjectKnowledgeException(); }
                content = platform.OpenApprovedContent(exact);
                ProjectContextFileMetadata before = platform.QueryApprovedContent(content);
                ValidateMetadata(before, exact, false);
                if (!probeData.StableEquals(before)) { throw new ProjectKnowledgeException(); }
                byte[] raw = platform.ReadApprovedContent(content, checked((int)before.Length));
                ProjectContextFileMetadata after = platform.QueryApprovedContent(content);
                if (raw == null || raw.Length != (int)before.Length || !before.StableEquals(after)) { throw new ProjectKnowledgeException(); }
                return raw;
            }
            catch (Exception error) { primary = error; throw error is ProjectKnowledgeException ? error : new ProjectKnowledgeException(); }
            finally
            {
                bool failed = false;
                if (content != null) { try { platform.CloseApprovedContent(content); } catch (Exception) { failed = true; } }
                if (probe != null) { try { platform.CloseLeafProbe(probe); } catch (Exception) { failed = true; } }
                if (primary == null && failed) { throw new ProjectKnowledgeException(); }
            }
        }

        private static void ValidateMetadata(ProjectContextFileMetadata value, string exact, bool directory)
        {
            if (value == null || !String.Equals(value.CanonicalPath, exact, StringComparison.Ordinal)) { throw new ProjectKnowledgeException(); }
            bool isDirectory = (value.Attributes & Directory) != 0, reparse = (value.Attributes & Reparse) != 0;
            if (isDirectory != directory || (value.Attributes & (Offline | RecallOpen | RecallData)) != 0) { throw new ProjectKnowledgeException(); }
            if (!reparse && value.ReparseTag == 0) { return; }
            if (reparse && directory && value.ReparseTag == DirectoryTag) { return; }
            if (reparse && !directory && value.ReparseTag == FileTag) { return; }
            throw new ProjectKnowledgeException();
        }

        private static string ValidateRoot(string root)
        {
            if (String.IsNullOrEmpty(root) || root.Length < 4 || root[1] != ':' || root[2] != '\\' || root.EndsWith("\\", StringComparison.Ordinal) || root.IndexOf('/') >= 0 || root.IndexOf("\\\\", StringComparison.Ordinal) >= 0 || root.IndexOf(':', 2) >= 0) { throw new ProjectKnowledgeException(); }
            if (root[0] < 'A' || root[0] > 'Z') { throw new ProjectKnowledgeException(); }
            string[] parts = root.Substring(3).Split('\\');
            for (int index = 0; index < parts.Length; index++) { if (parts[index].Length == 0 || parts[index] == "." || parts[index] == ".." || parts[index].EndsWith(" ", StringComparison.Ordinal) || parts[index].EndsWith(".", StringComparison.Ordinal) || parts[index].IndexOf('~') >= 0) { throw new ProjectKnowledgeException(); } }
            return root;
        }

        private static void Scan(string path, byte[] content, string query, List<ProjectKnowledgeMatch> matches, ref bool truncated)
        {
            string text;
            try { text = ContractCodec.Utf8Strict("Memory").GetString(content); } catch (Exception) { throw new ProjectKnowledgeException(); }
            if (text.IndexOf('\r') >= 0)
            {
                for (int i = 0; i < text.Length; i++) { if (text[i] == '\r' && (i + 1 >= text.Length || text[i + 1] != '\n')) { throw new ProjectKnowledgeException(); } }
                if (text.Replace("\r\n", String.Empty).IndexOf('\n') >= 0) { throw new ProjectKnowledgeException(); }
            }
            bool crlf = text.IndexOf("\r\n", StringComparison.Ordinal) >= 0;
            string terminator = crlf ? "\r\n" : "\n";
            string[] lines = crlf ? text.Split(new string[] { "\r\n" }, StringSplitOptions.None) : text.Split(new char[] { '\n' });
            bool finalTerminator = text.EndsWith(terminator, StringComparison.Ordinal);
            int logicalLineCount = lines.Length - (finalTerminator ? 1 : 0);
            if (logicalLineCount > 4096) { throw new ProjectKnowledgeException(); }
            if (lines.Length == 0 || lines[0] != "---") { throw new ProjectKnowledgeException(); }
            int close = -1, frontBytes = 0;
            for (int i = 0; i < lines.Length; i++)
            {
                int lineBytes = ContractCodec.Utf8Strict("Line").GetByteCount(lines[i]);
                if (lineBytes > 1024) { throw new ProjectKnowledgeException(); }
                bool terminated = i < lines.Length - 1;
                frontBytes += lineBytes + (terminated ? terminator.Length : 0);
                if (i > 0 && lines[i] == "---") { if (!terminated) { throw new ProjectKnowledgeException(); } close = i; break; }
            }
            if (close < 2 || close + 1 > 64 || frontBytes > 8192) { throw new ProjectKnowledgeException(); }
            string heading = String.Empty;
            for (int i = close + 1; i < lines.Length; i++)
            {
                string line = lines[i];
                if (ContractCodec.Utf8Strict("Line").GetByteCount(line) > 1024) { throw new ProjectKnowledgeException(); }
                string recognized;
                if (TryHeading(line, out recognized)) { heading = recognized; }
                if (line.Length == 0) { continue; }
                string normalized;
                try { normalized = line.Normalize(NormalizationForm.FormKC); } catch (Exception) { throw new ProjectKnowledgeException(); }
                if (normalized.IndexOf(query, StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    if (matches.Count < 8) { matches.Add(new ProjectKnowledgeMatch(path, i + 1, Truncate(heading, 160), Truncate(TrimAscii(line), 240))); }
                    else { truncated = true; }
                }
            }
        }

        private static bool TryHeading(string line, out string heading)
        {
            heading = String.Empty; int count = 0;
            while (count < line.Length && count < 7 && line[count] == '#') { count++; }
            if (count < 1 || count > 6 || (count < line.Length && line[count] != ' ')) { return false; }
            heading = TrimAscii(count == line.Length ? String.Empty : line.Substring(count + 1)); return true;
        }
        private static string TrimAscii(string value) { return value.Trim(new char[] { ' ', '\t' }); }
        private static string Truncate(string value, int maximum)
        {
            if (ContractCodec.Utf8Strict("Value").GetByteCount(value) <= maximum) { return value; }
            int end = 0;
            while (end < value.Length) { int next = end + (Char.IsHighSurrogate(value[end]) ? 2 : 1); if (ContractCodec.Utf8Strict("Value").GetByteCount(value.Substring(0, next)) > maximum) { break; } end = next; }
            return value.Substring(0, end);
        }

        private static string QueryDigest(string query)
        {
            byte[] q = ContractCodec.Utf8Strict("Query").GetBytes(query);
            return ContractCodec.Sha256Hex(ContractCodec.Concat(ContractCodec.Utf8Strict("Domain").GetBytes("EAIRA-KNOWLEDGE-QUERY-V1"), new byte[] { 0 }, ContractCodec.U32BE((uint)q.Length), q));
        }

        internal static string CanonicalJsonOrThrow(ProjectKnowledgeResult result)
        {
            if (result == null) { throw new ProjectKnowledgeException(); }
            string value = result.ToCanonicalJson();
            if (ContractCodec.Utf8Strict("Output").GetByteCount(value) + 1 > 16384) { throw new ProjectKnowledgeException(); }
            return value;
        }
        private static string ResultDigest(List<ProjectKnowledgeMatch> matches, bool truncated)
        {
            List<byte[]> frames = new List<byte[]>(); frames.Add(ContractCodec.Utf8Strict("Domain").GetBytes("EAIRA-KNOWLEDGE-RESULTSET-V1")); frames.Add(new byte[] { 0 }); frames.Add(ContractCodec.U32BE((uint)matches.Count)); frames.Add(new byte[] { truncated ? (byte)1 : (byte)0 });
            for (int index = 0; index < matches.Count; index++)
            {
                ProjectKnowledgeMatch item = matches[index];
                AddString(frames, item.Path); frames.Add(ContractCodec.U32BE((uint)item.Line)); AddString(frames, item.Heading); AddString(frames, item.Excerpt); AddString(frames, "NAVIGATIONAL_NOT_AUTHORITY");
            }
            return ContractCodec.Sha256Hex(ContractCodec.Concat(frames.ToArray()));
        }
        private static void AddString(List<byte[]> frames, string value) { byte[] bytes = ContractCodec.Utf8Strict("Frame").GetBytes(value); frames.Add(ContractCodec.U32BE((uint)bytes.Length)); frames.Add(bytes); }
    }
}
