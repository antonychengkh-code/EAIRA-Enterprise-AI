using System;
using System.Collections.Generic;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using EAIRA.AgentServices.Functional;

namespace EAIRA.AgentServices.Tests
{
    internal static class ProjectContextHarness
    {
        private const string Root = "C:\\EAIRA-CONTEXT-FIXTURE";
        private const uint DirectoryAttribute = 0x10;
        private const uint ReparseAttribute = 0x400;
        private const uint OfflineAttribute = 0x1000;
        private const uint RecallAttribute = 0x40000;
        private const uint RecallDataAttribute = 0x400000;
        private const uint DirectoryTag = 0x9000E01A;
        private const uint FileTag = 0x9000601A;
        private static readonly string[] PathIds = new string[]
        {
            "docs/project/status/CURRENT_STATUS.md",
            "docs/project/status/TODAY_OBJECTIVE.md",
            "docs/project/status/ACTIVE_TASK.yaml",
            "docs/project/status/AGENT_CONTEXT_VERSION.yaml"
        };
        private static int passed;
        private static FakePlatform platform;

        private sealed class FakePinnedToken : IPinnedAncestorHandle
        {
            internal FakePlatform Owner { get; private set; }
            internal string Path { get; private set; }
            internal FakePinnedToken(FakePlatform owner, string path) { Owner = owner; Path = path; }
        }

        private sealed class FakeProbeToken : ILeafProbeHandle
        {
            internal FakePlatform Owner { get; private set; }
            internal string Path { get; private set; }
            internal FakeProbeToken(FakePlatform owner, string path) { Owner = owner; Path = path; }
        }

        private sealed class FakeContentToken : IApprovedContentHandle
        {
            internal FakePlatform Owner { get; private set; }
            internal string Path { get; private set; }
            internal bool Read { get; set; }
            internal FakeContentToken(FakePlatform owner, string path) { Owner = owner; Path = path; }
        }

        private sealed class FakeFile
        {
            internal byte[] Bytes;
            internal uint Attributes;
            internal uint Tag;
            internal ulong Id;
            internal string CanonicalOverride;
            internal FakeFile(byte[] bytes, ulong id) { Bytes = bytes; Id = id; CanonicalOverride = null; }
        }

        private sealed class FakePlatform : IProjectContextReadOnlyPlatform
        {
            internal FakePlatform() { }

            private readonly Dictionary<string, FakeFile> files = new Dictionary<string, FakeFile>(StringComparer.Ordinal);
            private readonly List<string> ledger = new List<string>();
            private int openCount;
            private int closeCount;
            internal bool PartialRead;
            internal bool MutateAfterRead;
            internal string SubstitutePath;
            internal string ProbeSubstitutePath;
            internal string ContentBeforeSubstitutePath;
            internal string ContentAfterSubstitutePath;
            internal bool ThrowOnRead;
            internal string ProbeIdentityMismatchPath;
            internal uint AncestorAttributes;
            internal uint AncestorTag;
            internal string AncestorStatePath;
            internal uint AncestorStateAttributes;
            internal uint AncestorStateTag;
            internal bool ThrowOnPinnedAncestorOpen;
            internal bool ThrowOnLeafProbeOpen;
            internal string ThrowOnApprovedContentOpenPath;
            internal string ProbeStatePath;
            internal uint ProbeStateAttributes;
            internal uint ProbeStateTag;
            internal string ContentBeforeStatePath;
            internal uint ContentBeforeStateAttributes;
            internal uint ContentBeforeStateTag;
            internal string ContentAfterStatePath;
            internal uint ContentAfterStateAttributes;
            internal uint ContentAfterStateTag;

            internal IList<string> Ledger { get { return ledger.AsReadOnly(); } }
            internal int OpenCount { get { return openCount; } }
            internal int CloseCount { get { return closeCount; } }

            internal void Reset()
            {
                files.Clear(); ledger.Clear(); openCount = 0; closeCount = 0;
                PartialRead = false; MutateAfterRead = false; SubstitutePath = null; ProbeSubstitutePath = null;
                ContentBeforeSubstitutePath = null; ContentAfterSubstitutePath = null; ThrowOnRead = false; ProbeIdentityMismatchPath = null;
                AncestorAttributes = DirectoryAttribute; AncestorTag = 0;
                AncestorStatePath = null; AncestorStateAttributes = DirectoryAttribute; AncestorStateTag = 0;
                ThrowOnPinnedAncestorOpen = false; ThrowOnLeafProbeOpen = false; ThrowOnApprovedContentOpenPath = null;
                ProbeStatePath = null; ProbeStateAttributes = 0; ProbeStateTag = 0;
                ContentBeforeStatePath = null; ContentBeforeStateAttributes = 0; ContentBeforeStateTag = 0;
                ContentAfterStatePath = null; ContentAfterStateAttributes = 0; ContentAfterStateTag = 0;
                Add("docs\\project\\status\\CURRENT_STATUS.md", CurrentStatus(), 101);
                Add("docs\\project\\status\\TODAY_OBJECTIVE.md", TodayObjective(), 102);
                Add("docs\\project\\status\\ACTIVE_TASK.yaml", ActiveTask(), 103);
                Add("docs\\project\\status\\AGENT_CONTEXT_VERSION.yaml", AgentVersion(), 104);
            }

            internal void SetFileState(string suffix, uint attributes, uint tag)
            {
                FakeFile file = files[Root + "\\" + suffix]; file.Attributes = attributes; file.Tag = tag;
            }

            internal void ReplaceText(string suffix, string text)
            {
                files[Root + "\\" + suffix].Bytes = new UTF8Encoding(false, true).GetBytes(text);
            }

            internal void ReplaceBytes(string suffix, byte[] bytes)
            {
                files[Root + "\\" + suffix].Bytes = bytes;
            }

            internal byte[] GetBytes(string suffix)
            {
                byte[] source = files[Root + "\\" + suffix.Replace('/', '\\')].Bytes;
                byte[] copy = new byte[source.Length];
                Array.Copy(source, copy, source.Length);
                return copy;
            }

            internal void Remove(string suffix)
            {
                files.Remove(Root + "\\" + suffix.Replace('/', '\\'));
            }

            internal void AddExtra(string suffix, string text)
            {
                Add(suffix.Replace('/', '\\'), text, 900);
            }

            private void Add(string suffix, string text, ulong id)
            {
                files.Add(Root + "\\" + suffix, new FakeFile(new UTF8Encoding(false, true).GetBytes(text), id));
            }

            public IPinnedAncestorHandle OpenPinnedAncestor(string exactPath)
            {
                if (ThrowOnPinnedAncestorOpen) { ledger.Add("OpenPinnedAncestorFailure|" + exactPath); throw new ProjectContextException(); }
                ledger.Add("OpenPinnedAncestor|" + exactPath); openCount++;
                return new FakePinnedToken(this, exactPath);
            }

            public ILeafProbeHandle OpenLeafProbe(string exactPath)
            {
                if (ThrowOnLeafProbeOpen) { ledger.Add("OpenLeafProbeFailure|" + exactPath); throw new ProjectContextException(); }
                RequireFile(exactPath); ledger.Add("OpenLeafProbe|" + exactPath); openCount++;
                return new FakeProbeToken(this, exactPath);
            }

            public IApprovedContentHandle OpenApprovedContent(string exactPath)
            {
                if (String.Equals(ThrowOnApprovedContentOpenPath, exactPath, StringComparison.Ordinal)) { ledger.Add("OpenApprovedContentFailure|" + exactPath); throw new ProjectContextException(); }
                RequireFile(exactPath); ledger.Add("OpenApprovedContent|" + exactPath); openCount++;
                return new FakeContentToken(this, exactPath);
            }

            public ProjectContextFileMetadata QueryPinnedAncestor(IPinnedAncestorHandle handle)
            {
                FakePinnedToken token = RequirePinned(handle); ledger.Add("QueryPinnedAncestor|" + token.Path);
                string canonical = String.Equals(SubstitutePath, token.Path, StringComparison.Ordinal) ? token.Path + "-SUBSTITUTED" : token.Path;
                bool selected = String.Equals(AncestorStatePath, token.Path, StringComparison.Ordinal);
                uint attributes = selected ? AncestorStateAttributes : AncestorAttributes;
                uint tag = selected ? AncestorStateTag : AncestorTag;
                return new ProjectContextFileMetadata(canonical, 7, 10, 0, 50, attributes, tag);
            }

            public ProjectContextFileMetadata QueryLeafProbe(ILeafProbeHandle handle)
            {
                FakeProbeToken token = RequireProbe(handle); ledger.Add("QueryLeafProbe|" + token.Path);
                ProjectContextFileMetadata metadata = Metadata(token.Path, false, ProbeSubstitutePath);
                if (String.Equals(ProbeStatePath, token.Path, StringComparison.Ordinal))
                {
                    metadata = new ProjectContextFileMetadata(metadata.CanonicalPath, metadata.VolumeSerial, metadata.FileId, metadata.Length, metadata.LastWriteTime, ProbeStateAttributes, ProbeStateTag);
                }
                return String.Equals(ProbeIdentityMismatchPath, token.Path, StringComparison.Ordinal)
                    ? new ProjectContextFileMetadata(metadata.CanonicalPath, metadata.VolumeSerial, metadata.FileId + 900, metadata.Length, metadata.LastWriteTime, metadata.Attributes, metadata.ReparseTag)
                    : metadata;
            }

            public ProjectContextFileMetadata QueryApprovedContent(IApprovedContentHandle handle)
            {
                FakeContentToken token = RequireContent(handle); ledger.Add("QueryApprovedContent|" + token.Path);
                bool afterRead = token.Read;
                ProjectContextFileMetadata metadata = Metadata(token.Path, afterRead && MutateAfterRead, afterRead ? ContentAfterSubstitutePath : ContentBeforeSubstitutePath);
                if (!afterRead && String.Equals(ContentBeforeStatePath, token.Path, StringComparison.Ordinal))
                {
                    metadata = new ProjectContextFileMetadata(metadata.CanonicalPath, metadata.VolumeSerial, metadata.FileId, metadata.Length, metadata.LastWriteTime, ContentBeforeStateAttributes, ContentBeforeStateTag);
                }
                if (afterRead && String.Equals(ContentAfterStatePath, token.Path, StringComparison.Ordinal))
                {
                    metadata = new ProjectContextFileMetadata(metadata.CanonicalPath, metadata.VolumeSerial, metadata.FileId, metadata.Length, metadata.LastWriteTime, ContentAfterStateAttributes, ContentAfterStateTag);
                }
                return metadata;
            }

            public byte[] ReadApprovedContent(IApprovedContentHandle handle, int exactByteCount)
            {
                FakeContentToken token = RequireContent(handle); ledger.Add("ReadApprovedContent|" + token.Path);
                if (token.Read || ThrowOnRead) { throw new ProjectContextException(); }
                token.Read = true;
                byte[] source = files[token.Path].Bytes;
                int count = PartialRead && source.Length > 0 ? source.Length - 1 : source.Length;
                byte[] copy = new byte[count]; Array.Copy(source, copy, count); return copy;
            }

            public void ClosePinnedAncestor(IPinnedAncestorHandle handle) { FakePinnedToken token = RequirePinned(handle); ledger.Add("ClosePinnedAncestor|" + token.Path); closeCount++; }
            public void CloseLeafProbe(ILeafProbeHandle handle) { FakeProbeToken token = RequireProbe(handle); ledger.Add("CloseLeafProbe|" + token.Path); closeCount++; }
            public void CloseApprovedContent(IApprovedContentHandle handle) { FakeContentToken token = RequireContent(handle); ledger.Add("CloseApprovedContent|" + token.Path); closeCount++; }

            private ProjectContextFileMetadata Metadata(string path, bool mutated, string substitutePath)
            {
                FakeFile file = RequireFile(path);
                string canonical = file.CanonicalOverride ?? (String.Equals(substitutePath, path, StringComparison.Ordinal) ? path + "-SUBSTITUTED" : path);
                return new ProjectContextFileMetadata(canonical, 7, mutated ? file.Id + 1 : file.Id, checked((ulong)file.Bytes.Length), mutated ? 52UL : 51UL, file.Attributes, file.Tag);
            }

            private FakeFile RequireFile(string path)
            {
                FakeFile file; if (!files.TryGetValue(path, out file)) { throw new ProjectContextException(); } return file;
            }
            private FakePinnedToken RequirePinned(IPinnedAncestorHandle value) { FakePinnedToken token = value as FakePinnedToken; if (token == null || token.Owner != this) { throw new ProjectContextException(); } return token; }
            private FakeProbeToken RequireProbe(ILeafProbeHandle value) { FakeProbeToken token = value as FakeProbeToken; if (token == null || token.Owner != this) { throw new ProjectContextException(); } return token; }
            private FakeContentToken RequireContent(IApprovedContentHandle value) { FakeContentToken token = value as FakeContentToken; if (token == null || token.Owner != this) { throw new ProjectContextException(); } return token; }
        }

        private static ProjectContextLoader CreateLoaderForTests()
        {
            platform = new FakePlatform();
            platform.Reset();
            return ProjectContextLoader.CreateForTests(platform);
        }

        private static void Require(bool condition, string name)
        {
            if (!condition) { throw new ContractException("Context test failed: " + name); }
            passed++;
        }

        private static void RequireContextFailure(Action action, string name)
        {
            bool failed = false;
            try { action(); }
            catch (ProjectContextException) { failed = true; }
            Require(failed, name);
        }

        private static void Reset() { platform.Reset(); }

        private static int CountFramedFields(string projection)
        {
            byte[] bytes = new UTF8Encoding(false, true).GetBytes(projection);
            int position = 0;
            int count = 0;
            while (position < bytes.Length)
            {
                int labelLength = ReadDecimal(bytes, ref position);
                position = checked(position + labelLength);
                int valueLength = ReadDecimal(bytes, ref position);
                position = checked(position + valueLength);
                if (position >= bytes.Length || bytes[position] != 10) { throw new ContractException("Projection frame is invalid."); }
                position++; count++;
            }
            return count;
        }

        private static int ReadDecimal(byte[] bytes, ref int position)
        {
            if (position >= bytes.Length || bytes[position] < (byte)'0' || bytes[position] > (byte)'9') { throw new ContractException("Projection length is invalid."); }
            int value = 0;
            do { value = checked(value * 10 + bytes[position] - (byte)'0'); position++; }
            while (position < bytes.Length && bytes[position] >= (byte)'0' && bytes[position] <= (byte)'9');
            if (position >= bytes.Length || bytes[position] != (byte)':') { throw new ContractException("Projection delimiter is invalid."); }
            position++; return value;
        }

        private static string CurrentStatus()
        {
            return "# Status\n\n" +
                   "## Context ID\nCTX-S3\n\n" +
                   "## Version\n0.1\n\n" +
                   "## Updated At\n2026-09-05\n\n" +
                   "## Current Milestone\nM4\n\n" +
                   "## Active Phase\nRead-only context implementation.\nSecond bounded line.\n\n" +
                   "## Current Decision\nUse the reviewed allowlist only.\n\n" +
                   "## Blockers\n- None\n- Signing deferred\n\n" +
                   "## Next Action\nRun independent S3-R10 review.\n";
        }

        private static string TodayObjective()
        {
            return "# Today\n\n" +
                   "## Date\n2026-09-05\n\n" +
                   "## Version\n0.2\n\n" +
                   "## Milestone\nM4\n\n" +
                   "## Current Scope\nImplement a bounded read-only context slice.\n\n" +
                   "## Out of Scope\nWrites and external providers.\n\n" +
                   "## Expected Deliverables\nOne deterministic offline build candidate.\n\n" +
                   "## Success Criteria\n- Four files only\n- No writes\n";
        }

        private static string ActiveTask()
        {
            return "\"Task ID\": \"S3-R09\"\n" +
                   "\"Owner\": \"Human Project Owner\"\n" +
                   "\"Status\": \"AUTHORIZED\"\n" +
                   "\"Priority\": \"P1\"\n" +
                   "\"Dependencies\":\n" +
                   "  - \"R8 review pass\"\n" +
                   "  - \"NOWRITE_A\"\n" +
                   "\"Last Updated\": \"2026-09-05\"\n" +
                   "\"Unprojected Governance Field\": \"retained but not projected\"\n" +
                   "\"Unprojected Evidence List\":\n" +
                   "  - \"evidence one\"\n" +
                   "  - \"evidence two\"\n";
        }

        private static string AgentVersion()
        {
            return "\"Context Version\": \"0.1\"\n" +
                   "\"Last Updated\": \"2026-09-05\"\n" +
                   "\"Current Status Version\": \"0.1\"\n" +
                   "\"Today Objective Version\": \"0.2\"\n" +
                   "\"Knowledge Index Version\": \"0.1\"\n" +
                   "\"Verified Agents\": []\n" +
                   "\"Unprojected Version Note\": \"canonical repository shape allows additional fields\"\n";
        }

        private static void RunAll(ProjectContextLoader loader)
        {
            ProjectContextBundle first = loader.Load(Root);
            Require(first.AllowlistId == ProjectContextBundle.ExactAllowlistId, "allowlist id");
            Require(first.Provenance == ProjectContextBundle.ExactProvenance && first.Classification == ProjectContextBundle.ExactClassification, "fixed provenance and classification");
            string firstFileDigest = HashHex(platform.GetBytes(PathIds[0]));
            string resultMetadataJson = new ProjectContextResultMetadata(first).ToCanonicalJson();
            Require(first.AggregateSha256.Length == 64 && first.ProjectionSha256.Length == 64 && resultMetadataJson.IndexOf(firstFileDigest, StringComparison.Ordinal) < 0, "aggregate/projection digests emitted and per-file digest withheld");
            Require(first.AggregateSha256 == ComputeAggregateIndependently(), "aggregate digest independently recomputed");
            Require(first.ProjectionSha256 == HashHex(new UTF8Encoding(false, true).GetBytes(first.Projection)), "projection digest independently recomputed");
            Require(new UTF8Encoding(false, true).GetByteCount(first.Projection) == first.ProjectionBytes && first.ProjectionBytes <= 10000, "projection byte count");
            Require(CountFramedFields(first.Projection) == 27 && first.Projection.EndsWith("\n", StringComparison.Ordinal), "exact 27 fields and terminal LF");
            Require(platform.OpenCount == 12 && platform.CloseCount == 12, "all handles closed on success");
            Require(platform.Ledger[0] == "OpenPinnedAncestor|" + Root && platform.Ledger[8] == "OpenLeafProbe|" + Root + "\\docs\\project\\status\\CURRENT_STATUS.md", "root and first file order");
            ProjectContextBundle repeated = loader.Load(Root);
            Require(first.AggregateSha256 == repeated.AggregateSha256 && first.ProjectionSha256 == repeated.ProjectionSha256 && first.Projection == repeated.Projection, "deterministic repeat");
            string prompt = ProjectContextPrompt.Build("plan safely", repeated);
            Require(prompt == "EAIRA_M4_SLICE3_PLANNING_CONTEXT_V1\nGOAL=11:plan safely\nPROJECTION=" + repeated.ProjectionBytes + ":" + repeated.Projection, "exact planning prompt");
            int requestOverhead = LocalModelProvider.BuildCanonicalRequest(AgentRole.Planning, String.Empty).Length;
            string exactBoundaryPrompt = new string('A', 16384 - requestOverhead);
            Require(LocalModelProvider.BuildCanonicalRequest(AgentRole.Planning, exactBoundaryPrompt).Length == 16384, "canonical request exact 16384-byte boundary");
            ProjectContextRequestPreflight.Validate(exactBoundaryPrompt);
            passed++;
            RequireContextFailure(delegate { ProjectContextRequestPreflight.Validate(exactBoundaryPrompt + "A"); }, "canonical request 16385-byte boundary rejected and translated");

            Reset(); platform.AncestorAttributes = DirectoryAttribute | ReparseAttribute; platform.AncestorTag = DirectoryTag;
            SetAllFiles(ReparseAttribute, FileTag); loader.Load(Root); Require(platform.CloseCount == platform.OpenCount, "approved hydrated Cloud Files tags");

            string[] substitutedAncestors = new string[] { Root, Root + "\\docs", Root + "\\docs\\project", Root + "\\docs\\project\\status" };
            uint[] rejectedAncestorAttributes = new uint[]
            {
                DirectoryAttribute | ReparseAttribute,
                DirectoryAttribute | OfflineAttribute,
                DirectoryAttribute | RecallAttribute,
                DirectoryAttribute | RecallDataAttribute,
                DirectoryAttribute | ReparseAttribute,
                DirectoryAttribute | ReparseAttribute,
                DirectoryAttribute,
                0
            };
            uint[] rejectedAncestorTags = new uint[] { 0xA000000C, 0, 0, 0, 0xA0000003, FileTag, DirectoryTag, 0 };
            bool allAncestorCloudStatesRejected = true;
            for (int ancestorIndex = 0; ancestorIndex < substitutedAncestors.Length; ancestorIndex++)
            {
                for (int stateIndex = 0; stateIndex < rejectedAncestorAttributes.Length; stateIndex++)
                {
                    Reset();
                    platform.AncestorStatePath = substitutedAncestors[ancestorIndex];
                    platform.AncestorStateAttributes = rejectedAncestorAttributes[stateIndex];
                    platform.AncestorStateTag = rejectedAncestorTags[stateIndex];
                    try { loader.Load(Root); allAncestorCloudStatesRejected = false; }
                    catch (ProjectContextException) { }
                    if (platform.CloseCount != platform.OpenCount) { allAncestorCloudStatesRejected = false; }
                }
            }
            Require(allAncestorCloudStatesRejected, "every root and ancestor rejects foreign, offline, recall, name-surrogate, wrong, tag-without-reparse and non-directory states with cleanup");

            uint[] rejectedFileAttributes = new uint[]
            {
                ReparseAttribute,
                OfflineAttribute,
                RecallAttribute,
                RecallDataAttribute,
                ReparseAttribute,
                ReparseAttribute,
                0,
                DirectoryAttribute
            };
            uint[] rejectedFileTags = new uint[] { 0xA000000C, 0, 0, 0, 0xA0000003, DirectoryTag, FileTag, 0 };
            bool allFinalCloudStatesRejected = true;
            for (int fileIndex = 0; fileIndex < PathIds.Length; fileIndex++)
            {
                string suffix = PathIds[fileIndex].Replace('/', '\\');
                string fullPath = Root + "\\" + suffix;
                for (int stateIndex = 0; stateIndex < rejectedFileAttributes.Length; stateIndex++)
                {
                    Reset();
                    platform.ProbeStatePath = fullPath;
                    platform.ProbeStateAttributes = rejectedFileAttributes[stateIndex];
                    platform.ProbeStateTag = rejectedFileTags[stateIndex];
                    try { loader.Load(Root); allFinalCloudStatesRejected = false; }
                    catch (ProjectContextException) { }
                    if (platform.CloseCount != platform.OpenCount) { allFinalCloudStatesRejected = false; }

                    Reset();
                    platform.ContentBeforeStatePath = fullPath;
                    platform.ContentBeforeStateAttributes = rejectedFileAttributes[stateIndex];
                    platform.ContentBeforeStateTag = rejectedFileTags[stateIndex];
                    try { loader.Load(Root); allFinalCloudStatesRejected = false; }
                    catch (ProjectContextException) { }
                    if (platform.CloseCount != platform.OpenCount) { allFinalCloudStatesRejected = false; }

                    Reset();
                    platform.ContentAfterStatePath = fullPath;
                    platform.ContentAfterStateAttributes = rejectedFileAttributes[stateIndex];
                    platform.ContentAfterStateTag = rejectedFileTags[stateIndex];
                    try { loader.Load(Root); allFinalCloudStatesRejected = false; }
                    catch (ProjectContextException) { }
                    if (platform.CloseCount != platform.OpenCount) { allFinalCloudStatesRejected = false; }
                }
            }
            Require(allFinalCloudStatesRejected, "every final probe, content-before and content-after state rejects foreign, offline, both recall, name-surrogate, wrong, tag-without-reparse and directory states with cleanup");

            bool allAncestorSubstitutionsRejected = true;
            for (int ancestorIndex = 0; ancestorIndex < substitutedAncestors.Length; ancestorIndex++)
            {
                Reset(); platform.SubstitutePath = substitutedAncestors[ancestorIndex];
                try { loader.Load(Root); allAncestorSubstitutionsRejected = false; }
                catch (ProjectContextException) { }
            }
            Require(allAncestorSubstitutionsRejected, "root and every ancestor full-path substitution rejected");

            bool allFinalSubstitutionsRejected = true;
            for (int fileIndex = 0; fileIndex < PathIds.Length; fileIndex++)
            {
                string fullPath = Root + "\\" + PathIds[fileIndex].Replace('/', '\\');
                Reset(); platform.ProbeSubstitutePath = fullPath;
                try { loader.Load(Root); allFinalSubstitutionsRejected = false; }
                catch (ProjectContextException) { }
                if (platform.CloseCount != platform.OpenCount) { allFinalSubstitutionsRejected = false; }

                Reset(); platform.ContentBeforeSubstitutePath = fullPath;
                try { loader.Load(Root); allFinalSubstitutionsRejected = false; }
                catch (ProjectContextException) { }
                if (platform.CloseCount != platform.OpenCount) { allFinalSubstitutionsRejected = false; }

                Reset(); platform.ContentAfterSubstitutePath = fullPath;
                try { loader.Load(Root); allFinalSubstitutionsRejected = false; }
                catch (ProjectContextException) { }
                if (platform.CloseCount != platform.OpenCount) { allFinalSubstitutionsRejected = false; }
            }
            Require(allFinalSubstitutionsRejected, "every final file probe, content-before and content-after full-path substitution rejected with cleanup");

            bool allProbeIdentitySubstitutionsRejected = true;
            for (int fileIndex = 0; fileIndex < PathIds.Length; fileIndex++)
            {
                Reset(); platform.ProbeIdentityMismatchPath = Root + "\\" + PathIds[fileIndex].Replace('/', '\\');
                try { loader.Load(Root); allProbeIdentitySubstitutionsRejected = false; }
                catch (ProjectContextException) { }
                if (platform.CloseCount != platform.OpenCount) { allProbeIdentitySubstitutionsRejected = false; }
            }
            Require(allProbeIdentitySubstitutionsRejected, "probe-to-content identity substitution rejected for every final file with cleanup");
            Reset(); platform.MutateAfterRead = true; RequireContextFailure(delegate { loader.Load(Root); }, "same-handle mutation rejected"); Require(platform.CloseCount == platform.OpenCount, "mutation cleanup");
            Reset(); platform.PartialRead = true; RequireContextFailure(delegate { loader.Load(Root); }, "partial read rejected");
            Reset(); platform.ThrowOnRead = true; RequireContextFailure(delegate { loader.Load(Root); }, "read exception rejected"); Require(platform.CloseCount == platform.OpenCount, "read exception cleanup");
            bool allContentOpenFailuresRejected = true;
            for (int fileIndex = 0; fileIndex < PathIds.Length; fileIndex++)
            {
                Reset(); platform.ThrowOnApprovedContentOpenPath = Root + "\\" + PathIds[fileIndex].Replace('/', '\\');
                try { loader.Load(Root); allContentOpenFailuresRejected = false; }
                catch (ProjectContextException) { }
                if (platform.CloseCount != platform.OpenCount) { allContentOpenFailuresRejected = false; }
            }
            Require(allContentOpenFailuresRejected, "no-recall content-open failure rejected for every final file");
            Require(platform.CloseCount == platform.OpenCount, "open failure cleanup");

            Reset(); platform.ReplaceBytes("docs\\project\\status\\CURRENT_STATUS.md", new byte[] { 0xEF, 0xBB, 0xBF, 0x41 }); RequireContextFailure(delegate { loader.Load(Root); }, "UTF-8 BOM rejected");
            Reset(); platform.ReplaceBytes("docs\\project\\status\\CURRENT_STATUS.md", new byte[] { 0xC3, 0x28 }); RequireContextFailure(delegate { loader.Load(Root); }, "malformed UTF-8 rejected");
            Require(ProjectContextLoader.ValidateBudgetsForTests(0, 262144) == 262144, "per-file exact 262144-byte boundary accepted");
            Reset(); platform.ReplaceBytes("docs\\project\\status\\CURRENT_STATUS.md", new byte[262145]); RequireContextFailure(delegate { loader.Load(Root); }, "per-file byte ceiling rejected");
            Require(ProjectContextLoader.ValidateBudgetsForTests(1048576, 0) == 1048576, "aggregate exact 1048576-byte boundary accepted");
            RequireContextFailure(delegate { ProjectContextLoader.ValidateBudgetsForTests(1048576, 1); }, "aggregate 1048577-byte boundary rejected");

            Reset(); platform.Remove("docs\\project\\status\\TODAY_OBJECTIVE.md"); RequireContextFailure(delegate { loader.Load(Root); }, "missing allowlisted file rejected");
            Reset(); platform.AddExtra("docs\\project\\status\\EXTRA.md", "extra must remain unreachable");
            ProjectContextBundle withExtra = loader.Load(Root);
            Require(withExtra.AggregateSha256 == first.AggregateSha256 && withExtra.Projection == first.Projection &&
                    String.Join("\n", new List<string>(platform.Ledger).ToArray()).IndexOf("EXTRA.md", StringComparison.Ordinal) < 0,
                    "extra file is neither enumerated, read nor projected");

            Reset(); platform.ReplaceText("docs\\project\\status\\CURRENT_STATUS.md", CurrentStatus() + "\n## Version\n0.1\n"); RequireContextFailure(delegate { loader.Load(Root); }, "duplicate Markdown heading rejected");
            Reset(); platform.ReplaceText("docs\\project\\status\\ACTIVE_TASK.yaml", ActiveTask().Replace("\"Owner\": \"Human Project Owner\"\n", String.Empty)); RequireContextFailure(delegate { loader.Load(Root); }, "missing required YAML field rejected");
            Reset(); platform.ReplaceText("docs\\project\\status\\AGENT_CONTEXT_VERSION.yaml", AgentVersion().Replace("\"Current Status Version\": \"0.1\"", "\"Current Status Version\": \"9.9\"")); RequireContextFailure(delegate { loader.Load(Root); }, "version mismatch rejected");
            Reset(); platform.ReplaceText("docs\\project\\status\\AGENT_CONTEXT_VERSION.yaml", AgentVersion().Replace("\"Today Objective Version\": \"0.2\"", "\"Today Objective Version\": \"9.9\"")); RequireContextFailure(delegate { loader.Load(Root); }, "today objective version mismatch rejected");
            Reset(); platform.ReplaceText("docs\\project\\status\\CURRENT_STATUS.md", CurrentStatus().Replace("- Signing deferred\n\n", "- Signing deferred\n  continuation\n\n")); RequireContextFailure(delegate { loader.Load(Root); }, "Markdown list continuation rejected");
            Reset(); platform.ReplaceText("docs\\project\\status\\CURRENT_STATUS.md", CurrentStatus().Replace("- Signing deferred\n\n", "- Signing deferred\n  - nested\n\n")); RequireContextFailure(delegate { loader.Load(Root); }, "nested Markdown list rejected");
            Reset(); platform.ReplaceText("docs\\project\\status\\ACTIVE_TASK.yaml", ActiveTask() + "\"Task ID\": \"DUPLICATE\"\n"); RequireContextFailure(delegate { loader.Load(Root); }, "duplicate quoted YAML key rejected");
            Reset(); platform.ReplaceText("docs\\project\\status\\ACTIVE_TASK.yaml", ActiveTask().Replace("  - \"NOWRITE_A\"", "    - \"NESTED\"")); RequireContextFailure(delegate { loader.Load(Root); }, "nested YAML list rejected");
            Reset(); platform.ReplaceText("docs\\project\\status\\ACTIVE_TASK.yaml", ActiveTask().Replace("\"Owner\": \"Human Project Owner\"", "\"Owner\": \"Human \"Project\" Owner\"")); RequireContextFailure(delegate { loader.Load(Root); }, "unescaped YAML quote rejected");

            Reset(); platform.ReplaceText("docs\\project\\status\\AGENT_CONTEXT_VERSION.yaml", AgentVersion() + "\"Task ID\": \"LOWER_PRECEDENCE_OVERRIDE_ATTEMPT\"\n");
            RequireContextFailure(delegate { loader.Load(Root); }, "lower-precedence ownership conflict rejected");

            string scope = "Implement a bounded read-only context slice.";
            int projectionGrowth = 10000 - first.ProjectionBytes;
            int originalScopeBytes = new UTF8Encoding(false, true).GetByteCount(scope);
            int framedLengthGrowth = checked((originalScopeBytes + projectionGrowth).ToString(CultureInfo.InvariantCulture).Length - originalScopeBytes.ToString(CultureInfo.InvariantCulture).Length);
            projectionGrowth = checked(projectionGrowth - framedLengthGrowth);
            Reset(); platform.ReplaceText("docs\\project\\status\\TODAY_OBJECTIVE.md", TodayObjective().Replace(scope, scope + new string('X', projectionGrowth)));
            ProjectContextBundle exactProjection = loader.Load(Root);
            Require(exactProjection.ProjectionBytes == 10000, "projection exact 10000-byte boundary accepted");
            Reset(); platform.ReplaceText("docs\\project\\status\\TODAY_OBJECTIVE.md", TodayObjective().Replace(scope, scope + new string('X', projectionGrowth + 1)));
            RequireContextFailure(delegate { loader.Load(Root); }, "projection 10001-byte boundary rejected");

            byte[] empty = new byte[0];
            byte[] one = new byte[] { 0x41 };
            byte[] different = new byte[] { 0x42 };
            byte[] nonAscii = new UTF8Encoding(false, true).GetBytes("台");
            byte[] maximumMinusOne = new byte[262143];
            byte[] maximum = new byte[262144];
            for (int index = 0; index < maximumMinusOne.Length; index++) { maximumMinusOne[index] = 0x58; }
            for (int index = 0; index < maximum.Length; index++) { maximum[index] = 0x58; }
            string[] reversedPathIds = new string[] { PathIds[3], PathIds[2], PathIds[1], PathIds[0] };
            Require(ComputeSyntheticAggregate(new byte[][] { empty, empty, empty, empty }) == "F7D090412CE74767C331DD61AB004FC568B1D49EF3F27B08C9257EFF2D79B82B" &&
                    ComputeSyntheticAggregate(new byte[][] { one, one, one, one }) == "67D788CB7AE2FE4EA3871EAE6A67975E76E9A6AD3BAA4CB8E3D8224E01EC36BD" &&
                    ComputeSyntheticAggregate(new byte[][] { nonAscii, nonAscii, nonAscii, nonAscii }) == "6269C3B22B1A5156B05E12E1F1CF2F51907E81D9C6F8C0A4F670FA068D6C0A9A" &&
                    ComputeSyntheticAggregate(reversedPathIds, new byte[][] { empty, empty, empty, empty }) == "E2600CD56BD3F07F8586AD8D682AB990842281C36B0369922F6A1B2DB0475663" &&
                    ComputeSyntheticAggregate(new byte[][] { maximumMinusOne, empty, empty, empty }) == "5CCF24DB315EA48A19A903F2A4A2ED674BD80005529F2127C790676D01FC912D" &&
                    ComputeSyntheticAggregate(new byte[][] { maximum, empty, empty, empty }) == "7FDEFFB5478FA918474CFD3B69C156434F190D8DDCF57FA3D9DB2BB43A1A2082" &&
                    ComputeSyntheticAggregate(new byte[][] { different, one, one, one }) == "A725CF568F08C4FAA6C0EA7835452401278B87563F9E4E216863542031EBC0C3",
                    "fixed empty, one-byte, non-ASCII, path-order, maximum-length-boundary and content-change aggregate digest golden vectors");

            const string rawLogSentinel = "RAW_CONTEXT_LOG_SENTINEL_DO_NOT_EMIT";
            Reset(); platform.ReplaceText("docs\\project\\status\\CURRENT_STATUS.md", CurrentStatus() + "\n## Opaque Evidence\n" + rawLogSentinel + "\n");
            ProjectContextBundle sentinelBundle = loader.Load(Root);
            string sentinelMetadata = new ProjectContextResultMetadata(sentinelBundle).ToCanonicalJson();
            Require(sentinelMetadata.IndexOf(rawLogSentinel, StringComparison.Ordinal) < 0, "raw-content sentinel absent from canonical result metadata");

            Reset(); ProjectContextBundle beforeChange = loader.Load(Root); Reset(); platform.ReplaceText("docs\\project\\status\\TODAY_OBJECTIVE.md", TodayObjective().Replace("Four files only", "Exactly four files only")); ProjectContextBundle afterChange = loader.Load(Root);
            Require(beforeChange.AggregateSha256 != afterChange.AggregateSha256 && beforeChange.ProjectionSha256 != afterChange.ProjectionSha256, "content change binds aggregate and projection");
            string[] invalidRoots = new string[] { "relative-root", "C:/EAIRA-CONTEXT-FIXTURE", "c:\\EAIRA-CONTEXT-FIXTURE", "C:\\EAIRA-CONTEXT-FIXTURE:stream", "\\\\server\\share\\EAIRA", "\\\\?\\C:\\EAIRA-CONTEXT-FIXTURE", "\\\\.\\C:\\EAIRA-CONTEXT-FIXTURE" };
            bool allInvalidRootsRejected = true;
            for (int rootIndex = 0; rootIndex < invalidRoots.Length; rootIndex++)
            {
                try { loader.Load(invalidRoots[rootIndex]); allInvalidRootsRejected = false; }
                catch (ProjectContextException) { }
            }
            Require(allInvalidRootsRejected, "relative, separator, case, ADS, UNC and device roots rejected");
            RequireContextFailure(delegate { loader.Load("C:\\EAIRA~1"); }, "short-name root rejected");
        }

        private static void SetFirstFile(uint attributes, uint tag)
        {
            platform.SetFileState("docs\\project\\status\\CURRENT_STATUS.md", attributes, tag);
        }

        private static string ComputeAggregateIndependently()
        {
            List<byte> framed = new List<byte>();
            framed.AddRange(Encoding.ASCII.GetBytes("EAIRA_M4_SLICE3_CONTEXT_BUNDLE_V1"));
            framed.Add(0);
            for (int index = 0; index < PathIds.Length; index++)
            {
                byte[] path = new UTF8Encoding(false, true).GetBytes(PathIds[index]);
                byte[] raw = platform.GetBytes(PathIds[index]);
                AppendUInt32Independently(framed, checked((uint)path.Length));
                framed.AddRange(path);
                AppendUInt64Independently(framed, checked((ulong)raw.Length));
                framed.AddRange(Hash(raw));
            }
            return HashHex(framed.ToArray());
        }

        private static string ComputeSyntheticAggregate(byte[][] rawFiles)
        {
            return ComputeSyntheticAggregate(PathIds, rawFiles);
        }

        private static string ComputeSyntheticAggregate(string[] pathIds, byte[][] rawFiles)
        {
            if (pathIds == null || rawFiles == null || pathIds.Length != PathIds.Length || rawFiles.Length != PathIds.Length) { throw new ContractException("Synthetic aggregate input is invalid."); }
            List<byte> framed = new List<byte>();
            framed.AddRange(Encoding.ASCII.GetBytes("EAIRA_M4_SLICE3_CONTEXT_BUNDLE_V1"));
            framed.Add(0);
            for (int index = 0; index < pathIds.Length; index++)
            {
                byte[] path = new UTF8Encoding(false, true).GetBytes(pathIds[index]);
                byte[] raw = rawFiles[index];
                AppendUInt32Independently(framed, checked((uint)path.Length));
                framed.AddRange(path);
                AppendUInt64Independently(framed, checked((ulong)raw.Length));
                framed.AddRange(Hash(raw));
            }
            return HashHex(framed.ToArray());
        }

        private static void AppendUInt32Independently(List<byte> output, uint value)
        {
            for (int shift = 24; shift >= 0; shift -= 8) { output.Add((byte)((value >> shift) & 0xFFU)); }
        }

        private static void AppendUInt64Independently(List<byte> output, ulong value)
        {
            for (int shift = 56; shift >= 0; shift -= 8) { output.Add((byte)((value >> shift) & 0xFFUL)); }
        }

        private static byte[] Hash(byte[] value)
        {
            using (SHA256 sha = SHA256.Create()) { return sha.ComputeHash(value); }
        }

        private static string HashHex(byte[] value)
        {
            byte[] digest = Hash(value);
            StringBuilder text = new StringBuilder(64);
            for (int index = 0; index < digest.Length; index++) { text.Append(digest[index].ToString("X2")); }
            return text.ToString();
        }

        private static void SetAllFiles(uint attributes, uint tag)
        {
            platform.SetFileState("docs\\project\\status\\CURRENT_STATUS.md", attributes, tag);
            platform.SetFileState("docs\\project\\status\\TODAY_OBJECTIVE.md", attributes, tag);
            platform.SetFileState("docs\\project\\status\\ACTIVE_TASK.yaml", attributes, tag);
            platform.SetFileState("docs\\project\\status\\AGENT_CONTEXT_VERSION.yaml", attributes, tag);
        }

        internal static int Main(string[] args)
        {
            if (args == null || args.Length != 1 || !String.Equals(args[0], "--self-test", StringComparison.Ordinal)) { return 64; }
            try
            {
                ProjectContextLoader loader = CreateLoaderForTests();
                RunAll(loader);
                Console.WriteLine("{\"status\":\"PASS\",\"contract\":\"EAIRA_READ_ONLY_PROJECT_CONTEXT_V1\",\"testsPassed\":" + passed + ",\"network\":\"NONE\",\"writes\":\"NONE\"}");
                return 0;
            }
            catch (Exception)
            {
                Console.WriteLine("{\"status\":\"FAIL\",\"errorType\":\"HarnessFailure\"}");
                return 70;
            }
        }
    }
}
