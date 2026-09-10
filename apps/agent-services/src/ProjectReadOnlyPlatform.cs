using System;
using System.Runtime.InteropServices;
using System.Text;

namespace EAIRA.AgentServices.Functional
{
    internal sealed class ProjectReadOnlyException : Exception
    {
        internal ProjectReadOnlyException() : base(String.Empty) { }
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
            return other != null && String.Equals(CanonicalPath, other.CanonicalPath, StringComparison.Ordinal) &&
                   VolumeSerial == other.VolumeSerial && FileId == other.FileId && Length == other.Length &&
                   LastWriteTime == other.LastWriteTime && Attributes == other.Attributes && ReparseTag == other.ReparseTag;
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

#if EAIRA_PROJECT_READONLY_NATIVE
    internal sealed class ProjectContextWin32Platform : IProjectContextReadOnlyPlatform
    {
        private const int MaximumPhysicalReadBytes = 262144;
        private const uint GenericRead = 0x80000000;
        private const uint FileShareRead = 0x00000001;
        private const uint OpenExisting = 3;
        private const uint OpenReparsePoint = 0x00200000;
        private const uint BackupSemantics = 0x02000000;
        private const uint OpenNoRecall = 0x00100000;
        private const uint SequentialScan = 0x08000000;
        private const uint VolumeNameDos = 0;

        internal ProjectContextWin32Platform() { }

        private sealed class PinnedAncestorToken : IPinnedAncestorHandle { internal ProjectContextNativeLease Lease { get; private set; } internal PinnedAncestorToken(ProjectContextNativeLease lease) { Lease = lease; } }
        private sealed class LeafProbeToken : ILeafProbeHandle { internal ProjectContextNativeLease Lease { get; private set; } internal LeafProbeToken(ProjectContextNativeLease lease) { Lease = lease; } }
        private sealed class ApprovedContentToken : IApprovedContentHandle { internal ProjectContextNativeLease Lease { get; private set; } internal ApprovedContentToken(ProjectContextNativeLease lease) { Lease = lease; } }

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

        public ProjectContextFileMetadata QueryPinnedAncestor(IPinnedAncestorHandle handle) { PinnedAncestorToken token = handle as PinnedAncestorToken; if (token == null) { throw new ProjectReadOnlyException(); } return QueryMetadata(token.Lease); }
        public ProjectContextFileMetadata QueryLeafProbe(ILeafProbeHandle handle) { LeafProbeToken token = handle as LeafProbeToken; if (token == null) { throw new ProjectReadOnlyException(); } return QueryMetadata(token.Lease); }
        public ProjectContextFileMetadata QueryApprovedContent(IApprovedContentHandle handle) { ApprovedContentToken token = handle as ApprovedContentToken; if (token == null) { throw new ProjectReadOnlyException(); } return QueryMetadata(token.Lease); }

        public byte[] ReadApprovedContent(IApprovedContentHandle handle, int exactByteCount)
        {
            ApprovedContentToken token = handle as ApprovedContentToken;
            if (token == null || exactByteCount < 0 || exactByteCount > MaximumPhysicalReadBytes) { throw new ProjectReadOnlyException(); }
            byte[] buffer = new byte[exactByteCount];
            uint read;
            if (!ReadFile(token.Lease.Handle, buffer, checked((uint)exactByteCount), out read, IntPtr.Zero) || read != exactByteCount) { throw new ProjectReadOnlyException(); }
            return buffer;
        }

        public void ClosePinnedAncestor(IPinnedAncestorHandle handle) { PinnedAncestorToken token = handle as PinnedAncestorToken; if (token == null) { throw new ProjectReadOnlyException(); } token.Lease.Close(); }
        public void CloseLeafProbe(ILeafProbeHandle handle) { LeafProbeToken token = handle as LeafProbeToken; if (token == null) { throw new ProjectReadOnlyException(); } token.Lease.Close(); }
        public void CloseApprovedContent(IApprovedContentHandle handle) { ApprovedContentToken token = handle as ApprovedContentToken; if (token == null) { throw new ProjectReadOnlyException(); } token.Lease.Close(); }

        private static ProjectContextFileMetadata QueryMetadata(ProjectContextNativeLease lease)
        {
            ByHandleFileInformation information = QueryIdentityAndMetadata(lease);
            FileAttributeTagInformation tag = QueryAttributeTag(lease);
            string value = QueryCanonicalFinalPath(lease);
            return new ProjectContextFileMetadata(value, information.VolumeSerialNumber, ((ulong)information.FileIndexHigh << 32) | information.FileIndexLow, ((ulong)information.FileSizeHigh << 32) | information.FileSizeLow, ((ulong)information.LastWriteTimeHigh << 32) | information.LastWriteTimeLow, tag.FileAttributes, tag.ReparseTag);
        }

        private static ByHandleFileInformation QueryIdentityAndMetadata(ProjectContextNativeLease lease)
        {
            ByHandleFileInformation information;
            if (!GetFileInformationByHandle(lease.Handle, out information)) { throw new ProjectReadOnlyException(); }
            return information;
        }

        private static FileAttributeTagInformation QueryAttributeTag(ProjectContextNativeLease lease)
        {
            FileAttributeTagInformation tag;
            if (!GetFileInformationByHandleEx(lease.Handle, 9, out tag, checked((uint)Marshal.SizeOf(typeof(FileAttributeTagInformation))))) { throw new ProjectReadOnlyException(); }
            return tag;
        }

        private static string QueryCanonicalFinalPath(ProjectContextNativeLease lease)
        {
            StringBuilder buffer = new StringBuilder(32768);
            uint count = GetFinalPathNameByHandleW(lease.Handle, buffer, checked((uint)buffer.Capacity), VolumeNameDos);
            if (count == 0 || count >= buffer.Capacity) { throw new ProjectReadOnlyException(); }
            string value = buffer.ToString();
            const string prefix = "\\\\?\\";
            if (!value.StartsWith(prefix, StringComparison.Ordinal) || value.StartsWith("\\\\?\\UNC\\", StringComparison.OrdinalIgnoreCase)) { throw new ProjectReadOnlyException(); }
            value = value.Substring(prefix.Length);
            if (value.Length < 3 || value[1] != ':') { throw new ProjectReadOnlyException(); }
            return Char.ToUpperInvariant(value[0]) + value.Substring(1);
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct ByHandleFileInformation { internal uint FileAttributes, CreationTimeLow, CreationTimeHigh, LastAccessTimeLow, LastAccessTimeHigh, LastWriteTimeLow, LastWriteTimeHigh, VolumeSerialNumber, FileSizeHigh, FileSizeLow, NumberOfLinks, FileIndexHigh, FileIndexLow; }
        [StructLayout(LayoutKind.Sequential)]
        private struct FileAttributeTagInformation { internal uint FileAttributes; internal uint ReparseTag; }

        private sealed class ProjectContextNativeLease
        {
            internal IntPtr Handle { get; private set; }
            private ProjectContextNativeLease(IntPtr handle) { Handle = handle; }
            internal static ProjectContextNativeLease Create(IntPtr handle)
            {
                if (handle == IntPtr.Zero || handle == new IntPtr(-1)) { throw new ProjectReadOnlyException(); }
                return new ProjectContextNativeLease(handle);
            }
            internal void Close()
            {
                IntPtr handle = Handle;
                Handle = IntPtr.Zero;
                if (handle != IntPtr.Zero && !CloseHandle(handle)) { throw new ProjectReadOnlyException(); }
            }
        }

        [DllImport("kernel32.dll", EntryPoint = "CreateFileW", ExactSpelling = true, CallingConvention = CallingConvention.Winapi, CharSet = CharSet.Unicode, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true, PreserveSig = true)]
        private static extern IntPtr CreateFileW(string fileName, uint desiredAccess, uint shareMode, IntPtr securityAttributes, uint creationDisposition, uint flagsAndAttributes, IntPtr templateFile);
        [DllImport("kernel32.dll", EntryPoint = "GetFileInformationByHandle", ExactSpelling = true, CallingConvention = CallingConvention.Winapi, CharSet = CharSet.Unicode, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true, PreserveSig = true)]
        [return: MarshalAs(UnmanagedType.Bool)] private static extern bool GetFileInformationByHandle(IntPtr file, out ByHandleFileInformation information);
        [DllImport("kernel32.dll", EntryPoint = "GetFileInformationByHandleEx", ExactSpelling = true, CallingConvention = CallingConvention.Winapi, CharSet = CharSet.Unicode, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true, PreserveSig = true)]
        [return: MarshalAs(UnmanagedType.Bool)] private static extern bool GetFileInformationByHandleEx(IntPtr file, int informationClass, out FileAttributeTagInformation information, uint bufferSize);
        [DllImport("kernel32.dll", EntryPoint = "GetFinalPathNameByHandleW", ExactSpelling = true, CallingConvention = CallingConvention.Winapi, CharSet = CharSet.Unicode, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true, PreserveSig = true)]
        private static extern uint GetFinalPathNameByHandleW(IntPtr file, StringBuilder path, uint pathLength, uint flags);
        [DllImport("kernel32.dll", EntryPoint = "ReadFile", ExactSpelling = true, CallingConvention = CallingConvention.Winapi, CharSet = CharSet.Unicode, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true, PreserveSig = true)]
        [return: MarshalAs(UnmanagedType.Bool)] private static extern bool ReadFile(IntPtr file, [Out] byte[] buffer, uint bytesToRead, out uint bytesRead, IntPtr overlapped);
        [DllImport("kernel32.dll", EntryPoint = "CloseHandle", ExactSpelling = true, CallingConvention = CallingConvention.Winapi, CharSet = CharSet.Unicode, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true, PreserveSig = true)]
        [return: MarshalAs(UnmanagedType.Bool)] private static extern bool CloseHandle(IntPtr handle);
    }
#endif
}
