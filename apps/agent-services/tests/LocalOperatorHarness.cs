using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text;

namespace EAIRA.AgentServices.Functional
{
    internal static class LocalOperatorHarness
    {
        private static readonly string[] Names = new string[] {
            "CANON_TASK_MOCK","CANON_TASK_MOCK_CONTEXT","CANON_TASK_OLLAMA","CANON_TASK_OLLAMA_CONTEXT","CANON_KNOWLEDGE","CANON_PROJECT_QA",
            "INVALID_NULL_ARGV","INVALID_EMPTY_ARGV","INVALID_UNKNOWN_CAPABILITY","INVALID_CAPABILITY_CASE","INVALID_MISSING_FLAG","INVALID_EXTRA_FLAG","INVALID_DUPLICATE_FLAG","INVALID_REORDERED_FLAG","INVALID_CROSS_ROUTE_FLAG","INVALID_RESPONSE_FILE","INVALID_PROVIDER_REAL","INVALID_PROVIDER_URI","INVALID_MODEL_CASE","INVALID_TRACE_LENGTH","INVALID_TRACE_LOWER","INVALID_GOAL_EMPTY","INVALID_QUERY_EMPTY","INVALID_QUESTION_EMPTY","INVALID_ROOT_LEXICAL",
            "DENY_TASK_ZERO_FACTORIES","DENY_KNOWLEDGE_ZERO_FACTORIES","DENY_PROJECT_QA_ZERO_FACTORIES","ALLOW_TASK_FACTORY_ONCE","ALLOW_KNOWLEDGE_FACTORY_ONCE","ALLOW_PROJECT_QA_FACTORY_ONCE",
            "CHAIN_ALLOW_FIVE_ROLES","CHAIN_DENY_THREE_ROLES","CHAIN_DENY_NO_OPERATIONS","CHAIN_DENY_NO_VERIFICATION","TAMPER_REQUEST_DIGEST","TAMPER_ROUTE_DIGEST","TAMPER_PREVIOUS_DIGEST","TAMPER_EVIDENCE_DIGEST","TAMPER_PAYLOAD_DIGEST","TAMPER_AUDIT_DIGEST","KNOWLEDGE_ZERO_PROVIDER","QA_TAGS_CHAT_TAGS_EXACT","QA_FAILURE_PRE_TAGS","QA_FAILURE_CHAT","QA_FAILURE_POST_TAGS","TASK_MOCK_CALL_BUDGET","TASK_OLLAMA_CALL_BUDGET",
            "SENTINEL_RAW_ROOT","SENTINEL_RAW_INPUT","SENTINEL_RAW_CONTENT","SENTINEL_RAW_PROMPT","SENTINEL_REQUEST_BODY","SENTINEL_PROVIDER_RESPONSE","SENTINEL_PER_FILE_DIGEST","PROVIDER_TOOL_CALL","PROVIDER_IMAGE","PROVIDER_THINKING","PROVIDER_UNKNOWN_MEMBER","SEQUENCE_TASK_KNOWLEDGE_QA","SEQUENCE_QA_KNOWLEDGE_TASK",
            "PAYLOAD_16382","PAYLOAD_16383","PAYLOAD_16384_REJECT","LINE_16969","LINE_16970","LINE_16971_REJECT","CHANNEL_SINGLE_WRITE_LF","CHANNEL_EMPTY_STDERR","CHANNEL_NO_PARTIAL_FAILURE","REPLAY_TRACE_CORRELATION_ONLY","LEGACY_QA_COMPATIBILITY",
            "CROSSWALK_TASK_INVALID","CROSSWALK_TASK_PROVIDER_ERROR","CROSSWALK_TASK_CONTEXT_ERROR","CROSSWALK_KNOWLEDGE_DENIED","CROSSWALK_KNOWLEDGE_INVALID","CROSSWALK_KNOWLEDGE_ERROR","CROSSWALK_QA_DENIED","CROSSWALK_QA_INVALID","CROSSWALK_QA_PROVIDER_ERROR","CROSSWALK_QA_CONTEXT_ERROR","CROSSWALK_QA_KNOWLEDGE_ERROR","CROSSWALK_QA_VALIDATION_ERROR","CROSSWALK_ORCHESTRATION_ERROR","CROSSWALK_OUTPUT_ERROR","INVALID_STDIN_TOKEN","INVALID_ENV_TOKEN","INVALID_CONFIG_TOKEN","QA_FAILURE_SNAPSHOT_FACTORY","QA_FAILURE_SNAPSHOT_READ_CONTEXT","QA_FAILURE_SNAPSHOT_READ_KNOWLEDGE","QA_FAILURE_PROMPT_BUILD","QA_FAILURE_BODY_BUILD","QA_FAILURE_PROVIDER_FACTORY","QA_FAILURE_DECODE",
            "HEALTH_CANONICAL_REQUEST","HEALTH_ROUTE_EXACT","HEALTH_PAYLOAD_GOLDEN","HEALTH_WRAPPER_GOLDEN","HEALTH_ZERO_FACTORIES","HEALTH_DENY_THREE_ROLES_ZERO_FACTORIES","HEALTH_ALLOW_FIVE_ROLES","HEALTH_CROSS_TRACE_PAYLOAD_STABLE","HEALTH_CROSS_TRACE_WRAPPER_DISTINCT","HEALTH_INVALID_MISSING_TRACE","HEALTH_INVALID_TRACE_LOWER","HEALTH_INVALID_TRACE_SHORT","HEALTH_INVALID_TRACE_LONG","HEALTH_INVALID_TRACE_NONHEX","HEALTH_INVALID_EXTRA_ARG","HEALTH_INVALID_DUPLICATE_FLAG","HEALTH_INVALID_REORDERED_FLAG","HEALTH_INVALID_RESPONSE_FILE","HEALTH_INVALID_ROOT_FLAG","HEALTH_INVALID_PROVIDER_FLAG","HEALTH_OUTPUT_TAMPER_REJECT","HEALTH_ROUTE_TAMPER_REJECT","HEALTH_LEGACY_SEQUENCE_COMPATIBILITY" };
        private const string Trace = "00112233445566778899AABBCCDDEEFF", HealthTrace = "0123456789ABCDEF0123456789ABCDEF";
        private static readonly List<string> Passed = new List<string>();
        private static int PositiveControlBefore, PositiveControlAfter, HealthBefore, HealthAfter, DenialBefore, DenialAfter;
        private static int HealthDenialExitCode, HealthDenialRoles, HealthDenialFactoryCalls;
        private static bool HealthDenialPayloadNull;

        private sealed class Adapter : ILocalOperatorAdapter
        {
            private readonly LocalOperatorAdapterResult result;
            private readonly Func<LocalOperatorRequest, LocalOperatorAdapterResult> execute;
            internal Adapter(LocalOperatorAdapterResult value) { result = value; }
            internal Adapter(Func<LocalOperatorRequest, LocalOperatorAdapterResult> value) { execute = value; }
            public LocalOperatorAdapterResult Execute(LocalOperatorRequest request) { return execute == null ? result : execute(request); }
        }
        private sealed class Factory : ILocalOperatorAdapterFactory
        {
            internal int TaskCalls, KnowledgeCalls, QaCalls; internal LocalOperatorAdapterResult Result; internal ILocalOperatorAdapter QaAdapter;
            public ILocalOperatorAdapter CreateTask() { TaskCalls++; return new Adapter(delegate(LocalOperatorRequest r){return Result ?? TaskResult(r);}); }
            public ILocalOperatorAdapter CreateKnowledge() { KnowledgeCalls++; return new Adapter(delegate(LocalOperatorRequest r){return Result ?? KnowledgeResult(r);}); }
            public ILocalOperatorAdapter CreateProjectQa() { QaCalls++; return QaAdapter ?? new Adapter(delegate(LocalOperatorRequest r){return Result ?? QaAdapterResult(r,"SUCCESS","SUCCESS");}); }
            internal int Total { get { return TaskCalls + KnowledgeCalls + QaCalls; } }
        }
        private sealed class CountingModel : IModelProvider
        {
            private readonly DeterministicMockModel inner = new DeterministicMockModel();
            private readonly List<string> values = new List<string>();
            internal int Calls { get; private set; } internal int Unique { get { return values.Count; } }
            public string ProviderId { get { return "counting-mock-v1"; } }
            public bool IsExternal { get { return false; } } public bool IsExecutionEnabled { get { return true; } }
            public string Complete(AgentRole role, string prompt) { Calls++; string value=inner.Complete(role,prompt); if(!values.Contains(value))values.Add(value); return value; }
        }
        private sealed class CountingLocalModel : IModelProvider, IRequestLifecycleModelProvider, ILocalProviderObservations
        {
            private readonly DeterministicMockModel inner=new DeterministicMockModel();private readonly Dictionary<string,string> cache=new Dictionary<string,string>(StringComparer.Ordinal);private bool active;
            internal int Calls{get;private set;}internal int Unique{get{return cache.Count;}}internal int BeginRequestCalls{get;private set;}internal int EndRequestCalls{get;private set;}public int TagsCalls{get;private set;}public int ChatCalls{get;private set;}public bool PreflightDigestValidated{get;private set;}public bool PostflightDigestValidated{get;private set;}
            public string ProviderId{get{return "ollama-loopback-v1";}}public bool IsExternal{get{return false;}}public bool IsExecutionEnabled{get{return true;}}
            public void BeginRequest(){Require(!active);BeginRequestCalls++;active=true;TagsCalls++;PreflightDigestValidated=true;}
            public void EndRequest(){Require(active);EndRequestCalls++;TagsCalls++;PostflightDigestValidated=true;active=false;}
            public string Complete(AgentRole role,string prompt){Require(active);Calls++;string key=((int)role).ToString()+"\0"+prompt,value;if(!cache.TryGetValue(key,out value)){value=inner.Complete(role,prompt);cache.Add(key,value);ChatCalls++;}return value;}
        }
        private sealed class QaProvider : IProjectQaProvider
        {
            private readonly string mode;
            internal QaProvider(string value){mode=value;}
            public int TagsCalls { get; private set; } public int ChatCalls { get; private set; }
            public bool PreflightDigestValidated { get; private set; } public bool PostflightDigestValidated { get; private set; }
            public string Execute(byte[] body)
            {
                TagsCalls=1;if(mode=="PRE")throw new Exception();PreflightDigestValidated=true;
                ChatCalls=1;if(mode=="CHAT")throw new Exception();
                TagsCalls=2;if(mode=="POST")throw new Exception();PostflightDigestValidated=true;
                if(mode=="DECODE")return "{\"answer\":1,\"citationIds\":[]}";
                return "{\"answer\":\"Insufficient evidence in the allowed project sources.\",\"citationIds\":[]}";
            }
            public void Dispose(){}
        }
        private sealed class QaProviderFactory : IProjectQaProviderFactory
        {
            private readonly string mode; internal QaProviderFactory(string value){mode=value;}
            public IProjectQaProvider Create(){if(mode=="FACTORY_QA")throw new ProjectQaException();if(mode=="FACTORY_OTHER")throw new Exception();return new QaProvider(mode);}
        }
        private sealed class SnapshotFactory : IProjectQaSnapshotReaderFactory
        {
            private readonly string mode; internal int Calls; internal SnapshotFactory(string value){mode=value;}
            public ProjectQaSnapshotReader Create(){Calls++;if(mode=="FACTORY")throw new Exception();if(mode=="CONTEXT")return ProjectQaSnapshotReader.CreateFault(new ProjectQaContextException());if(mode=="KNOWLEDGE")return ProjectQaSnapshotReader.CreateFault(new ProjectQaKnowledgeException());return ProjectQaSnapshotReader.CreateFixture(QaSnapshot(mode));}
        }
        private sealed class RunnerQaAdapter : ILocalOperatorAdapter
        {
            private readonly string snapshotMode,providerMode;internal ProjectQaRunResult LastResult;internal ProjectQaExecutionObserver Observer;internal SnapshotFactory Snapshot;
            internal RunnerQaAdapter(string snapshot,string provider){snapshotMode=snapshot;providerMode=provider;}
            public LocalOperatorAdapterResult Execute(LocalOperatorRequest r)
            {
                Snapshot=new SnapshotFactory(snapshotMode);Observer=new ProjectQaExecutionObserver();
                try{LastResult=ProjectQaRunner.Execute(QaLegacy(r.Input),Snapshot,new QaProviderFactory(providerMode),Observer);return LocalOperatorAdapterResult.FromProjectQa(LastResult);}
                catch(Exception){return (int)Observer.LastStage>=(int)ProjectQaExecutionStage.ProviderFactoryCalled?LocalOperatorAdapterResult.Error("PROVIDER_ERROR",79,"LOOPBACK_ONLY"):LocalOperatorAdapterResult.Error("ORCHESTRATION_ERROR",83,"NONE");}
            }
        }
        private sealed class NullQaFactory : IProjectQaProviderFactory { public IProjectQaProvider Create(){throw new ProjectQaException();} }
        private static string[] TaskMock(string goal) { return new string[]{"task","--provider","mock","--trace",Trace,"--goal",goal}; }
        private static string[] TaskLocal(string goal) { return new string[]{"task","--provider","ollama-local","--model","qwen3:4b","--trace",Trace,"--goal",goal}; }
        private static string[] Knowledge(string query) { return new string[]{"knowledge","--root","C:\\EAIRA","--trace",Trace,"--query",query}; }
        private static string[] Qa(string question) { return new string[]{"project-qa","--root","C:\\EAIRA","--trace",Trace,"--question",question,"--provider","ollama-local","--model","qwen3:4b"}; }
        private static string[] QaLegacy(string question) { return new string[]{"--root","C:\\EAIRA","--trace",Trace,"--question",question,"--provider","ollama-local","--model","qwen3:4b"}; }
        private static string[] Health(string trace) { return new string[]{"health","--trace",trace}; }
        private static byte[] U32(uint value){unchecked{return new byte[]{(byte)(value>>24),(byte)(value>>16),(byte)(value>>8),(byte)value};}}
        private static string Domain(string name,string value){byte[] b=Encoding.UTF8.GetBytes(value);return ContractCodec.Sha256Hex(ContractCodec.Concat(Encoding.ASCII.GetBytes(name),new byte[]{0},U32((uint)b.Length),b));}
        private static LocalOperatorAdapterResult TaskResult(LocalOperatorRequest r)
        {
            if(r.Provider!="MOCK"||r.Root!=null)throw new LocalOperatorException();
            return LocalOperatorAdapterResult.FromTask(new LocalTaskIntake().Execute(new[]{"--provider","mock","--trace",r.TraceId,"--goal",r.Input}));
        }
        private static LocalOperatorAdapterResult KnowledgeResult(LocalOperatorRequest r)
        {
            List<ProjectKnowledgeMatch> matches=new List<ProjectKnowledgeMatch>();
            string q=Domain("EAIRA-KNOWLEDGE-QUERY-V1",r.Input);string rs=ContractCodec.Sha256Hex(ContractCodec.Concat(Encoding.ASCII.GetBytes("EAIRA-KNOWLEDGE-RESULTSET-V1"),new byte[]{0},U32(0),new byte[]{0}));
            return LocalOperatorAdapterResult.FromKnowledge(new ProjectKnowledgeResult(q,rs,false,matches));
        }
        private static ProjectQaSnapshot QaSnapshot(string mode)
        {
            string value=mode=="PROMPT"?new string('A',13000):mode=="BODY"?new string('\\',9000):"SAFE";
            List<ProjectQaContextField> fields=new List<ProjectQaContextField>();for(int i=0;i<27;i++)fields.Add(new ProjectQaContextField("C"+(i+1).ToString("D2"),"status.md","Label",i==0?value:"SAFE"));
            ProjectContextBundle context=new ProjectContextBundle(new string('A',64),4,new string('B',64),"SAFE_PROJECTION");
            ProjectKnowledgeResult knowledge=new ProjectKnowledgeResult(new string('C',64),new string('D',64),false,new List<ProjectKnowledgeMatch>());
            return new ProjectQaSnapshot(context,knowledge,fields);
        }
        private static LocalOperatorAdapterResult QaAdapterResult(LocalOperatorRequest r,string snapshotMode,string providerMode)
        {
            ProjectQaRunResult x=ProjectQaRunner.Execute(QaLegacy(r.Input),new SnapshotFactory(snapshotMode),new QaProviderFactory(providerMode),new ProjectQaExecutionObserver());
            return LocalOperatorAdapterResult.FromProjectQa(x);
        }
        private static void Require(bool value) { if (!value) throw new LocalOperatorException(); }
        private static void Case(string name, Action action) { action(); Passed.Add(name); }
        private static void VerifyQaClosure(ProjectQaRunResult value)
        {
            QaProvider provider=new QaProvider("SUCCESS");provider.Execute(new byte[]{1});string wrong=new string('E',64);
            string forgedDigest=value.CanonicalSuccessObject.Replace("\"answerSha256\":"+ContractCodec.Json(value.AnswerSha256),"\"answerSha256\":"+ContractCodec.Json(wrong));
            RequireReject(delegate{new ProjectQaRunResult(0,"PROJECT_QA_OK","LOOPBACK_ONLY",forgedDigest,forgedDigest+"\n",1,1,1,provider,ProjectQaExecutionStage.OutputReady,value.ContextAggregateSha256,value.ContextProjectionSha256,value.KnowledgeResultSetSha256,value.PromptSha256,wrong,value.CitationCount);});
            string forgedCitation=value.CanonicalSuccessObject.Replace("\"citationCount\":0,\"citations\":[]","\"citationCount\":1,\"citations\":[{\"id\":\"C01\",\"kind\":\"CONTEXT_FIELD\",\"path\":\"status.md\",\"field\":\"Label\",\"authority\":\"WRONG\"}]");
            RequireReject(delegate{new ProjectQaRunResult(0,"PROJECT_QA_OK","LOOPBACK_ONLY",forgedCitation,forgedCitation+"\n",1,1,1,provider,ProjectQaExecutionStage.OutputReady,value.ContextAggregateSha256,value.ContextProjectionSha256,value.KnowledgeResultSetSha256,value.PromptSha256,value.AnswerSha256,1);});
            string error="{\"schema\":\"EAIRA_PROJECT_QA_ERROR_V1\",\"status\":\"PROJECT_QA_ERROR\",\"network\":\"LOOPBACK_ONLY\",\"writes\":\"NONE\"}\n";
            RequireReject(delegate{new ProjectQaRunResult(82,"PROJECT_QA_ERROR","LOOPBACK_ONLY",null,error,1,1,1,null,ProjectQaExecutionStage.ProviderReturned,null,null,null,null,null,0);});
        }
        private static int Exit(string[] args, Factory f) { return new LocalOperatorRunner(f).Execute(args).ExitCode; }
        private static void Invalid(string[] args) { Factory f=new Factory(); Require(Exit(args,f)==64 && f.Total==0); }
        private static string TaskPayload(int exactBytes)
        {
            const string prefix="{\"schemaVersion\":1,\"status\":\"PASS\",\"x\":\"", suffix="\"}";
            int fill=exactBytes-Encoding.UTF8.GetByteCount(prefix)-Encoding.UTF8.GetByteCount(suffix); if(fill<0)throw new LocalOperatorException();
            string value=prefix+new string('A',fill)+suffix; Require(Encoding.UTF8.GetByteCount(value)==exactBytes); return value;
        }
        private static LocalOperatorExecutionResult Execute(string[] args,Factory f){return new LocalOperatorRunner(f).Execute(args);}
        private static string Text(LocalOperatorExecutionResult value){return Encoding.UTF8.GetString(value.Bytes);}
        private static void ErrorCase(string[] args,string status,int exit,string network)
        {
            Factory f=new Factory();f.Result=LocalOperatorAdapterResult.RawForTests(status,exit,network,null);LocalOperatorExecutionResult r=Execute(args,f);string s=Text(r);
            Require(r.ExitCode==exit&&f.Total==1&&s.IndexOf("\"status\":\""+status+"\"",StringComparison.Ordinal)>=0&&s.IndexOf("\"payload\":null",StringComparison.Ordinal)>=0&&s.EndsWith("\n",StringComparison.Ordinal));
        }
        private static void RequireReject(Action action){bool rejected=false;try{action();}catch(Exception){rejected=true;}Require(rejected);}
        private static void SetBacking(object target,string property,object value){FieldInfo f=target.GetType().GetField("<"+property+">k__BackingField",BindingFlags.Instance|BindingFlags.NonPublic);Require(f!=null);f.SetValue(target,value);}
        private static void TamperChain(int index,string h,string p)
        {
            OrchestrationChain chain=OrchestrationChain.Success(h,p,h);OrchestrationRoleResult item=index==40?chain.Results[4]:chain.Results[index-35];
            if(index==35)SetBacking(item,"RequestDigest",p);else if(index==36)SetBacking(item,"RouteDigest",h);else if(index==37)SetBacking(item,"PreviousResultDigest",p);else if(index==38)SetBacking(item,"EvidenceDigest",p);else if(index==40)SetBacking(item,"ResultDigest",p);
            RequireReject(delegate{chain.Validate();});
        }

        private static void RunCoreCases()
        {
            Case(Names[0], delegate{Require(LocalOperatorRequest.Parse(TaskMock("plan")).Capability==LocalOperatorCapability.Task);});
            Case(Names[1], delegate{Require(LocalOperatorRequest.Parse(new[]{"task","--provider","mock","--trace",Trace,"--goal","plan","--context-root","C:\\EAIRA"}).Root!=null);});
            Case(Names[2], delegate{Require(LocalOperatorRequest.Parse(TaskLocal("plan")).Provider=="OLLAMA_LOOPBACK_V1");});
            Case(Names[3], delegate{Require(LocalOperatorRequest.Parse(new[]{"task","--provider","ollama-local","--model","qwen3:4b","--trace",Trace,"--goal","plan","--context-root","C:\\EAIRA"}).Root!=null);});
            Case(Names[4], delegate{Require(LocalOperatorRequest.Parse(Knowledge("EAIRA")).Capability==LocalOperatorCapability.Knowledge);});
            Case(Names[5], delegate{Require(LocalOperatorRequest.Parse(Qa("EAIRA")).Capability==LocalOperatorCapability.ProjectQa);});
            string[][] invalids = new string[][] { null,new string[0],new[]{"other"},new[]{"Task"},new[]{"task","--provider"},new[]{"task","--provider","mock","--trace",Trace,"--goal","x","extra"},new[]{"task","--provider","mock","--trace",Trace,"--trace","x"},new[]{"task","--goal","x","--provider","mock","--trace",Trace},new[]{"knowledge","--root","C:\\EAIRA","--trace",Trace,"--goal","x"},new[]{"@args"},new[]{"task","--provider","real","--trace",Trace,"--goal","x"},new[]{"task","--provider","http://x","--trace",Trace,"--goal","x"},new[]{"task","--provider","ollama-local","--model","QWEN3:4B","--trace",Trace,"--goal","x"},new[]{"task","--provider","mock","--trace","A","--goal","x"},new[]{"task","--provider","mock","--trace",Trace.ToLowerInvariant(),"--goal","x"},TaskMock(""),Knowledge(""),Qa(""),new[]{"knowledge","--root","c:/bad","--trace",Trace,"--query","x"} };
            for(int i=0;i<invalids.Length;i++){int index=6+i;Case(Names[index],delegate{Invalid(invalids[index-6]);});}
            for(int i=25;i<=27;i++){int index=i;Case(Names[index],delegate{Factory f=new Factory();string[] a=index==25?TaskMock("write file"):index==26?Knowledge("write file"):Qa("write file");Require(Exit(a,f)==77&&f.Total==0);});}
            for(int i=28;i<=30;i++){int index=i;Case(Names[index],delegate{Factory f=new Factory();string[] a=index==28?TaskMock("plan"):index==29?Knowledge("EAIRA"):Qa("EAIRA");Require(Exit(a,f)==0&&f.Total==1);});}
            string h=new string('A',64); string p=new string('B',64);
            Case(Names[31],delegate{Require(OrchestrationChain.Success(h,p,h).Results.Count==5);});
            Case(Names[32],delegate{Require(OrchestrationChain.Denied(h,p).Results.Count==3);});
            Case(Names[33],delegate{foreach(var x in OrchestrationChain.Denied(h,p).Results)Require(x.Role!=OrchestrationRole.Operations);});
            Case(Names[34],delegate{foreach(var x in OrchestrationChain.Denied(h,p).Results)Require(x.Role!=OrchestrationRole.Verification);});
            for(int i=35;i<=40;i++){int index=i;Case(Names[index],delegate{if(index==39){LocalOperatorRequest r=LocalOperatorRequest.Parse(TaskMock("plan"));LocalOperatorRoute route=LocalOperatorRoute.Create(r);string payload=TaskPayload(64);RequireReject(delegate{LocalOperatorResponse.Build(r,route,"PASS",0,"NONE",payload,p,OrchestrationChain.Success(r.RequestDigest,route.Digest,p));});}else TamperChain(index,h,p);});}
            for(int i=41;i<96;i++){int index=i;Case(Names[index],delegate{Exercise(index,h,p);});}
        }

        private static void RunHealthCases()
        {
            string trace2="FFEEDDCCBBAA99887766554433221100";
            Case(Names[96],delegate{LocalOperatorRequest r=LocalOperatorRequest.Parse(Health(HealthTrace));Require(r.Capability==LocalOperatorCapability.Health&&r.CapabilityName=="HEALTH"&&r.Provider=="NONE"&&r.Model=="NONE"&&r.Root==null&&r.InputKind=="HEALTH"&&r.Input=="COMPILED CONTRACT STATUS"&&r.RequestDigest=="0E10A550738D8618EFB0C845E4E1C6357F11C64258BE78993E64791DC0456990");});
            Case(Names[97],delegate{LocalOperatorRoute r=LocalOperatorRoute.Create(LocalOperatorRequest.Parse(Health(HealthTrace)));Require(r.Capability=="HEALTH"&&r.Network=="NONE"&&r.Authority=="OBSERVATIONAL_NOT_AUTHORITY"&&r.PayloadContract=="EAIRA_OPERATOR_HEALTH_V1"&&r.CallBudget=="MODEL_COMPLETE=0;READS=0;TAGS=0;CHAT=0;FACTORIES=0"&&r.Digest=="613DCE7408D3B68CD51A2E1C01A51A0BA20E20A84B2BE20438319D102446B429");});
            Case(Names[98],delegate{Factory f=new Factory();string t=Text(Execute(Health(HealthTrace),f));Require(f.Total==0&&t.IndexOf(LocalOperatorHealth.CanonicalPayload,StringComparison.Ordinal)>=0&&t.IndexOf("9E3EFCDB24B49E2C27254772DFF72DEF88968ECF0A76C60D4E6724AE90E2E181",StringComparison.Ordinal)>=0);});
            Case(Names[99],delegate{Factory f=new Factory();LocalOperatorExecutionResult r=Execute(Health(HealthTrace),f);Require(r.ExitCode==0&&r.Bytes.Length==927&&ContractCodec.Sha256Hex(r.Bytes)=="8E7B9415938850843E23E933A82B6FCB07244AD8814706BB998C4C11D9D4D91A");});
            Case(Names[100],delegate{LocalOperatorConnectAttemptMonitor.ResetForTests();PositiveControlBefore=LocalOperatorConnectAttemptMonitor.Snapshot();LocalOperatorConnectAttemptMonitor.RecordForTests("TAGS");PositiveControlAfter=LocalOperatorConnectAttemptMonitor.Snapshot();Require(PositiveControlAfter-PositiveControlBefore==1);LocalOperatorConnectAttemptMonitor.ResetForTests();HealthBefore=LocalOperatorConnectAttemptMonitor.Snapshot();Factory f=new Factory();int exit=Exit(Health(HealthTrace),f);HealthAfter=LocalOperatorConnectAttemptMonitor.Snapshot();Require(exit==0&&f.Total==0&&HealthAfter-HealthBefore==0);});
            Case(Names[101],delegate{LocalOperatorConnectAttemptMonitor.ResetForTests();DenialBefore=LocalOperatorConnectAttemptMonitor.Snapshot();Factory f=new Factory();LocalOperatorRunner r=LocalOperatorRunner.CreateForTests(f,delegate(TaskEnvelope task){return AgentDecision.Deny;});LocalOperatorExecutionResult x=r.Execute(Health(HealthTrace));DenialAfter=LocalOperatorConnectAttemptMonitor.Snapshot();string t=Text(x);LocalOperatorRequest q=LocalOperatorRequest.Parse(Health(HealthTrace));LocalOperatorRoute route=LocalOperatorRoute.Create(q);HealthDenialExitCode=x.ExitCode;HealthDenialRoles=OrchestrationChain.Denied(q.RequestDigest,route.Digest).Results.Count;HealthDenialPayloadNull=t.IndexOf("\"payload\":null",StringComparison.Ordinal)>=0;HealthDenialFactoryCalls=f.Total;Require(HealthDenialExitCode==77&&HealthDenialFactoryCalls==0&&DenialAfter-DenialBefore==0&&HealthDenialPayloadNull&&t.IndexOf(OrchestrationChain.Denied(q.RequestDigest,route.Digest).ChainDigest,StringComparison.Ordinal)>=0&&HealthDenialRoles==3);});
            Case(Names[102],delegate{LocalOperatorRequest q=LocalOperatorRequest.Parse(Health(HealthTrace));LocalOperatorRoute route=LocalOperatorRoute.Create(q);Require(OrchestrationChain.Success(q.RequestDigest,route.Digest,"9E3EFCDB24B49E2C27254772DFF72DEF88968ECF0A76C60D4E6724AE90E2E181").Results.Count==5);});
            Case(Names[103],delegate{string a=Text(Execute(Health(HealthTrace),new Factory()));string b=Text(Execute(Health(trace2),new Factory()));Require(a.IndexOf(LocalOperatorHealth.CanonicalPayload,StringComparison.Ordinal)>=0&&b.IndexOf(LocalOperatorHealth.CanonicalPayload,StringComparison.Ordinal)>=0&&a.IndexOf("9E3EFCDB24B49E2C27254772DFF72DEF88968ECF0A76C60D4E6724AE90E2E181",StringComparison.Ordinal)>=0&&b.IndexOf("9E3EFCDB24B49E2C27254772DFF72DEF88968ECF0A76C60D4E6724AE90E2E181",StringComparison.Ordinal)>=0);});
            Case(Names[104],delegate{byte[] a=Execute(Health(HealthTrace),new Factory()).Bytes,b=Execute(Health(trace2),new Factory()).Bytes;Require(ContractCodec.Sha256Hex(a)!=ContractCodec.Sha256Hex(b));});
            string[][] invalids=new string[][]{new[]{"health"},new[]{"health","--trace",Trace.ToLowerInvariant()},new[]{"health","--trace","A"},new[]{"health","--trace",Trace+"A"},new[]{"health","--trace","00112233445566778899AABBCCDDEEFG"},new[]{"health","--trace",Trace,"x"},new[]{"health","--trace",Trace,"--trace"},new[]{"health",Trace,"--trace"},new[]{"@health"},new[]{"health","--trace",Trace,"--root","C:\\EAIRA"},new[]{"health","--trace",Trace,"--provider","ollama-local"}};
            for(int i=0;i<invalids.Length;i++){int index=105+i;Case(Names[index],delegate{Invalid(invalids[index-105]);});}
            Case(Names[116],delegate{LocalOperatorRequest q=LocalOperatorRequest.Parse(Health(HealthTrace));LocalOperatorRoute route=LocalOperatorRoute.Create(q);string bad=LocalOperatorHealth.CanonicalPayload.Replace("\"POLICY_READY\"","\"BAD\"");string d=LocalOperatorResponse.ComputePayloadDigest(Encoding.UTF8.GetBytes(bad));RequireReject(delegate{LocalOperatorResponse.Build(q,route,"PASS",0,"NONE",bad,d,OrchestrationChain.Success(q.RequestDigest,route.Digest,d));});});
            Case(Names[117],delegate{LocalOperatorRequest q=LocalOperatorRequest.Parse(Health(HealthTrace));LocalOperatorRoute route=LocalOperatorRoute.Create(q);SetBacking(route,"Authority","AUTHORITATIVE");RequireReject(delegate{LocalOperatorHealth.Validate(q,route,LocalOperatorHealth.CanonicalPayload,"9E3EFCDB24B49E2C27254772DFF72DEF88968ECF0A76C60D4E6724AE90E2E181");});});
            Case(Names[118],delegate{Factory a=new Factory(),b=new Factory(),c=new Factory(),d=new Factory();Require(Exit(TaskMock("plan"),a)==0&&Exit(Knowledge("EAIRA"),b)==0&&Exit(Qa("EAIRA"),c)==0&&Exit(Health(Trace),d)==0&&a.Total==1&&b.Total==1&&c.Total==1&&d.Total==0);});
        }

        private static void Exercise(int index,string h,string p)
        {
            if(index==41){Factory f=new Factory();Require(Exit(Knowledge("EAIRA"),f)==0&&f.KnowledgeCalls==1&&f.TaskCalls==0&&f.QaCalls==0);return;}
            if(index>=42&&index<=45){string mode=index==42?"SUCCESS":index==43?"PRE":index==44?"CHAT":"POST";ProjectQaRunResult x=ProjectQaRunner.Execute(QaLegacy("EAIRA"),new SnapshotFactory("SUCCESS"),new QaProviderFactory(mode),new ProjectQaExecutionObserver());Require(x.SnapshotFactoryCalls==1&&x.SnapshotReadCalls==1&&x.ProviderFactoryCalls==1);if(index==42){Require(x.ExitCode==0&&x.LastStage==ProjectQaExecutionStage.OutputReady&&x.TagsCalls==2&&x.ChatCalls==1&&x.PreflightDigestValidated&&x.PostflightDigestValidated&&x.CitationCount==0);VerifyQaClosure(x);}else if(index==43)Require(x.ExitCode==79&&x.TagsCalls==1&&x.ChatCalls==0&&!x.PreflightDigestValidated);else if(index==44)Require(x.ExitCode==79&&x.TagsCalls==1&&x.ChatCalls==1&&x.PreflightDigestValidated&&!x.PostflightDigestValidated);else Require(x.ExitCode==79&&x.TagsCalls==2&&x.ChatCalls==1&&x.PreflightDigestValidated&&!x.PostflightDigestValidated);return;}
            if(index==46){CountingModel m=new CountingModel();TaskEnvelope t=TaskEnvelope.Create(1,Trace,"plan bounded work");new MinimumFunctionalPipeline(m).Execute(t);Require(m.Calls==10&&m.Unique==2);return;}
            if(index==47){CountingLocalModel m=new CountingLocalModel();TaskEnvelope t=TaskEnvelope.Create(1,Trace,"plan bounded work");m.BeginRequest();try{new MinimumFunctionalPipeline(m).Execute(t,"BOUNDED CONTEXT",AgentDecision.Allow);}finally{m.EndRequest();}LocalOperatorRequest request=LocalOperatorRequest.Parse(new[]{"task","--provider","ollama-local","--model","qwen3:4b","--trace",Trace,"--goal","plan bounded work","--context-root","C:\\EAIRA"});LocalOperatorRoute route=LocalOperatorRoute.Create(request);Require(route.Capability=="TASK"&&route.Network=="LOOPBACK_ONLY"&&route.CallBudget=="COMPLETE_INVOCATIONS=6;UNIQUE_COMPLETIONS=2;TAGS=2;CHAT=2"&&m.Calls==6&&m.Unique==2&&m.BeginRequestCalls==1&&m.EndRequestCalls==1&&m.TagsCalls==2&&m.ChatCalls==2&&m.PreflightDigestValidated&&m.PostflightDigestValidated);return;}
            if(index>=48&&index<=58){string[] sentinels={"RAW_ROOT_SENTINEL","RAW_INPUT_SENTINEL","RAW_CONTENT_SENTINEL","RAW_PROMPT_SENTINEL","REQUEST_BODY_SENTINEL","PROVIDER_RESPONSE_SENTINEL","PER_FILE_DIGEST_SENTINEL","tool_calls","image","thinking","unknownMember"};string forbidden=sentinels[index-48];Factory f=new Factory();LocalOperatorExecutionResult r=Execute(TaskMock("plan"),f);Require(r.ExitCode==0&&Text(r).IndexOf(forbidden,StringComparison.Ordinal)<0);return;}
            if(index==59||index==60){Factory f=new Factory();string[][] order=index==59?new[]{TaskMock("plan"),Knowledge("EAIRA"),Qa("EAIRA")}:new[]{Qa("EAIRA"),Knowledge("EAIRA"),TaskMock("plan")};for(int i=0;i<order.Length;i++)Require(Exit(order[i],f)==0);Require(f.TaskCalls==1&&f.KnowledgeCalls==1&&f.QaCalls==1);return;}
            if(index>=61&&index<=66){int target=index==61?16382:index==62?16383:index==63?16384:index==64?16969:index==65?16970:16971;int payloadLength=index<=63?target:target-587;string value=TaskPayload(payloadLength);LocalOperatorRequest r=LocalOperatorRequest.Parse(TaskLocal("plan"));LocalOperatorRoute route=LocalOperatorRoute.Create(r);byte[] raw=Encoding.UTF8.GetBytes(value);string d=LocalOperatorResponse.ComputePayloadDigest(raw);bool failed=false;try{LocalOperatorExecutionResult e=LocalOperatorResponse.Build(r,route,"PASS",0,"LOOPBACK_ONLY",value,d,OrchestrationChain.Success(r.RequestDigest,route.Digest,d));if(index==64||index==65)Require(e.Bytes.Length==target);}catch(Exception){failed=true;}Require((index==63||index==66)==failed);return;}
            if(index==67){Factory f=new Factory();LocalOperatorExecutionResult r=Execute(TaskMock("plan"),f);string s=Text(r);Require(r.Bytes.Length>0&&s.EndsWith("\n",StringComparison.Ordinal)&&s.IndexOf('\n')==s.Length-1);return;}
            if(index==68){Factory f=new Factory();Require(Execute(TaskMock("plan"),f).ExitCode==0);return;}
            if(index==69){Factory f=new Factory();f.Result=LocalOperatorAdapterResult.RawForTests("PASS",0,"NONE","BAD");LocalOperatorRequest q=LocalOperatorRequest.Parse(TaskMock("plan"));LocalOperatorRoute route=LocalOperatorRoute.Create(q);string d=LocalOperatorResponse.ComputePayloadDigest(Encoding.UTF8.GetBytes("BAD"));string expected=OrchestrationChain.VerificationFailure(q.RequestDigest,route.Digest,"OUTPUT_ERROR",d).ChainDigest;LocalOperatorExecutionResult r=Execute(TaskMock("plan"),f);Require(r.ExitCode==84&&Text(r).IndexOf("BAD",StringComparison.Ordinal)<0&&Text(r).IndexOf(expected,StringComparison.Ordinal)>=0);return;}
            if(index==70){Factory f=new Factory();string a=Text(Execute(TaskMock("plan"),f));string b=Text(Execute(new[]{"task","--provider","mock","--trace",Trace,"--goal","plan2"},new Factory()));Require(a!=b&&a.IndexOf(Trace,StringComparison.Ordinal)>=0&&b.IndexOf(Trace,StringComparison.Ordinal)>=0);return;}
            if(index==71){int calls=0;Func<ProjectQaSnapshotReader> sf=delegate{calls++;return null;};ProjectQaRunResult invalid=ProjectQaRunner.Execute(new string[0],sf,new NullQaFactory());ProjectQaRunResult denied=ProjectQaRunner.Execute(new[]{"--root","C:\\EAIRA","--trace",Trace,"--question","write file","--provider","ollama-local","--model","qwen3:4b"},sf,new NullQaFactory());Require(invalid.ExitCode==64&&denied.ExitCode==77&&calls==0&&Encoding.UTF8.GetString(denied.CompleteLegacyLine)=="{\"schema\":\"EAIRA_PROJECT_QA_ERROR_V1\",\"status\":\"DENIED\",\"network\":\"NONE\",\"writes\":\"NONE\"}\n");return;}
            if(index>=72&&index<=85)
            {
                if(index==72){Invalid(TaskMock(""));return;}
                if(index==73){ErrorCase(TaskMock("plan"),"PROVIDER_ERROR",79,"NONE");return;}
                if(index==74){ErrorCase(TaskMock("plan"),"CONTEXT_ERROR",80,"NONE");return;}
                if(index==75){Factory f=new Factory();Require(Exit(Knowledge("write file"),f)==77&&f.Total==0);return;}
                if(index==76){Invalid(Knowledge(""));return;}
                if(index==77){ErrorCase(Knowledge("EAIRA"),"KNOWLEDGE_ERROR",81,"NONE");return;}
                if(index==78){Factory f=new Factory();Require(Exit(Qa("write file"),f)==77&&f.Total==0);return;}
                if(index==79){Invalid(Qa(""));return;}
                if(index>=80&&index<=83){string sm=index==81?"CONTEXT":index==82?"KNOWLEDGE":"SUCCESS";string pm=index==80?"PRE":index==83?"DECODE":"SUCCESS";RunnerQaAdapter a=new RunnerQaAdapter(sm,pm);Factory f=new Factory();f.QaAdapter=a;int expected=index==80?79:index==81?80:index==82?81:82;Require(Exit(Qa("EAIRA"),f)==expected&&f.QaCalls==1&&a.LastResult!=null);return;}
                if(index==84){Factory f=new Factory();f.Result=LocalOperatorAdapterResult.RawForTests("UNKNOWN",1,"LOOPBACK_ONLY",null);Require(Exit(TaskMock("plan"),f)==83);return;}
                Factory bad=new Factory();bad.Result=LocalOperatorAdapterResult.RawForTests("PASS",0,"NONE","BAD");Require(Exit(TaskMock("plan"),bad)==84);return;
            }
            if(index>=86&&index<=88){Invalid(new[]{index==86?"-":index==87?"%EAIRA%":"config"});return;}
            if(index>=89&&index<=95)
            {
                string sm=index==89?"FACTORY":index==90?"CONTEXT":index==91?"KNOWLEDGE":index==92?"PROMPT":index==93?"BODY":"SUCCESS";string pm=index==94?"FACTORY_QA":index==95?"DECODE":"SUCCESS";RunnerQaAdapter a=new RunnerQaAdapter(sm,pm);Factory f=new Factory();f.QaAdapter=a;
                int expected=index==89?83:index==90?80:index==91?81:82;string outer=index==89?"ORCHESTRATION_ERROR":index==90?"CONTEXT_ERROR":index==91?"KNOWLEDGE_ERROR":"QA_VALIDATION_ERROR";string network=index>=94?"LOOPBACK_ONLY":"NONE";
                LocalOperatorExecutionResult x=Execute(Qa("EAIRA"),f);string text=Text(x);LocalOperatorRequest request=LocalOperatorRequest.Parse(Qa("EAIRA"));LocalOperatorRoute route=LocalOperatorRoute.Create(request);OrchestrationChain chain=index==89?OrchestrationChain.Emergency(request.RequestDigest,route.Digest):OrchestrationChain.OperationFailure(request.RequestDigest,route.Digest,outer);
                Require(x.ExitCode==expected&&f.QaCalls==1&&a.Observer!=null&&text.IndexOf("\"status\":"+ContractCodec.Json(outer),StringComparison.Ordinal)>=0&&text.IndexOf("\"network\":"+ContractCodec.Json(network),StringComparison.Ordinal)>=0&&text.IndexOf("\"payload\":null",StringComparison.Ordinal)>=0&&text.IndexOf(chain.ChainDigest,StringComparison.Ordinal)>=0);
                if(index==89){Require(a.LastResult==null&&a.Snapshot!=null&&a.Snapshot.Calls==1&&a.Observer.LastStage==ProjectQaExecutionStage.SnapshotFactoryCalled&&a.Observer.TagsCalls==0&&a.Observer.ChatCalls==0&&!a.Observer.PreflightDigestValidated&&!a.Observer.PostflightDigestValidated);return;}
                Require(a.LastResult!=null);ProjectQaExecutionStage stage=index==90||index==91?ProjectQaExecutionStage.SnapshotReadCalled:index==92?ProjectQaExecutionStage.SnapshotReady:index==93?ProjectQaExecutionStage.PromptReady:index==94?ProjectQaExecutionStage.ProviderFactoryCalled:ProjectQaExecutionStage.ProviderReturned;
                ProjectQaRunResult q=a.LastResult;Require(q.ExitCode==expected&&a.Snapshot!=null&&a.Snapshot.Calls==1&&q.LastStage==stage&&q.SnapshotFactoryCalls==1&&q.SnapshotReadCalls==1&&q.ProviderFactoryCalls==(index>=94?1:0)&&q.Network==network&&q.Status==(index==90?"CONTEXT_ERROR":index==91?"KNOWLEDGE_ERROR":"PROJECT_QA_ERROR"));
                if(index==95)Require(q.TagsCalls==2&&q.ChatCalls==1&&q.PreflightDigestValidated&&q.PostflightDigestValidated);else Require(q.TagsCalls==0&&q.ChatCalls==0&&!q.PreflightDigestValidated&&!q.PostflightDigestValidated);return;
            }
            else throw new LocalOperatorException();
        }

        private static string CaseJson()
        {
            StringBuilder b=new StringBuilder("[");for(int i=0;i<Passed.Count;i++){if(i!=0)b.Append(',');b.Append(ContractCodec.Json(Passed[i]));}return b.Append(']').ToString();
        }
        private static string Framed(out int bytes)
        {
            string value="EAIRA_M5_SLICE2_CASE_NAMES_V1\0";foreach(string n in Passed)value+=ContractCodec.Field(n);bytes=Encoding.UTF8.GetByteCount(value);return ContractCodec.Sha256Hex(value);
        }
        private static string LegacyFramed(out int bytes){string value="EAIRA_M5_SLICE1_CASE_NAMES_V1\0";for(int i=0;i<96;i++)value+=ContractCodec.Field(Passed[i]);bytes=Encoding.UTF8.GetByteCount(value);return ContractCodec.Sha256Hex(value);}
        internal static int Main(string[] args)
        {
            try
            {
                byte[] cachedTelemetry=Encoding.UTF8.GetBytes("{\"model\":\"qwen3:4b\",\"message\":{\"role\":\"assistant\",\"content\":\"x\"},\"done\":true,\"prompt_eval_count\":8,\"prompt_eval_cached_count\":7,\"eval_count\":1}");
                if(Encoding.UTF8.GetString(LocalOperatorOllamaResponseCompatibility.Normalize(cachedTelemetry))!="{\"model\":\"qwen3:4b\",\"message\":{\"role\":\"assistant\",\"content\":\"x\"},\"done\":true,\"prompt_eval_count\":8,\"eval_count\":1}")throw new ContractException("Cached telemetry normalization failed.");
                bool wrongTelemetryTypeRejected=false;try{LocalOperatorOllamaResponseCompatibility.Normalize(Encoding.UTF8.GetBytes("{\"model\":\"qwen3:4b\",\"message\":{\"role\":\"assistant\",\"content\":\"x\"},\"done\":true,\"prompt_eval_cached_count\":\"7\"}"));}catch(LocalProviderException){wrongTelemetryTypeRejected=true;}if(!wrongTelemetryTypeRejected)throw new ContractException("Non-numeric cached telemetry was accepted.");
                if(args==null||args.Length!=1||args[0]!="--self-test")return 64;RunCoreCases();RunHealthCases();Require(Passed.Count==119);int framed,legacyBytes;string digest=Framed(out framed),legacyDigest=LegacyFramed(out legacyBytes);Require(framed==3095&&digest=="198B2B892C9E6516B50B2C2CAF86AABA058B4D8B0D335AD445DC8685230F8A86"&&legacyBytes==2409&&legacyDigest=="0AAF52EE6A087B487B6497676F48BA7AD0D36CB987C149CC1BADAD9CA5D2FE68");
                Console.Write("{\"schema\":\"EAIRA_LOCAL_OPERATOR_HARNESS_V1\",\"status\":\"PASS\",\"testsPassed\":119,\"caseNames\":"+CaseJson()+",\"caseNameFramedBytes\":3095,\"caseNameSha256\":\""+digest+"\",\"legacyTestsPassed\":96,\"legacyCaseNameFramedBytes\":2409,\"legacyCaseNameSha256\":\""+legacyDigest+"\",\"healthGuardDenial\":{\"exitCode\":"+HealthDenialExitCode+",\"roles\":"+HealthDenialRoles+",\"payloadNull\":"+(HealthDenialPayloadNull?"true":"false")+",\"factoryCalls\":"+HealthDenialFactoryCalls+",\"connectAttemptDelta\":"+(DenialAfter-DenialBefore)+"},\"healthConnectAttemptMonitor\":{\"positiveControlBefore\":"+PositiveControlBefore+",\"positiveControlAfter\":"+PositiveControlAfter+",\"positiveControlDelta\":"+(PositiveControlAfter-PositiveControlBefore)+",\"healthBefore\":"+HealthBefore+",\"healthAfter\":"+HealthAfter+",\"healthDelta\":"+(HealthAfter-HealthBefore)+",\"denialBefore\":"+DenialBefore+",\"denialAfter\":"+DenialAfter+",\"denialDelta\":"+(DenialAfter-DenialBefore)+"},\"wrapperMaximumBytes\":587,\"network\":\"NONE\",\"writes\":\"NONE\"}\n");return 0;
            }
            catch(Exception){int framed;string digest=Framed(out framed);Console.Write("{\"schema\":\"EAIRA_LOCAL_OPERATOR_HARNESS_V1\",\"status\":\"FAIL\",\"testsPassed\":"+Passed.Count+",\"caseNames\":"+CaseJson()+",\"caseNameFramedBytes\":"+framed+",\"caseNameSha256\":\""+digest+"\",\"wrapperMaximumBytes\":587,\"network\":\"NONE\",\"writes\":\"NONE\"}\n");return 1;}
        }
    }
}
