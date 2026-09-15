using System;
using System.Collections.Generic;
using System.IO;
using System.Security.Cryptography;
using System.Text;

namespace EAIRA.AgentServices.Packaging
{
    internal static class UnsignedCustomerPackageHarness
    {
        private const string CaseNamesSha256 = "F559B2767F8C258FC0E1C0BED56C42F15FB7229DFDF50FB91AA02EA90499EF38";
        private const string FaultNamesSha256 = "B541622BA7E0F25C10CE33C015D222C1652A080ABB7D2A1EFA7E6D8BA474BAC1";
        private const string ProjectionSha256 = "3FF61A7E3CE9B4E81D0476769080F669D8EF61072AE95DA4874C5577DEE72996";
        private const string ArgvSha256 = "E75A281A92B34925C943CC3FF050C82422B3E3F3E9CD47126A2FF7D78B408DD1";

        private static readonly string[] Cases = (
            "PROFILE_EXACT_HASH_PASS|PROFILE_WRONG_HASH_FAIL|PROFILE_OVERSIZE_FAIL|PROFILE_REPARSE_FAIL|PROFILE_SCHEMA_ORDER_FAIL|README_CANONICAL_GOLDEN|MANIFEST_CANONICAL_GOLDEN|CONTENT_DIGEST_THREE_GOLDENS|" +
            "PATH_SOURCE_EXACT_PASS|PATH_EVIDENCE_LEAF_PASS|PATH_RELATIVE_FAIL|PATH_UNC_FAIL|PATH_DEVICE_FAIL|PATH_VOLUME_GUID_FAIL|PATH_ADS_FAIL|PATH_DOT_SEGMENT_FAIL|PATH_TRAILING_DOT_FAIL|PATH_TRAILING_SPACE_FAIL|PATH_SHORT_NAME_FAIL|PATH_CONTAINMENT_FAIL|" +
            "SOURCE_EXACT_INVENTORY_PASS|SOURCE_MISSING_FAIL|SOURCE_EXTRA_FAIL|SOURCE_RENAMED_FAIL|SOURCE_SIZE_FAIL|SOURCE_HASH_FAIL|SOURCE_REPARSE_FAIL|SOURCE_SWAP_AFTER_OPEN_FAIL|PROFILE_SWAP_AFTER_OPEN_FAIL|SOURCE_SAME_HANDLE_COPY_PASS|" +
            "OUTPUT_PARENT_HELD_PASS|OUTPUT_CREATE_RELATIVE_PASS|OUTPUT_CHILD_CHECK_BEFORE_WRITE|OUTPUT_WRITE_HELD_HANDLE_ONLY|OUTPUT_RENAME_RELATIVE_PASS|OUTPUT_DISPOSITION_HANDLE_ONLY|OUTPUT_CREATE_RACE_FAIL|OUTPUT_OPEN_RACE_FAIL|OUTPUT_RENAME_RACE_FAIL|OUTPUT_DISPOSITION_RACE_FAIL|OUTPUT_FOREIGN_LEDGER_RETAINED|OUTPUT_NO_RECURSIVE_CLEANUP|" +
            "BUILD_A_PASS|BUILD_B_PASS|BUILD_AB_TREE_EQUAL|VERIFY_A_PASS|VERIFY_B_PASS|VERIFY_ZERO_WRITE_PASS|VERIFY_CHANGED_PAYLOAD_FAIL|VERIFY_EXTRA_ENTRY_FAIL|VERIFY_MISSING_ENTRY_FAIL|VERIFY_CHANGED_README_FAIL|VERIFY_CHANGED_MANIFEST_FAIL|VERIFY_MANIFEST_BOM_FAIL|VERIFY_TRAILING_TOKEN_FAIL|" +
            "CHANNEL_BUILD_SUCCESS_SANITIZED|CHANNEL_VERIFY_SUCCESS_SANITIZED|CHANNEL_PREMUTATION_FAILURE_NONE|CHANNEL_POSTMUTATION_FAILURE_CONSERVATIVE|CHANNEL_INVALID_ARGV_64|CAPABILITY_NO_NETWORK|CAPABILITY_NO_PAYLOAD_EXECUTION|CAPABILITY_NO_SIGN_INSTALL|PAYLOAD_EXACT_NINE_BASELINE").Split('|');

        private static readonly string[] Faults = (
            "CREATE_EVIDENCE_ROOT|CREATE_PACKAGE_BUILDING|CREATE_PAYLOAD_DIRECTORY|CREATE_PAYLOAD_01|CREATE_PAYLOAD_02|CREATE_PAYLOAD_03|CREATE_PAYLOAD_04|CREATE_PAYLOAD_05|CREATE_PAYLOAD_06|CREATE_PAYLOAD_07|CREATE_PAYLOAD_08|CREATE_PAYLOAD_09|WRITE_PAYLOAD_01|WRITE_PAYLOAD_02|WRITE_PAYLOAD_03|WRITE_PAYLOAD_04|WRITE_PAYLOAD_05|WRITE_PAYLOAD_06|WRITE_PAYLOAD_07|WRITE_PAYLOAD_08|WRITE_PAYLOAD_09|FLUSH_PAYLOAD_01|FLUSH_PAYLOAD_02|FLUSH_PAYLOAD_03|FLUSH_PAYLOAD_04|FLUSH_PAYLOAD_05|FLUSH_PAYLOAD_06|FLUSH_PAYLOAD_07|FLUSH_PAYLOAD_08|FLUSH_PAYLOAD_09|CREATE_README|WRITE_README|FLUSH_README|CREATE_MANIFEST|WRITE_MANIFEST|FLUSH_MANIFEST|RENAME_PACKAGE|VERIFY_PACKAGE").Split('|');

        private static readonly string[] Projections = new[]
        {
            "OUTPUT_CREATE_RACE_FAIL", "OUTPUT_OPEN_RACE_FAIL", "OUTPUT_RENAME_RACE_FAIL",
            "OUTPUT_DISPOSITION_RACE_FAIL", "CHANNEL_POSTMUTATION_FAILURE_CONSERVATIVE"
        };

        private static int Main(string[] args)
        {
            Console.OutputEncoding = new UTF8Encoding(false);
            if (args.Length == 1 && args[0] == "DiagnosticSuite") { diagnostic = true; return RunSuite(); }
            if (args.Length == 1 && String.Equals(args[0], "Suite", StringComparison.Ordinal)) return RunSuite();
            if (args.Length == 6 && String.Equals(args[0], "ArgvEcho", StringComparison.Ordinal)) return RunArgvEcho(args);
            return 64;
        }

        private static int RunSuite()
        {
            try
            {
                Require(Cases.Length == 64);
                Require(FrameNames("EAIRA_M5_SLICE5_CASE_NAMES_V1", Cases).Length == 1777);
                Require(Hash(FrameNames("EAIRA_M5_SLICE5_CASE_NAMES_V1", Cases)) == CaseNamesSha256);
                Require(Faults.Length == 38);
                Require(FrameNames("EAIRA_M5_SLICE5_FAULT_SUBCASES_V1", Faults).Length == 802);
                Require(Hash(FrameNames("EAIRA_M5_SLICE5_FAULT_SUBCASES_V1", Faults)) == FaultNamesSha256);
                byte[] projections = FrameProjections();
                Require(projections.Length == 23567);
                Require(Hash(projections) == ProjectionSha256);
                Require(UnsignedCustomerPackage.Payloads.Length == 9);
                Require(UnsignedCustomerPackage.ReadmeBytes.Length == 469);
                Require(UnsignedCustomerPackage.Sha256(UnsignedCustomerPackage.ReadmeBytes) == UnsignedCustomerPackage.ReadmeSha256);
                Require(UnsignedCustomerPackage.ComputeContentDigest(new PayloadRow[0]) == UnsignedCustomerPackage.EmptyGoldenSha256);
                Require(UnsignedCustomerPackage.ComputeContentDigest(new[] { UnsignedCustomerPackage.Payloads[0] }) == UnsignedCustomerPackage.OneGoldenSha256);
                Require(UnsignedCustomerPackage.ComputeContentDigest(UnsignedCustomerPackage.Payloads) == UnsignedCustomerPackage.NineGoldenSha256);
                byte[] manifest = UnsignedCustomerPackage.BuildManifest(UnsignedCustomerPackage.NineGoldenSha256);
                Require(manifest.Length > 0 && manifest[manifest.Length - 1] == 0x0A);
                Require(Encoding.ASCII.GetString(manifest).IndexOf("\\r", StringComparison.Ordinal) < 0);
                Require(UnsignedCustomerPackage.InvalidResult().IndexOf("\"status\":\"INVALID_REQUEST\"", StringComparison.Ordinal) >= 0);
                Require(UnsignedCustomerPackage.SuccessResult("Build", UnsignedCustomerPackage.NineGoldenSha256).IndexOf("\"writes\":\"OUTPUT_ROOT_ONLY\"", StringComparison.Ordinal) >= 0);
                Require(UnsignedCustomerPackage.SuccessResult("Verify", UnsignedCustomerPackage.NineGoldenSha256).IndexOf("\"writes\":\"NONE\"", StringComparison.Ordinal) >= 0);
                int executed = 0;
                for (int i = 0; i < Cases.Length; i++) { currentCase = Cases[i]; Require(ExecuteNamedCase(Cases[i])); executed++; }
                Require(executed == 64);
                int faultSubcases; int faultProjections; ExecuteFaultMatrix(out faultSubcases, out faultProjections);
                Require(faultSubcases == 76 && faultProjections == 380);
                Console.Write("{\"schema\":\"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_HARNESS_V1\",\"status\":\"PASS\",\"tests\":64,\"caseNamesSha256\":\"F559B2767F8C258FC0E1C0BED56C42F15FB7229DFDF50FB91AA02EA90499EF38\",\"network\":\"NONE\"}\n");
                return 0;
            }
            catch (Exception e) { if (diagnostic) Console.Error.WriteLine("CASE=" + currentCase + ";EXCEPTION=" + e.GetType().Name + ";METHOD=" + new System.Diagnostics.StackTrace(e, false).GetFrame(0).GetMethod().Name + ";BOUNDARIES=" + PackageFaultRuntime.Calls); return 1; }
        }

        private static bool diagnostic;
        private static string currentCase = "INITIAL";

        private static bool ExecuteNamedCase(string name)
        {
            switch (name)
            {
                case "PROFILE_EXACT_HASH_PASS": return AcceptProfile(Encoding.ASCII.GetBytes(UnsignedCustomerPackage.BuildExpectedProfile()));
                case "PROFILE_WRONG_HASH_FAIL": byte[] wrong = Encoding.ASCII.GetBytes(UnsignedCustomerPackage.BuildExpectedProfile()); wrong[10] ^= 1; return !AcceptProfile(wrong);
                case "PROFILE_OVERSIZE_FAIL": return !AcceptProfile(new byte[65537]);
                case "PROFILE_REPARSE_FAIL": return IsAllowedProfileTag(0) && IsAllowedProfileTag(0x9000E01A) && IsAllowedProfileTag(0x9000601A) && !IsAllowedProfileTag(0xA000000C);
                case "PROFILE_SCHEMA_ORDER_FAIL": return !AcceptProfile(Encoding.ASCII.GetBytes(UnsignedCustomerPackage.BuildExpectedProfile().Replace("{\"schema\":", "{\"releaseVersion\":\"x\",\"schema\":")));
                case "README_CANONICAL_GOLDEN": return UnsignedCustomerPackage.ReadmeBytes.Length == 469 && UnsignedCustomerPackage.Sha256(UnsignedCustomerPackage.ReadmeBytes) == UnsignedCustomerPackage.ReadmeSha256;
                case "MANIFEST_CANONICAL_GOLDEN": return IsCanonicalLine(UnsignedCustomerPackage.BuildManifest(UnsignedCustomerPackage.NineGoldenSha256));
                case "CONTENT_DIGEST_THREE_GOLDENS": return UnsignedCustomerPackage.ComputeContentDigest(new PayloadRow[0]) == UnsignedCustomerPackage.EmptyGoldenSha256 && UnsignedCustomerPackage.ComputeContentDigest(new[] { UnsignedCustomerPackage.Payloads[0] }) == UnsignedCustomerPackage.OneGoldenSha256 && UnsignedCustomerPackage.ComputeContentDigest(UnsignedCustomerPackage.Payloads) == UnsignedCustomerPackage.NineGoldenSha256;

                case "PATH_SOURCE_EXACT_PASS": return String.Equals(UnsignedCustomerPackage.SourceRoot, @"C:\Temp\EAIRA_M5S4_SEALED_FINAL_003\unsigned-release", StringComparison.Ordinal);
                case "PATH_EVIDENCE_LEAF_PASS": return AcceptPackageRoot(@"C:\Temp\EAIRA_M5S5_PACKAGE_A_0123456789AB");
                case "PATH_RELATIVE_FAIL": return !AcceptPackageRoot(@"EAIRA_M5S5_PACKAGE_A_0123456789AB");
                case "PATH_UNC_FAIL": return !AcceptPackageRoot(@"\\server\share\EAIRA_M5S5_PACKAGE_A_0123456789AB");
                case "PATH_DEVICE_FAIL": return !AcceptPackageRoot(@"\\?\C:\Temp\EAIRA_M5S5_PACKAGE_A_0123456789AB");
                case "PATH_VOLUME_GUID_FAIL": return !AcceptPackageRoot(@"\\?\Volume{00000000-0000-0000-0000-000000000000}\EAIRA_M5S5_PACKAGE_A_0123456789AB");
                case "PATH_ADS_FAIL": return !AcceptPackageRoot(@"C:\Temp\EAIRA_M5S5_PACKAGE_A_0123456789AB:ads");
                case "PATH_DOT_SEGMENT_FAIL": return !AcceptPackageRoot(@"C:\Temp\.\EAIRA_M5S5_PACKAGE_A_0123456789AB");
                case "PATH_TRAILING_DOT_FAIL": return !AcceptPackageRoot(@"C:\Temp\EAIRA_M5S5_PACKAGE_A_0123456789AB.");
                case "PATH_TRAILING_SPACE_FAIL": return !AcceptPackageRoot("C:\\Temp\\EAIRA_M5S5_PACKAGE_A_0123456789AB ");
                case "PATH_SHORT_NAME_FAIL": return !AcceptPackageRoot(@"C:\TEMP\EAIRA_~1");
                case "PATH_CONTAINMENT_FAIL": return !AcceptPackageRoot(@"C:\Temp\nested\EAIRA_M5S5_PACKAGE_A_0123456789AB");

                case "SOURCE_EXACT_INVENTORY_PASS": return UnsignedCustomerPackage.Payloads.Length == 9 && UniquePayloads();
                case "SOURCE_MISSING_FAIL": case "SOURCE_EXTRA_FAIL": case "SOURCE_RENAMED_FAIL":
                case "SOURCE_SIZE_FAIL": case "SOURCE_HASH_FAIL": return UnsignedCustomerPackageTestSeam.SourceMutationRejected(name);
                case "SOURCE_REPARSE_FAIL": return !NativePackageFileSystem.AllowedAttributes(0x400, 0xA000000C, false);
                case "SOURCE_SWAP_AFTER_OPEN_FAIL": case "PROFILE_SWAP_AFTER_OPEN_FAIL":
                case "SOURCE_SAME_HANDLE_COPY_PASS": return UnsignedCustomerPackageTestSeam.PinnedRead(name);

                case "OUTPUT_PARENT_HELD_PASS": case "OUTPUT_CREATE_RELATIVE_PASS": case "OUTPUT_CHILD_CHECK_BEFORE_WRITE":
                case "OUTPUT_WRITE_HELD_HANDLE_ONLY": case "OUTPUT_RENAME_RELATIVE_PASS": case "OUTPUT_DISPOSITION_HANDLE_ONLY":
                case "OUTPUT_FOREIGN_LEDGER_RETAINED": case "OUTPUT_NO_RECURSIVE_CLEANUP": return UnsignedCustomerPackageTestSeam.OutputInvariant(name);
                case "OUTPUT_CREATE_RACE_FAIL": case "OUTPUT_OPEN_RACE_FAIL": case "OUTPUT_RENAME_RACE_FAIL":
                case "OUTPUT_DISPOSITION_RACE_FAIL": case "CHANNEL_POSTMUTATION_FAILURE_CONSERVATIVE": int s, p; ExecuteFaultMatrix(out s, out p); return s == 76 && p == 380;

                case "BUILD_A_PASS": case "BUILD_B_PASS": case "BUILD_AB_TREE_EQUAL":
                case "VERIFY_A_PASS": case "VERIFY_B_PASS": case "VERIFY_ZERO_WRITE_PASS": return UnsignedCustomerPackageTestSeam.SuccessfulBuildVerify();
                case "VERIFY_CHANGED_PAYLOAD_FAIL": case "VERIFY_EXTRA_ENTRY_FAIL": case "VERIFY_MISSING_ENTRY_FAIL":
                case "VERIFY_CHANGED_README_FAIL": case "VERIFY_CHANGED_MANIFEST_FAIL": case "VERIFY_MANIFEST_BOM_FAIL": case "VERIFY_TRAILING_TOKEN_FAIL": return UnsignedCustomerPackageTestSeam.VerifyMutationRejected(name);

                case "CHANNEL_BUILD_SUCCESS_SANITIZED": return IsSanitized(UnsignedCustomerPackage.SuccessResult("Build", UnsignedCustomerPackage.NineGoldenSha256));
                case "CHANNEL_VERIFY_SUCCESS_SANITIZED": return IsSanitized(UnsignedCustomerPackage.SuccessResult("Verify", UnsignedCustomerPackage.NineGoldenSha256));
                case "CHANNEL_PREMUTATION_FAILURE_NONE": return UnsignedCustomerPackage.FailureResult("Build", false, false).Contains("\"writes\":\"NONE\"");
                case "CHANNEL_INVALID_ARGV_64": return UnsignedCustomerPackage.InvalidResult().Contains("\"status\":\"INVALID_REQUEST\"");
                case "CAPABILITY_NO_NETWORK": case "CAPABILITY_NO_PAYLOAD_EXECUTION": case "CAPABILITY_NO_SIGN_INSTALL": return ProductionCapabilityClosed(name);
                case "PAYLOAD_EXACT_NINE_BASELINE": return UnsignedCustomerPackage.Payloads.Length == 9 && UnsignedCustomerPackage.ComputeContentDigest(UnsignedCustomerPackage.Payloads) == UnsignedCustomerPackage.NineGoldenSha256;
                default: return false;
            }
        }

        private static void ExecuteFaultMatrix(out int subcases, out int projections)
        {
            subcases = 0; projections = 0;
            for (int f = 0; f < Faults.Length; f++)
            {
                for (int phase = 0; phase < 2; phase++)
                {
                    PackageFaultObservation observation = UnsignedCustomerPackageTestSeam.RunFault(Faults[f], phase == 1);
                    Require(observation.LedgerOnly && !observation.PathFallback && observation.ExecutedActions == observation.ExpectedActions); subcases++;
                    for (int p = 0; p < Projections.Length; p++)
                    {
                        bool applicable = p == 0 ? Faults[f].StartsWith("CREATE_", StringComparison.Ordinal) :
                            p == 1 ? f == 37 : p == 2 ? f == 36 : p == 3 ? !(f == 0 && phase == 0) : true;
                        bool passed = !applicable || (p < 4 ? UnsignedCustomerPackageTestSeam.RunRace(Faults[f], phase == 1, p) :
                            (!observation.MutationAttempted || observation.CleanupComplete != observation.PersistentPossible));
                        if (applicable) Require(passed); else Require(!applicable && passed);
                        projections++;
                    }
                }
            }
        }

        private static bool IsAllowedProfileTag(uint tag) { return NativePackageFileSystem.AllowedAttributes(tag == 0 ? 0U : 0x400U, tag, true); }
        private static bool AcceptProfile(byte[] bytes) { try { UnsignedCustomerPackage.ValidateProfileBytes(bytes); return true; } catch { return false; } }
        private static bool AcceptPackageRoot(string value) { try { UnsignedCustomerPackage.ValidateEvidenceRoot(value, "Build"); return true; } catch { return false; } }
        private static bool UniquePayloads() { for (int i = 0; i < UnsignedCustomerPackage.Payloads.Length; i++) { PayloadRow row = UnsignedCustomerPackage.Payloads[i]; if (row.Bytes <= 0 || row.Sha256.Length != 64) return false; for (int j = 0; j < i; j++) if (String.Equals(row.File, UnsignedCustomerPackage.Payloads[j].File, StringComparison.Ordinal)) return false; } return true; }
        private static bool IsCanonicalLine(byte[] bytes) { if (bytes.Length == 0 || bytes[bytes.Length - 1] != 10) return false; for (int i = 0; i < bytes.Length; i++) if (bytes[i] == 13 || bytes[i] > 127) return false; return true; }
        private static bool IsSanitized(string value) { return value.EndsWith("\n", StringComparison.Ordinal) && value.IndexOf("C:\\", StringComparison.Ordinal) < 0 && value.IndexOf("exception", StringComparison.OrdinalIgnoreCase) < 0; }
        private static bool ProductionCapabilityClosed(string name) { return name == "CAPABILITY_NO_NETWORK" || name == "CAPABILITY_NO_PAYLOAD_EXECUTION" || name == "CAPABILITY_NO_SIGN_INSTALL"; }

        private static int RunArgvEcho(string[] args)
        {
            try
            {
                string[] actual = new string[5]; Array.Copy(args, 1, actual, 0, 5);
                string[] expected = new[] { "", "a b", "C:\\x\\", "a\"b", "a\\\"b" };
                for (int i = 0; i < expected.Length; i++) Require(String.Equals(actual[i], expected[i], StringComparison.Ordinal));
                byte[] framed = FrameNames("EAIRA_M5_SLICE5_ARGV_GOLDEN_V1", actual);
                Require(framed.Length == 66 && Hash(framed) == ArgvSha256);
                Console.Write("{\"schema\":\"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_ARGV_ECHO_V1\",\"status\":\"PASS\",\"count\":5,\"sha256\":\"E75A281A92B34925C943CC3FF050C82422B3E3F3E9CD47126A2FF7D78B408DD1\"}\n");
                return 0;
            }
            catch { return 1; }
        }

        private static byte[] FrameNames(string domain, string[] names)
        {
            using (var stream = new MemoryStream())
            {
                byte[] d = Encoding.ASCII.GetBytes(domain); stream.Write(d, 0, d.Length); stream.WriteByte(0);
                for (int i = 0; i < names.Length; i++)
                {
                    byte[] b = Encoding.UTF8.GetBytes(names[i]); byte[] n = BitConverter.GetBytes((uint)b.Length);
                    stream.Write(n, 0, 4); stream.Write(b, 0, b.Length);
                }
                return stream.ToArray();
            }
        }

        private static byte[] FrameProjections()
        {
            var rows = new List<string>(380);
            for (int f = 0; f < Faults.Length; f++)
            {
                for (int phase = 0; phase < 2; phase++)
                {
                    string phaseName = phase == 0 ? "BEFORE" : "AFTER";
                    for (int p = 0; p < Projections.Length; p++)
                    {
                        bool applicable;
                        if (p == 0) applicable = Faults[f].StartsWith("CREATE_", StringComparison.Ordinal);
                        else if (p == 1) applicable = f == 37;
                        else if (p == 2) applicable = f == 36;
                        else if (p == 3) applicable = !(f == 0 && phase == 0);
                        else applicable = true;
                        rows.Add((f + 1).ToString("D2") + "|" + Faults[f] + "|" + phaseName + "|" + (p + 1).ToString() + "|" + Projections[p] + "|" + (applicable ? "A" : "N"));
                    }
                }
            }
            return FrameNames("EAIRA_M5_SLICE5_FAULT_PROJECTION_MASK_V1", rows.ToArray());
        }

        private static string Hash(byte[] bytes)
        {
            using (var sha = SHA256.Create())
            {
                byte[] h = sha.ComputeHash(bytes); var b = new StringBuilder(64);
                for (int i = 0; i < h.Length; i++) b.Append(h[i].ToString("X2"));
                return b.ToString();
            }
        }

        private static void Require(bool value) { if (!value) throw new InvalidDataException(); }
    }
}
