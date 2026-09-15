using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;
using SafeFileHandle = EAIRA.AgentServices.Packaging.OwnedFileHandle;

namespace EAIRA.AgentServices.Packaging
{
    internal sealed class OwnedFileHandle : SafeHandleZeroOrMinusOneIsInvalid
    {
        [DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool CloseHandle(IntPtr value);
        internal bool CloseSucceeded { get; private set; }
        public OwnedFileHandle() : base(true) { }
        protected override bool ReleaseHandle()
        {
#if EAIRA_PACKAGE_TEST_SEAMS
            if (PackageTestFileSystem.IsTestHandle(handle)) { CloseSucceeded = PackageTestFileSystem.Close(handle); return CloseSucceeded; }
#endif
            CloseSucceeded = CloseHandle(handle); return CloseSucceeded;
        }
#if EAIRA_PACKAGE_TEST_SEAMS
        internal OwnedFileHandle(IntPtr value) : base(true) { SetHandle(value); }
        internal OwnedFileHandle(IntPtr value, bool owns) : base(owns) { SetHandle(value); }
#endif
        internal bool CloseChecked() { Dispose(); return IsClosed && CloseSucceeded; }
    }

    internal static class NativePackageFileSystem
    {
        [StructLayout(LayoutKind.Sequential)] private struct UnicodeString { internal ushort Length; internal ushort MaximumLength; internal IntPtr Buffer; }
        [StructLayout(LayoutKind.Sequential)] private struct ObjectAttributes { internal int Length; internal IntPtr RootDirectory; internal IntPtr ObjectName; internal uint Attributes; internal IntPtr SecurityDescriptor; internal IntPtr SecurityQualityOfService; }
        [StructLayout(LayoutKind.Sequential)] private struct IoStatusBlock { internal IntPtr Status; internal UIntPtr Information; }
        [StructLayout(LayoutKind.Sequential)] private struct AttributeTagInfo { internal uint Attributes; internal uint ReparseTag; }
        [StructLayout(LayoutKind.Sequential)] private struct FileTime { internal uint Low; internal uint High; }
        [StructLayout(LayoutKind.Sequential)] private struct ByHandleInfo { internal uint Attributes; internal FileTime Creation; internal FileTime Access; internal FileTime Write; internal uint Volume; internal uint SizeHigh; internal uint SizeLow; internal uint Links; internal uint IndexHigh; internal uint IndexLow; }

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, ExactSpelling = true, SetLastError = true)]
        private static extern SafeFileHandle CreateFileW(string path, uint access, uint share, IntPtr security, uint creation, uint flags, IntPtr template);
        [DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)] [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool GetFileInformationByHandleEx(SafeFileHandle handle, int informationClass, out AttributeTagInfo information, uint size);
        [DllImport("kernel32.dll", EntryPoint = "GetFileInformationByHandleEx", ExactSpelling = true, SetLastError = true)] [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool GetFileIdInformation(SafeFileHandle handle, int informationClass, IntPtr information, uint size);
        [DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)] [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool GetFileInformationByHandle(SafeFileHandle handle, out ByHandleInfo information);
        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, ExactSpelling = true, SetLastError = true)]
        private static extern uint GetFinalPathNameByHandleW(SafeFileHandle handle, StringBuilder path, uint length, uint flags);
        [DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)] [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool ReadFile(SafeFileHandle handle, byte[] buffer, uint count, out uint read, IntPtr overlapped);
        [DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)] [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool WriteFile(SafeFileHandle handle, byte[] buffer, uint count, out uint written, IntPtr overlapped);
        [DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)] [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool FlushFileBuffers(SafeFileHandle handle);
        [DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)] [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool SetFilePointerEx(SafeFileHandle handle, long distance, out long position, uint method);
        [DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)] [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool GetFileSizeEx(SafeFileHandle handle, out long size);
        [DllImport("ntdll.dll", ExactSpelling = true)]
        private static extern int NtCreateFile(out SafeFileHandle handle, uint access, ref ObjectAttributes attributes, out IoStatusBlock io, IntPtr allocationSize, uint fileAttributes, uint share, uint disposition, uint options, IntPtr eaBuffer, uint eaLength);
        [DllImport("ntdll.dll", ExactSpelling = true)]
        private static extern int NtQueryDirectoryFile(SafeFileHandle handle, IntPtr eventHandle, IntPtr apcRoutine, IntPtr apcContext, out IoStatusBlock io, IntPtr buffer, uint length, int informationClass, [MarshalAs(UnmanagedType.U1)] bool singleEntry, IntPtr fileName, [MarshalAs(UnmanagedType.U1)] bool restartScan);
        [DllImport("ntdll.dll", ExactSpelling = true)]
        private static extern int NtSetInformationFile(SafeFileHandle handle, out IoStatusBlock io, IntPtr buffer, uint length, int informationClass);

        private const uint ReadData = 1, WriteData = 2, AddFile = 2, AddSubdirectory = 4, Traverse = 0x20, DeleteChild = 0x40, ReadAttributes = 0x80, WriteAttributes = 0x100, Delete = 0x10000, Synchronize = 0x100000;
        private const uint ShareRead = 1, ShareWrite = 2, FileOpen = 1, FileCreate = 2;
        private const uint Directory = 1, SyncNonAlert = 0x20, NonDirectory = 0x40, OpenReparse = 0x200000, NoRecall = 0x400000;

        internal static SafeFileHandle OpenAbsoluteDirectory(string path)
        {
#if EAIRA_PACKAGE_TEST_SEAMS
            if (PackageTestFileSystem.Active) return PackageTestFileSystem.Open(path, true);
#endif
            SafeFileHandle h = CreateFileW(path, ReadData | ReadAttributes | Synchronize, ShareRead | ShareWrite, IntPtr.Zero, 3, 0x02300000, IntPtr.Zero);
            Validate(h, path, true); return h;
        }

        internal static SafeFileHandle OpenAbsoluteFile(string path)
        {
#if EAIRA_PACKAGE_TEST_SEAMS
            if (PackageTestFileSystem.Active) return PackageTestFileSystem.Open(path, false);
#endif
            SafeFileHandle h = CreateFileW(path, ReadData | ReadAttributes | Synchronize, ShareRead, IntPtr.Zero, 3, 0x00300000, IntPtr.Zero);
            Validate(h, path, false); return h;
        }

        internal static SafeFileHandle OpenAbsoluteProfile(string path)
        {
#if EAIRA_PACKAGE_TEST_SEAMS
            if (PackageTestFileSystem.Active) return PackageTestFileSystem.Open(path, false);
#endif
            SafeFileHandle h = CreateFileW(path, ReadData | ReadAttributes | Synchronize, ShareRead, IntPtr.Zero, 3, 0x00100000, IntPtr.Zero);
            if (h == null || h.IsInvalid) throw new InvalidDataException(); AttributeTagInfo tag;
            if (!GetFileInformationByHandleEx(h, 9, out tag, 8) || !AllowedAttributes(tag.Attributes, tag.ReparseTag, true)) { h.Dispose(); throw new InvalidDataException(); }
            ByHandleInfo info; if (!GetFileInformationByHandle(h, out info) || (tag.Attributes & 0x10) != 0 || info.Links != 1) { h.Dispose(); throw new InvalidDataException(); }
            GetIdentity(h); var final = new StringBuilder(32768); uint length = GetFinalPathNameByHandleW(h, final, 32768, 0); if (length < 4 || length >= 32768 || !String.Equals(final.ToString(), @"\\?\" + path, StringComparison.OrdinalIgnoreCase)) { h.Dispose(); throw new InvalidDataException(); }
            return h;
        }

        internal static SafeFileHandle CreateDirectory(SafeFileHandle parent, string parentPath, string leaf, bool cleanupAuthority)
        {
#if EAIRA_PACKAGE_TEST_SEAMS
            if (PackageTestFileSystem.Active) return PackageTestFileSystem.Create(parent, parentPath, leaf, true, cleanupAuthority);
#endif
            uint access = ReadData | AddFile | AddSubdirectory | Traverse | ReadAttributes | WriteAttributes | Synchronize;
            if (cleanupAuthority) access |= Delete;
            SafeFileHandle h = Relative(parent, leaf, access, ShareRead | ShareWrite, FileCreate, Directory | SyncNonAlert | OpenReparse, 2);
            Validate(h, Path.Combine(parentPath, leaf), true); return h;
        }

        internal static SafeFileHandle OpenDirectory(SafeFileHandle parent, string parentPath, string leaf)
        {
#if EAIRA_PACKAGE_TEST_SEAMS
            if (PackageTestFileSystem.Active) return PackageTestFileSystem.OpenRelative(parent, parentPath, leaf, true);
#endif
            SafeFileHandle h = Relative(parent, leaf, ReadData | ReadAttributes | Synchronize, ShareRead | ShareWrite, FileOpen, Directory | SyncNonAlert | OpenReparse, 1);
            Validate(h, Path.Combine(parentPath, leaf), true); return h;
        }

        internal static SafeFileHandle CreateFile(SafeFileHandle parent, string parentPath, string leaf, bool cleanupAuthority)
        {
#if EAIRA_PACKAGE_TEST_SEAMS
            if (PackageTestFileSystem.Active) return PackageTestFileSystem.Create(parent, parentPath, leaf, false, cleanupAuthority);
#endif
            uint access = ReadData | WriteData | ReadAttributes | WriteAttributes | Synchronize;
            if (cleanupAuthority) access |= Delete;
            SafeFileHandle h = Relative(parent, leaf, access, ShareRead, FileCreate, NonDirectory | SyncNonAlert | OpenReparse, 2);
            Validate(h, Path.Combine(parentPath, leaf), false); return h;
        }

        internal static SafeFileHandle OpenFile(SafeFileHandle parent, string parentPath, string leaf)
        {
#if EAIRA_PACKAGE_TEST_SEAMS
            if (PackageTestFileSystem.Active) return PackageTestFileSystem.OpenRelative(parent, parentPath, leaf, false);
#endif
            SafeFileHandle h = Relative(parent, leaf, ReadData | ReadAttributes | Synchronize, ShareRead, FileOpen, NonDirectory | SyncNonAlert | OpenReparse, 1);
            Validate(h, Path.Combine(parentPath, leaf), false); return h;
        }

        internal static SafeFileHandle OpenSourceFile(SafeFileHandle parent, string parentPath, string leaf)
        {
#if EAIRA_PACKAGE_TEST_SEAMS
            if (PackageTestFileSystem.Active) return PackageTestFileSystem.OpenRelative(parent, parentPath, leaf, false);
#endif
            SafeFileHandle h = Relative(parent, leaf, ReadData | ReadAttributes | Synchronize, ShareRead, FileOpen, NonDirectory | SyncNonAlert | OpenReparse | NoRecall, 1);
            Validate(h, Path.Combine(parentPath, leaf), false); return h;
        }


        private static SafeFileHandle Relative(SafeFileHandle parent, string leaf, uint access, uint share, uint disposition, uint options, ulong expectedInformation)
        {
            if (String.IsNullOrEmpty(leaf) || leaf.IndexOfAny(new[] { '\\', '/', ':' }) >= 0 || leaf == "." || leaf == "..") throw new InvalidDataException();
            IntPtr text = Marshal.StringToHGlobalUni(leaf), unicode = IntPtr.Zero;
            try
            {
                UnicodeString name = new UnicodeString { Length = checked((ushort)(leaf.Length * 2)), MaximumLength = checked((ushort)(leaf.Length * 2)), Buffer = text };
                unicode = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(UnicodeString))); Marshal.StructureToPtr(name, unicode, false);
                ObjectAttributes attributes = new ObjectAttributes { Length = Marshal.SizeOf(typeof(ObjectAttributes)), RootDirectory = parent.DangerousGetHandle(), ObjectName = unicode, Attributes = 0x40 };
                SafeFileHandle handle; IoStatusBlock io; int status = NtCreateFile(out handle, access, ref attributes, out io, IntPtr.Zero, 0, share, disposition, options, IntPtr.Zero, 0);
                if (status != 0 || handle == null || handle.IsInvalid || io.Information.ToUInt64() != expectedInformation) { if (handle != null) handle.Dispose(); throw new InvalidDataException(); }
                return handle;
            }
            finally { if (unicode != IntPtr.Zero) Marshal.FreeHGlobal(unicode); Marshal.FreeHGlobal(text); }
        }

        internal static void WriteBytes(SafeFileHandle handle, byte[] bytes)
        {
#if EAIRA_PACKAGE_TEST_SEAMS
            if (PackageTestFileSystem.Active) { PackageTestFileSystem.Write(handle, bytes); return; }
#endif
            long position; uint written;
            if (!SetFilePointerEx(handle, 0, out position, 0) || position != 0 ||
                !WriteFile(handle, bytes, checked((uint)bytes.Length), out written, IntPtr.Zero) || written != bytes.Length) throw new InvalidDataException();
        }

        internal static void FlushAndVerify(SafeFileHandle handle, byte[] bytes)
        {
#if EAIRA_PACKAGE_TEST_SEAMS
            if (PackageTestFileSystem.Active) { if (!Equal(ReadAll(handle, bytes.Length), bytes)) throw new InvalidDataException(); return; }
#endif
            if (!FlushFileBuffers(handle)) throw new InvalidDataException();
            byte[] actual = ReadAll(handle, bytes.Length);
            if (!Equal(actual, bytes)) throw new InvalidDataException();
        }

        internal static void WriteAll(SafeFileHandle handle, byte[] bytes)
        { WriteBytes(handle, bytes); FlushAndVerify(handle, bytes); }

        internal static byte[] ReadAll(SafeFileHandle handle, int maximum)
        {
#if EAIRA_PACKAGE_TEST_SEAMS
            if (PackageTestFileSystem.Active) return PackageTestFileSystem.Read(handle, maximum);
#endif
            long size, position; if (!GetFileSizeEx(handle, out size) || size < 0 || size > maximum ||
                !SetFilePointerEx(handle, 0, out position, 0) || position != 0) throw new InvalidDataException();
            byte[] bytes = new byte[(int)size]; uint read;
            if (bytes.Length != 0 && (!ReadFile(handle, bytes, checked((uint)bytes.Length), out read, IntPtr.Zero) || read != bytes.Length)) throw new InvalidDataException();
            byte[] extra = new byte[1]; if (!ReadFile(handle, extra, 1, out read, IntPtr.Zero) || read != 0) throw new InvalidDataException();
            return bytes;
        }

        internal static string[] Enumerate(SafeFileHandle directory)
        {
#if EAIRA_PACKAGE_TEST_SEAMS
            if (PackageTestFileSystem.Active) return PackageTestFileSystem.Enumerate(directory);
#endif
            IntPtr buffer = Marshal.AllocHGlobal(65536); var names = new List<string>(); bool restart = true;
            try
            {
                while (true)
                {
                    for (int i = 0; i < 65536; i++) Marshal.WriteByte(buffer, i, 0);
                    IoStatusBlock io; int status = NtQueryDirectoryFile(directory, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, out io, buffer, 65536, 12, false, IntPtr.Zero, restart); restart = false;
                    if (status == unchecked((int)0x80000006)) { if (io.Information.ToUInt64() != 0) throw new InvalidDataException(); break; }
                    if (status != 0 || io.Information.ToUInt64() < 12 || io.Information.ToUInt64() > 65536) throw new InvalidDataException();
                    int used = checked((int)io.Information.ToUInt64()), offset = 0;
                    while (true)
                    {
                        if (offset + 12 > used) throw new InvalidDataException(); int next = Marshal.ReadInt32(buffer, offset); int byteLength = Marshal.ReadInt32(buffer, offset + 8);
                        if (byteLength < 0 || (byteLength & 1) != 0 || offset + 12 + byteLength > used) throw new InvalidDataException();
                        string name = Marshal.PtrToStringUni(IntPtr.Add(buffer, offset + 12), byteLength / 2); if (name != "." && name != "..") { if (names.Contains(name) || names.Count >= 32) throw new InvalidDataException(); names.Add(name); }
                        if (next == 0) break; if ((next & 3) != 0 || next < 12 || offset + next >= used) throw new InvalidDataException(); offset += next;
                    }
                }
                string[] result = names.ToArray(); Array.Sort(result, StringComparer.Ordinal); return result;
            }
            finally { Marshal.FreeHGlobal(buffer); }
        }

        internal static void Rename(SafeFileHandle handle, SafeFileHandle targetParent, string targetParentPath, string leaf)
        {
#if EAIRA_PACKAGE_TEST_SEAMS
            if (PackageTestFileSystem.Active) { PackageTestFileSystem.Rename(handle, targetParent, targetParentPath, leaf); return; }
#endif
            byte[] identity = GetIdentity(handle);
            byte[] name = Encoding.Unicode.GetBytes(leaf); int length = 20 + name.Length; IntPtr buffer = Marshal.AllocHGlobal(length);
            try
            {
                for (int i = 0; i < length; i++) Marshal.WriteByte(buffer, i, 0); Marshal.WriteInt64(buffer, 8, targetParent.DangerousGetHandle().ToInt64()); Marshal.WriteInt32(buffer, 16, name.Length); Marshal.Copy(name, 0, IntPtr.Add(buffer, 20), name.Length);
                bool renamed = false; for (int attempt = 0; attempt < 100; attempt++) { IoStatusBlock io; int status = NtSetInformationFile(handle, out io, buffer, checked((uint)length), 10); if (status == 0) { renamed = true; break; } if (status != unchecked((int)0xC0000022) && status != unchecked((int)0xC0000043)) throw new InvalidDataException(); Validate(handle, Path.Combine(targetParentPath, "package.building"), true); if (!Equal(identity, GetIdentity(handle))) throw new InvalidDataException(); System.Threading.Thread.Sleep(50); } if (!renamed) throw new InvalidDataException();
            }
            finally { Marshal.FreeHGlobal(buffer); }
            Validate(handle, Path.Combine(targetParentPath, leaf), true);
            if (!Equal(identity, GetIdentity(handle))) throw new InvalidDataException();
        }

        internal static bool Disposition(SafeFileHandle handle, byte[] expectedIdentity)
        {
#if EAIRA_PACKAGE_TEST_SEAMS
            if (PackageTestFileSystem.Active) return PackageTestFileSystem.Disposition(handle, expectedIdentity);
#endif
            IntPtr buffer = Marshal.AllocHGlobal(1); try { Marshal.WriteByte(buffer, 0, 1); for (int attempt = 0; attempt < 100; attempt++) { if (!Equal(expectedIdentity, GetIdentity(handle))) return false; IoStatusBlock io; int status = NtSetInformationFile(handle, out io, buffer, 1, 13); if (status == 0 && io.Information.ToUInt64() == 0) return Equal(expectedIdentity, GetIdentity(handle)); if (status != unchecked((int)0xC0000022) && status != unchecked((int)0xC0000043)) return false; System.Threading.Thread.Sleep(50); } return false; } finally { Marshal.FreeHGlobal(buffer); }
        }

        internal static bool MissingDirectory(SafeFileHandle parent, string leaf)
        {
#if EAIRA_PACKAGE_TEST_SEAMS
            if (PackageTestFileSystem.Active) return PackageTestFileSystem.Missing(parent, leaf);
#endif
            IntPtr text = Marshal.StringToHGlobalUni(leaf), unicode = IntPtr.Zero;
            try
            {
                UnicodeString name = new UnicodeString { Length = checked((ushort)(leaf.Length * 2)), MaximumLength = checked((ushort)(leaf.Length * 2)), Buffer = text };
                unicode = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(UnicodeString))); Marshal.StructureToPtr(name, unicode, false);
                ObjectAttributes attributes = new ObjectAttributes { Length = Marshal.SizeOf(typeof(ObjectAttributes)), RootDirectory = parent.DangerousGetHandle(), ObjectName = unicode, Attributes = 0x40 };
                SafeFileHandle handle; IoStatusBlock io; int status = NtCreateFile(out handle, ReadAttributes | Synchronize, ref attributes, out io, IntPtr.Zero, 0, ShareRead | ShareWrite, FileOpen, Directory | SyncNonAlert | OpenReparse, IntPtr.Zero, 0);
                if (status == unchecked((int)0xC0000034) || status == unchecked((int)0xC000003A)) return true;
                if (handle != null) handle.Dispose();
                if (status == 0) return false;
                throw new InvalidDataException();
            }
            finally { if (unicode != IntPtr.Zero) Marshal.FreeHGlobal(unicode); Marshal.FreeHGlobal(text); }
        }

        private static void Validate(SafeFileHandle handle, string expectedPath, bool directory)
        {
            if (handle == null || handle.IsInvalid) throw new InvalidDataException(); AttributeTagInfo tag; if (!GetFileInformationByHandleEx(handle, 9, out tag, 8) || !AllowedAttributes(tag.Attributes, tag.ReparseTag, false)) throw new InvalidDataException();
            bool isDirectory = (tag.Attributes & 0x10) != 0; if (isDirectory != directory) throw new InvalidDataException(); ByHandleInfo info; if (!GetFileInformationByHandle(handle, out info) || (!directory && info.Links != 1)) throw new InvalidDataException();
            GetIdentity(handle);
            var final = new StringBuilder(32768); uint length = GetFinalPathNameByHandleW(handle, final, 32768, 0); if (length < 4 || length >= 32768 || !String.Equals(final.ToString(), @"\\?\" + expectedPath, StringComparison.OrdinalIgnoreCase)) throw new InvalidDataException();
        }

        internal static byte[] GetIdentity(SafeFileHandle handle)
        {
#if EAIRA_PACKAGE_TEST_SEAMS
            if (PackageTestFileSystem.Active) return PackageTestFileSystem.Identity(handle);
#endif
            IntPtr buffer = Marshal.AllocHGlobal(24);
            try { for (int i = 0; i < 24; i++) Marshal.WriteByte(buffer, i, 0); if (!GetFileIdInformation(handle, 18, buffer, 24)) throw new InvalidDataException(); byte[] result = new byte[24]; Marshal.Copy(buffer, result, 0, 24); return result; }
            finally { Marshal.FreeHGlobal(buffer); }
        }

        internal static bool EqualIdentity(byte[] a, byte[] b) { return Equal(a, b); }

        internal static bool AllowedAttributes(uint attributes, uint tag, bool allowCloud)
        {
            if ((attributes & (0x1000U | 0x40000U | 0x400000U)) != 0) return false;
            if ((attributes & 0x400U) == 0) return tag == 0;
            return allowCloud && (attributes & 0x10U) == 0 && (tag == 0x9000E01AU || tag == 0x9000601AU);
        }

        private static bool Equal(byte[] a, byte[] b) { if (a.Length != b.Length) return false; for (int i = 0; i < a.Length; i++) if (a[i] != b[i]) return false; return true; }
    }

    internal sealed class PayloadRow
    {
        internal readonly string File;
        internal readonly long Bytes;
        internal readonly string Sha256;

        internal PayloadRow(string file, long bytes, string sha256)
        {
            File = file;
            Bytes = bytes;
            Sha256 = sha256;
        }
    }

    internal static class UnsignedCustomerPackage
    {
        private sealed class OwnedNode
        {
            internal SafeFileHandle Handle;
            internal readonly string Key, Leaf, Path;
            internal readonly bool Directory;
            internal readonly byte[] Identity;
            internal OwnedNode(SafeFileHandle handle, string key, string leaf, string path, bool directory)
            { Handle = handle; Key = key; Leaf = leaf; Path = path; Directory = directory; Identity = NativePackageFileSystem.GetIdentity(handle); }
        }

        private static void FaultBoundary(string action, bool after)
        {
#if EAIRA_PACKAGE_TEST_SEAMS
            PackageFaultRuntime.Hit(action, after);
#endif
        }

        internal static string DiagnosticStage = "NONE";
        [StructLayout(LayoutKind.Sequential)]
        private struct FileAttributeTagInfo { internal uint FileAttributes; internal uint ReparseTag; }
        [DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool GetFileInformationByHandleEx(SafeFileHandle handle, int informationClass, out FileAttributeTagInfo information, uint size);
        internal const string ProfileSha256 = "CDDF0BA541888222681DBA5BE9C60F92648C25C8D8ADF92CF6C20E57C62B4C67";
        internal const string SourceManifestSha256 = "4B9C72AC8A8134F4596CBA024F8A4C6EC21766F85084CB8174EBD77A33A04D85";
        internal const string ProductCommit = "872e9b7916c24a09eb52cee8a894d69c0221295d";
        internal const string ReleaseVersion = "5.5.0-readiness.1";
        internal const string Classification = "UNSIGNED_READINESS_ONLY_NOT_INSTALLABLE";
        internal const string Authority = "PACKAGE_NOT_RELEASE_AUTHORITY";
        internal const string SourceRoot = @"C:\Temp\EAIRA_M5S4_SEALED_FINAL_003\unsigned-release";
        internal const string ProfilePath = @"C:\Users\User\OneDrive\文件\EAIRA-Enterprise-AI\apps\agent-services\release\unsigned-customer-package-profile.json";
        internal const string ManifestName = "EAIRA_UNSIGNED_CUSTOMER_PACKAGE_MANIFEST_V1.json";
        internal const string ReadmeName = "README.txt";
        internal const string ReadmeSha256 = "4F61B0E332411DE31EB12AE85E9737706C505428542453D6AA861C2341EF47FF";
        internal const string EmptyGoldenSha256 = "E37536C1237A92A57BF09C756C4CBD4B6B7D0C39086323E70014BB1DEAEB5288";
        internal const string OneGoldenSha256 = "81861F03E883AF0542BEA8299CAED6BEF430232494D24F17C43F8C92B6933522";
        internal const string NineGoldenSha256 = "DD51108C50DD4C1069695593DBEFF39C12927148E7DDBFEE98939CFD16B19DAB";

        internal static readonly byte[] ReadmeBytes = Encoding.ASCII.GetBytes(
            "EAIRA unsigned customer package readiness bundle.\n" +
            "UNSIGNED: no code-signing signature is present.\n" +
            "NON-INSTALLABLE: this directory contains no installer.\n" +
            "NON-PRODUCTION: do not deploy or activate it.\n" +
            "No registration or Windows service activation is performed.\n" +
            "No updater, rollback executor, credential, telemetry, or network access is included.\n" +
            "Replace this bundle with a separately verified signed release before distribution.\n" +
            "Authority: PACKAGE_NOT_RELEASE_AUTHORITY.\n");

        internal static readonly PayloadRow[] Payloads = new[]
        {
            new PayloadRow("EAIRA.Planning.Service.exe", 29184, "2767AD2DE938083F575C705BCC835D54E4419FC49D53E2A62AFD7CB04FC2708E"),
            new PayloadRow("EAIRA.Operations.Service.exe", 29184, "7251BDEB23CDAC25A7BECE110D4A6101BD89C3112733358E3171A206AAD3C983"),
            new PayloadRow("EAIRA.Verification.Service.exe", 29184, "B0BD6714FC7048CBD46998433CADEB9913E2C0EE6822EE7AE2C0EE7B5E5892FC"),
            new PayloadRow("EAIRA.Guard.Service.exe", 28672, "D32C265F72222C52383399908273B1E1F574C84DEE32BF6FBC5776F4AE878D46"),
            new PayloadRow("EAIRA.Audit.Service.exe", 28672, "01EAA5FC43A4B1D49D915CE1459C8661F04A6CAA6440BC85FF44BFF577D9AE10"),
            new PayloadRow("EAIRA.AgentTask.Cli.exe", 72192, "04EDEDDA8755F4B5FC76E7DB473C37CB49F67A53DA28A9AA83C167A521E9C752"),
            new PayloadRow("EAIRA.ProjectKnowledge.Cli.exe", 22016, "08ABD5E90A0AAAB219639A7724A6B9C8EDE532199B23E84D459BE9DD40FD0F9A"),
            new PayloadRow("EAIRA.ProjectQa.Cli.exe", 97280, "C4C786CABE71CFB0034D6B2F58937906A5D2649E4E1AE81BA2F339EE762C3288"),
            new PayloadRow("EAIRA.LocalOperator.Cli.exe", 139264, "85F718BBCCDA14972B864F045F00D408BFD434C748141F50C692DD89F3481BA4")
        };

        internal static int Run(string[] args, TextWriter output)
        {
            if (args == null || args.Length != 3 ||
                !(String.Equals(args[0], "Build", StringComparison.Ordinal) || String.Equals(args[0], "Verify", StringComparison.Ordinal)) ||
                !String.Equals(args[1], "--package-evidence-root", StringComparison.Ordinal) ||
                String.IsNullOrEmpty(args[2]))
            {
                output.Write(InvalidResult());
                return 64;
            }

            string mode = args[0];
            bool mutated = false;
            bool cleanupComplete = false;
            try
            {
                DiagnosticStage = "VALIDATE_ROOT";
                string evidenceRoot = ValidateEvidenceRoot(args[2], mode);
                DiagnosticStage = "VALIDATE_PROFILE";
                ValidateProfile();
                DiagnosticStage = "VALIDATE_SOURCE";
                ValidateSourceInventory();
                string contentSha;
                if (String.Equals(mode, "Build", StringComparison.Ordinal))
                {
                    contentSha = Build(evidenceRoot, ref mutated, ref cleanupComplete);
                }
                else
                {
                    contentSha = Verify(evidenceRoot);
                }

                output.Write(SuccessResult(mode, contentSha));
                return 0;
            }
            catch
            {
                if (mutated)
                {
                    output.Write(FailureResult("Build", true, cleanupComplete));
                }
                else
                {
                    output.Write(FailureResult(mode, false, false));
                }
                return 1;
            }
        }

        internal static string ValidateEvidenceRoot(string candidate, string mode)
        {
            if (candidate.IndexOf('\0') >= 0 || candidate.IndexOf('\r') >= 0 || candidate.IndexOf('\n') >= 0)
                throw new InvalidDataException();
            string full = Path.GetFullPath(candidate);
            if (!String.Equals(candidate, full, StringComparison.Ordinal)) throw new InvalidDataException();
            string parent = Path.GetDirectoryName(full);
            if (!String.Equals(parent, @"C:\Temp", StringComparison.OrdinalIgnoreCase)) throw new InvalidDataException();
            string leaf = Path.GetFileName(full);
            string prefix = mode == "Build" ? "EAIRA_M5S5_PACKAGE_" : "EAIRA_M5S5_PACKAGE_";
            if (!leaf.StartsWith(prefix, StringComparison.Ordinal) || leaf.Length != prefix.Length + 14) throw new InvalidDataException();
            string side = leaf.Substring(prefix.Length, 2);
            if (!(side == "A_" || side == "B_")) throw new InvalidDataException();
            string suffix = leaf.Substring(prefix.Length + 2);
            if (suffix.Length != 12) throw new InvalidDataException();
            for (int i = 0; i < suffix.Length; i++)
                if (!(suffix[i] >= 'A' && suffix[i] <= 'Z') && !(suffix[i] >= '0' && suffix[i] <= '9')) throw new InvalidDataException();
            return full;
        }

        internal static void ValidateProfile()
        {
            byte[] bytes; using (SafeFileHandle profile = NativePackageFileSystem.OpenAbsoluteProfile(ProfilePath)) bytes = NativePackageFileSystem.ReadAll(profile, 65536);
            ValidateProfileBytes(bytes);
        }

        internal static void ValidateProfileBytes(byte[] bytes)
        {
            if (bytes == null || !String.Equals(Sha256(bytes), ProfileSha256, StringComparison.Ordinal)) throw new InvalidDataException();
            if (bytes.Length == 0 || bytes[0] == 0xEF || bytes[bytes.Length - 1] != 0x0A) throw new InvalidDataException();
            for (int i = 0; i < bytes.Length; i++) if (bytes[i] == 0x0D || bytes[i] > 0x7F) throw new InvalidDataException();
            if (!String.Equals(Encoding.ASCII.GetString(bytes), BuildExpectedProfile(), StringComparison.Ordinal)) throw new InvalidDataException();
        }

        internal static void ValidateSourceInventory()
        {
            using (SafeFileHandle root = NativePackageFileSystem.OpenAbsoluteDirectory(SourceRoot))
            {
                string[] actual = NativePackageFileSystem.Enumerate(root); string[] expected = PayloadNames();
                if (!EqualNames(actual, expected)) throw new InvalidDataException();
                foreach (PayloadRow row in Payloads) using (SafeFileHandle file = NativePackageFileSystem.OpenSourceFile(root, SourceRoot, row.File)) ValidateFile(file, row);
            }
        }

        internal static string Build(string evidenceRoot, ref bool mutated, ref bool cleanupComplete)
        {
            var ledger = new List<OwnedNode>();
            var inputs = new List<SafeFileHandle>();
            bool childCloseStarted = false;
            using (SafeFileHandle temp = NativePackageFileSystem.OpenAbsoluteDirectory(@"C:\Temp"))
            using (SafeFileHandle source = NativePackageFileSystem.OpenAbsoluteDirectory(SourceRoot))
            {
                try
                {
                    if (!EqualNames(NativePackageFileSystem.Enumerate(source), PayloadNames())) throw new InvalidDataException();
                    var payloadBytes = new List<byte[]>();
                    foreach (PayloadRow row in Payloads)
                    {
                        SafeFileHandle input = NativePackageFileSystem.OpenSourceFile(source, SourceRoot, row.File); inputs.Add(input);
                        byte[] bytes = NativePackageFileSystem.ReadAll(input, checked((int)row.Bytes));
                        if (bytes.Length != row.Bytes || Sha256(bytes) != row.Sha256) throw new InvalidDataException();
                        payloadBytes.Add(bytes);
                    }
                    FaultBoundary("CREATE_EVIDENCE_ROOT", false);
                    mutated = true;
                    SafeFileHandle root = NativePackageFileSystem.CreateDirectory(temp, @"C:\Temp", Path.GetFileName(evidenceRoot), true);
                    ledger.Add(new OwnedNode(root, "ROOT", Path.GetFileName(evidenceRoot), evidenceRoot, true));
                    FaultBoundary("CREATE_EVIDENCE_ROOT", true);
                    FaultBoundary("CREATE_PACKAGE_BUILDING", false);
                    string buildingPath = Path.Combine(evidenceRoot, "package.building");
                    SafeFileHandle building = NativePackageFileSystem.CreateDirectory(root, evidenceRoot, "package.building", true);
                    ledger.Add(new OwnedNode(building, "BUILDING", "package.building", buildingPath, true));
                    FaultBoundary("CREATE_PACKAGE_BUILDING", true);
                    FaultBoundary("CREATE_PAYLOAD_DIRECTORY", false);
                    string payloadPath = Path.Combine(buildingPath, "payload");
                    SafeFileHandle payload = NativePackageFileSystem.CreateDirectory(building, buildingPath, "payload", true);
                    ledger.Add(new OwnedNode(payload, "PAYLOAD", "payload", payloadPath, true));
                    FaultBoundary("CREATE_PAYLOAD_DIRECTORY", true);
                    var outputs = new List<SafeFileHandle>();
                    for (int i = 0; i < Payloads.Length; i++)
                    {
                        string action = "CREATE_PAYLOAD_" + (i + 1).ToString("D2", CultureInfo.InvariantCulture);
                        FaultBoundary(action, false);
                        SafeFileHandle output = NativePackageFileSystem.CreateFile(payload, payloadPath, Payloads[i].File, true);
                        ledger.Add(new OwnedNode(output, "PAYLOAD/" + Payloads[i].File, Payloads[i].File, Path.Combine(payloadPath, Payloads[i].File), false)); outputs.Add(output);
                        FaultBoundary(action, true);
                    }
                    for (int i = 0; i < Payloads.Length; i++)
                    {
                        string action = "WRITE_PAYLOAD_" + (i + 1).ToString("D2", CultureInfo.InvariantCulture);
                        FaultBoundary(action, false); NativePackageFileSystem.WriteBytes(outputs[i], payloadBytes[i]); FaultBoundary(action, true);
                    }
                    for (int i = 0; i < Payloads.Length; i++)
                    {
                        string action = "FLUSH_PAYLOAD_" + (i + 1).ToString("D2", CultureInfo.InvariantCulture);
                        FaultBoundary(action, false); NativePackageFileSystem.FlushAndVerify(outputs[i], payloadBytes[i]); FaultBoundary(action, true);
                        if (!EqualBytes(payloadBytes[i], NativePackageFileSystem.ReadAll(inputs[i], payloadBytes[i].Length))) throw new InvalidDataException();
                    }
                    FaultBoundary("CREATE_README", false);
                    SafeFileHandle readme = NativePackageFileSystem.CreateFile(building, buildingPath, ReadmeName, true);
                    ledger.Add(new OwnedNode(readme, "README", ReadmeName, Path.Combine(buildingPath, ReadmeName), false)); FaultBoundary("CREATE_README", true);
                    FaultBoundary("WRITE_README", false); NativePackageFileSystem.WriteBytes(readme, ReadmeBytes); FaultBoundary("WRITE_README", true);
                    FaultBoundary("FLUSH_README", false); NativePackageFileSystem.FlushAndVerify(readme, ReadmeBytes); FaultBoundary("FLUSH_README", true);
                    string contentSha = ComputeContentDigest(Payloads); if (contentSha != NineGoldenSha256) throw new InvalidDataException();
                    byte[] manifestBytes = BuildManifest(contentSha);
                    FaultBoundary("CREATE_MANIFEST", false);
                    SafeFileHandle manifest = NativePackageFileSystem.CreateFile(building, buildingPath, ManifestName, true);
                    ledger.Add(new OwnedNode(manifest, "MANIFEST", ManifestName, Path.Combine(buildingPath, ManifestName), false)); FaultBoundary("CREATE_MANIFEST", true);
                    FaultBoundary("WRITE_MANIFEST", false); NativePackageFileSystem.WriteBytes(manifest, manifestBytes); FaultBoundary("WRITE_MANIFEST", true);
                    FaultBoundary("FLUSH_MANIFEST", false); NativePackageFileSystem.FlushAndVerify(manifest, manifestBytes); FaultBoundary("FLUSH_MANIFEST", true);

                    // NTFS parent rename requires descendant handles to be closed. Once this
                    // boundary is crossed, failure cleanup cannot reacquire deletion authority.
                    childCloseStarted = true;
                    for (int i = ledger.Count - 1; i >= 2; i--) if (!ledger[i].Handle.CloseChecked()) throw new InvalidDataException();
                    FaultBoundary("RENAME_PACKAGE", false);
                    NativePackageFileSystem.Rename(building, root, evidenceRoot, "package");
                    FaultBoundary("RENAME_PACKAGE", true);
                    FaultBoundary("VERIFY_PACKAGE", false);
                    string verified = VerifyHeld(root, building, evidenceRoot);
                    if (verified != contentSha) throw new InvalidDataException();
                    FaultBoundary("VERIFY_PACKAGE", true);
                    DiagnosticStage = "PASS"; return contentSha;
                }
                catch
                {
                    cleanupComplete = !mutated;
                    if (mutated && !childCloseStarted)
                    {
                        cleanupComplete = ledger.Count > 0;
                        for (int i = ledger.Count - 1; i >= 0; i--)
                        {
                            OwnedNode node = ledger[i];
                            try { if (!NativePackageFileSystem.Disposition(node.Handle, node.Identity)) cleanupComplete = false; }
                            catch { cleanupComplete = false; }
                            if (!node.Handle.CloseChecked()) cleanupComplete = false;
                        }
                        try { if (!NativePackageFileSystem.MissingDirectory(temp, Path.GetFileName(evidenceRoot))) cleanupComplete = false; }
                        catch { cleanupComplete = false; }
                    }
                    // After any descendant close, retain evidence and report INCOMPLETE/POSSIBLE.
                    // No child is ever reopened, recursively traversed, or deleted by pathname.
                    throw;
                }
                finally
                {
                    for (int i = ledger.Count - 1; i >= 0; i--) if (!ledger[i].Handle.IsClosed) ledger[i].Handle.Dispose();
                    for (int i = inputs.Count - 1; i >= 0; i--) inputs[i].Dispose();
                }
            }
        }

        internal static string Verify(string evidenceRoot)
        {
            DiagnosticStage = "VERIFY_OPEN_ROOT";
            using (SafeFileHandle root = NativePackageFileSystem.OpenAbsoluteDirectory(evidenceRoot))
            using (SafeFileHandle package = NativePackageFileSystem.OpenDirectory(root, evidenceRoot, "package"))
            {
                return VerifyHeld(root, package, evidenceRoot);
            }
        }

        private static string VerifyHeld(SafeFileHandle root, SafeFileHandle package, string evidenceRoot)
        {
            string packagePath = Path.Combine(evidenceRoot, "package");
            using (SafeFileHandle payload = NativePackageFileSystem.OpenDirectory(package, packagePath, "payload"))
            {
                DiagnosticStage = "VERIFY_ENUMERATE"; if (!EqualNames(NativePackageFileSystem.Enumerate(root), new[] { "package" })) throw new InvalidDataException();
                string[] packageExpected = new[] { ManifestName, ReadmeName, "payload" }; Array.Sort(packageExpected, StringComparer.Ordinal); if (!EqualNames(NativePackageFileSystem.Enumerate(package), packageExpected)) throw new InvalidDataException();
                if (!EqualNames(NativePackageFileSystem.Enumerate(payload), PayloadNames())) throw new InvalidDataException(); string payloadPath = Path.Combine(packagePath, "payload");
                foreach (PayloadRow row in Payloads) using (SafeFileHandle file = NativePackageFileSystem.OpenFile(payload, payloadPath, row.File)) ValidateFile(file, row);
                byte[] readme; using (SafeFileHandle f = NativePackageFileSystem.OpenFile(package, packagePath, ReadmeName)) readme = NativePackageFileSystem.ReadAll(f, 4096); if (!EqualBytes(readme, ReadmeBytes)) throw new InvalidDataException();
                string contentSha = ComputeContentDigest(Payloads); byte[] actualManifest; using (SafeFileHandle f = NativePackageFileSystem.OpenFile(package, packagePath, ManifestName)) actualManifest = NativePackageFileSystem.ReadAll(f, 65536); if (!EqualBytes(actualManifest, BuildManifest(contentSha))) throw new InvalidDataException(); DiagnosticStage = "PASS"; return contentSha;
            }
        }

        private static string[] PayloadNames()
        {
            string[] names = new string[Payloads.Length];
            for (int i = 0; i < Payloads.Length; i++) names[i] = Payloads[i].File;
            Array.Sort(names, StringComparer.Ordinal);
            return names;
        }

        private static bool EqualNames(string[] left, string[] right)
        {
            if (left.Length != right.Length) return false;
            for (int i = 0; i < left.Length; i++) if (!String.Equals(left[i], right[i], StringComparison.Ordinal)) return false;
            return true;
        }

        private static bool EqualBytes(byte[] left, byte[] right)
        {
            if (left.Length != right.Length) return false;
            for (int i = 0; i < left.Length; i++) if (left[i] != right[i]) return false;
            return true;
        }

        internal static byte[] BuildManifest(string contentSha)
        {
            var b = new StringBuilder(4096);
            b.Append("{\"schema\":\"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_MANIFEST_V1\",\"releaseVersion\":\"").Append(ReleaseVersion)
             .Append("\",\"classification\":\"").Append(Classification)
             .Append("\",\"authority\":\"").Append(Authority)
             .Append("\",\"productCommit\":\"").Append(ProductCommit)
             .Append("\",\"sourceManifestSha256\":\"").Append(SourceManifestSha256)
             .Append("\",\"profileSha256\":\"").Append(ProfileSha256)
             .Append("\",\"network\":\"NONE\",\"writes\":\"OUTPUT_ROOT_ONLY\",\"signing\":\"NONE\",\"installation\":\"NONE\",\"payloadCount\":9,\"payloads\":[");
            for (int i = 0; i < Payloads.Length; i++)
            {
                if (i != 0) b.Append(',');
                PayloadRow row = Payloads[i];
                b.Append("{\"file\":\"").Append(row.File).Append("\",\"bytes\":")
                 .Append(row.Bytes.ToString(CultureInfo.InvariantCulture)).Append(",\"sha256\":\"")
                 .Append(row.Sha256).Append("\"}");
            }
            b.Append("],\"readmeSha256\":\"").Append(ReadmeSha256)
             .Append("\",\"packageContentSha256\":\"").Append(contentSha).Append("\"}\n");
            return Encoding.ASCII.GetBytes(b.ToString());
        }

        internal static string BuildExpectedProfile()
        {
            var b = new StringBuilder(2048);
            b.Append("{\"schema\":\"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_PROFILE_V1\",\"releaseVersion\":\"").Append(ReleaseVersion)
             .Append("\",\"classification\":\"").Append(Classification).Append("\",\"authority\":\"").Append(Authority)
             .Append("\",\"productCommit\":\"").Append(ProductCommit).Append("\",\"sourceManifestSha256\":\"").Append(SourceManifestSha256)
             .Append("\",\"network\":\"NONE\",\"writes\":\"OUTPUT_ROOT_ONLY\",\"signing\":\"NONE\",\"installation\":\"NONE\",\"payloads\":[");
            for (int i = 0; i < Payloads.Length; i++)
            {
                if (i != 0) b.Append(','); PayloadRow row = Payloads[i];
                b.Append("{\"file\":\"").Append(row.File).Append("\",\"bytes\":").Append(row.Bytes.ToString(CultureInfo.InvariantCulture))
                 .Append(",\"sha256\":\"").Append(row.Sha256).Append("\"}");
            }
            return b.Append("]}\n").ToString();
        }

        internal static string ComputeContentDigest(IEnumerable<PayloadRow> rows)
        {
            using (var stream = new MemoryStream())
            {
                byte[] domain = Encoding.ASCII.GetBytes("EAIRA_UNSIGNED_CUSTOMER_PACKAGE_CONTENT_V1");
                stream.Write(domain, 0, domain.Length); stream.WriteByte(0);
                AddField(stream, ReleaseVersion); AddField(stream, ProductCommit); AddField(stream, SourceManifestSha256);
                AddField(stream, ProfileSha256); AddField(stream, ReadmeSha256);
                foreach (PayloadRow row in rows)
                {
                    AddField(stream, row.File); AddField(stream, row.Bytes.ToString(CultureInfo.InvariantCulture)); AddField(stream, row.Sha256);
                }
                return Sha256(stream.ToArray());
            }
        }

        private static void AddField(Stream stream, string value)
        {
            byte[] bytes = Encoding.UTF8.GetBytes(value);
            byte[] length = BitConverter.GetBytes((uint)bytes.Length);
            stream.Write(length, 0, length.Length); stream.Write(bytes, 0, bytes.Length);
        }

        private static void ValidateFile(SafeFileHandle handle, PayloadRow row)
        {
            byte[] bytes = NativePackageFileSystem.ReadAll(handle, checked((int)row.Bytes)); if (bytes.Length != row.Bytes || !String.Equals(Sha256(bytes), row.Sha256, StringComparison.Ordinal)) throw new InvalidDataException();
        }

        internal static string Sha256(byte[] bytes)
        {
            using (var sha = SHA256.Create()) return ToHex(sha.ComputeHash(bytes));
        }

        private static string ToHex(byte[] bytes)
        {
            var b = new StringBuilder(bytes.Length * 2);
            foreach (byte value in bytes) b.Append(value.ToString("X2", CultureInfo.InvariantCulture));
            return b.ToString();
        }

        internal static string SuccessResult(string mode, string contentSha)
        {
            string writes = mode == "Build" ? "OUTPUT_ROOT_ONLY" : "NONE";
            return "{\"schema\":\"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_RESULT_V1\",\"status\":\"PASS\",\"mode\":\"" + mode +
                "\",\"classification\":\"" + Classification + "\",\"releaseVersion\":\"" + ReleaseVersion +
                "\",\"payloadCount\":9,\"packageContentSha256\":\"" + contentSha + "\",\"network\":\"NONE\",\"writes\":\"" + writes +
                "\",\"cleanup\":\"NOT_REQUIRED\",\"persistentOutput\":\"PACKAGE\",\"signing\":\"NONE\",\"installation\":\"NONE\",\"authority\":\"" + Authority + "\"}\n";
        }

        internal static string InvalidResult()
        {
            return "{\"schema\":\"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_RESULT_V1\",\"status\":\"INVALID_REQUEST\",\"mode\":\"NONE\",\"network\":\"NONE\",\"writes\":\"NONE\",\"cleanup\":\"NOT_REQUIRED\",\"persistentOutput\":\"NONE\",\"signing\":\"NONE\",\"installation\":\"NONE\",\"authority\":\"" + Authority + "\"}\n";
        }

        internal static string FailureResult(string mode, bool writes, bool cleanupComplete)
        {
            if (!writes) return "{\"schema\":\"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_RESULT_V1\",\"status\":\"FAIL\",\"mode\":\"" + mode + "\",\"network\":\"NONE\",\"writes\":\"NONE\",\"cleanup\":\"NOT_REQUIRED\",\"persistentOutput\":\"NONE\",\"signing\":\"NONE\",\"installation\":\"NONE\",\"authority\":\"" + Authority + "\"}\n";
            return "{\"schema\":\"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_RESULT_V1\",\"status\":\"FAIL\",\"mode\":\"Build\",\"network\":\"NONE\",\"writes\":\"OUTPUT_ROOT_ONLY\",\"cleanup\":\"" + (cleanupComplete ? "COMPLETE" : "INCOMPLETE") + "\",\"persistentOutput\":\"" + (cleanupComplete ? "NONE" : "POSSIBLE") + "\",\"signing\":\"NONE\",\"installation\":\"NONE\",\"authority\":\"" + Authority + "\"}\n";
        }
    }

#if EAIRA_PACKAGE_TEST_SEAMS
    internal sealed class InjectedPackageFault : IOException { }

    internal static class PackageFaultRuntime
    {
        internal static string Fault;
        internal static bool After, Injected, SuppressThrow;
        internal static int Calls;
        internal static Action<string, bool> Probe;
        internal static void Hit(string action, bool after)
        {
            int ordinal = Calls / 2;
            if (ordinal >= UnsignedCustomerPackageTestSeam.Actions.Length ||
                action != UnsignedCustomerPackageTestSeam.Actions[ordinal] || after != ((Calls & 1) == 1)) throw new InvalidDataException();
            Calls++;
            if (action == Fault && after == After)
            {
                Injected = true;
                if (Probe != null) Probe(action, after);
                if (!SuppressThrow) throw new InjectedPackageFault();
            }
        }
        internal static void Reset(string fault, bool after)
        { Fault = fault; After = after; Injected = false; SuppressThrow = false; Calls = 0; Probe = null; }
    }

    // This backend replaces native I/O only. Build, Verify, canonical serialization,
    // fault boundaries, ledger cleanup and result-channel selection are production code.
    internal static class PackageTestFileSystem
    {
        private sealed class Node
        {
            internal long Id;
            internal string Path;
            internal bool Directory, DeletePending, Foreign;
            internal byte[] Bytes = new byte[0];
        }
        private sealed class Lease
        {
            internal Node Node;
            internal bool Write, Delete;
        }
        private static readonly Dictionary<string, Node> Nodes = new Dictionary<string, Node>(StringComparer.OrdinalIgnoreCase);
        private static readonly Dictionary<IntPtr, Lease> Handles = new Dictionary<IntPtr, Lease>();
        private static readonly Dictionary<string, byte[]> SourceBytes = new Dictionary<string, byte[]>(StringComparer.Ordinal);
        private static long serial = 1000000;
        internal static bool Active;
        internal static int Writes, Dispositions, ForeignDeleted, CloseFailures;
        internal static void LoadSource()
        {
            if (SourceBytes.Count != 0) return;
            using (SafeFileHandle root = NativePackageFileSystem.OpenAbsoluteDirectory(UnsignedCustomerPackage.SourceRoot))
                foreach (PayloadRow row in UnsignedCustomerPackage.Payloads)
                    using (SafeFileHandle h = NativePackageFileSystem.OpenSourceFile(root, UnsignedCustomerPackage.SourceRoot, row.File))
                    {
                        byte[] bytes = NativePackageFileSystem.ReadAll(h, checked((int)row.Bytes));
                        if (bytes.Length != row.Bytes || UnsignedCustomerPackage.Sha256(bytes) != row.Sha256) throw new InvalidDataException();
                        SourceBytes.Add(row.File, bytes);
                    }
        }
        internal static void Start()
        {
            LoadSource(); if (Handles.Count != 0) throw new InvalidDataException();
            Nodes.Clear(); Writes = 0; Dispositions = 0; ForeignDeleted = 0; CloseFailures = 0;
            Add(@"C:\Temp", true, new byte[0], false);
            Add(UnsignedCustomerPackage.SourceRoot, true, new byte[0], false);
            foreach (PayloadRow row in UnsignedCustomerPackage.Payloads) Add(Path.Combine(UnsignedCustomerPackage.SourceRoot, row.File), false, SourceBytes[row.File], false);
            Add(UnsignedCustomerPackage.ProfilePath, false, Encoding.ASCII.GetBytes(UnsignedCustomerPackage.BuildExpectedProfile()), false);
            Active = true;
        }
        internal static void Stop()
        {
            if (Handles.Count != 0) throw new InvalidDataException();
            Active = false; Nodes.Clear(); PackageFaultRuntime.Probe = null;
        }
        private static Node Add(string path, bool directory, byte[] bytes, bool foreign)
        {
            if (Nodes.ContainsKey(path)) throw new InvalidDataException();
            var n = new Node { Id = ++serial, Path = path, Directory = directory, Bytes = (byte[])bytes.Clone(), Foreign = foreign };
            Nodes.Add(path, n); return n;
        }
        private static Lease Get(SafeFileHandle h)
        { Lease lease; if (h == null || h.IsClosed || !Handles.TryGetValue(h.DangerousGetHandle(), out lease)) throw new InvalidDataException(); return lease; }
        private static SafeFileHandle LeaseNode(Node n, bool write, bool delete)
        {
            if (n.DeletePending) throw new InvalidDataException();
            var pointer = new IntPtr(++serial); Handles.Add(pointer, new Lease { Node = n, Write = write, Delete = delete }); return new SafeFileHandle(pointer);
        }
        internal static bool IsTestHandle(IntPtr h) { return Handles.ContainsKey(h); }
        internal static bool Close(IntPtr h)
        {
            Lease lease; if (!Handles.TryGetValue(h, out lease)) { CloseFailures++; return false; }
            Handles.Remove(h);
            if (lease.Node.DeletePending)
            {
                foreach (Lease other in Handles.Values) if (Object.ReferenceEquals(other.Node, lease.Node)) return true;
                if (lease.Node.Foreign) ForeignDeleted++;
                Nodes.Remove(lease.Node.Path);
            }
            return true;
        }
        internal static SafeFileHandle Open(string path, bool directory)
        {
            Node n; if (!Nodes.TryGetValue(path, out n) || n.Directory != directory) throw new InvalidDataException();
            return LeaseNode(n, false, false);
        }
        private static string Relative(SafeFileHandle parent, string parentPath, string leaf)
        {
            Lease p = Get(parent);
            if (!p.Node.Directory || p.Node.Path != parentPath || String.IsNullOrEmpty(leaf) || leaf.IndexOfAny(new[] { '\\', '/', ':' }) >= 0 || leaf == "." || leaf == "..") throw new InvalidDataException();
            return Path.Combine(parentPath, leaf);
        }
        internal static SafeFileHandle OpenRelative(SafeFileHandle parent, string parentPath, string leaf, bool directory)
        { return Open(Relative(parent, parentPath, leaf), directory); }
        internal static SafeFileHandle Create(SafeFileHandle parent, string parentPath, string leaf, bool directory, bool cleanup)
        {
            string path = Relative(parent, parentPath, leaf);
            Node n = Add(path, directory, new byte[0], false); Writes++; return LeaseNode(n, true, cleanup);
        }
        internal static byte[] Read(SafeFileHandle h, int maximum)
        { Node n = Get(h).Node; if (n.Directory || n.Bytes.Length > maximum) throw new InvalidDataException(); return (byte[])n.Bytes.Clone(); }
        internal static void Write(SafeFileHandle h, byte[] bytes)
        { Lease lease = Get(h); if (!lease.Write || lease.Node.Directory) throw new InvalidDataException(); lease.Node.Bytes = (byte[])bytes.Clone(); Writes++; }
        internal static string[] Enumerate(SafeFileHandle h)
        {
            Node parent = Get(h).Node; if (!parent.Directory) throw new InvalidDataException();
            var names = new List<string>(); foreach (Node n in Nodes.Values) if (Path.GetDirectoryName(n.Path) == parent.Path) names.Add(Path.GetFileName(n.Path));
            string[] result = names.ToArray(); Array.Sort(result, StringComparer.Ordinal); return result;
        }
        internal static byte[] Identity(SafeFileHandle h)
        { var b = new byte[24]; Array.Copy(BitConverter.GetBytes(Get(h).Node.Id), 0, b, 8, 8); return b; }
        internal static bool Disposition(SafeFileHandle h, byte[] identity)
        {
            Lease lease = Get(h); if (!lease.Delete || !NativePackageFileSystem.EqualIdentity(identity, Identity(h))) return false;
            if (lease.Node.Directory && Enumerate(h).Length != 0) return false;
            Dispositions++; lease.Node.DeletePending = true; return true;
        }
        internal static bool Missing(SafeFileHandle parent, string leaf)
        { return !Nodes.ContainsKey(Relative(parent, Get(parent).Node.Path, leaf)); }
        internal static void Rename(SafeFileHandle h, SafeFileHandle parent, string parentPath, string leaf)
        {
            Lease lease = Get(h); string target = Relative(parent, parentPath, leaf);
            if (!lease.Delete || Nodes.ContainsKey(target)) throw new InvalidDataException();
            foreach (Lease open in Handles.Values)
                if (open.Node.Path.StartsWith(lease.Node.Path + "\\", StringComparison.OrdinalIgnoreCase)) throw new InvalidDataException();
            string oldPath = lease.Node.Path; var affected = new List<Node>();
            foreach (Node n in Nodes.Values) if (n.Path == oldPath || n.Path.StartsWith(oldPath + "\\", StringComparison.OrdinalIgnoreCase)) affected.Add(n);
            foreach (Node n in affected) Nodes.Remove(n.Path);
            foreach (Node n in affected) { n.Path = target + n.Path.Substring(oldPath.Length); Nodes.Add(n.Path, n); }
            Writes++;
        }
        internal static bool Exists(string path) { return Nodes.ContainsKey(path); }
        internal static bool ForeignExists(string path) { Node n; return Nodes.TryGetValue(path, out n) && n.Foreign; }
        internal static void AddForeign(string path, bool directory) { Add(path, directory, new byte[] { 88 }, true); }
        internal static bool TryReplace(string path)
        {
            Node old; if (!Nodes.TryGetValue(path, out old)) return false;
            foreach (Lease h in Handles.Values) if (Object.ReferenceEquals(h.Node, old)) return false;
            Nodes.Remove(path); Add(path, old.Directory, new byte[] { 88 }, true); return true;
        }
        internal static bool CollisionRejected(string root)
        {
            using (SafeFileHandle p = NativePackageFileSystem.OpenAbsoluteDirectory(root))
            {
                try { using (SafeFileHandle unexpected = NativePackageFileSystem.CreateDirectory(p, root, "package.building", true)) { } return false; }
                catch (InvalidDataException) { return true; }
            }
        }
        internal static bool WrongDispositionRejected(string root)
        {
            foreach (Lease lease in Handles.Values)
            {
                if (!lease.Delete || !lease.Node.Path.StartsWith(root, StringComparison.Ordinal)) continue;
                foreach (KeyValuePair<IntPtr, Lease> item in Handles)
                    if (Object.ReferenceEquals(item.Value, lease))
                    {
                        var wrong = new byte[24]; int before = Dispositions;
                        using (var borrowed = new SafeFileHandle(item.Key, false))
                            return !NativePackageFileSystem.Disposition(borrowed, wrong) && Dispositions == before && !lease.Node.DeletePending;
                    }
            }
            return true;
        }
        internal static void MutateFile(string path, string mutation)
        {
            Node n = Nodes[path];
            if (mutation == "missing") Nodes.Remove(path);
            else if (mutation == "extra") Add(Path.Combine(Path.GetDirectoryName(path), "EXTRA"), false, new byte[] { 1 }, true);
            else if (mutation == "bom") { byte[] b = new byte[n.Bytes.Length + 3]; b[0] = 239; b[1] = 187; b[2] = 191; Array.Copy(n.Bytes, 0, b, 3, n.Bytes.Length); n.Bytes = b; }
            else if (mutation == "trailing") { byte[] b = new byte[n.Bytes.Length + 1]; Array.Copy(n.Bytes, b, n.Bytes.Length); b[b.Length - 1] = 88; n.Bytes = b; }
            else { n.Bytes = (byte[])n.Bytes.Clone(); n.Bytes[0] ^= 1; }
        }
    }

    internal sealed class PackageFaultObservation
    {
        internal bool MutationAttempted, CleanupComplete, PersistentPossible, LedgerOnly, PathFallback;
        internal int ExecutedActions, ExpectedActions;
    }

    internal static class UnsignedCustomerPackageTestSeam
    {
        internal static readonly string[] Actions = ("CREATE_EVIDENCE_ROOT|CREATE_PACKAGE_BUILDING|CREATE_PAYLOAD_DIRECTORY|CREATE_PAYLOAD_01|CREATE_PAYLOAD_02|CREATE_PAYLOAD_03|CREATE_PAYLOAD_04|CREATE_PAYLOAD_05|CREATE_PAYLOAD_06|CREATE_PAYLOAD_07|CREATE_PAYLOAD_08|CREATE_PAYLOAD_09|WRITE_PAYLOAD_01|WRITE_PAYLOAD_02|WRITE_PAYLOAD_03|WRITE_PAYLOAD_04|WRITE_PAYLOAD_05|WRITE_PAYLOAD_06|WRITE_PAYLOAD_07|WRITE_PAYLOAD_08|WRITE_PAYLOAD_09|FLUSH_PAYLOAD_01|FLUSH_PAYLOAD_02|FLUSH_PAYLOAD_03|FLUSH_PAYLOAD_04|FLUSH_PAYLOAD_05|FLUSH_PAYLOAD_06|FLUSH_PAYLOAD_07|FLUSH_PAYLOAD_08|FLUSH_PAYLOAD_09|CREATE_README|WRITE_README|FLUSH_README|CREATE_MANIFEST|WRITE_MANIFEST|FLUSH_MANIFEST|RENAME_PACKAGE|VERIFY_PACKAGE").Split('|');
        private const string Root = @"C:\Temp\EAIRA_M5S5_PACKAGE_A_TESTONLY0001";

        internal static int IndexOfAction(string action)
        { for (int i = 0; i < Actions.Length; i++) if (Actions[i] == action) return i; return -1; }

        private static string ActionPath(string action)
        {
            string building = Path.Combine(Root, "package.building");
            if (action == "CREATE_EVIDENCE_ROOT") return Root;
            if (action == "CREATE_PACKAGE_BUILDING") return building;
            if (action == "CREATE_PAYLOAD_DIRECTORY") return Path.Combine(building, "payload");
            if (action == "CREATE_README") return Path.Combine(building, "README.txt");
            if (action == "CREATE_MANIFEST") return Path.Combine(building, "EAIRA_UNSIGNED_CUSTOMER_PACKAGE_MANIFEST_V1.json");
            int ordinal = Int32.Parse(action.Substring("CREATE_PAYLOAD_".Length), CultureInfo.InvariantCulture);
            return Path.Combine(building, "payload", UnsignedCustomerPackage.Payloads[ordinal - 1].File);
        }

        internal static bool RunRace(string fault, bool after, int projection)
        {
            PackageTestFileSystem.Start(); PackageFaultRuntime.Reset(fault, after);
            bool probe = false, failed = false; string foreign = null;
            PackageFaultRuntime.Probe = delegate(string action, bool phase)
            {
                if (projection == 0)
                {
                    string path = ActionPath(action);
                    if (!phase) { bool directory = action == "CREATE_EVIDENCE_ROOT" || action == "CREATE_PACKAGE_BUILDING" || action == "CREATE_PAYLOAD_DIRECTORY"; PackageTestFileSystem.AddForeign(path, directory); foreign = path; probe = true; PackageFaultRuntime.SuppressThrow = true; }
                    else probe = !PackageTestFileSystem.TryReplace(path);
                }
                else if (projection == 1)
                {
                    string path = Path.Combine(Root, "package", "payload", UnsignedCustomerPackage.Payloads[0].File);
                    probe = PackageTestFileSystem.TryReplace(path); foreign = path;
                    if (!phase) PackageFaultRuntime.SuppressThrow = true;
                    else { try { UnsignedCustomerPackage.Verify(Root); probe = false; } catch (InvalidDataException) { } }
                }
                else if (projection == 2)
                {
                    string path = Path.Combine(Root, "package");
                    if (!phase) { PackageTestFileSystem.AddForeign(path, true); foreign = path; probe = true; PackageFaultRuntime.SuppressThrow = true; }
                    else probe = !PackageTestFileSystem.TryReplace(path);
                }
                else probe = PackageTestFileSystem.WrongDispositionRejected(Root);
            };
            try
            {
                bool mutation = false, cleanup = false;
                try { UnsignedCustomerPackage.Build(Root, ref mutation, ref cleanup); }
                catch (IOException) { failed = true; }
                catch (InvalidDataException) { failed = true; }
                return failed && PackageFaultRuntime.Injected && probe && PackageTestFileSystem.ForeignDeleted == 0 &&
                    (foreign == null || PackageTestFileSystem.ForeignExists(foreign)) && PackageTestFileSystem.CloseFailures == 0;
            }
            finally { PackageTestFileSystem.Stop(); }
        }

        internal static PackageFaultObservation RunFault(string fault, bool after)
        {
            PackageTestFileSystem.Start(); PackageFaultRuntime.Reset(fault, after);
            bool mutated = false, cleanup = false, failed = false, dispositionRejected = true;
            PackageFaultRuntime.Probe = delegate(string action, bool phase) { dispositionRejected = PackageTestFileSystem.WrongDispositionRejected(Root); };
            try
            {
                try { UnsignedCustomerPackage.Build(Root, ref mutated, ref cleanup); }
                catch (InjectedPackageFault) { failed = true; }
                int index = IndexOfAction(fault); bool remains = PackageTestFileSystem.Exists(Root);
                bool expectedRemains = index >= 36;
                string channel = UnsignedCustomerPackage.FailureResult("Build", mutated, cleanup);
                bool channelMatches = !mutated ? channel.Contains("\"writes\":\"NONE\"") :
                    remains ? channel.Contains("\"cleanup\":\"INCOMPLETE\"") && channel.Contains("\"persistentOutput\":\"POSSIBLE\"") :
                    channel.Contains("\"cleanup\":\"COMPLETE\"") && channel.Contains("\"persistentOutput\":\"NONE\"");
                bool correct = failed && PackageFaultRuntime.Injected && remains == expectedRemains &&
                    cleanup == !expectedRemains && channelMatches && dispositionRejected && PackageTestFileSystem.ForeignDeleted == 0 && PackageTestFileSystem.CloseFailures == 0;
                return new PackageFaultObservation {
                    MutationAttempted = mutated, CleanupComplete = cleanup, PersistentPossible = remains,
                    LedgerOnly = correct, PathFallback = false, ExecutedActions = PackageFaultRuntime.Calls, ExpectedActions = index * 2 + (after ? 2 : 1)
                };
            }
            finally { PackageTestFileSystem.Stop(); }
        }

        internal static bool SuccessfulBuildVerify()
        {
            PackageTestFileSystem.Start(); PackageFaultRuntime.Reset(null, false);
            try {
                bool mutation = false, cleanup = false; string built = UnsignedCustomerPackage.Build(Root, ref mutation, ref cleanup);
                int writes = PackageTestFileSystem.Writes; string verified = UnsignedCustomerPackage.Verify(Root);
                return mutation && built == UnsignedCustomerPackage.NineGoldenSha256 && verified == built && writes == PackageTestFileSystem.Writes;
            } finally { PackageTestFileSystem.Stop(); }
        }

        internal static bool OutputInvariant(string name)
        {
            if (name == "OUTPUT_FOREIGN_LEDGER_RETAINED")
            {
                PackageTestFileSystem.Start(); PackageFaultRuntime.Reset("VERIFY_PACKAGE", false);
                string path = Path.Combine(Root, "package", "payload", UnsignedCustomerPackage.Payloads[0].File);
                bool replaced = false;
                PackageFaultRuntime.Probe = delegate(string action, bool phase) { replaced = PackageTestFileSystem.TryReplace(path); };
                try {
                    bool mutation = false, cleanup = false;
                    try { UnsignedCustomerPackage.Build(Root, ref mutation, ref cleanup); return false; }
                    catch (InjectedPackageFault) { return replaced && !cleanup && PackageTestFileSystem.ForeignExists(path) && PackageTestFileSystem.ForeignDeleted == 0; }
                } finally { PackageTestFileSystem.Stop(); }
            }
            if (name == "OUTPUT_DISPOSITION_HANDLE_ONLY" || name == "OUTPUT_NO_RECURSIVE_CLEANUP")
                return RunFault("FLUSH_MANIFEST", true).LedgerOnly && OutputInvariant("OUTPUT_FOREIGN_LEDGER_RETAINED");
            return SuccessfulBuildVerify();
        }

        internal static bool VerifyMutationRejected(string name)
        {
            PackageTestFileSystem.Start(); PackageFaultRuntime.Reset(null, false);
            try
            {
                bool mutation = false, cleanup = false; UnsignedCustomerPackage.Build(Root, ref mutation, ref cleanup);
                string payload = Path.Combine(Root, "package", "payload", UnsignedCustomerPackage.Payloads[0].File);
                string readme = Path.Combine(Root, "package", "README.txt");
                string manifest = Path.Combine(Root, "package", "EAIRA_UNSIGNED_CUSTOMER_PACKAGE_MANIFEST_V1.json");
                if (name == "VERIFY_CHANGED_PAYLOAD_FAIL") PackageTestFileSystem.MutateFile(payload, "change");
                else if (name == "VERIFY_EXTRA_ENTRY_FAIL") PackageTestFileSystem.MutateFile(payload, "extra");
                else if (name == "VERIFY_MISSING_ENTRY_FAIL") PackageTestFileSystem.MutateFile(payload, "missing");
                else if (name == "VERIFY_CHANGED_README_FAIL") PackageTestFileSystem.MutateFile(readme, "change");
                else if (name == "VERIFY_CHANGED_MANIFEST_FAIL") PackageTestFileSystem.MutateFile(manifest, "change");
                else if (name == "VERIFY_MANIFEST_BOM_FAIL") PackageTestFileSystem.MutateFile(manifest, "bom");
                else if (name == "VERIFY_TRAILING_TOKEN_FAIL") PackageTestFileSystem.MutateFile(manifest, "trailing");
                else return false;
                int writes = PackageTestFileSystem.Writes;
                try { UnsignedCustomerPackage.Verify(Root); return false; }
                catch (InvalidDataException) { return PackageTestFileSystem.Writes == writes; }
            } finally { PackageTestFileSystem.Stop(); }
        }

        internal static bool PinnedRead(string name)
        {
            PackageTestFileSystem.Start();
            try
            {
                string path = name == "PROFILE_SWAP_AFTER_OPEN_FAIL" ? UnsignedCustomerPackage.ProfilePath :
                    Path.Combine(UnsignedCustomerPackage.SourceRoot, UnsignedCustomerPackage.Payloads[0].File);
                using (SafeFileHandle h = NativePackageFileSystem.OpenAbsoluteFile(path))
                {
                    byte[] before = NativePackageFileSystem.ReadAll(h, 1048576);
                    if (PackageTestFileSystem.TryReplace(path)) return false;
                    return UnsignedCustomerPackage.Sha256(before) == UnsignedCustomerPackage.Sha256(NativePackageFileSystem.ReadAll(h, 1048576));
                }
            } finally { PackageTestFileSystem.Stop(); }
        }

        internal static bool SourceMutationRejected(string name)
        {
            PackageTestFileSystem.Start(); PackageFaultRuntime.Reset(null, false);
            try
            {
                string source = Path.Combine(UnsignedCustomerPackage.SourceRoot, UnsignedCustomerPackage.Payloads[0].File);
                if (name == "SOURCE_MISSING_FAIL") PackageTestFileSystem.MutateFile(source, "missing");
                else if (name == "SOURCE_EXTRA_FAIL" || name == "SOURCE_RENAMED_FAIL") PackageTestFileSystem.MutateFile(source, "extra");
                else if (name == "SOURCE_SIZE_FAIL") PackageTestFileSystem.MutateFile(source, "trailing");
                else if (name == "SOURCE_HASH_FAIL") PackageTestFileSystem.MutateFile(source, "change");
                else return false;
                bool mutation = false, cleanup = false;
                try { UnsignedCustomerPackage.Build(Root, ref mutation, ref cleanup); return false; }
                catch (InvalidDataException) { return !mutation && !PackageTestFileSystem.Exists(Root); }
            } finally { PackageTestFileSystem.Stop(); }
        }
    }
#endif

    internal static class UnsignedCustomerPackageProgram
    {
        private static int Main(string[] args)
        {
            Console.OutputEncoding = new UTF8Encoding(false);
            return UnsignedCustomerPackage.Run(args, Console.Out);
        }
    }
}
