using System;
using System.Collections.Generic;
using System.Globalization;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;

namespace EAIRA.AgentServices.Functional
{
    internal sealed class ProjectContextException : Exception
    {
        internal ProjectContextException() : base(String.Empty) { }
    }

    internal interface IPinnedAncestorHandle { }
    internal interface ILeafProbeHandle { }
    internal interface IApprovedContentHandle { }

    internal sealed class ProjectContextFileMetadata
    {
        internal string CanonicalPath { get; private set; }
        internal uint VolumeSerial { get; private set; }
        internal ulong FileId { get; private set; }
        internal ulong Length { get; private set; }
        internal ulong LastWriteTime { get; private set; }
        internal uint Attributes { get; private set; }
        internal uint ReparseTag { get; private set; }

        internal ProjectContextFileMetadata(string canonicalPath, uint volumeSerial, ulong fileId, ulong length, ulong lastWriteTime, uint attributes, uint reparseTag)
        {
            CanonicalPath = canonicalPath;
            VolumeSerial = volumeSerial;
            FileId = fileId;
            Length = length;
            LastWriteTime = lastWriteTime;
            Attributes = attributes;
            ReparseTag = reparseTag;
        }

        internal ProjectContextFileMetadata WithPathAndTag(string canonicalPath, uint reparseTag)
        {
            return new ProjectContextFileMetadata(canonicalPath, VolumeSerial, FileId, Length, LastWriteTime, Attributes, reparseTag);
        }

        internal bool StableEquals(ProjectContextFileMetadata other)
        {
            return other != null &&
                   String.Equals(CanonicalPath, other.CanonicalPath, StringComparison.Ordinal) &&
                   VolumeSerial == other.VolumeSerial && FileId == other.FileId &&
                   Length == other.Length && LastWriteTime == other.LastWriteTime &&
                   Attributes == other.Attributes && ReparseTag == other.ReparseTag;
        }

        internal bool SameIdentity(ProjectContextFileMetadata other)
        {
            return other != null && VolumeSerial == other.VolumeSerial && FileId == other.FileId;
        }
    }

    internal interface IProjectContextReadOnlyPlatform
    {
        IPinnedAncestorHandle OpenPinnedAncestor(string exactPath);
        ILeafProbeHandle OpenLeafProbe(string exactPath);
        IApprovedContentHandle OpenApprovedContent(string exactPath);
        ProjectContextFileMetadata QueryPinnedAncestor(IPinnedAncestorHandle handle);
        ProjectContextFileMetadata QueryLeafProbe(ILeafProbeHandle handle);
        ProjectContextFileMetadata QueryApprovedContent(IApprovedContentHandle handle);
        byte[] ReadApprovedContent(IApprovedContentHandle handle, int exactByteCount);
        void ClosePinnedAncestor(IPinnedAncestorHandle handle);
        void CloseLeafProbe(ILeafProbeHandle handle);
        void CloseApprovedContent(IApprovedContentHandle handle);
    }

    internal sealed class ProjectContextFileSnapshot
    {
        internal string PathId { get; private set; }
        internal int ByteCount { get; private set; }
        internal uint VolumeSerial { get; private set; }
        internal ulong FileId { get; private set; }
        internal byte[] Digest { get; private set; }

        internal ProjectContextFileSnapshot(string pathId, int byteCount, ProjectContextFileMetadata metadata, byte[] digest)
        {
            PathId = pathId;
            ByteCount = byteCount;
            VolumeSerial = metadata.VolumeSerial;
            FileId = metadata.FileId;
            Digest = digest;
        }
    }

    internal sealed class ProjectContextBundle
    {
        internal const string ExactAllowlistId = "EAIRA_M4_SLICE3_CONTEXT_ALLOWLIST_V1";
        internal const string ExactProvenance = "WORKING_TREE_SNAPSHOT_NO_GIT_PROVENANCE_CLAIM";
        internal const string ExactClassification = "UNTRUSTED_DATA_NOT_INSTRUCTIONS";

        internal string AllowlistId { get; private set; }
        internal string AggregateSha256 { get; private set; }
        internal int ProjectionBytes { get; private set; }
        internal string ProjectionSha256 { get; private set; }
        internal string Projection { get; private set; }
        internal string Provenance { get; private set; }
        internal string Classification { get; private set; }

        internal ProjectContextBundle(string aggregateSha256, int projectionBytes, string projectionSha256, string projection)
        {
            AllowlistId = ExactAllowlistId;
            AggregateSha256 = aggregateSha256;
            ProjectionBytes = projectionBytes;
            ProjectionSha256 = projectionSha256;
            Projection = projection;
            Provenance = ExactProvenance;
            Classification = ExactClassification;
        }
    }

    internal sealed class ProjectContextResultMetadata
    {
        internal string AllowlistId { get; private set; }
        internal string AggregateSha256 { get; private set; }
        internal int ProjectionBytes { get; private set; }
        internal string ProjectionSha256 { get; private set; }
        internal string Provenance { get; private set; }
        internal string Classification { get; private set; }

        internal ProjectContextResultMetadata(ProjectContextBundle bundle)
        {
            if (bundle == null) { throw new ProjectContextException(); }
            AllowlistId = bundle.AllowlistId;
            AggregateSha256 = bundle.AggregateSha256;
            ProjectionBytes = bundle.ProjectionBytes;
            ProjectionSha256 = bundle.ProjectionSha256;
            Provenance = bundle.Provenance;
            Classification = bundle.Classification;
        }

        internal string ToCanonicalJson()
        {
            return "{\"allowlistId\":" + ContractCodec.Json(AllowlistId) +
                   ",\"aggregateSha256\":" + ContractCodec.Json(AggregateSha256) +
                   ",\"projectionBytes\":" + ProjectionBytes.ToString(CultureInfo.InvariantCulture) +
                   ",\"projectionSha256\":" + ContractCodec.Json(ProjectionSha256) +
                   ",\"provenance\":" + ContractCodec.Json(Provenance) +
                   ",\"classification\":" + ContractCodec.Json(Classification) + "}";
        }
    }

    internal sealed class ProjectContextPreparedRequest
    {
        internal string ExactPlanningPrompt { get; private set; }
        internal ProjectContextResultMetadata Metadata { get; private set; }

        internal ProjectContextPreparedRequest(string exactPlanningPrompt, ProjectContextResultMetadata metadata)
        {
            if (exactPlanningPrompt == null || metadata == null) { throw new ProjectContextException(); }
            ExactPlanningPrompt = exactPlanningPrompt;
            Metadata = metadata;
        }
    }

    internal interface IProjectContextRequestCoordinator
    {
        ProjectContextPreparedRequest Prepare(string absoluteRoot, string exactGoal);
    }

    internal static class ProjectContextPrompt
    {
        internal static string Build(string exactGoal, ProjectContextBundle bundle)
        {
            if (exactGoal == null || bundle == null) { throw new ProjectContextException(); }
            try
            {
                ContractCodec.RequireWellFormedUtf16(exactGoal, "Context goal");
                UTF8Encoding utf8 = new UTF8Encoding(false, true);
                return "EAIRA_M4_SLICE3_PLANNING_CONTEXT_V1\n" +
                       "GOAL=" + utf8.GetByteCount(exactGoal).ToString(CultureInfo.InvariantCulture) + ":" + exactGoal + "\n" +
                       "PROJECTION=" + bundle.ProjectionBytes.ToString(CultureInfo.InvariantCulture) + ":" + bundle.Projection;
            }
            catch (ProjectContextException) { throw; }
            catch (Exception) { throw new ProjectContextException(); }
        }
    }

    internal sealed partial class ProjectContextLoader
    {
        private const int MaximumFileBytes = 262144;
        private const int MaximumAggregateBytes = 1048576;
        private const int MaximumProjectionBytes = 10000;
        private const uint FileAttributeDirectory = 0x00000010;
        private const uint FileAttributeReparsePoint = 0x00000400;
        private const uint FileAttributeOffline = 0x00001000;
        private const uint FileAttributeRecallOnOpen = 0x00040000;
        private const uint FileAttributeRecallOnDataAccess = 0x00400000;
        private const uint NameSurrogateBit = 0x20000000;
        private const uint ApprovedDirectoryTag = 0x9000E01A;
        private const uint ApprovedFileTag = 0x9000601A;

        private static readonly string[] PathIds = new string[]
        {
            "docs/project/status/CURRENT_STATUS.md",
            "docs/project/status/TODAY_OBJECTIVE.md",
            "docs/project/status/ACTIVE_TASK.yaml",
            "docs/project/status/AGENT_CONTEXT_VERSION.yaml"
        };

        private readonly IProjectContextReadOnlyPlatform platform;
        private ProjectContextLoader(IProjectContextReadOnlyPlatform exactPlatform)
        {
            if (exactPlatform == null) { throw new ProjectContextException(); }
            platform = exactPlatform;
        }

        internal ProjectContextBundle Load(string absoluteRoot)
        {
            string root = ValidateRoot(absoluteRoot);
            List<IPinnedAncestorHandle> pinned = new List<IPinnedAncestorHandle>();
            List<ProjectContextFileSnapshot> snapshots = new List<ProjectContextFileSnapshot>();
            List<string> texts = new List<string>();
            int aggregateBytes = 0;
            try
            {
                PinAncestor(root, true, pinned);
                string statusDirectory = root + "\\docs\\project\\status";
                PinAncestor(root + "\\docs", true, pinned);
                PinAncestor(root + "\\docs\\project", true, pinned);
                PinAncestor(statusDirectory, true, pinned);

                for (int index = 0; index < PathIds.Length; index++)
                {
                    string exactPath = root + "\\" + PathIds[index].Replace('/', '\\');
                    ILeafProbeHandle probe = null;
                    IApprovedContentHandle content = null;
                    ProjectContextFileMetadata probeMetadata = null;
                    try
                    {
                        probe = platform.OpenLeafProbe(exactPath);
                        probeMetadata = platform.QueryLeafProbe(probe);
                        ValidateMetadata(probeMetadata, exactPath, false, true);
                        platform.CloseLeafProbe(probe);
                        probe = null;

                        content = platform.OpenApprovedContent(exactPath);
                        ProjectContextFileMetadata before = platform.QueryApprovedContent(content);
                        ValidateMetadata(before, exactPath, false, true);
                        if (!probeMetadata.SameIdentity(before)) { throw new ProjectContextException(); }
                        if (before.Length > Int32.MaxValue) { throw new ProjectContextException(); }
                        int count = checked((int)before.Length);
                        aggregateBytes = AddValidatedBytes(aggregateBytes, count);
                        byte[] raw = platform.ReadApprovedContent(content, count);
                        if (raw == null || raw.Length != count) { throw new ProjectContextException(); }
                        ProjectContextFileMetadata after = platform.QueryApprovedContent(content);
                        ValidateMetadata(after, exactPath, false, true);
                        if (!before.StableEquals(after)) { throw new ProjectContextException(); }
                        byte[] digest = Sha256(raw);
                        string decoded = DecodeStrict(raw);
                        snapshots.Add(new ProjectContextFileSnapshot(PathIds[index], count, before, digest));
                        texts.Add(NormalizeNewlines(decoded));
                    }
                    finally
                    {
                        if (content != null) { platform.CloseApprovedContent(content); }
                        if (probe != null) { platform.CloseLeafProbe(probe); }
                    }
                }

                string projection = BuildProjection(texts);
                byte[] projectionBytes = StrictUtf8(projection);
                if (projectionBytes.Length > MaximumProjectionBytes) { throw new ProjectContextException(); }
                return new ProjectContextBundle(ToHex(ComputeAggregate(snapshots)), projectionBytes.Length, ToHex(Sha256(projectionBytes)), projection);
            }
            catch (ProjectContextException) { throw; }
            catch (Exception) { throw new ProjectContextException(); }
            finally
            {
                for (int index = pinned.Count - 1; index >= 0; index--)
                {
                    try { platform.ClosePinnedAncestor(pinned[index]); } catch (Exception) { }
                }
            }
        }

        private void PinAncestor(string exactPath, bool directory, List<IPinnedAncestorHandle> pinned)
        {
            IPinnedAncestorHandle handle = platform.OpenPinnedAncestor(exactPath);
            if (handle == null) { throw new ProjectContextException(); }
            pinned.Add(handle);
            ValidateMetadata(platform.QueryPinnedAncestor(handle), exactPath, directory, false);
        }

        private static string ValidateRoot(string root)
        {
            if (String.IsNullOrEmpty(root) || root.Length < 4 || root[1] != ':' || root[2] != '\\') { throw new ProjectContextException(); }
            char drive = root[0];
            if (!(drive >= 'A' && drive <= 'Z')) { throw new ProjectContextException(); }
            if (root.EndsWith("\\", StringComparison.Ordinal) || root.IndexOf('/') >= 0 || root.IndexOf("\\\\", StringComparison.Ordinal) >= 0 || root.IndexOf(':', 2) >= 0) { throw new ProjectContextException(); }
            string[] parts = root.Substring(3).Split('\\');
            if (parts.Length == 0) { throw new ProjectContextException(); }
            for (int index = 0; index < parts.Length; index++)
            {
                string part = parts[index];
                if (part.Length == 0 || part == "." || part == ".." || part.EndsWith(" ", StringComparison.Ordinal) || part.EndsWith(".", StringComparison.Ordinal) || part.IndexOf('~') >= 0) { throw new ProjectContextException(); }
            }
            return root;
        }

        private static int AddValidatedBytes(int currentAggregateBytes, int nextFileBytes)
        {
            if (currentAggregateBytes < 0 || nextFileBytes < 0 || nextFileBytes > MaximumFileBytes) { throw new ProjectContextException(); }
            int total = checked(currentAggregateBytes + nextFileBytes);
            if (total > MaximumAggregateBytes) { throw new ProjectContextException(); }
            return total;
        }

        private static void ValidateMetadata(ProjectContextFileMetadata metadata, string exactPath, bool directory, bool leaf)
        {
            if (metadata == null || !String.Equals(metadata.CanonicalPath, exactPath, StringComparison.Ordinal)) { throw new ProjectContextException(); }
            uint rejected = FileAttributeOffline | FileAttributeRecallOnOpen | FileAttributeRecallOnDataAccess;
            if ((metadata.Attributes & rejected) != 0 || (metadata.ReparseTag & NameSurrogateBit) != 0) { throw new ProjectContextException(); }
            bool isDirectory = (metadata.Attributes & FileAttributeDirectory) != 0;
            if (isDirectory != directory) { throw new ProjectContextException(); }
            if (directory)
            {
                if (metadata.ReparseTag != 0 && metadata.ReparseTag != ApprovedDirectoryTag) { throw new ProjectContextException(); }
            }
            else if (leaf)
            {
                if (metadata.ReparseTag != 0 && metadata.ReparseTag != ApprovedFileTag) { throw new ProjectContextException(); }
            }
            if ((metadata.Attributes & FileAttributeReparsePoint) == 0 && metadata.ReparseTag != 0) { throw new ProjectContextException(); }
        }

        private static string BuildProjection(IList<string> texts)
        {
            if (texts == null || texts.Count != 4) { throw new ProjectContextException(); }
            Dictionary<string, string> current = ParseMarkdown(texts[0], new string[] { "Context ID", "Version", "Updated At", "Current Milestone", "Active Phase", "Current Decision", "Blockers", "Next Action" });
            Dictionary<string, string> today = ParseMarkdown(texts[1], new string[] { "Date", "Version", "Milestone", "Current Scope", "Out of Scope", "Expected Deliverables", "Success Criteria" });
            Dictionary<string, object> active = ParseYaml(
                texts[2],
                new string[] { "Task ID", "Owner", "Status", "Priority", "Dependencies", "Last Updated" },
                new string[] { "Dependencies" },
                new string[] { "Context ID", "Version", "Updated At", "Current Milestone", "Active Phase", "Current Decision", "Blockers", "Next Action", "Date", "Milestone", "Current Scope", "Out of Scope", "Expected Deliverables", "Success Criteria", "Context Version", "Current Status Version", "Today Objective Version", "Knowledge Index Version", "Verified Agents" });
            Dictionary<string, object> versions = ParseYaml(
                texts[3],
                new string[] { "Context Version", "Last Updated", "Current Status Version", "Today Objective Version", "Knowledge Index Version", "Verified Agents" },
                new string[] { "Verified Agents" },
                new string[] { "Context ID", "Version", "Updated At", "Current Milestone", "Active Phase", "Current Decision", "Blockers", "Next Action", "Date", "Milestone", "Current Scope", "Out of Scope", "Expected Deliverables", "Success Criteria", "Task ID", "Owner", "Status", "Priority", "Dependencies" });
            string statusVersion = Scalar(current, "Version");
            if (!String.Equals(statusVersion, Scalar(versions, "Current Status Version"), StringComparison.Ordinal) ||
                !String.Equals(Scalar(today, "Version"), Scalar(versions, "Today Objective Version"), StringComparison.Ordinal)) { throw new ProjectContextException(); }

            List<KeyValuePair<string, string>> fields = new List<KeyValuePair<string, string>>();
            Add(fields, "Current Status.Context ID", Scalar(current, "Context ID"));
            Add(fields, "Current Status.Version", statusVersion);
            Add(fields, "Current Status.Updated At", Scalar(current, "Updated At"));
            Add(fields, "Current Status.Current Milestone", Scalar(current, "Current Milestone"));
            Add(fields, "Current Status.Active Phase", FirstParagraph(current["Active Phase"]));
            Add(fields, "Current Status.Current Decision", FirstParagraph(current["Current Decision"]));
            Add(fields, "Current Status.Blockers", FirstList(current["Blockers"]));
            Add(fields, "Current Status.Next Action", FirstParagraph(current["Next Action"]));
            Add(fields, "Today Objective.Date", Scalar(today, "Date"));
            Add(fields, "Today Objective.Milestone", Scalar(today, "Milestone"));
            Add(fields, "Today Objective.Current Scope", FirstParagraph(today["Current Scope"]));
            Add(fields, "Today Objective.Expected Deliverables", FirstParagraph(today["Expected Deliverables"]));
            Add(fields, "Today Objective.Success Criteria", FirstList(today["Success Criteria"]));
            Add(fields, "Active Task.Task ID", Scalar(active, "Task ID"));
            Add(fields, "Active Task.Owner", Scalar(active, "Owner"));
            Add(fields, "Active Task.Status", Scalar(active, "Status"));
            Add(fields, "Active Task.Priority", Scalar(active, "Priority"));
            Add(fields, "Active Task.Last Updated", Scalar(active, "Last Updated"));
            List<string> dependencies = List(active, "Dependencies");
            Add(fields, "Active Task.Dependency Count", dependencies.Count.ToString(CultureInfo.InvariantCulture));
            Add(fields, "Active Task.Dependency SHA-256", ToHex(HashList(dependencies)));
            Add(fields, "Agent Context Version.Context Version", Scalar(versions, "Context Version"));
            Add(fields, "Agent Context Version.Last Updated", Scalar(versions, "Last Updated"));
            Add(fields, "Agent Context Version.Current Status Version", Scalar(versions, "Current Status Version"));
            Add(fields, "Agent Context Version.Today Objective Version", Scalar(versions, "Today Objective Version"));
            Add(fields, "Agent Context Version.Knowledge Index Version", Scalar(versions, "Knowledge Index Version"));
            List<string> agents = List(versions, "Verified Agents");
            Add(fields, "Agent Context Version.Verified Agent Count", agents.Count.ToString(CultureInfo.InvariantCulture));
            Add(fields, "Agent Context Version.Verified Agent SHA-256", ToHex(HashList(agents)));
            StringBuilder projection = new StringBuilder();
            UTF8Encoding utf8 = new UTF8Encoding(false, true);
            for (int index = 0; index < fields.Count; index++)
            {
                string label = fields[index].Key;
                string value = fields[index].Value;
                projection.Append(utf8.GetByteCount(label).ToString(CultureInfo.InvariantCulture)).Append(':').Append(label)
                          .Append(utf8.GetByteCount(value).ToString(CultureInfo.InvariantCulture)).Append(':').Append(value).Append('\n');
            }
            return projection.ToString();
        }

        private static void Add(List<KeyValuePair<string, string>> fields, string label, string value)
        {
            if (String.IsNullOrEmpty(value)) { throw new ProjectContextException(); }
            fields.Add(new KeyValuePair<string, string>(label, value));
        }

        private static Dictionary<string, string> ParseMarkdown(string text, string[] required)
        {
            string[] lines = text.Split('\n');
            Dictionary<string, string> sections = new Dictionary<string, string>(StringComparer.Ordinal);
            string active = null;
            StringBuilder body = null;
            for (int index = 0; index < lines.Length; index++)
            {
                string line = lines[index];
                if (line.StartsWith("## ", StringComparison.Ordinal))
                {
                    if (active != null) { sections.Add(active, body.ToString()); }
                    active = line.Substring(3);
                    if (active.Length == 0 || sections.ContainsKey(active)) { throw new ProjectContextException(); }
                    body = new StringBuilder();
                }
                else if (active != null) { body.Append(line).Append('\n'); }
            }
            if (active != null) { sections.Add(active, body.ToString()); }
            for (int index = 0; index < required.Length; index++)
            {
                int matches = sections.ContainsKey(required[index]) ? 1 : 0;
                if (matches != 1) { throw new ProjectContextException(); }
            }
            return sections;
        }

        private static Dictionary<string, object> ParseYaml(string text, string[] required, string[] listKeys, string[] forbiddenOwnerKeys)
        {
            Dictionary<string, object> values = new Dictionary<string, object>(StringComparer.Ordinal);
            Dictionary<string, bool> seen = new Dictionary<string, bool>(StringComparer.Ordinal);
            string activeList = null;
            bool ignoreIndented = false;
            string[] lines = text.Split('\n');
            for (int index = 0; index < lines.Length; index++)
            {
                string line = lines[index];
                if (line.Length == 0) { continue; }
                if (line[0] == ' ' || line[0] == '\t')
                {
                    if (ignoreIndented) { continue; }
                    if (activeList == null || !line.StartsWith("  - ", StringComparison.Ordinal)) { throw new ProjectContextException(); }
                    string item = ParseQuoted(line.Substring(4));
                    ((List<string>)values[activeList]).Add(item);
                    continue;
                }
                activeList = null;
                ignoreIndented = false;
                int colon = line.IndexOf(':');
                if (colon <= 0) { throw new ProjectContextException(); }
                string rawKey = TrimAscii(line.Substring(0, colon));
                string key = rawKey.StartsWith("\"", StringComparison.Ordinal) ? ParseQuoted(rawKey) : rawKey;
                RequireClean(key);
                if (seen.ContainsKey(key)) { throw new ProjectContextException(); }
                seen.Add(key, true);
                string raw = TrimAscii(line.Substring(colon + 1));
                bool isRequired = false;
                for (int requiredIndex = 0; requiredIndex < required.Length; requiredIndex++)
                {
                    if (String.Equals(key, required[requiredIndex], StringComparison.Ordinal)) { isRequired = true; break; }
                }
                if (!isRequired)
                {
                    for (int forbiddenIndex = 0; forbiddenIndex < forbiddenOwnerKeys.Length; forbiddenIndex++)
                    {
                        if (String.Equals(key, forbiddenOwnerKeys[forbiddenIndex], StringComparison.Ordinal)) { throw new ProjectContextException(); }
                    }
                    ignoreIndented = raw.Length == 0;
                    continue;
                }
                bool isList = false;
                for (int listIndex = 0; listIndex < listKeys.Length; listIndex++)
                {
                    if (String.Equals(key, listKeys[listIndex], StringComparison.Ordinal)) { isList = true; break; }
                }
                if (isList)
                {
                    List<string> items = new List<string>();
                    if (raw == "[]") { values.Add(key, items); }
                    else if (raw.Length == 0) { values.Add(key, items); activeList = key; }
                    else { throw new ProjectContextException(); }
                }
                else { values.Add(key, ParseQuoted(raw)); }
            }
            for (int index = 0; index < required.Length; index++)
            {
                if (!values.ContainsKey(required[index])) { throw new ProjectContextException(); }
            }
            return values;
        }

        private static string ParseQuoted(string raw)
        {
            if (raw == null || raw.Length < 2 || raw[0] != '"' || raw[raw.Length - 1] != '"') { throw new ProjectContextException(); }
            StringBuilder value = new StringBuilder();
            for (int index = 1; index < raw.Length - 1; index++)
            {
                char current = raw[index];
                if (current == '\\')
                {
                    index++;
                    if (index >= raw.Length - 1) { throw new ProjectContextException(); }
                    char escaped = raw[index];
                    if (escaped == '\\' || escaped == '"') { value.Append(escaped); }
                    else { throw new ProjectContextException(); }
                }
                else if (current == '"') { throw new ProjectContextException(); }
                else { value.Append(current); }
            }
            string result = value.ToString();
            RequireClean(result);
            return result;
        }

        private static string Scalar(IDictionary<string, string> values, string key)
        {
            string value;
            if (!values.TryGetValue(key, out value)) { throw new ProjectContextException(); }
            List<string> selected = new List<string>();
            string[] lines = value.Split('\n');
            for (int index = 0; index < lines.Length; index++)
            {
                string candidate = TrimAscii(lines[index]);
                if (candidate.Length == 0) { continue; }
                if (candidate.StartsWith("#", StringComparison.Ordinal) || candidate.StartsWith("- ", StringComparison.Ordinal)) { throw new ProjectContextException(); }
                RequireClean(candidate);
                selected.Add(candidate);
            }
            if (selected.Count == 0) { throw new ProjectContextException(); }
            return String.Join("\n", selected.ToArray());
        }

        private static string Scalar(IDictionary<string, object> values, string key)
        {
            object value;
            if (!values.TryGetValue(key, out value) || !(value is string)) { throw new ProjectContextException(); }
            return (string)value;
        }

        private static List<string> List(IDictionary<string, object> values, string key)
        {
            object value;
            if (!values.TryGetValue(key, out value) || !(value is List<string>)) { throw new ProjectContextException(); }
            return (List<string>)value;
        }

        private static string FirstParagraph(string section)
        {
            string[] lines = section.Split('\n');
            List<string> result = new List<string>();
            bool started = false;
            for (int index = 0; index < lines.Length; index++)
            {
                string line = TrimAscii(lines[index]);
                if (!started)
                {
                    if (line.Length == 0) { continue; }
                    if (line.StartsWith("#", StringComparison.Ordinal) || line.StartsWith("- ", StringComparison.Ordinal)) { continue; }
                    started = true;
                }
                if (line.Length == 0 || line.StartsWith("#", StringComparison.Ordinal) || line.StartsWith("- ", StringComparison.Ordinal)) { break; }
                RequireClean(line);
                result.Add(line);
            }
            if (result.Count == 0) { throw new ProjectContextException(); }
            return String.Join("\n", result.ToArray());
        }

        private static string FirstList(string section)
        {
            string[] lines = section.Split('\n');
            List<string> result = new List<string>();
            bool started = false;
            for (int index = 0; index < lines.Length; index++)
            {
                string line = lines[index];
                if (!started)
                {
                    if (line.StartsWith("- ", StringComparison.Ordinal)) { started = true; }
                    else { continue; }
                }
                if (!line.StartsWith("- ", StringComparison.Ordinal))
                {
                    string trimmed = TrimAscii(line);
                    if (trimmed.Length != 0 && (line[0] == ' ' || line[0] == '\t')) { throw new ProjectContextException(); }
                    break;
                }
                string value = TrimAscii(line.Substring(2));
                if (value.Length == 0) { throw new ProjectContextException(); }
                RequireClean(value);
                result.Add(value);
            }
            if (result.Count == 0) { throw new ProjectContextException(); }
            return String.Join("\n", result.ToArray());
        }

        private static string TrimAscii(string value)
        {
            if (value == null) { throw new ProjectContextException(); }
            int start = 0;
            int end = value.Length;
            while (start < end && (value[start] == ' ' || value[start] == '\t')) { start++; }
            while (end > start && (value[end - 1] == ' ' || value[end - 1] == '\t')) { end--; }
            return value.Substring(start, end - start);
        }

        private static void RequireClean(string value)
        {
            if (String.IsNullOrEmpty(value)) { throw new ProjectContextException(); }
            for (int index = 0; index < value.Length; index++)
            {
                int code = value[index];
                if (code <= 0x1F || (code >= 0x7F && code <= 0x9F) || code == '\r' || code == '\n') { throw new ProjectContextException(); }
            }
            ContractCodec.RequireWellFormedUtf16(value, "Context value");
        }

        private static byte[] HashList(IList<string> values)
        {
            List<byte> framed = new List<byte>();
            for (int index = 0; index < values.Count; index++)
            {
                byte[] bytes = StrictUtf8(values[index]);
                AppendUInt32(framed, checked((uint)bytes.Length));
                framed.AddRange(bytes);
            }
            return Sha256(framed.ToArray());
        }

        private static byte[] ComputeAggregate(IList<ProjectContextFileSnapshot> snapshots)
        {
            if (snapshots.Count != PathIds.Length) { throw new ProjectContextException(); }
            List<byte> framed = new List<byte>();
            framed.AddRange(Encoding.ASCII.GetBytes("EAIRA_M4_SLICE3_CONTEXT_BUNDLE_V1"));
            framed.Add(0);
            for (int index = 0; index < snapshots.Count; index++)
            {
                ProjectContextFileSnapshot snapshot = snapshots[index];
                if (!String.Equals(snapshot.PathId, PathIds[index], StringComparison.Ordinal) || snapshot.Digest == null || snapshot.Digest.Length != 32) { throw new ProjectContextException(); }
                byte[] path = StrictUtf8(snapshot.PathId);
                AppendUInt32(framed, checked((uint)path.Length));
                framed.AddRange(path);
                AppendUInt64(framed, checked((ulong)snapshot.ByteCount));
                framed.AddRange(snapshot.Digest);
            }
            return Sha256(framed.ToArray());
        }

        private static void AppendUInt32(List<byte> output, uint value)
        {
            output.Add((byte)((value >> 24) & 0xFFU));
            output.Add((byte)((value >> 16) & 0xFFU));
            output.Add((byte)((value >> 8) & 0xFFU));
            output.Add((byte)(value & 0xFFU));
        }

        private static void AppendUInt64(List<byte> output, ulong value)
        {
            for (int shift = 56; shift >= 0; shift -= 8) { output.Add((byte)((value >> shift) & 0xFFUL)); }
        }

        private static byte[] StrictUtf8(string text)
        {
            try { return new UTF8Encoding(false, true).GetBytes(text); }
            catch (Exception) { throw new ProjectContextException(); }
        }

        private static string DecodeStrict(byte[] raw)
        {
            if (raw.Length >= 3 && raw[0] == 0xEF && raw[1] == 0xBB && raw[2] == 0xBF) { throw new ProjectContextException(); }
            try { return new UTF8Encoding(false, true).GetString(raw); }
            catch (Exception) { throw new ProjectContextException(); }
        }

        private static string NormalizeNewlines(string text)
        {
            return text.Replace("\r\n", "\n").Replace("\r", "\n");
        }

        private static byte[] Sha256(byte[] input)
        {
            using (SHA256 algorithm = SHA256.Create()) { return algorithm.ComputeHash(input); }
        }

        private static string ToHex(byte[] bytes)
        {
            StringBuilder output = new StringBuilder(bytes.Length * 2);
            for (int index = 0; index < bytes.Length; index++) { output.Append(bytes[index].ToString("X2", CultureInfo.InvariantCulture)); }
            return output.ToString();
        }

    }

#if EAIRA_PROJECT_CONTEXT_NATIVE
    internal static class ProjectContextRequestPreflight
    {
        internal static void Validate(string exactPlanningPrompt)
        {
            try { LocalModelProvider.BuildCanonicalRequest(AgentRole.Planning, exactPlanningPrompt); }
            catch (LocalProviderException) { throw new ProjectContextException(); }
        }
    }

    internal sealed class ProjectContextRequestCoordinator : IProjectContextRequestCoordinator
    {
        private readonly ProjectContextLoader loader;
        private ProjectContextRequestCoordinator(ProjectContextLoader exactLoader)
        {
            if (exactLoader == null) { throw new ProjectContextException(); }
            loader = exactLoader;
        }

        internal static IProjectContextRequestCoordinator CreateNative()
        {
            return new ProjectContextRequestCoordinator(ProjectContextLoader.CreateNative());
        }

        public ProjectContextPreparedRequest Prepare(string absoluteRoot, string exactGoal)
        {
            ProjectContextBundle bundle = loader.Load(absoluteRoot);
            string prompt = ProjectContextPrompt.Build(exactGoal, bundle);
            ProjectContextRequestPreflight.Validate(prompt);
            return new ProjectContextPreparedRequest(prompt, new ProjectContextResultMetadata(bundle));
        }
    }

    internal sealed partial class ProjectContextLoader
    {
        internal static ProjectContextLoader CreateNative()
        {
            return new ProjectContextLoader(new ProjectContextWin32Platform());
        }

        private sealed class ProjectContextWin32Platform : IProjectContextReadOnlyPlatform
        {
            internal ProjectContextWin32Platform() { }

            private const uint GenericRead = 0x80000000;
            private const uint FileShareRead = 0x00000001;
            private const uint OpenExisting = 3;
            private const uint OpenReparsePoint = 0x00200000;
            private const uint BackupSemantics = 0x02000000;
            private const uint OpenNoRecall = 0x00100000;
            private const uint SequentialScan = 0x08000000;
            private const uint VolumeNameDos = 0;

            private sealed class PinnedAncestorToken : IPinnedAncestorHandle
            {
                internal ProjectContextNativeLease Lease { get; private set; }
                internal PinnedAncestorToken(ProjectContextNativeLease lease) { Lease = lease; }
            }

            private sealed class LeafProbeToken : ILeafProbeHandle
            {
                internal ProjectContextNativeLease Lease { get; private set; }
                internal LeafProbeToken(ProjectContextNativeLease lease) { Lease = lease; }
            }

            private sealed class ApprovedContentToken : IApprovedContentHandle
            {
                internal ProjectContextNativeLease Lease { get; private set; }
                internal ApprovedContentToken(ProjectContextNativeLease lease) { Lease = lease; }
            }

            public IPinnedAncestorHandle OpenPinnedAncestor(string exactPath)
            {
                IntPtr handle = CreateFileW(exactPath, GenericRead, FileShareRead, IntPtr.Zero, OpenExisting, OpenReparsePoint | BackupSemantics | OpenNoRecall, IntPtr.Zero);
                return new PinnedAncestorToken(ProjectContextNativeLease.Create(handle));
            }

            public ILeafProbeHandle OpenLeafProbe(string exactPath)
            {
                IntPtr handle = CreateFileW(exactPath, GenericRead, FileShareRead, IntPtr.Zero, OpenExisting, OpenReparsePoint | OpenNoRecall, IntPtr.Zero);
                return new LeafProbeToken(ProjectContextNativeLease.Create(handle));
            }

            public IApprovedContentHandle OpenApprovedContent(string exactPath)
            {
                IntPtr handle = CreateFileW(exactPath, GenericRead, FileShareRead, IntPtr.Zero, OpenExisting, SequentialScan | OpenNoRecall, IntPtr.Zero);
                return new ApprovedContentToken(ProjectContextNativeLease.Create(handle));
            }

            public ProjectContextFileMetadata QueryPinnedAncestor(IPinnedAncestorHandle handle)
            {
                PinnedAncestorToken token = handle as PinnedAncestorToken;
                if (token == null) { throw new ProjectContextException(); }
                return QueryMetadata(token.Lease);
            }

            public ProjectContextFileMetadata QueryLeafProbe(ILeafProbeHandle handle)
            {
                LeafProbeToken token = handle as LeafProbeToken;
                if (token == null) { throw new ProjectContextException(); }
                return QueryMetadata(token.Lease);
            }

            public ProjectContextFileMetadata QueryApprovedContent(IApprovedContentHandle handle)
            {
                ApprovedContentToken token = handle as ApprovedContentToken;
                if (token == null) { throw new ProjectContextException(); }
                return QueryMetadata(token.Lease);
            }

            public byte[] ReadApprovedContent(IApprovedContentHandle handle, int exactByteCount)
            {
                ApprovedContentToken token = handle as ApprovedContentToken;
                if (token == null || exactByteCount < 0 || exactByteCount > MaximumFileBytes) { throw new ProjectContextException(); }
                byte[] buffer = new byte[exactByteCount];
                uint read;
                if (!ReadFile(token.Lease.Handle, buffer, checked((uint)exactByteCount), out read, IntPtr.Zero) || read != exactByteCount) { throw new ProjectContextException(); }
                return buffer;
            }

            public void ClosePinnedAncestor(IPinnedAncestorHandle handle)
            {
                PinnedAncestorToken token = handle as PinnedAncestorToken;
                if (token == null) { throw new ProjectContextException(); }
                token.Lease.Close();
            }

            public void CloseLeafProbe(ILeafProbeHandle handle)
            {
                LeafProbeToken token = handle as LeafProbeToken;
                if (token == null) { throw new ProjectContextException(); }
                token.Lease.Close();
            }

            public void CloseApprovedContent(IApprovedContentHandle handle)
            {
                ApprovedContentToken token = handle as ApprovedContentToken;
                if (token == null) { throw new ProjectContextException(); }
                token.Lease.Close();
            }

            private static ProjectContextFileMetadata QueryMetadata(ProjectContextNativeLease lease)
            {
                ByHandleFileInformation information = QueryIdentityAndMetadata(lease);
                FileAttributeTagInformation tag = QueryAttributeTag(lease);
                string canonical = QueryCanonicalFinalPath(lease);
                ulong fileId = ((ulong)information.FileIndexHigh << 32) | information.FileIndexLow;
                ulong length = ((ulong)information.FileSizeHigh << 32) | information.FileSizeLow;
                ulong lastWrite = ((ulong)information.LastWriteTimeHigh << 32) | information.LastWriteTimeLow;
                return new ProjectContextFileMetadata(canonical, information.VolumeSerialNumber, fileId, length, lastWrite, tag.FileAttributes, tag.ReparseTag);
            }

            private static ByHandleFileInformation QueryIdentityAndMetadata(ProjectContextNativeLease lease)
            {
                ByHandleFileInformation information;
                if (!GetFileInformationByHandle(lease.Handle, out information)) { throw new ProjectContextException(); }
                return information;
            }

            private static FileAttributeTagInformation QueryAttributeTag(ProjectContextNativeLease lease)
            {
                FileAttributeTagInformation tag;
                if (!GetFileInformationByHandleEx(lease.Handle, 9, out tag, checked((uint)Marshal.SizeOf(typeof(FileAttributeTagInformation))))) { throw new ProjectContextException(); }
                return tag;
            }

            private static string QueryCanonicalFinalPath(ProjectContextNativeLease lease)
            {
                StringBuilder buffer = new StringBuilder(32768);
                uint count = GetFinalPathNameByHandleW(lease.Handle, buffer, checked((uint)buffer.Capacity), VolumeNameDos);
                if (count == 0 || count >= buffer.Capacity) { throw new ProjectContextException(); }
                string value = buffer.ToString();
                const string prefix = "\\\\?\\";
                if (!value.StartsWith(prefix, StringComparison.Ordinal) || value.StartsWith("\\\\?\\UNC\\", StringComparison.OrdinalIgnoreCase)) { throw new ProjectContextException(); }
                value = value.Substring(prefix.Length);
                if (value.Length < 3 || value[1] != ':') { throw new ProjectContextException(); }
                return Char.ToUpperInvariant(value[0]) + value.Substring(1);
            }

            [StructLayout(LayoutKind.Sequential)]
            private struct ByHandleFileInformation
                {
                    internal uint FileAttributes;
                    internal uint CreationTimeLow;
                    internal uint CreationTimeHigh;
                    internal uint LastAccessTimeLow;
                    internal uint LastAccessTimeHigh;
                    internal uint LastWriteTimeLow;
                    internal uint LastWriteTimeHigh;
                    internal uint VolumeSerialNumber;
                    internal uint FileSizeHigh;
                    internal uint FileSizeLow;
                    internal uint NumberOfLinks;
                    internal uint FileIndexHigh;
                    internal uint FileIndexLow;
                }

            [StructLayout(LayoutKind.Sequential)]
            private struct FileAttributeTagInformation
                {
                    internal uint FileAttributes;
                    internal uint ReparseTag;
                }

            private sealed class ProjectContextNativeLease
                {
                    internal IntPtr Handle { get; private set; }
                    private ProjectContextNativeLease(IntPtr handle) { Handle = handle; }
                    internal static ProjectContextNativeLease Create(IntPtr handle)
                    {
                        if (handle == IntPtr.Zero || handle == new IntPtr(-1)) { throw new ProjectContextException(); }
                        return new ProjectContextNativeLease(handle);
                    }
                    internal void Close()
                    {
                        IntPtr handle = Handle;
                        Handle = IntPtr.Zero;
                        if (handle != IntPtr.Zero && !CloseHandle(handle)) { throw new ProjectContextException(); }
                    }
                }

                [DllImport("kernel32.dll", EntryPoint = "CreateFileW", ExactSpelling = true, CallingConvention = CallingConvention.Winapi, CharSet = CharSet.Unicode, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true, PreserveSig = true)]
                private static extern IntPtr CreateFileW(string fileName, uint desiredAccess, uint shareMode, IntPtr securityAttributes, uint creationDisposition, uint flagsAndAttributes, IntPtr templateFile);

                [DllImport("kernel32.dll", EntryPoint = "GetFileInformationByHandle", ExactSpelling = true, CallingConvention = CallingConvention.Winapi, CharSet = CharSet.Unicode, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true, PreserveSig = true)]
                [return: MarshalAs(UnmanagedType.Bool)]
                private static extern bool GetFileInformationByHandle(IntPtr file, out ByHandleFileInformation information);

                [DllImport("kernel32.dll", EntryPoint = "GetFileInformationByHandleEx", ExactSpelling = true, CallingConvention = CallingConvention.Winapi, CharSet = CharSet.Unicode, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true, PreserveSig = true)]
                [return: MarshalAs(UnmanagedType.Bool)]
                private static extern bool GetFileInformationByHandleEx(IntPtr file, int informationClass, out FileAttributeTagInformation information, uint bufferSize);

                [DllImport("kernel32.dll", EntryPoint = "GetFinalPathNameByHandleW", ExactSpelling = true, CallingConvention = CallingConvention.Winapi, CharSet = CharSet.Unicode, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true, PreserveSig = true)]
                private static extern uint GetFinalPathNameByHandleW(IntPtr file, StringBuilder path, uint pathLength, uint flags);

                [DllImport("kernel32.dll", EntryPoint = "ReadFile", ExactSpelling = true, CallingConvention = CallingConvention.Winapi, CharSet = CharSet.Unicode, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true, PreserveSig = true)]
                [return: MarshalAs(UnmanagedType.Bool)]
                private static extern bool ReadFile(IntPtr file, [Out] byte[] buffer, uint bytesToRead, out uint bytesRead, IntPtr overlapped);

                [DllImport("kernel32.dll", EntryPoint = "CloseHandle", ExactSpelling = true, CallingConvention = CallingConvention.Winapi, CharSet = CharSet.Unicode, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true, PreserveSig = true)]
                [return: MarshalAs(UnmanagedType.Bool)]
                private static extern bool CloseHandle(IntPtr handle);
        }
    }
#endif

#if EAIRA_PROJECT_CONTEXT_TEST_SEAM
    internal sealed partial class ProjectContextLoader
    {
        internal static int ValidateBudgetsForTests(int currentAggregateBytes, int nextFileBytes)
        {
            return AddValidatedBytes(currentAggregateBytes, nextFileBytes);
        }

        internal static ProjectContextLoader CreateForTests(IProjectContextReadOnlyPlatform exactPlatform)
        {
            return new ProjectContextLoader(exactPlatform);
        }
    }
#endif
}
