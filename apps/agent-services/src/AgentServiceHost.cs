using System;
using System.IO;
using System.Reflection;
using System.ServiceProcess;
using System.Threading;
using EAIRA.AgentServices.Functional;

[assembly: AssemblyCompany("EAIRA")]
[assembly: AssemblyProduct("EAIRA Agent Services")]
[assembly: AssemblyCopyright("Copyright © 2026")]
[assembly: AssemblyVersion("0.1.0.0")]
[assembly: AssemblyFileVersion("0.1.0.0")]
[assembly: AssemblyInformationalVersion("0.1.0-rc.3-unsigned")]

#if PLANNING
[assembly: AssemblyTitle("EAIRA Planning Agent Service")]
#elif OPERATIONS
[assembly: AssemblyTitle("EAIRA Operations Agent Service")]
#elif VERIFICATION
[assembly: AssemblyTitle("EAIRA Verification Agent Service")]
#elif GUARD
[assembly: AssemblyTitle("EAIRA Guard Agent Service")]
#elif AUDIT
[assembly: AssemblyTitle("EAIRA Audit Agent Service")]
#endif

namespace EAIRA.AgentServices
{
    internal static class RoleProfile
    {
        internal const string BuildContract = "EAIRA_GATE25_UNSIGNED_RC3";
        internal const string TargetFramework = ".NETFramework,Version=v4.8";

#if PLANNING
        internal const string Role = "Planning";
        internal const string ServiceName = "svcEAIRAPlan";
        internal const string ConfigPath = @"C:\ProgramData\EAIRA\AgentServices\Config\planning.json";
#elif OPERATIONS
        internal const string Role = "Operations";
        internal const string ServiceName = "svcEAIROps";
        internal const string ConfigPath = @"C:\ProgramData\EAIRA\AgentServices\Config\operations.json";
#elif VERIFICATION
        internal const string Role = "Verification";
        internal const string ServiceName = "svcEAIRVerify";
        internal const string ConfigPath = @"C:\ProgramData\EAIRA\AgentServices\Config\verification.json";
#elif GUARD
        internal const string Role = "Guard";
        internal const string ServiceName = "svcEAIRGuard";
        internal const string ConfigPath = @"C:\ProgramData\EAIRA\AgentServices\Config\guard.json";
#elif AUDIT
        internal const string Role = "Audit";
        internal const string ServiceName = "svcEAIRAudit";
        internal const string ConfigPath = @"C:\ProgramData\EAIRA\AgentServices\Config\audit.json";
#else
#error Exactly one EAIRA role symbol is required.
#endif
    }

    internal sealed class AgentService : ServiceBase
    {
        private readonly ManualResetEvent stopEvent = new ManualResetEvent(false);
        private Thread worker;

        internal AgentService()
        {
            ServiceName = RoleProfile.ServiceName;
            CanStop = true;
            CanPauseAndContinue = false;
            CanShutdown = true;
            AutoLog = false;
        }

        protected override void OnStart(string[] args)
        {
            if (args == null || args.Length != 0)
            {
                throw new InvalidOperationException("Service arguments are prohibited.");
            }

            if (!Path.IsPathRooted(RoleProfile.ConfigPath))
            {
                throw new InvalidOperationException("Config path is not absolute.");
            }

            if (!File.Exists(RoleProfile.ConfigPath))
            {
                throw new InvalidOperationException("Required configuration is absent.");
            }

            worker = new Thread(new ThreadStart(delegate { stopEvent.WaitOne(); }));
            worker.IsBackground = true;
            worker.Name = "EAIRA-" + RoleProfile.Role;
            worker.Start();
        }

        protected override void OnStop()
        {
            stopEvent.Set();
            if (worker != null && !worker.Join(TimeSpan.FromSeconds(5)))
            {
                throw new System.TimeoutException("Worker did not stop within the bounded interval.");
            }
        }

        protected override void OnShutdown()
        {
            OnStop();
        }

        internal static int Main(string[] args)
        {
            if (args != null && args.Length == 1 && String.Equals(args[0], "--self-test", StringComparison.Ordinal))
            {
                bool ok = RoleProfile.ServiceName.StartsWith("svcEAIR", StringComparison.Ordinal) &&
                          Path.IsPathRooted(RoleProfile.ConfigPath) &&
                          RoleProfile.ConfigPath.EndsWith(".json", StringComparison.OrdinalIgnoreCase) &&
                          FunctionalSliceSelfTest.ForRole(RoleProfile.Role);

                Console.WriteLine(
                    "{\"status\":\"" + (ok ? "PASS" : "FAIL") +
                    "\",\"contract\":\"" + RoleProfile.BuildContract +
                    "\",\"framework\":\"" + RoleProfile.TargetFramework +
                    "\",\"role\":\"" + RoleProfile.Role +
                    "\",\"service\":\"" + RoleProfile.ServiceName +
                    "\",\"functional_slice\":\"OFFLINE_TEST_ONLY\"" +
                    ",\"network\":\"NONE\",\"ipc\":\"PROHIBITED\",\"child_process\":\"PROHIBITED\"}");
                return ok ? 0 : 70;
            }

            if (args != null && args.Length != 0)
            {
                return 64;
            }

            if (Environment.UserInteractive)
            {
                return 65;
            }

            ServiceBase.Run(new AgentService());
            return 0;
        }
    }
}
