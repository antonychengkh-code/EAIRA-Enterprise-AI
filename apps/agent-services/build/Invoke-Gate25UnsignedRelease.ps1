[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$RoslynCscPath,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$OutputRoot,

    [ValidateNotNullOrEmpty()]
    [string]$ReferenceAssemblyRoot = 'C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.8',

    [switch]$DevelopmentProbe,

    [switch]$ProjectKnowledgeDiscovery,

    [switch]$ProjectQaDiscovery,

    [switch]$LocalOperatorDiscovery,

    [switch]$LocalOperatorPreflightDiscovery,

    [switch]$LocalOperatorDryRunDiscovery,

    [ValidatePattern('^[0-9A-F]{64}$')]
    [string]$ExpectedReleaseProfileSha256
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
Add-Type -AssemblyName System.Reflection.Metadata
$script:EairaHealthIlInspectorSource = @'
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Reflection.Emit;
using System.Reflection.Metadata;
using System.Reflection.Metadata.Ecma335;
using System.Reflection.PortableExecutable;
using System.Security.Cryptography;
using System.Text;

public static class EairaHealthIlInspector
{
    sealed class GenericContext { }
    sealed class TypeProvider : ISignatureTypeProvider<string, GenericContext>
    {
        readonly MetadataReader r;
        internal TypeProvider(MetadataReader reader) { r = reader; }
        string TypeDef(TypeDefinitionHandle h) { var d=r.GetTypeDefinition(h); var n=r.GetString(d.Name); var p=d.GetDeclaringType(); if(!p.IsNil)return TypeDef(p)+"+"+n; var s=r.GetString(d.Namespace); return String.IsNullOrEmpty(s)?n:s+"."+n; }
        string TypeRef(TypeReferenceHandle h) { var d=r.GetTypeReference(h); var n=r.GetString(d.Name); if(d.ResolutionScope.Kind==HandleKind.TypeReference)return TypeRef((TypeReferenceHandle)d.ResolutionScope)+"+"+n; var s=r.GetString(d.Namespace); return String.IsNullOrEmpty(s)?n:s+"."+n; }
        public string GetArrayType(string e, ArrayShape s) { return e+"["+new string(',',Math.Max(0,s.Rank-1))+"]"; }
        public string GetByReferenceType(string e) { return e+"&"; }
        public string GetFunctionPointerType(MethodSignature<string> s) { return "FNPTR:"+CallSite(s); }
        public string GetGenericInstantiation(string g, ImmutableArray<string> a) { return g+"<"+String.Join(",",a)+">"; }
        public string GetGenericMethodParameter(GenericContext c, int i) { return "!!"+i.ToString(CultureInfo.InvariantCulture); }
        public string GetGenericTypeParameter(GenericContext c, int i) { return "!"+i.ToString(CultureInfo.InvariantCulture); }
        public string GetModifiedType(string m, string u, bool req) { return u; }
        public string GetPinnedType(string e) { return "PINNED:"+e; }
        public string GetPointerType(string e) { return e+"*"; }
        public string GetPrimitiveType(PrimitiveTypeCode c) { switch(c){case PrimitiveTypeCode.Void:return "System.Void";case PrimitiveTypeCode.Boolean:return "System.Boolean";case PrimitiveTypeCode.Char:return "System.Char";case PrimitiveTypeCode.SByte:return "System.SByte";case PrimitiveTypeCode.Byte:return "System.Byte";case PrimitiveTypeCode.Int16:return "System.Int16";case PrimitiveTypeCode.UInt16:return "System.UInt16";case PrimitiveTypeCode.Int32:return "System.Int32";case PrimitiveTypeCode.UInt32:return "System.UInt32";case PrimitiveTypeCode.Int64:return "System.Int64";case PrimitiveTypeCode.UInt64:return "System.UInt64";case PrimitiveTypeCode.Single:return "System.Single";case PrimitiveTypeCode.Double:return "System.Double";case PrimitiveTypeCode.String:return "System.String";case PrimitiveTypeCode.TypedReference:return "System.TypedReference";case PrimitiveTypeCode.IntPtr:return "System.IntPtr";case PrimitiveTypeCode.UIntPtr:return "System.UIntPtr";case PrimitiveTypeCode.Object:return "System.Object";default:throw new InvalidDataException("Unsupported primitive type.");} }
        public string GetSZArrayType(string e) { return e+"[]"; }
        public string GetTypeFromDefinition(MetadataReader x, TypeDefinitionHandle h, byte k) { return TypeDef(h); }
        public string GetTypeFromReference(MetadataReader x, TypeReferenceHandle h, byte k) { return TypeRef(h); }
        public string GetTypeFromSpecification(MetadataReader x, GenericContext c, TypeSpecificationHandle h, byte k) { return r.GetTypeSpecification(h).DecodeSignature(this,c); }
        internal string Entity(EntityHandle h) { if(h.IsNil)return null; switch(h.Kind){case HandleKind.TypeDefinition:return TypeDef((TypeDefinitionHandle)h);case HandleKind.TypeReference:return TypeRef((TypeReferenceHandle)h);case HandleKind.TypeSpecification:return r.GetTypeSpecification((TypeSpecificationHandle)h).DecodeSignature(this,new GenericContext());default:throw new InvalidDataException("Unsupported type handle "+h.Kind); } }
        internal static string CallSite(MethodSignature<string> s) { var b=BaseConvention(s.Header.CallingConvention); if(s.Header.IsInstance)b+="+INSTANCE"; if((s.Header.RawValue&0x40)!=0)b+="+EXPLICITTHIS"; return "callsite|"+b+"|"+s.GenericParameterCount.ToString(CultureInfo.InvariantCulture)+"|"+s.ReturnType+"|"+String.Join(",",s.ParameterTypes); }
        static string BaseConvention(SignatureCallingConvention c) { switch(c){case SignatureCallingConvention.Default:return "DEFAULT";case SignatureCallingConvention.VarArgs:return "VARARG";case SignatureCallingConvention.CDecl:return "C";case SignatureCallingConvention.StdCall:return "STDCALL";case SignatureCallingConvention.ThisCall:return "THISCALL";case SignatureCallingConvention.FastCall:return "FASTCALL";default:throw new InvalidDataException("Unsupported calling convention.");} }
    }
    sealed class MethodInfoRow { internal int Token; internal string Type,Name,Full; internal MethodDefinitionHandle Handle; internal MethodDefinition Def; internal List<Instruction> Instructions; internal string[] Details; internal ExceptionRegion[] Regions; }
    sealed class FieldInfoRow { internal int Token; internal string Type,Name,FieldType,Full; internal FieldDefinitionHandle Handle; }
    sealed class Instruction { internal int Offset,End; internal OpCode Op; internal string Kind,Value,Target; internal int[] BranchTargets=new int[0]; internal EntityHandle Entity; }
    sealed class Block { internal int Start,End; internal List<Instruction> I=new List<Instruction>(); internal List<int> Succ=new List<int>(); }
    static readonly Dictionary<ushort,OpCode> Ops=BuildOps();
    static Dictionary<ushort,OpCode> BuildOps(){var d=new Dictionary<ushort,OpCode>();foreach(var f in typeof(OpCodes).GetFields(BindingFlags.Public|BindingFlags.Static)){var o=(OpCode)f.GetValue(null);d[unchecked((ushort)o.Value)]=o;}return d;}
    static string Sha(byte[] b){using(var h=SHA256.Create())return BitConverter.ToString(h.ComputeHash(b)).Replace("-","");}
    static string SummarySha(IEnumerable<string> rows){return Sha(Encoding.UTF8.GetBytes(String.Join("\n",rows)));}
    static string Hex8(int n){return unchecked((uint)n).ToString("X8",CultureInfo.InvariantCulture);}
    static string MethodName(TypeProvider p, MetadataReader r, string type, MethodDefinition d){var s=d.DecodeSignature(p,new GenericContext());return type+"::"+r.GetString(d.Name)+"("+String.Join(",",s.ParameterTypes)+")";}
    static string MemberName(TypeProvider p, MetadataReader r, MemberReferenceHandle h){var m=r.GetMemberReference(h);string t=null;if(m.Parent.Kind==HandleKind.TypeDefinition||m.Parent.Kind==HandleKind.TypeReference||m.Parent.Kind==HandleKind.TypeSpecification)t=p.Entity((EntityHandle)m.Parent);else if(m.Parent.Kind==HandleKind.MethodDefinition)t="METHOD_PARENT";if(m.GetKind()==MemberReferenceKind.Method){var s=m.DecodeMethodSignature(p,new GenericContext());return t+"::"+r.GetString(m.Name)+"("+String.Join(",",s.ParameterTypes)+")";}return t+"::"+r.GetString(m.Name)+":"+m.DecodeFieldSignature(p,new GenericContext());}
    static string MethodSpecName(TypeProvider p, MetadataReader r, MethodSpecificationHandle h, Dictionary<int,MethodInfoRow> methods){var s=r.GetMethodSpecification(h);string b=ResolveMethod(p,r,(EntityHandle)s.Method,methods);var a=s.DecodeSignature(p,new GenericContext());int x=b.IndexOf('(');return (x<0?b:b.Substring(0,x))+"<"+String.Join(",",a)+">"+(x<0?"":b.Substring(x));}
    static string ResolveMethod(TypeProvider p,MetadataReader r,EntityHandle h,Dictionary<int,MethodInfoRow> methods){int t=MetadataTokens.GetToken(h);if(h.Kind==HandleKind.MethodDefinition)return methods[t].Full;if(h.Kind==HandleKind.MemberReference)return MemberName(p,r,(MemberReferenceHandle)h);if(h.Kind==HandleKind.MethodSpecification)return MethodSpecName(p,r,(MethodSpecificationHandle)h,methods);throw new InvalidDataException("Unresolved method token.");}
    static string ResolveField(TypeProvider p,MetadataReader r,EntityHandle h,Dictionary<int,FieldInfoRow> fields){int t=MetadataTokens.GetToken(h);if(h.Kind==HandleKind.FieldDefinition)return fields[t].Full;if(h.Kind==HandleKind.MemberReference)return MemberName(p,r,(MemberReferenceHandle)h);throw new InvalidDataException("Unresolved field token.");}
    static string ResolveToken(TypeProvider p,MetadataReader r,EntityHandle h,Dictionary<int,MethodInfoRow> methods,Dictionary<int,FieldInfoRow> fields){if(h.Kind==HandleKind.MethodDefinition||h.Kind==HandleKind.MethodSpecification)return ResolveMethod(p,r,h,methods);if(h.Kind==HandleKind.MemberReference){var m=r.GetMemberReference((MemberReferenceHandle)h);return m.GetKind()==MemberReferenceKind.Method?ResolveMethod(p,r,h,methods):ResolveField(p,r,h,fields);}if(h.Kind==HandleKind.FieldDefinition)return ResolveField(p,r,h,fields);if(h.Kind==HandleKind.TypeDefinition||h.Kind==HandleKind.TypeReference||h.Kind==HandleKind.TypeSpecification)return p.Entity(h);throw new InvalidDataException("Unresolved token kind.");}
    static ushort U16(byte[] b,int o){return BitConverter.ToUInt16(b,o);} static int I32(byte[] b,int o){return BitConverter.ToInt32(b,o);} static long I64(byte[] b,int o){return BitConverter.ToInt64(b,o);}
    static List<Instruction> Decode(byte[] il,TypeProvider p,MetadataReader r,Dictionary<int,MethodInfoRow> methods,Dictionary<int,FieldInfoRow> fields){var a=new List<Instruction>();int o=0;while(o<il.Length){int start=o;ushort code=il[o++];if(code==0xFE){if(o>=il.Length)throw new InvalidDataException("Truncated opcode.");code=(ushort)(0xFE00|il[o++]);}OpCode op;if(!Ops.TryGetValue(code,out op))throw new InvalidDataException("Unknown opcode.");var q=new Instruction{Offset=start,Op=op};int token;switch(op.OperandType){case OperandType.InlineNone:q.Kind="none";q.Value="-";break;case OperandType.ShortInlineI:q.Kind="i1";q.Value=unchecked((sbyte)il[o]).ToString(CultureInfo.InvariantCulture);o++;break;case OperandType.InlineI:q.Kind="i4";q.Value=I32(il,o).ToString(CultureInfo.InvariantCulture);o+=4;break;case OperandType.InlineI8:q.Kind="i8";q.Value=I64(il,o).ToString(CultureInfo.InvariantCulture);o+=8;break;case OperandType.ShortInlineR:q.Kind="r4";q.Value=BitConverter.ToString(il,o,4).Replace("-","");o+=4;break;case OperandType.InlineR:q.Kind="r8";q.Value=BitConverter.ToString(il,o,8).Replace("-","");o+=8;break;case OperandType.ShortInlineVar:q.Kind="var";q.Value=il[o++].ToString(CultureInfo.InvariantCulture);break;case OperandType.InlineVar:q.Kind="var";q.Value=U16(il,o).ToString(CultureInfo.InvariantCulture);o+=2;break;case OperandType.ShortInlineBrTarget:{int d=unchecked((sbyte)il[o]);o++;int x=o+d;q.Kind="branch";q.Value=Hex8(x);q.BranchTargets=new[]{x};break;}case OperandType.InlineBrTarget:{int d=I32(il,o);o+=4;int x=o+d;q.Kind="branch";q.Value=Hex8(x);q.BranchTargets=new[]{x};break;}case OperandType.InlineSwitch:{int n=I32(il,o);o+=4;if(n<0||o+4*n>il.Length)throw new InvalidDataException("Bad switch.");var ds=new int[n];for(int i=0;i<n;i++){ds[i]=I32(il,o);o+=4;}int b=o;var xs=ds.Select(x=>b+x).ToArray();q.Kind="switch";q.Value=String.Join(",",xs.Select(Hex8));q.BranchTargets=xs;break;}case OperandType.InlineString:token=I32(il,o);o+=4;var us=r.GetUserString(MetadataTokens.UserStringHandle(token&0x00FFFFFF));var ub=Encoding.UTF8.GetBytes(us);q.Kind="string";q.Value=ub.Length.ToString(CultureInfo.InvariantCulture)+":"+Sha(ub);break;case OperandType.InlineMethod:token=I32(il,o);o+=4;q.Entity=(EntityHandle)MetadataTokens.Handle(token);q.Kind="method";q.Value=ResolveMethod(p,r,q.Entity,methods);q.Target=q.Value;break;case OperandType.InlineField:token=I32(il,o);o+=4;q.Entity=(EntityHandle)MetadataTokens.Handle(token);q.Kind="field";q.Value=ResolveField(p,r,q.Entity,fields);break;case OperandType.InlineType:token=I32(il,o);o+=4;q.Entity=(EntityHandle)MetadataTokens.Handle(token);q.Kind="type";q.Value=p.Entity(q.Entity);break;case OperandType.InlineSig:token=I32(il,o);o+=4;var ss=r.GetStandaloneSignature(MetadataTokens.StandaloneSignatureHandle(token&0x00FFFFFF)).DecodeMethodSignature(p,new GenericContext());q.Kind="signature";q.Value=TypeProvider.CallSite(ss);break;case OperandType.InlineTok:token=I32(il,o);o+=4;q.Entity=(EntityHandle)MetadataTokens.Handle(token);q.Kind="token";q.Value=ResolveToken(p,r,q.Entity,methods,fields);if(q.Entity.Kind==HandleKind.MethodDefinition||q.Entity.Kind==HandleKind.MethodSpecification||(q.Entity.Kind==HandleKind.MemberReference&&r.GetMemberReference((MemberReferenceHandle)q.Entity).GetKind()==MemberReferenceKind.Method))q.Target=q.Value;break;default:throw new InvalidDataException("Unsupported operand kind "+op.OperandType);}q.End=o;a.Add(q);}return a;}
    static string[] Details(PEReader pe,MetadataReader r,TypeProvider p,MethodInfoRow m){var body=pe.GetMethodBody(m.Def.RelativeVirtualAddress);var il=body.GetILBytes();m.Instructions=Decode(il,p,r,_methods,_fields);string header=(pe.GetSectionData(m.Def.RelativeVirtualAddress).GetContent()[0]&3)==2?"tiny":"fat";var rows=new List<string>();rows.Add("BODY|"+m.Full+"|"+header+"|"+body.MaxStack.ToString(CultureInfo.InvariantCulture)+"|"+(body.LocalVariablesInitialized?"TRUE":"FALSE"));if(body.LocalSignature.IsNil)rows.Add("LOCALS|"+m.Full+"|0|-");else{var ls=r.GetStandaloneSignature(body.LocalSignature).DecodeLocalSignature(p,new GenericContext());var vals=ls.Select(x=>x.StartsWith("PINNED:",StringComparison.Ordinal)?x:"VALUE:"+x).ToArray();rows.Add("LOCALS|"+m.Full+"|"+vals.Length.ToString(CultureInfo.InvariantCulture)+"|"+String.Join(",",vals));}foreach(var i in m.Instructions)rows.Add("IL|"+m.Full+"|"+Hex8(i.Offset)+"|"+i.Op.Name.ToLowerInvariant()+"|"+i.Kind+"|"+i.Value);var er=body.ExceptionRegions.ToArray();m.Regions=er;var eh=new List<string>();foreach(var e in er){string k=e.Kind==ExceptionRegionKind.Catch?"catch":e.Kind==ExceptionRegionKind.Finally?"finally":e.Kind==ExceptionRegionKind.Fault?"fault":"filter";string tail=e.Kind==ExceptionRegionKind.Catch?p.Entity(e.CatchType):e.Kind==ExceptionRegionKind.Filter?Hex8(e.FilterOffset):"-";eh.Add(k+"|"+Hex8(e.TryOffset)+"|"+Hex8(e.TryOffset+e.TryLength)+"|"+Hex8(e.HandlerOffset)+"|"+Hex8(e.HandlerOffset+e.HandlerLength)+"|"+tail);}eh.Sort(StringComparer.Ordinal);for(int i=0;i<eh.Count;i++)rows.Add("EH|"+m.Full+"|"+i.ToString(CultureInfo.InvariantCulture)+"|"+eh[i]);m.Details=rows.ToArray();return m.Details;}
    static Dictionary<int,MethodInfoRow> _methods; static Dictionary<int,FieldInfoRow> _fields;
    static List<Block> Blocks(MethodInfoRow m){var starts=new SortedSet<int>();starts.Add(0);foreach(var i in m.Instructions){foreach(var t in i.BranchTargets)starts.Add(t);if(i.Op.FlowControl==FlowControl.Branch||i.Op.FlowControl==FlowControl.Cond_Branch||i.Op.FlowControl==FlowControl.Return||i.Op.FlowControl==FlowControl.Throw)if(i.End<m.Instructions.Last().End)starts.Add(i.End);}foreach(var e in m.Regions){starts.Add(e.TryOffset);starts.Add(e.TryOffset+e.TryLength);starts.Add(e.HandlerOffset);starts.Add(e.HandlerOffset+e.HandlerLength);if(e.Kind==ExceptionRegionKind.Filter)starts.Add(e.FilterOffset);}var ss=starts.Where(x=>x>=0&&x<=m.Instructions.Last().End).ToArray();var bs=new List<Block>();for(int z=0;z<ss.Length;z++){int end=z+1<ss.Length?ss[z+1]:m.Instructions.Last().End;var b=new Block{Start=ss[z],End=end,I=m.Instructions.Where(x=>x.Offset>=ss[z]&&x.Offset<end).ToList()};if(b.I.Count>0)bs.Add(b);}var map=bs.ToDictionary(x=>x.Start);foreach(var b in bs){var last=b.I.Last();foreach(var t in last.BranchTargets)if(map.ContainsKey(t))b.Succ.Add(t);if(last.Op.FlowControl!=FlowControl.Branch&&last.Op.FlowControl!=FlowControl.Return&&last.Op.FlowControl!=FlowControl.Throw&&map.ContainsKey(last.End))b.Succ.Add(last.End);}return bs;}
    static HashSet<int> Reach(List<Block> bs,int root){var map=bs.ToDictionary(x=>x.Start);var s=new HashSet<int>();var q=new Queue<int>();q.Enqueue(root);while(q.Count>0){int x=q.Dequeue();if(!s.Add(x))continue;foreach(var y in map[x].Succ)if(map.ContainsKey(y))q.Enqueue(y);}return s;}
    static Dictionary<int,HashSet<int>> Dominators(List<Block> bs,int root,HashSet<int> reach){var all=new HashSet<int>(reach);var d=new Dictionary<int,HashSet<int>>();foreach(int x in reach)d[x]=x==root?new HashSet<int>{root}:new HashSet<int>(all);bool changed=true;while(changed){changed=false;foreach(int x in reach.Where(x=>x!=root)){var preds=bs.Where(b=>reach.Contains(b.Start)&&b.Succ.Contains(x)).Select(b=>b.Start).ToArray();if(preds.Length==0)throw new InvalidDataException("Unreachable CFG block.");var n=new HashSet<int>(d[preds[0]]);foreach(int p in preds.Skip(1))n.IntersectWith(d[p]);n.Add(x);if(!n.SetEquals(d[x])){d[x]=n;changed=true;}}}return d;}
    static void ValidateDispatch(MethodInfoRow m,string healthRoot){if(m.Regions.Any(e=>e.Kind==ExceptionRegionKind.Finally||e.Kind==ExceptionRegionKind.Fault))throw new InvalidDataException("Execute contains finally/fault.");var bs=Blocks(m);var reach=Reach(bs,0);var dom=Dominators(bs,0,reach);Func<string,Block[]> calls=t=>bs.Where(b=>b.I.Any(i=>i.Target==t)).ToArray();string guard="EAIRA.AgentServices.Functional.GuardAgent::ExpectedDecision(EAIRA.AgentServices.Functional.TaskEnvelope)";var gb=calls(guard);var hb=calls(healthRoot);if(gb.Length!=1||hb.Length!=1)throw new InvalidDataException("Guard/Health dispatch call count mismatch.");var selectors=bs.Where(b=>b.I.Any(i=>i.Target=="EAIRA.AgentServices.Functional.LocalOperatorRequest::get_Capability()")&&b.I.Any(i=>i.Op.Name=="ldc.i4.4")&&b.I.Any(i=>i.Op.FlowControl==FlowControl.Cond_Branch)).ToArray();if(selectors.Length!=1||!dom[selectors[0].Start].Contains(gb[0].Start)||!dom[hb[0].Start].Contains(gb[0].Start)||!dom[hb[0].Start].Contains(selectors[0].Start))throw new InvalidDataException("Health Guard dominance mismatch: guard="+gb.Length+" health="+hb.Length+" selectors="+selectors.Length+" guardBlocks="+String.Join(",",gb.Select(x=>Hex8(x.Start)))+" healthBlocks="+String.Join(",",hb.Select(x=>Hex8(x.Start)))+" selectorBlocks="+String.Join(",",selectors.Select(x=>Hex8(x.Start)))+".");int[] protectedOffsets={gb[0].Start,selectors[0].Start,hb[0].Start};foreach(var e in m.Regions)foreach(int x in protectedOffsets)if((x>=e.TryOffset&&x<e.TryOffset+e.TryLength)||(x>=e.HandlerOffset&&x<e.HandlerOffset+e.HandlerLength)||(e.Kind==ExceptionRegionKind.Filter&&x>=e.FilterOffset&&x<e.HandlerOffset))throw new InvalidDataException("Health dispatch lies in EH region.");var hreach=Reach(bs,hb[0].Start);if(hreach.SelectMany(x=>bs.First(b=>b.Start==x).I).Any(i=>i.Target!=null&&(i.Target.Contains("::CreateTask(")||i.Target.Contains("::CreateKnowledge(")||i.Target.Contains("::CreateProjectQa("))))throw new InvalidDataException("Factory reachable from Health dispatch.");}
    static string DeclaringType(EntityHandle h,MetadataReader r,TypeProvider p,Dictionary<int,MethodInfoRow> methods,Dictionary<int,FieldInfoRow> fields){if(h.IsNil)return null;if(h.Kind==HandleKind.MethodDefinition)return methods[MetadataTokens.GetToken(h)].Type;if(h.Kind==HandleKind.FieldDefinition)return fields[MetadataTokens.GetToken(h)].Type;if(h.Kind==HandleKind.TypeDefinition)return p.Entity(h);if(h.Kind==HandleKind.MethodSpecification)return DeclaringType((EntityHandle)r.GetMethodSpecification((MethodSpecificationHandle)h).Method,r,p,methods,fields);if(h.Kind==HandleKind.MemberReference){var m=r.GetMemberReference((MemberReferenceHandle)h);if(m.Parent.Kind==HandleKind.TypeDefinition)return p.Entity((EntityHandle)m.Parent);}return null;}
    static bool Forbidden(string s){if(String.IsNullOrEmpty(s))return false;if(s=="EAIRA.AgentServices.Functional.LocalOperatorConnectAttemptMonitor::Snapshot()")return false;int z=s.LastIndexOf("::",StringComparison.Ordinal);string t=z<0?s:s.Substring(0,z);if(t=="EAIRA.AgentServices.Functional.ILocalOperatorAdapterFactory"||t=="EAIRA.AgentServices.Functional.ILocalOperatorAdapter")return true;if(t.StartsWith("EAIRA.",StringComparison.Ordinal)&&(t.Contains("Adapter")||t.Contains("Factory")||t.Contains("Provider")||t.Contains("Transport")||t.Contains("Ollama")))return true;string[] prefixes={"System.Net","System.IO","System.Environment","System.Diagnostics","Microsoft.Win32","System.ServiceProcess","System.IO.Pipes","System.Reflection","System.Security.Cryptography.RandomNumberGenerator","System.Security.Cryptography.RNGCryptoServiceProvider"};if(prefixes.Any(x=>t.StartsWith(x,StringComparison.Ordinal)))return true;string[] exact={"System.DateTime","System.DateTimeOffset","System.Random","System.Environment","System.Diagnostics.Process","System.Diagnostics.ProcessStartInfo","Microsoft.Win32.Registry","Microsoft.Win32.RegistryKey","System.Guid","System.Threading.Timer","System.Timers.Timer","System.Diagnostics.Stopwatch"};if(exact.Contains(t,StringComparer.Ordinal))return true;if(z>=0){string n=s.Substring(z+2);int q=n.IndexOfAny(new[]{'(',':'});if(q>=0)n=n.Substring(0,q);string[] parts={"Clock","Random","Socket","Connect","Send","Receive","Open","Read","Write","Start","CreateProcess"};if(parts.Any(x=>n.Contains(x))||new[]{"NewGuid","get_UtcNow","get_Now","get_TickCount","GetTimestamp","Delay","Sleep"}.Contains(n,StringComparer.Ordinal))return true;}return false;}
    static Dictionary<string,object> Summary(IList<string> x){return new Dictionary<string,object>{{"count",x.Count},{"sha256",SummarySha(x)}};}
    public static Dictionary<string,object> Inspect(string path)
    {
        using(var fs=File.OpenRead(path))using(var pe=new PEReader(fs)){
            var r=pe.GetMetadataReader();var p=new TypeProvider(r);_methods=new Dictionary<int,MethodInfoRow>();_fields=new Dictionary<int,FieldInfoRow>();var byType=new Dictionary<string,List<MethodInfoRow>>(StringComparer.Ordinal);var typeBases=new Dictionary<string,string>(StringComparer.Ordinal);
            foreach(var th in r.TypeDefinitions){var td=r.GetTypeDefinition(th);string tn=p.Entity((EntityHandle)th);if(!td.BaseType.IsNil)typeBases[tn]=p.Entity(td.BaseType);var list=new List<MethodInfoRow>();byType[tn]=list;foreach(var fh in td.GetFields()){var fd=r.GetFieldDefinition(fh);var row=new FieldInfoRow{Token=MetadataTokens.GetToken(fh),Type=tn,Name=r.GetString(fd.Name),FieldType=fd.DecodeSignature(p,new GenericContext()),Handle=fh};row.Full=tn+"::"+row.Name+":"+row.FieldType;_fields[row.Token]=row;}foreach(var mh in td.GetMethods()){var md=r.GetMethodDefinition(mh);var row=new MethodInfoRow{Token=MetadataTokens.GetToken(mh),Type=tn,Name=r.GetString(md.Name),Handle=mh,Def=md};row.Full=MethodName(p,r,tn,md);_methods[row.Token]=row;list.Add(row);}}
            foreach(var m in _methods.Values.Where(x=>x.Def.RelativeVirtualAddress!=0))Details(pe,r,p,m);
            string dispatch="EAIRA.AgentServices.Functional.LocalOperatorRunner::Execute(System.String[])";string root="EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecuteHealthAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)";
            var dm=_methods.Values.SingleOrDefault(x=>x.Full==dispatch);var rm=_methods.Values.SingleOrDefault(x=>x.Full==root);if(dm==null||rm==null)throw new InvalidDataException("Exact Health method identity missing.");ValidateDispatch(dm,root);
            var closure=new Dictionary<int,MethodInfoRow>();var q=new Queue<MethodInfoRow>();Action<MethodInfoRow> add=m=>{if(m!=null&&!closure.ContainsKey(m.Token)){closure[m.Token]=m;q.Enqueue(m);}};add(rm);var moduleCctor=_methods.Values.SingleOrDefault(x=>x.Type=="<Module>"&&x.Name==".cctor");add(moduleCctor);
            while(q.Count>0){var m=q.Dequeue();if(m.Instructions==null)throw new InvalidDataException("Reachable same-module Health closure method has no body.");foreach(var i in m.Instructions){if((i.Kind=="method"||i.Kind=="field"||i.Kind=="type"||i.Kind=="token")&&Forbidden(i.Value))throw new InvalidDataException("Forbidden Health closure reference: "+i.Value+".");string dt=DeclaringType(i.Entity,r,p,_methods,_fields);while(!String.IsNullOrEmpty(dt)){List<MethodInfoRow> ml;if(byType.TryGetValue(dt,out ml))add(ml.SingleOrDefault(x=>x.Name==".cctor"));int plus=dt.LastIndexOf('+');if(plus<0)break;dt=dt.Substring(0,plus);}if(i.Target!=null&&(i.Op.Name=="call"||i.Op.Name=="callvirt"||i.Op.Name=="newobj"||i.Op.Name=="ldftn"||i.Op.Name=="ldvirtftn")){int tok=MetadataTokens.GetToken(i.Entity);if(i.Entity.Kind==HandleKind.MethodSpecification)tok=MetadataTokens.GetToken(r.GetMethodSpecification((MethodSpecificationHandle)i.Entity).Method);if(_methods.ContainsKey(tok))add(_methods[tok]);else if(i.Entity.Kind==HandleKind.MemberReference){var mr=r.GetMemberReference((MemberReferenceHandle)i.Entity);if(mr.Parent.Kind==HandleKind.TypeDefinition){var candidates=byType[p.Entity((EntityHandle)mr.Parent)].Where(x=>x.Full==i.Target).ToArray();if(candidates.Length==1)add(candidates[0]);}}}}}
            var details=closure.Values.OrderBy(x=>x.Full,StringComparer.Ordinal).Select(m=>(object)new Dictionary<string,object>{{"method",m.Full},{"detailRows",m.Details}}).ToArray();var mrows=closure.Values.OrderBy(x=>x.Full,StringComparer.Ordinal).Select(m=>"METHOD|"+m.Full+"|"+SummarySha(m.Details)).ToArray();var crows=closure.Values.SelectMany(m=>m.Instructions.Where(i=>i.Target!=null&&(i.Op.Name=="call"||i.Op.Name=="callvirt"||i.Op.Name=="newobj"||i.Op.Name=="ldftn"||i.Op.Name=="ldvirtftn")).Select(i=>"CALL|"+m.Full+"|"+Hex8(i.Offset)+"|"+i.Op.Name.ToLowerInvariant()+"|"+i.Target)).OrderBy(x=>x,StringComparer.Ordinal).ToArray();
            var operands=closure.Values.SelectMany(m=>m.Instructions.Where(i=>i.Kind=="method"||i.Kind=="field"||i.Kind=="type"||i.Kind=="token").Select(i=>i.Value)).ToArray();var forbiddenRows=operands.Where(Forbidden).Distinct(StringComparer.Ordinal).OrderBy(x=>x,StringComparer.Ordinal).ToArray();Func<string,string> typeOf=s=>{int x=s.LastIndexOf("::",StringComparison.Ordinal);return x<0?s:s.Substring(0,x);};int forbidden=forbiddenRows.Length;int factories=operands.Count(x=>typeOf(x).Contains("Factory"));int providers=operands.Count(x=>typeOf(x).Contains("Provider"));int networks=operands.Count(x=>typeOf(x).StartsWith("System.Net",StringComparison.Ordinal)||typeOf(x).Contains("Transport")||typeOf(x).Contains("Ollama")||typeOf(x).Contains("Socket"));if(forbidden!=0||factories!=0||providers!=0||networks!=0||closure.Values.Any(x=>(x.Def.Attributes&MethodAttributes.PinvokeImpl)!=0))throw new InvalidDataException("Forbidden Health closure reference: "+String.Join(";",forbiddenRows)+" counts="+forbidden+","+factories+","+providers+","+networks+".");
            string[] eps={"EAIRA.AgentServices.Functional.LocalOperatorCompatibleLoopbackTransport::GetTags(System.Threading.CancellationToken)","EAIRA.AgentServices.Functional.LocalOperatorCompatibleLoopbackTransport::SendChat(System.Byte[],System.Threading.CancellationToken)"};string[] inner={"EAIRA.AgentServices.Functional.OllamaLoopbackTransport::GetTags(System.Threading.CancellationToken)","EAIRA.AgentServices.Functional.OllamaLoopbackTransport::SendChat(System.Byte[],System.Threading.CancellationToken)"};string record="EAIRA.AgentServices.Functional.LocalOperatorConnectAttemptMonitor::Record(System.String)";var ir=new List<string>();for(int z=0;z<2;z++){var m=_methods.Values.Single(x=>x.Full==eps[z]);if(m.Regions.Length!=0)throw new InvalidDataException("Instrumented entrypoint has EH.");var rc=m.Instructions.Where(i=>i.Target==record).ToArray();var ic=m.Instructions.Where(i=>i.Target==inner[z]).ToArray();if(rc.Length!=1||ic.Length!=1)throw new InvalidDataException("Instrumentation call count mismatch.");var bs=Blocks(m);var rootReach=Reach(bs,0);var dom=Dominators(bs,0,rootReach);var rb=bs.Single(b=>b.I.Contains(rc[0]));var ib=bs.Single(b=>b.I.Contains(ic[0]));if(!dom[ib.Start].Contains(rb.Start)||(rb.Start==ib.Start&&rc[0].Offset>=ic[0].Offset))throw new InvalidDataException("Record does not dominate inner call.");ir.Add("INSTRUMENT|"+eps[z]+"|"+Hex8(rc[0].Offset)+"|"+Hex8(ic[0].Offset)+"|"+record+"|"+inner[z]+"|DOMINATES");}
            return new Dictionary<string,object>{{"dispatchMethod",dispatch},{"allowedRoot",root},{"dispatchRows",dm.Details},{"methodDetails",details},{"methodRows",mrows},{"callRows",crows},{"dispatchIl",Summary(dm.Details)},{"allowedClosureMethods",Summary(mrows)},{"allowedClosureCalls",Summary(crows)},{"forbiddenMatchCount",forbidden},{"factoryReferenceCount",factories},{"providerReferenceCount",providers},{"networkReferenceCount",networks},{"instrumentedEntryPoints",eps},{"instrumentationRows",ir.ToArray()},{"instrumentation",Summary(ir)}};
        }
    }
    static string PreflightLocal(string s){if(s.StartsWith("PINNED:",StringComparison.Ordinal))return "PINNED:"+PreflightLocal(s.Substring(7));if(s.EndsWith("&",StringComparison.Ordinal))return "BYREF:"+PreflightLocal(s.Substring(0,s.Length-1));if(s.EndsWith("*",StringComparison.Ordinal))return "PTR:"+PreflightLocal(s.Substring(0,s.Length-1));if(s.EndsWith("[]",StringComparison.Ordinal))return "SZARRAY:"+PreflightLocal(s.Substring(0,s.Length-2));return s;}
    static string[] PreflightDetails(PEReader pe,MetadataReader r,TypeProvider p,MethodInfoRow m){var body=pe.GetMethodBody(m.Def.RelativeVirtualAddress);var il=body.GetILBytes();string header=(pe.GetSectionData(m.Def.RelativeVirtualAddress).GetContent()[0]&3)==2?"tiny":"fat";var rows=new List<string>();rows.Add("BODY|"+m.Full+"|"+header+"|"+il.Length.ToString(CultureInfo.InvariantCulture)+"|"+body.MaxStack.ToString(CultureInfo.InvariantCulture)+"|"+(body.LocalVariablesInitialized?"TRUE":"FALSE"));if(body.LocalSignature.IsNil)rows.Add("LOCALS|"+m.Full+"|0|-");else{var ls=r.GetStandaloneSignature(body.LocalSignature).DecodeLocalSignature(p,new GenericContext());var vals=ls.Select(PreflightLocal).ToArray();rows.Add("LOCALS|"+m.Full+"|"+vals.Length.ToString(CultureInfo.InvariantCulture)+"|"+String.Join(",",vals));}foreach(var i in m.Instructions)rows.Add("IL|"+m.Full+"|"+Hex8(i.Offset)+"|"+i.Op.Name.ToLowerInvariant()+"|"+i.Kind+"|"+i.Value);var eh=new List<string>();foreach(var e in body.ExceptionRegions){string k=e.Kind==ExceptionRegionKind.Catch?"catch":e.Kind==ExceptionRegionKind.Finally?"finally":e.Kind==ExceptionRegionKind.Fault?"fault":"filter";string tail=e.Kind==ExceptionRegionKind.Catch?p.Entity(e.CatchType):e.Kind==ExceptionRegionKind.Filter?Hex8(e.FilterOffset):"-";eh.Add("EH|"+m.Full+"|"+k+"|"+Hex8(e.TryOffset)+"|"+Hex8(e.TryOffset+e.TryLength)+"|"+Hex8(e.HandlerOffset)+"|"+Hex8(e.HandlerOffset+e.HandlerLength)+"|"+tail);}eh.Sort(StringComparer.Ordinal);rows.AddRange(eh);return rows.ToArray();}
    static bool TypeChar(char c){return Char.IsLetterOrDigit(c)||c=='_'||c=='.'||c=='+'||c=='`';}
    static bool HasTypeIdentity(string s,string t){if(String.IsNullOrEmpty(s)||String.IsNullOrEmpty(t))return false;int at=0;while((at=s.IndexOf(t,at,StringComparison.Ordinal))>=0){int end=at+t.Length;if((at==0||!TypeChar(s[at-1]))&&(end==s.Length||!TypeChar(s[end])))return true;at++;}return false;}
    static string PreflightRule(string s)
    {
        if(String.IsNullOrEmpty(s))return null;
        int z=s.LastIndexOf("::",StringComparison.Ordinal);string t=z<0?s:s.Substring(0,z);string n=z<0?"":s.Substring(z+2);
        if(n.StartsWith("Execute(",StringComparison.Ordinal))return "PREFLIGHT_ROUTE_EXECUTION_REFERENCE";
        if(n.StartsWith("CreateTask(",StringComparison.Ordinal)||n.StartsWith("CreateKnowledge(",StringComparison.Ordinal)||n.StartsWith("CreateProjectQa(",StringComparison.Ordinal)||t.Contains("Factory")||t.Contains("Provider"))return "PREFLIGHT_FACTORY_OR_PROVIDER_REFERENCE";
        if(s.IndexOf("System.Net.",StringComparison.Ordinal)>=0||s.Contains("Transport")||s.Contains("Socket")||s.Contains("Http")||s.Contains("Pipe"))return "PREFLIGHT_NETWORK_REFERENCE";
        if(s.IndexOf("System.IO.",StringComparison.Ordinal)>=0)return "PREFLIGHT_FILESYSTEM_REFERENCE";
        if(t=="System.Environment"||HasTypeIdentity(s,"System.Environment"))return "PREFLIGHT_ENVIRONMENT_REFERENCE";
        if(s.IndexOf("System.Reflection.",StringComparison.Ordinal)>=0||t=="System.Activator"||(t=="System.Type"&&n.StartsWith("GetType",StringComparison.Ordinal))||s.IndexOf("System.Runtime.Loader.",StringComparison.Ordinal)>=0)return "PREFLIGHT_DYNAMIC_LOAD_REFERENCE";
        if(t=="System.Threading.Thread"&&n.StartsWith("Sleep",StringComparison.Ordinal))return "PREFLIGHT_THREAD_SLEEP_REFERENCE";
        if(t=="System.Threading.Tasks.Task"&&n.StartsWith("Delay",StringComparison.Ordinal))return "PREFLIGHT_TASK_DELAY_REFERENCE";
        if(HasTypeIdentity(s,"System.Threading.Timer")||HasTypeIdentity(s,"System.Timers.Timer"))return "PREFLIGHT_TIMER_REFERENCE";
        if(HasTypeIdentity(s,"System.Security.Cryptography.RandomNumberGenerator")||HasTypeIdentity(s,"System.Security.Cryptography.RNGCryptoServiceProvider"))return "PREFLIGHT_CRYPTO_RNG_REFERENCE";
        if(s.Contains("Registry")||s.Contains("Process")||s.IndexOf("System.Diagnostics.",StringComparison.Ordinal)>=0||HasTypeIdentity(s,"System.DateTime")||HasTypeIdentity(s,"System.DateTimeOffset")||HasTypeIdentity(s,"System.Random")||HasTypeIdentity(s,"System.Guid"))return "PREFLIGHT_OTHER_FORBIDDEN_REFERENCE";
        return null;
    }
    static int ArgIndex(Instruction i){if(i.Op.Name=="ldarg.0")return 0;if(i.Op.Name=="ldarg.1")return 1;if(i.Op.Name=="ldarg.2")return 2;if(i.Op.Name=="ldarg.3")return 3;if(i.Op.Name=="ldarg"||i.Op.Name=="ldarg.s"){int x;if(Int32.TryParse(i.Value,NumberStyles.None,CultureInfo.InvariantCulture,out x))return x;}return -1;}
    static void ValidatePreflightDispatch(MethodInfoRow m,string root){if(m.Regions.Any(e=>e.Kind==ExceptionRegionKind.Finally||e.Kind==ExceptionRegionKind.Fault))throw new InvalidDataException("PREFLIGHT_OTHER_FORBIDDEN_REFERENCE");string guard="EAIRA.AgentServices.Functional.GuardAgent::ExpectedDecision(EAIRA.AgentServices.Functional.TaskEnvelope)";string lookup="EAIRA.AgentServices.Functional.LocalOperatorPreflight::Lookup(System.String)";string payload="EAIRA.AgentServices.Functional.LocalOperatorPreflight::CanonicalPayload(EAIRA.AgentServices.Functional.LocalOperatorPreflightPolicy)";var gi=m.Instructions.Where(i=>i.Target==guard).ToArray();if(gi.Length!=1)throw new InvalidDataException("PREFLIGHT_OTHER_FORBIDDEN_REFERENCE");if(m.Instructions.Any(i=>i.Offset<gi[0].Offset&&i.Target==payload))throw new InvalidDataException("PREFLIGHT_PAYLOAD_BEFORE_GUARD");if(m.Instructions.Any(i=>i.Offset<gi[0].Offset&&i.Target==lookup))throw new InvalidDataException("PREFLIGHT_LOOKUP_BEFORE_GUARD");var bs=Blocks(m);var reach=Reach(bs,0);var dom=Dominators(bs,0,reach);Func<string,Block[]> calls=t=>bs.Where(b=>b.I.Any(i=>i.Target==t)).ToArray();var gb=calls(guard);var rb=calls(root);var selectors=bs.Where(b=>b.I.Any(i=>i.Target=="EAIRA.AgentServices.Functional.LocalOperatorRequest::get_Capability()")&&b.I.Any(i=>i.Op.Name=="ldc.i4.5")&&b.I.Any(i=>i.Op.FlowControl==FlowControl.Cond_Branch)).ToArray();if(gb.Length!=1||rb.Length!=1||selectors.Length!=1||!dom[selectors[0].Start].Contains(gb[0].Start)||!dom[rb[0].Start].Contains(gb[0].Start)||!dom[rb[0].Start].Contains(selectors[0].Start))throw new InvalidDataException("PREFLIGHT_OTHER_FORBIDDEN_REFERENCE");int[] protectedOffsets={gb[0].Start,selectors[0].Start,rb[0].Start};foreach(var e in m.Regions)foreach(int x in protectedOffsets)if((x>=e.TryOffset&&x<e.TryOffset+e.TryLength)||(x>=e.HandlerOffset&&x<e.HandlerOffset+e.HandlerLength)||(e.Kind==ExceptionRegionKind.Filter&&x>=e.FilterOffset&&x<e.HandlerOffset))throw new InvalidDataException("PREFLIGHT_OTHER_FORBIDDEN_REFERENCE");}
    public static Dictionary<string,object> InspectPreflight(string path)
    {
        using(var fs=File.OpenRead(path))using(var pe=new PEReader(fs)){
            var r=pe.GetMetadataReader();var p=new TypeProvider(r);_methods=new Dictionary<int,MethodInfoRow>();_fields=new Dictionary<int,FieldInfoRow>();var byType=new Dictionary<string,List<MethodInfoRow>>(StringComparer.Ordinal);var typeBases=new Dictionary<string,string>(StringComparer.Ordinal);
            foreach(var th in r.TypeDefinitions){var td=r.GetTypeDefinition(th);string tn=p.Entity((EntityHandle)th);if(!td.BaseType.IsNil)typeBases[tn]=p.Entity(td.BaseType);var list=new List<MethodInfoRow>();byType[tn]=list;foreach(var fh in td.GetFields()){var fd=r.GetFieldDefinition(fh);var row=new FieldInfoRow{Token=MetadataTokens.GetToken(fh),Type=tn,Name=r.GetString(fd.Name),FieldType=fd.DecodeSignature(p,new GenericContext()),Handle=fh};row.Full=tn+"::"+row.Name+":"+row.FieldType;_fields[row.Token]=row;}foreach(var mh in td.GetMethods()){var md=r.GetMethodDefinition(mh);var row=new MethodInfoRow{Token=MetadataTokens.GetToken(mh),Type=tn,Name=r.GetString(md.Name),Handle=mh,Def=md};row.Full=MethodName(p,r,tn,md);_methods[row.Token]=row;list.Add(row);}}
            foreach(var m in _methods.Values.Where(x=>x.Def.RelativeVirtualAddress!=0))Details(pe,r,p,m);
            string dispatch="EAIRA.AgentServices.Functional.LocalOperatorRunner::Execute(System.String[])";string root="EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecutePreflightAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)";var dm=_methods.Values.SingleOrDefault(x=>x.Full==dispatch);var rm=_methods.Values.SingleOrDefault(x=>x.Full==root);if(dm==null||rm==null)throw new InvalidDataException("PREFLIGHT_OTHER_FORBIDDEN_REFERENCE");ValidatePreflightDispatch(dm,root);
            string build8="EAIRA.AgentServices.Functional.LocalOperatorResponse::Build(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,System.String,System.Int32,System.String,System.String,System.String,EAIRA.AgentServices.Functional.OrchestrationChain)";string build9="EAIRA.AgentServices.Functional.LocalOperatorResponse::Build(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,System.String,System.Int32,System.String,System.String,System.String,EAIRA.AgentServices.Functional.OrchestrationChain,System.String)";string lookup="EAIRA.AgentServices.Functional.LocalOperatorPreflight::Lookup(System.String)";string canonical="EAIRA.AgentServices.Functional.LocalOperatorPreflight::CanonicalPayload(EAIRA.AgentServices.Functional.LocalOperatorPreflightPolicy)";string validate="EAIRA.AgentServices.Functional.LocalOperatorPreflight::Validate(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,EAIRA.AgentServices.Functional.LocalOperatorPreflightPolicy,System.String,System.String)";string guard="EAIRA.AgentServices.Functional.GuardAgent::ExpectedDecision(EAIRA.AgentServices.Functional.TaskEnvelope)";string payloadDigest="EAIRA.AgentServices.Functional.LocalOperatorRunner::PayloadDigest(System.String)";string success="EAIRA.AgentServices.Functional.OrchestrationChain::Success(System.String,System.String,System.String)";var b8=_methods.Values.SingleOrDefault(x=>x.Full==build8);var b9=_methods.Values.SingleOrDefault(x=>x.Full==build9);int[] b8Args={0,1,2,3,4,5,6,7,6};bool b8Shape=b8!=null&&b9!=null&&b8.Regions.Length==0&&Blocks(b8).Count==1&&b8.Instructions.Count==11&&b8.Instructions.Take(9).Select(ArgIndex).SequenceEqual(b8Args)&&b8.Instructions[9].Op.Name=="call"&&b8.Instructions[9].Target==build9&&b8.Instructions[10].Op.FlowControl==FlowControl.Return;if(!b8Shape)throw new InvalidDataException("PREFLIGHT_OTHER_FORBIDDEN_REFERENCE");string[][] criticalPairs={new[]{build8,build9},new[]{build9,lookup},new[]{build9,validate},new[]{dispatch,guard},new[]{dispatch,root},new[]{root,canonical},new[]{root,lookup},new[]{root,validate},new[]{root,build8},new[]{root,payloadDigest},new[]{root,success}};var criticalRows=new List<string>();foreach(var pair in criticalPairs){var caller=_methods.Values.SingleOrDefault(x=>x.Full==pair[0]);if(caller==null)throw new InvalidDataException("PREFLIGHT_OTHER_FORBIDDEN_REFERENCE");int count=caller.Instructions.Count(i=>i.Target==pair[1]);criticalRows.Add("CALL|"+pair[0]+"|"+pair[1]+"|"+count.ToString(CultureInfo.InvariantCulture));if(count!=1)throw new InvalidDataException("PREFLIGHT_OTHER_FORBIDDEN_REFERENCE");}criticalRows.Sort(StringComparer.Ordinal);if(criticalRows.Count!=11||SummarySha(criticalRows)!="54FE70CC5D09904BF093D0551E0EDDB33A312345D61295415C5398A1A335B4F4")throw new InvalidDataException("PREFLIGHT_OTHER_FORBIDDEN_REFERENCE");
            var rngTypes=new HashSet<string>(StringComparer.Ordinal){"System.Security.Cryptography.RandomNumberGenerator","System.Security.Cryptography.RNGCryptoServiceProvider"};bool grew=true;while(grew){grew=false;foreach(var kv in typeBases)if(rngTypes.Any(x=>HasTypeIdentity(kv.Value,x))&&rngTypes.Add(kv.Key))grew=true;}
            var closure=new Dictionary<int,MethodInfoRow>();var q=new Queue<MethodInfoRow>();Action<MethodInfoRow> add=m=>{if(m!=null&&!closure.ContainsKey(m.Token)){closure[m.Token]=m;q.Enqueue(m);}};Action<string> addTypeCctors=s=>{if(String.IsNullOrEmpty(s))return;foreach(var tn in byType.Keys)if(HasTypeIdentity(s,tn)){string dt=tn;while(!String.IsNullOrEmpty(dt)){List<MethodInfoRow> ml;if(byType.TryGetValue(dt,out ml))add(ml.SingleOrDefault(x=>x.Name==".cctor"));int plus=dt.LastIndexOf('+');if(plus<0)break;dt=dt.Substring(0,plus);}}};add(rm);var moduleCctor=_methods.Values.SingleOrDefault(x=>x.Type=="<Module>"&&x.Name==".cctor");add(moduleCctor);
            while(q.Count>0){var m=q.Dequeue();if(m.Instructions==null)throw new InvalidDataException("PREFLIGHT_OTHER_FORBIDDEN_REFERENCE");var methodBody=pe.GetMethodBody(m.Def.RelativeVirtualAddress);if(!methodBody.LocalSignature.IsNil)foreach(var x in r.GetStandaloneSignature(methodBody.LocalSignature).DecodeLocalSignature(p,new GenericContext()))addTypeCctors(x);foreach(var i in m.Instructions){addTypeCctors(i.Value);string dt=DeclaringType(i.Entity,r,p,_methods,_fields);while(!String.IsNullOrEmpty(dt)){List<MethodInfoRow> ml;if(byType.TryGetValue(dt,out ml))add(ml.SingleOrDefault(x=>x.Name==".cctor"));int plus=dt.LastIndexOf('+');if(plus<0)break;dt=dt.Substring(0,plus);}if(i.Target!=null&&(i.Op.Name=="call"||i.Op.Name=="callvirt"||i.Op.Name=="newobj"||i.Op.Name=="ldftn"||i.Op.Name=="ldvirtftn")){int tok=MetadataTokens.GetToken(i.Entity);if(i.Entity.Kind==HandleKind.MethodSpecification)tok=MetadataTokens.GetToken(r.GetMethodSpecification((MethodSpecificationHandle)i.Entity).Method);if(_methods.ContainsKey(tok)&&_methods[tok].Def.RelativeVirtualAddress!=0)add(_methods[tok]);else if(i.Entity.Kind==HandleKind.MemberReference){var mr=r.GetMemberReference((MemberReferenceHandle)i.Entity);if(mr.Parent.Kind==HandleKind.TypeDefinition){var candidates=byType[p.Entity((EntityHandle)mr.Parent)].Where(x=>x.Full==i.Target&&x.Def.RelativeVirtualAddress!=0).ToArray();if(candidates.Length==1)add(candidates[0]);}}}}}
            Func<string,string> ruleFor=s=>{string rule=PreflightRule(s);if(rule==null&&rngTypes.Any(x=>HasTypeIdentity(s,x)))rule="PREFLIGHT_CRYPTO_RNG_REFERENCE";return rule;};var rules=new List<string>();foreach(var m in closure.Values){if((m.Def.Attributes&MethodAttributes.PinvokeImpl)!=0)rules.Add("PREFLIGHT_OTHER_FORBIDDEN_REFERENCE");foreach(var i in m.Instructions){if(i.Kind=="method"||i.Kind=="field"||i.Kind=="type"||i.Kind=="token"||i.Kind=="signature"){var rule=ruleFor(i.Value);if(rule!=null)rules.Add(rule);}}var body=pe.GetMethodBody(m.Def.RelativeVirtualAddress);if(!body.LocalSignature.IsNil)foreach(var x in r.GetStandaloneSignature(body.LocalSignature).DecodeLocalSignature(p,new GenericContext())){var rule=ruleFor(x);if(rule!=null)rules.Add(rule);}}
            string[] precedence={"PREFLIGHT_ROUTE_EXECUTION_REFERENCE","PREFLIGHT_FACTORY_OR_PROVIDER_REFERENCE","PREFLIGHT_NETWORK_REFERENCE","PREFLIGHT_FILESYSTEM_REFERENCE","PREFLIGHT_ENVIRONMENT_REFERENCE","PREFLIGHT_DYNAMIC_LOAD_REFERENCE","PREFLIGHT_THREAD_SLEEP_REFERENCE","PREFLIGHT_TASK_DELAY_REFERENCE","PREFLIGHT_TIMER_REFERENCE","PREFLIGHT_CRYPTO_RNG_REFERENCE","PREFLIGHT_OTHER_FORBIDDEN_REFERENCE"};foreach(var rule in precedence)if(rules.Contains(rule))throw new InvalidDataException(rule);
            var methodDetails=closure.Values.OrderBy(x=>x.Full,StringComparer.Ordinal).Select(m=>{var rows=PreflightDetails(pe,r,p,m);return (object)new Dictionary<string,object>{{"method",m.Full},{"token","0x"+m.Token.ToString("X8",CultureInfo.InvariantCulture)},{"detailRows",rows},{"bodySha256",SummarySha(rows)}};}).ToArray();var methodRows=closure.Values.OrderBy(x=>x.Full,StringComparer.Ordinal).Select(m=>{var rows=PreflightDetails(pe,r,p,m);return "METHOD|"+m.Full+"|0x"+m.Token.ToString("X8",CultureInfo.InvariantCulture)+"|"+SummarySha(rows);}).ToArray();var callRows=criticalRows.ToArray();var closureCallRows=closure.Values.SelectMany(m=>m.Instructions.Where(i=>i.Target!=null&&(i.Op.Name=="call"||i.Op.Name=="callvirt"||i.Op.Name=="newobj"||i.Op.Name=="ldftn"||i.Op.Name=="ldvirtftn")).Select(i=>"CALL|"+m.Full+"|"+i.Op.Name.ToLowerInvariant()+"|"+i.Target)).OrderBy(x=>x,StringComparer.Ordinal).ToArray();var tokenRows=closure.Values.SelectMany(m=>m.Instructions.Where(i=>i.Kind=="method"||i.Kind=="field"||i.Kind=="type"||i.Kind=="token").Select(i=>"TOKEN|"+m.Full+"|"+i.Op.Name.ToLowerInvariant()+"|"+i.Value)).OrderBy(x=>x,StringComparer.Ordinal).ToArray();var closureRows=methodRows.Concat(closureCallRows).Concat(tokenRows).ToArray();return new Dictionary<string,object>{{"dispatchMethod",dispatch},{"allowedRoot",root},{"dispatchRows",PreflightDetails(pe,r,p,dm)},{"methodDetails",methodDetails},{"methodRows",methodRows},{"callRows",callRows},{"closureCallRows",closureCallRows},{"tokenRows",tokenRows},{"methodManifest",Summary(methodRows)},{"callManifest",Summary(callRows)},{"closureCallManifest",Summary(closureCallRows)},{"tokenManifest",Summary(tokenRows)},{"closureManifest",Summary(closureRows)},{"build8",build8},{"build9",build9},{"forbiddenMatchCount",0}};
        }
    }
    static string DryRunRule(string s){string value=PreflightRule(s);return value==null?null:value.Replace("PREFLIGHT_","DRY_RUN_");}
    static void ValidateDryRunDispatch(MethodInfoRow m,string root){if(m.Regions.Any(e=>e.Kind==ExceptionRegionKind.Finally||e.Kind==ExceptionRegionKind.Fault))throw new InvalidDataException("DRY_RUN_OTHER_FORBIDDEN_REFERENCE");string guard="EAIRA.AgentServices.Functional.GuardAgent::ExpectedDecision(EAIRA.AgentServices.Functional.TaskEnvelope)";string lookup="EAIRA.AgentServices.Functional.LocalOperatorPreflight::Lookup(System.String)";string payload="EAIRA.AgentServices.Functional.LocalOperatorDryRun::CanonicalPayload(EAIRA.AgentServices.Functional.LocalOperatorPreflightPolicy)";var gi=m.Instructions.Where(i=>i.Target==guard).ToArray();if(gi.Length!=1)throw new InvalidDataException("DRY_RUN_OTHER_FORBIDDEN_REFERENCE");if(m.Instructions.Any(i=>i.Offset<gi[0].Offset&&i.Target==payload))throw new InvalidDataException("DRY_RUN_PAYLOAD_BEFORE_GUARD");if(m.Instructions.Any(i=>i.Offset<gi[0].Offset&&i.Target==lookup))throw new InvalidDataException("DRY_RUN_LOOKUP_BEFORE_GUARD");var bs=Blocks(m);var reach=Reach(bs,0);var dom=Dominators(bs,0,reach);Func<string,Block[]> calls=t=>bs.Where(b=>b.I.Any(i=>i.Target==t)).ToArray();var gb=calls(guard);var rb=calls(root);var selectors=bs.Where(b=>b.I.Any(i=>i.Target=="EAIRA.AgentServices.Functional.LocalOperatorRequest::get_Capability()")&&b.I.Any(i=>i.Op.Name=="ldc.i4.6")&&b.I.Any(i=>i.Op.FlowControl==FlowControl.Cond_Branch)).ToArray();if(gb.Length!=1||rb.Length!=1||selectors.Length!=1||!dom[selectors[0].Start].Contains(gb[0].Start)||!dom[rb[0].Start].Contains(gb[0].Start)||!dom[rb[0].Start].Contains(selectors[0].Start))throw new InvalidDataException("DRY_RUN_OTHER_FORBIDDEN_REFERENCE");int[] protectedOffsets={gb[0].Start,selectors[0].Start,rb[0].Start};foreach(var e in m.Regions)foreach(int x in protectedOffsets)if((x>=e.TryOffset&&x<e.TryOffset+e.TryLength)||(x>=e.HandlerOffset&&x<e.HandlerOffset+e.HandlerLength)||(e.Kind==ExceptionRegionKind.Filter&&x>=e.FilterOffset&&x<e.HandlerOffset))throw new InvalidDataException("DRY_RUN_OTHER_FORBIDDEN_REFERENCE");}
    public static Dictionary<string,object> InspectDryRun(string path)
    {
        using(var fs=File.OpenRead(path))using(var pe=new PEReader(fs)){
            var r=pe.GetMetadataReader();var p=new TypeProvider(r);_methods=new Dictionary<int,MethodInfoRow>();_fields=new Dictionary<int,FieldInfoRow>();var byType=new Dictionary<string,List<MethodInfoRow>>(StringComparer.Ordinal);var typeBases=new Dictionary<string,string>(StringComparer.Ordinal);
            foreach(var th in r.TypeDefinitions){var td=r.GetTypeDefinition(th);string tn=p.Entity((EntityHandle)th);if(!td.BaseType.IsNil)typeBases[tn]=p.Entity(td.BaseType);var list=new List<MethodInfoRow>();byType[tn]=list;foreach(var fh in td.GetFields()){var fd=r.GetFieldDefinition(fh);var row=new FieldInfoRow{Token=MetadataTokens.GetToken(fh),Type=tn,Name=r.GetString(fd.Name),FieldType=fd.DecodeSignature(p,new GenericContext()),Handle=fh};row.Full=tn+"::"+row.Name+":"+row.FieldType;_fields[row.Token]=row;}foreach(var mh in td.GetMethods()){var md=r.GetMethodDefinition(mh);var row=new MethodInfoRow{Token=MetadataTokens.GetToken(mh),Type=tn,Name=r.GetString(md.Name),Handle=mh,Def=md};row.Full=MethodName(p,r,tn,md);_methods[row.Token]=row;list.Add(row);}}
            foreach(var m in _methods.Values.Where(x=>x.Def.RelativeVirtualAddress!=0))Details(pe,r,p,m);
            string dispatch="EAIRA.AgentServices.Functional.LocalOperatorRunner::Execute(System.String[])";string root="EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecuteDryRunAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)";var dm=_methods.Values.SingleOrDefault(x=>x.Full==dispatch);var rm=_methods.Values.SingleOrDefault(x=>x.Full==root);if(dm==null||rm==null)throw new InvalidDataException("DRY_RUN_OTHER_FORBIDDEN_REFERENCE");ValidateDryRunDispatch(dm,root);
            string build8="EAIRA.AgentServices.Functional.LocalOperatorResponse::Build(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,System.String,System.Int32,System.String,System.String,System.String,EAIRA.AgentServices.Functional.OrchestrationChain)";string build9="EAIRA.AgentServices.Functional.LocalOperatorResponse::Build(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,System.String,System.Int32,System.String,System.String,System.String,EAIRA.AgentServices.Functional.OrchestrationChain,System.String)";string lookup="EAIRA.AgentServices.Functional.LocalOperatorPreflight::Lookup(System.String)";string canonical="EAIRA.AgentServices.Functional.LocalOperatorDryRun::CanonicalPayload(EAIRA.AgentServices.Functional.LocalOperatorPreflightPolicy)";string validate="EAIRA.AgentServices.Functional.LocalOperatorDryRun::Validate(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,EAIRA.AgentServices.Functional.LocalOperatorPreflightPolicy,System.String,System.String)";string guard="EAIRA.AgentServices.Functional.GuardAgent::ExpectedDecision(EAIRA.AgentServices.Functional.TaskEnvelope)";string payloadDigest="EAIRA.AgentServices.Functional.LocalOperatorRunner::PayloadDigest(System.String)";string success="EAIRA.AgentServices.Functional.OrchestrationChain::Success(System.String,System.String,System.String)";var b8=_methods.Values.SingleOrDefault(x=>x.Full==build8);var b9=_methods.Values.SingleOrDefault(x=>x.Full==build9);int[] b8Args={0,1,2,3,4,5,6,7,6};bool b8Shape=b8!=null&&b9!=null&&b8.Regions.Length==0&&Blocks(b8).Count==1&&b8.Instructions.Count==11&&b8.Instructions.Take(9).Select(ArgIndex).SequenceEqual(b8Args)&&b8.Instructions[9].Op.Name=="call"&&b8.Instructions[9].Target==build9&&b8.Instructions[10].Op.FlowControl==FlowControl.Return;if(!b8Shape)throw new InvalidDataException("DRY_RUN_OTHER_FORBIDDEN_REFERENCE");string[][] criticalPairs={new[]{build8,build9},new[]{build9,lookup},new[]{build9,validate},new[]{dispatch,guard},new[]{dispatch,root},new[]{root,canonical},new[]{root,lookup},new[]{root,validate},new[]{root,build8},new[]{root,payloadDigest},new[]{root,success}};var criticalRows=new List<string>();foreach(var pair in criticalPairs){var caller=_methods.Values.SingleOrDefault(x=>x.Full==pair[0]);if(caller==null)throw new InvalidDataException("DRY_RUN_OTHER_FORBIDDEN_REFERENCE");int count=caller.Instructions.Count(i=>i.Target==pair[1]);criticalRows.Add("CALL|"+pair[0]+"|"+pair[1]+"|"+count.ToString(CultureInfo.InvariantCulture));if(count!=1)throw new InvalidDataException("DRY_RUN_OTHER_FORBIDDEN_REFERENCE");}criticalRows.Sort(StringComparer.Ordinal);if(criticalRows.Count!=11||SummarySha(criticalRows)!="86DC77C3EF248181E02CADC0B42AE7652A73495EFAE77C09629D0B220CCE7DB4")throw new InvalidDataException("DRY_RUN_OTHER_FORBIDDEN_REFERENCE");
            var rngTypes=new HashSet<string>(StringComparer.Ordinal){"System.Security.Cryptography.RandomNumberGenerator","System.Security.Cryptography.RNGCryptoServiceProvider"};bool grew=true;while(grew){grew=false;foreach(var kv in typeBases)if(rngTypes.Any(x=>HasTypeIdentity(kv.Value,x))&&rngTypes.Add(kv.Key))grew=true;}
            var closure=new Dictionary<int,MethodInfoRow>();var q=new Queue<MethodInfoRow>();Action<MethodInfoRow> add=m=>{if(m!=null&&!closure.ContainsKey(m.Token)){closure[m.Token]=m;q.Enqueue(m);}};Action<string> addTypeCctors=s=>{if(String.IsNullOrEmpty(s))return;foreach(var tn in byType.Keys)if(HasTypeIdentity(s,tn)){string dt=tn;while(!String.IsNullOrEmpty(dt)){List<MethodInfoRow> ml;if(byType.TryGetValue(dt,out ml))add(ml.SingleOrDefault(x=>x.Name==".cctor"));int plus=dt.LastIndexOf('+');if(plus<0)break;dt=dt.Substring(0,plus);}}};add(rm);var moduleCctor=_methods.Values.SingleOrDefault(x=>x.Type=="<Module>"&&x.Name==".cctor");add(moduleCctor);
            while(q.Count>0){var m=q.Dequeue();if(m.Instructions==null)throw new InvalidDataException("DRY_RUN_OTHER_FORBIDDEN_REFERENCE");var methodBody=pe.GetMethodBody(m.Def.RelativeVirtualAddress);if(!methodBody.LocalSignature.IsNil)foreach(var x in r.GetStandaloneSignature(methodBody.LocalSignature).DecodeLocalSignature(p,new GenericContext()))addTypeCctors(x);foreach(var i in m.Instructions){addTypeCctors(i.Value);string dt=DeclaringType(i.Entity,r,p,_methods,_fields);while(!String.IsNullOrEmpty(dt)){List<MethodInfoRow> ml;if(byType.TryGetValue(dt,out ml))add(ml.SingleOrDefault(x=>x.Name==".cctor"));int plus=dt.LastIndexOf('+');if(plus<0)break;dt=dt.Substring(0,plus);}if(i.Target!=null&&(i.Op.Name=="call"||i.Op.Name=="callvirt"||i.Op.Name=="newobj"||i.Op.Name=="ldftn"||i.Op.Name=="ldvirtftn")){int tok=MetadataTokens.GetToken(i.Entity);if(i.Entity.Kind==HandleKind.MethodSpecification)tok=MetadataTokens.GetToken(r.GetMethodSpecification((MethodSpecificationHandle)i.Entity).Method);if(_methods.ContainsKey(tok)&&_methods[tok].Def.RelativeVirtualAddress!=0)add(_methods[tok]);else if(i.Entity.Kind==HandleKind.MemberReference){var mr=r.GetMemberReference((MemberReferenceHandle)i.Entity);if(mr.Parent.Kind==HandleKind.TypeDefinition){var candidates=byType[p.Entity((EntityHandle)mr.Parent)].Where(x=>x.Full==i.Target&&x.Def.RelativeVirtualAddress!=0).ToArray();if(candidates.Length==1)add(candidates[0]);}}}}}
            Func<string,string> ruleFor=s=>{string rule=DryRunRule(s);if(rule==null&&rngTypes.Any(x=>HasTypeIdentity(s,x)))rule="DRY_RUN_CRYPTO_RNG_REFERENCE";return rule;};var rules=new List<string>();foreach(var m in closure.Values){if((m.Def.Attributes&MethodAttributes.PinvokeImpl)!=0)rules.Add("DRY_RUN_OTHER_FORBIDDEN_REFERENCE");foreach(var i in m.Instructions){if(i.Kind=="method"||i.Kind=="field"||i.Kind=="type"||i.Kind=="token"||i.Kind=="signature"){var rule=ruleFor(i.Value);if(rule!=null)rules.Add(rule);}}var body=pe.GetMethodBody(m.Def.RelativeVirtualAddress);if(!body.LocalSignature.IsNil)foreach(var x in r.GetStandaloneSignature(body.LocalSignature).DecodeLocalSignature(p,new GenericContext())){var rule=ruleFor(x);if(rule!=null)rules.Add(rule);}}
            string[] precedence={"DRY_RUN_ROUTE_EXECUTION_REFERENCE","DRY_RUN_FACTORY_OR_PROVIDER_REFERENCE","DRY_RUN_NETWORK_REFERENCE","DRY_RUN_FILESYSTEM_REFERENCE","DRY_RUN_ENVIRONMENT_REFERENCE","DRY_RUN_DYNAMIC_LOAD_REFERENCE","DRY_RUN_THREAD_SLEEP_REFERENCE","DRY_RUN_TASK_DELAY_REFERENCE","DRY_RUN_TIMER_REFERENCE","DRY_RUN_CRYPTO_RNG_REFERENCE","DRY_RUN_OTHER_FORBIDDEN_REFERENCE"};foreach(var rule in precedence)if(rules.Contains(rule))throw new InvalidDataException(rule);
            var methodDetails=closure.Values.OrderBy(x=>x.Full,StringComparer.Ordinal).Select(m=>{var rows=PreflightDetails(pe,r,p,m);return (object)new Dictionary<string,object>{{"method",m.Full},{"token","0x"+m.Token.ToString("X8",CultureInfo.InvariantCulture)},{"detailRows",rows},{"bodySha256",SummarySha(rows)}};}).ToArray();var methodRows=closure.Values.OrderBy(x=>x.Full,StringComparer.Ordinal).Select(m=>{var rows=PreflightDetails(pe,r,p,m);return "METHOD|"+m.Full+"|0x"+m.Token.ToString("X8",CultureInfo.InvariantCulture)+"|"+SummarySha(rows);}).ToArray();var callRows=criticalRows.ToArray();var closureCallRows=closure.Values.SelectMany(m=>m.Instructions.Where(i=>i.Target!=null&&(i.Op.Name=="call"||i.Op.Name=="callvirt"||i.Op.Name=="newobj"||i.Op.Name=="ldftn"||i.Op.Name=="ldvirtftn")).Select(i=>"CALL|"+m.Full+"|"+i.Op.Name.ToLowerInvariant()+"|"+i.Target)).OrderBy(x=>x,StringComparer.Ordinal).ToArray();var tokenRows=closure.Values.SelectMany(m=>m.Instructions.Where(i=>i.Kind=="method"||i.Kind=="field"||i.Kind=="type"||i.Kind=="token").Select(i=>"TOKEN|"+m.Full+"|"+i.Op.Name.ToLowerInvariant()+"|"+i.Value)).OrderBy(x=>x,StringComparer.Ordinal).ToArray();var closureRows=methodRows.Concat(closureCallRows).Concat(tokenRows).ToArray();return new Dictionary<string,object>{{"dispatchMethod",dispatch},{"allowedRoot",root},{"dispatchRows",PreflightDetails(pe,r,p,dm)},{"methodDetails",methodDetails},{"methodRows",methodRows},{"callRows",callRows},{"closureCallRows",closureCallRows},{"tokenRows",tokenRows},{"methodManifest",Summary(methodRows)},{"callManifest",Summary(callRows)},{"closureCallManifest",Summary(closureCallRows)},{"tokenManifest",Summary(tokenRows)},{"closureManifest",Summary(closureRows)},{"build8",build8},{"build9",build9},{"forbiddenMatchCount",0}};
        }
    }
}

'@

function Get-LocalOperatorHealthIlEvidence {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)
    if ($null -eq ('EairaHealthIlInspector' -as [type])) {
        Add-Type -TypeDefinition $script:EairaHealthIlInspectorSource -Language CSharp
    }
    return [EairaHealthIlInspector]::Inspect($LiteralPath)
}

function Get-LocalOperatorPreflightIlEvidence {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)
    if ($null -eq ('EairaHealthIlInspector' -as [type])) {
        Add-Type -TypeDefinition $script:EairaHealthIlInspectorSource -Language CSharp
    }
    return [EairaHealthIlInspector]::InspectPreflight($LiteralPath)
}

function Get-LocalOperatorDryRunIlEvidence {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)
    if ($null -eq ('EairaHealthIlInspector' -as [type])) {
        Add-Type -TypeDefinition $script:EairaHealthIlInspectorSource -Language CSharp
    }
    return [EairaHealthIlInspector]::InspectDryRun($LiteralPath)
}


function Get-Sha256 {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)
    return (Get-FileHash -LiteralPath $LiteralPath -Algorithm SHA256).Hash.ToUpperInvariant()
}

function Get-PeMachine {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)

    $stream = [System.IO.File]::Open($LiteralPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
    try {
        $reader = New-Object System.IO.BinaryReader($stream)
        if ($reader.ReadUInt16() -ne 0x5A4D) { throw "Not an MZ executable: $LiteralPath" }
        $stream.Position = 0x3C
        $peOffset = $reader.ReadInt32()
        if ($peOffset -lt 0x40) { throw "Invalid PE offset: $LiteralPath" }
        $stream.Position = $peOffset
        if ($reader.ReadUInt32() -ne 0x00004550) { throw "Missing PE signature: $LiteralPath" }
        return ('0x{0:X4}' -f $reader.ReadUInt16())
    }
    finally {
        $stream.Dispose()
    }
}

function Assert-NoForbiddenBinaryMetadata {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [switch]$AllowLoopbackHttp,
        [switch]$AllowProjectContextPInvoke
    )

    $bytes = [System.IO.File]::ReadAllBytes($LiteralPath)
    $metadataText = [System.Text.Encoding]::UTF8.GetString($bytes) + "`n" + [System.Text.Encoding]::Unicode.GetString($bytes)
    $forbiddenMetadata = @(
        'NamedPipe',
        'TcpClient',
        'UdpClient',
        'ProcessStartInfo',
        'Microsoft.Win32',
        'DllImportAttribute',
        'WriteAllText',
        'WriteAllBytes',
        'AppendAllText',
        'CreateDirectory',
        'OpenWrite',
        'CreateText',
        'AppendText',
        'WriteAllLines',
        'AppendAllLines',
        'SetAttributes',
        'SetCreationTime',
        'SetLastAccessTime',
        'SetLastWriteTime',
        'FileStream',
        'StreamWriter'
    )
    if (-not $AllowLoopbackHttp) {
        $forbiddenMetadata += 'System.Net'
        $forbiddenMetadata += 'HttpClient'
    }
    if ($AllowProjectContextPInvoke) {
        $forbiddenMetadata = @($forbiddenMetadata | Where-Object { $_ -cne 'DllImportAttribute' })
    }
    foreach ($token in $forbiddenMetadata) {
        if ($metadataText.IndexOf($token, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
            throw "Compiled output contains prohibited metadata token '$token': $LiteralPath"
        }
    }
}

function Get-MetadataTypeName {
    param($MetadataReader, $TypeHandle)
    $type = $MetadataReader.GetTypeDefinition($TypeHandle)
    $name = $MetadataReader.GetString($type.Name)
    $declaring = $type.GetDeclaringType()
    if (-not $declaring.IsNil) { return (Get-MetadataTypeName -MetadataReader $MetadataReader -TypeHandle $declaring) + '+' + $name }
    $namespace = $MetadataReader.GetString($type.Namespace)
    return $(if ([String]::IsNullOrEmpty($namespace)) { $name } else { $namespace + '.' + $name })
}

function Get-MetadataTypeReferenceName {
    param($MetadataReader, $TypeReferenceHandle)
    $type = $MetadataReader.GetTypeReference([System.Reflection.Metadata.TypeReferenceHandle]$TypeReferenceHandle)
    $name = $MetadataReader.GetString($type.Name)
    if ($type.ResolutionScope.Kind -eq [System.Reflection.Metadata.HandleKind]::TypeReference) {
        return (Get-MetadataTypeReferenceName -MetadataReader $MetadataReader -TypeReferenceHandle ([System.Reflection.Metadata.TypeReferenceHandle]$type.ResolutionScope)) + '+' + $name
    }
    $namespace = $MetadataReader.GetString($type.Namespace)
    return $(if ([String]::IsNullOrEmpty($namespace)) { $name } else { $namespace + '.' + $name })
}

function Get-MetadataEntityTypeName {
    param($MetadataReader, $EntityHandle)
    if ($EntityHandle.IsNil) { return $null }
    switch ($EntityHandle.Kind) {
        ([System.Reflection.Metadata.HandleKind]::TypeDefinition) {
            return Get-MetadataTypeName -MetadataReader $MetadataReader -TypeHandle ([System.Reflection.Metadata.TypeDefinitionHandle]$EntityHandle)
        }
        ([System.Reflection.Metadata.HandleKind]::TypeReference) {
            return Get-MetadataTypeReferenceName -MetadataReader $MetadataReader -TypeReferenceHandle ([System.Reflection.Metadata.TypeReferenceHandle]$EntityHandle)
        }
        default { throw "Unsupported metadata type handle '$($EntityHandle.Kind)'." }
    }
}
function Get-ByteArraySha256 {
    param([Parameter(Mandatory = $true)][AllowEmptyCollection()][byte[]]$Bytes)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return [BitConverter]::ToString($sha.ComputeHash($Bytes)).Replace('-', '') }
    finally { $sha.Dispose() }
}

function Get-ProjectContextIlGraph {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)

    $opcodeMap = @{}
    foreach ($field in [Reflection.Emit.OpCodes].GetFields([Reflection.BindingFlags]'Public,Static')) {
        $opcode = [Reflection.Emit.OpCode]$field.GetValue($null)
        $value = [int]$opcode.Value
        if ($value -lt 0) { $value += 65536 }
        $opcodeMap[$value] = $opcode
    }

    $stream = [System.IO.File]::OpenRead($LiteralPath)
    $peReader = [System.Reflection.PortableExecutable.PEReader]::new($stream)
    try {
        $reader = [System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($peReader)
        $methods = @{}
        $methodRows = @()
        $typeRows = @()
        $fieldRows = @()
        $methodRow = 0
        foreach ($typeHandleRaw in $reader.TypeDefinitions) {
            $typeHandle = [System.Reflection.Metadata.TypeDefinitionHandle]$typeHandleRaw
            $type = $reader.GetTypeDefinition($typeHandle)
            $typeName = Get-MetadataTypeName -MetadataReader $reader -TypeHandle $typeHandle
            $interfaceNames = @()
            foreach ($interfaceHandleRaw in $type.GetInterfaceImplementations()) {
                $interfaceRow = $reader.GetInterfaceImplementation([System.Reflection.Metadata.InterfaceImplementationHandle]$interfaceHandleRaw)
                $interfaceNames += Get-MetadataEntityTypeName -MetadataReader $reader -EntityHandle $interfaceRow.Interface
            }
            $genericCount = @($type.GetGenericParameters()).Count
            $typeRows += [pscustomobject][ordered]@{
                fullName = $typeName
                attributes = [int]$type.Attributes
                baseType = Get-MetadataEntityTypeName -MetadataReader $reader -EntityHandle $type.BaseType
                interfaces = @($interfaceNames | Sort-Object)
                genericParameterCount = $genericCount
            }
            foreach ($fieldHandleRaw in $type.GetFields()) {
                $fieldHandle = [System.Reflection.Metadata.FieldDefinitionHandle]$fieldHandleRaw
                $field = $reader.GetFieldDefinition($fieldHandle)
                $fieldRows += [pscustomobject][ordered]@{
                    declaringType = $typeName
                    name = $reader.GetString($field.Name)
                    signature = [BitConverter]::ToString($reader.GetBlobBytes($field.Signature)).Replace('-', '')
                    attributes = [int]$field.Attributes
                }
            }
            foreach ($methodHandleRaw in $type.GetMethods()) {
                $methodRow++
                $methodHandle = [System.Reflection.Metadata.MethodDefinitionHandle]$methodHandleRaw
                $method = $reader.GetMethodDefinition($methodHandle)
                $token = 0x06000000 + $methodRow
                $row = [pscustomobject][ordered]@{
                    token = $token
                    declaringType = $typeName
                    name = $reader.GetString($method.Name)
                    signature = [BitConverter]::ToString($reader.GetBlobBytes($method.Signature)).Replace('-', '')
                    attributes = [int]$method.Attributes
                    implAttributes = [int]$method.ImplAttributes
                    rva = [int]$method.RelativeVirtualAddress
                    pInvoke = (([int]$method.Attributes -band [int][Reflection.MethodAttributes]::PinvokeImpl) -ne 0)
                    ilSha256 = $null
                    genericParameterCount = @($method.GetGenericParameters()).Count
                }
                $methods[$token] = $row
                $methodRows += $row
            }
        }

        $memberReferences = @{}
        $memberReferenceRows = @()
        foreach ($memberHandleRaw in $reader.MemberReferences) {
            $memberHandle = [System.Reflection.Metadata.MemberReferenceHandle]$memberHandleRaw
            $member = $reader.GetMemberReference($memberHandle)
            $memberToken = [System.Reflection.Metadata.Ecma335.MetadataTokens]::GetToken([System.Reflection.Metadata.EntityHandle]$memberHandle)
            $parentType = $null
            if ($member.Parent.Kind -eq [System.Reflection.Metadata.HandleKind]::TypeDefinition -or
                $member.Parent.Kind -eq [System.Reflection.Metadata.HandleKind]::TypeReference) {
                $parentType = Get-MetadataEntityTypeName -MetadataReader $reader -EntityHandle $member.Parent
            }
            elseif ($member.Parent.Kind -eq [System.Reflection.Metadata.HandleKind]::MethodDefinition) {
                $parentMethodToken = [System.Reflection.Metadata.Ecma335.MetadataTokens]::GetToken($member.Parent)
                if ($methods.ContainsKey($parentMethodToken)) { $parentType = [string]$methods[$parentMethodToken].declaringType }
            }
            $memberName = $reader.GetString($member.Name)
            $memberSignature = [BitConverter]::ToString($reader.GetBlobBytes($member.Signature)).Replace('-', '')
            $resolvedRows = @($methodRows | Where-Object {
                $null -ne $parentType -and $_.declaringType -ceq $parentType -and $_.name -ceq $memberName -and $_.signature -ceq $memberSignature
            })
            $memberReferenceRow = [pscustomobject][ordered]@{
                token = $memberToken
                declaringType = $parentType
                name = $memberName
                signature = $memberSignature
                parentKind = $member.Parent.Kind.ToString()
                resolvedTarget = $(if ($resolvedRows.Count -eq 1) { $resolvedRows[0] } else { $null })
                ambiguousResolution = ($resolvedRows.Count -gt 1)
            }
            $memberReferences[$memberToken] = $memberReferenceRow
            $memberReferenceRows += $memberReferenceRow
        }

        $methodSpecifications = @{}
        $methodSpecCount = [System.Reflection.Metadata.Ecma335.MetadataReaderExtensions]::GetTableRowCount(
            $reader,
            [System.Reflection.Metadata.Ecma335.TableIndex]::MethodSpec
        )
        for ($methodSpecRow = 1; $methodSpecRow -le $methodSpecCount; $methodSpecRow++) {
            $methodSpecHandle = [System.Reflection.Metadata.Ecma335.MetadataTokens]::MethodSpecificationHandle($methodSpecRow)
            $methodSpec = $reader.GetMethodSpecification($methodSpecHandle)
            $methodSpecToken = [System.Reflection.Metadata.Ecma335.MetadataTokens]::GetToken([System.Reflection.Metadata.EntityHandle]$methodSpecHandle)
            $baseToken = [System.Reflection.Metadata.Ecma335.MetadataTokens]::GetToken($methodSpec.Method)
            $resolvedTarget = $null
            $baseType = $null
            $baseName = $null
            $baseSignature = $null
            if ($methods.ContainsKey($baseToken)) {
                $resolvedTarget = $methods[$baseToken]
                $baseType = [string]$resolvedTarget.declaringType
                $baseName = [string]$resolvedTarget.name
                $baseSignature = [string]$resolvedTarget.signature
            }
            elseif ($memberReferences.ContainsKey($baseToken)) {
                $baseMember = $memberReferences[$baseToken]
                $resolvedTarget = $baseMember.resolvedTarget
                $baseType = [string]$baseMember.declaringType
                $baseName = [string]$baseMember.name
                $baseSignature = [string]$baseMember.signature
            }
            $methodSpecifications[$methodSpecToken] = [pscustomobject][ordered]@{
                token = $methodSpecToken
                baseToken = $baseToken
                baseKind = $methodSpec.Method.Kind.ToString()
                declaringType = $baseType
                name = $baseName
                signature = $baseSignature
                instantiationSignature = [BitConverter]::ToString($reader.GetBlobBytes($methodSpec.Signature)).Replace('-', '')
                resolvedTarget = $resolvedTarget
            }
        }
        $nativeEdges = @()
        $allDirectEdges = @()
        $methodOperandRows = @()
        $calliCount = 0
        foreach ($caller in $methodRows) {
            if ($caller.rva -eq 0) { continue }
            $body = [System.Reflection.Metadata.PEReaderExtensions]::GetMethodBody($peReader, $caller.rva)
            [byte[]]$il = $body.GetILBytes()
            $caller.ilSha256 = Get-ByteArraySha256 -Bytes $il
            $offset = 0
            while ($offset -lt $il.Length) {
                $opcodeOffset = $offset
                $code = [int]$il[$offset]
                $offset++
                if ($code -eq 0xFE) {
                    if ($offset -ge $il.Length) { throw "Truncated two-byte IL opcode: $LiteralPath" }
                    $code = 0xFE00 + [int]$il[$offset]
                    $offset++
                }
                if (-not $opcodeMap.ContainsKey($code)) { throw "Unknown IL opcode: $LiteralPath" }
                $opcode = [Reflection.Emit.OpCode]$opcodeMap[$code]
                $operandSize = 0
                $targetToken = $null
                switch ($opcode.OperandType.ToString()) {
                    'InlineNone' { $operandSize = 0 }
                    'ShortInlineBrTarget' { $operandSize = 1 }
                    'ShortInlineI' { $operandSize = 1 }
                    'ShortInlineVar' { $operandSize = 1 }
                    'InlineVar' { $operandSize = 2 }
                    'InlineI' { $operandSize = 4 }
                    'InlineBrTarget' { $operandSize = 4 }
                    'InlineField' { $operandSize = 4 }
                    'InlineMethod' { $operandSize = 4; $targetToken = [BitConverter]::ToInt32($il, $offset) }
                    'InlineSig' { $operandSize = 4 }
                    'InlineString' { $operandSize = 4 }
                    'InlineTok' { $operandSize = 4; $targetToken = [BitConverter]::ToInt32($il, $offset) }
                    'InlineType' { $operandSize = 4 }
                    'ShortInlineR' { $operandSize = 4 }
                    'InlineI8' { $operandSize = 8 }
                    'InlineR' { $operandSize = 8 }
                    'InlineSwitch' {
                        if ($offset + 4 -gt $il.Length) { throw "Truncated IL switch: $LiteralPath" }
                        $caseCount = [BitConverter]::ToInt32($il, $offset)
                        if ($caseCount -lt 0) { throw "Negative IL switch count: $LiteralPath" }
                        $operandSize = 4 + (4 * $caseCount)
                    }
                    default { throw "Unsupported IL operand type '$($opcode.OperandType)': $LiteralPath" }
                }
                if ($offset + $operandSize -gt $il.Length) { throw "Truncated IL operand: $LiteralPath" }
                if ($opcode.Name -ceq 'calli') { $calliCount++ }
                if ($null -ne $targetToken) {
                    $target = $null
                    $targetOperandKind = $null
                    $targetType = $null
                    $targetName = $null
                    $targetSignature = $null
                    $methodSpecSignature = $null
                    if ($methods.ContainsKey($targetToken)) {
                        $targetOperandKind = 'MethodDefinition'
                        $target = $methods[$targetToken]
                    }
                    elseif ($memberReferences.ContainsKey($targetToken)) {
                        $targetOperandKind = 'MemberReference'
                        $reference = $memberReferences[$targetToken]
                        if ($reference.ambiguousResolution) { throw "Ambiguous MemberRef resolution: $LiteralPath" }
                        $target = $reference.resolvedTarget
                        $targetType = [string]$reference.declaringType
                        $targetName = [string]$reference.name
                        $targetSignature = [string]$reference.signature
                    }
                    elseif ($methodSpecifications.ContainsKey($targetToken)) {
                        $targetOperandKind = 'MethodSpecification'
                        $specification = $methodSpecifications[$targetToken]
                        $target = $specification.resolvedTarget
                        $targetType = [string]$specification.declaringType
                        $targetName = [string]$specification.name
                        $targetSignature = [string]$specification.signature
                        $methodSpecSignature = [string]$specification.instantiationSignature
                    }
                    if ($null -ne $targetOperandKind) {
                        if ($null -ne $target) {
                            $targetType = [string]$target.declaringType
                            $targetName = [string]$target.name
                            $targetSignature = [string]$target.signature
                        }
                        $resolved = $null -ne $target
                        $methodOperandRows += [pscustomobject][ordered]@{
                            callerType = $caller.declaringType
                            callerName = $caller.name
                            callerSignature = $caller.signature
                            opcode = $opcode.Name
                            targetOperandKind = $targetOperandKind
                            targetType = $targetType
                            targetName = $targetName
                            targetSignature = $targetSignature
                            methodSpecificationSignature = $methodSpecSignature
                            resolvedMethodDefinition = $resolved
                            offset = $opcodeOffset
                        }
                        if ($resolved) {
                            $edge = [pscustomobject][ordered]@{
                                callerType = $caller.declaringType
                                callerName = $caller.name
                                callerSignature = $caller.signature
                                opcode = $opcode.Name
                                targetOperandKind = $targetOperandKind
                                targetType = $target.declaringType
                                targetName = $target.name
                                targetSignature = $target.signature
                                methodSpecificationSignature = $methodSpecSignature
                                offset = $opcodeOffset
                            }
                            $allDirectEdges += $edge
                            if ($target.pInvoke) { $nativeEdges += $edge }
                        }
                    }
                }
                $offset += $operandSize
            }
        }
        return [ordered]@{
            calliCount = $calliCount
            methods = $methodRows
            types = $typeRows
            fields = $fieldRows
            memberReferences = $memberReferenceRows
            directEdges = $allDirectEdges
            methodOperands = $methodOperandRows
            nativeEdges = $nativeEdges
        }
    }
    finally {
        $peReader.Dispose()
        $stream.Dispose()
    }
}

function Assert-ProjectContextPInvokeCallerPolicy {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][ValidateSet('Cli','ContextHarness','KnowledgeCli','ProjectQaCli','LocalOperatorCli')][string]$OutputKind,
        [switch]$Discovery
    )

    $graph = Get-ProjectContextIlGraph -LiteralPath $LiteralPath
    if ($graph.calliCount -ne 0) { throw "Compiled output contains indirect calli: $LiteralPath" }

    $platform = 'EAIRA.AgentServices.Functional.ProjectContextWin32Platform'
    $lease = $platform + '+ProjectContextNativeLease'
    $expected = [ordered]@{
        CreateFileW = @(
            "$platform::OpenApprovedContent",
            "$platform::OpenLeafProbe",
            "$platform::OpenPinnedAncestor"
        )
        GetFileInformationByHandle = @("$platform::QueryIdentityAndMetadata")
        GetFileInformationByHandleEx = @("$platform::QueryAttributeTag")
        GetFinalPathNameByHandleW = @("$platform::QueryCanonicalFinalPath")
        ReadFile = @("$platform::ReadApprovedContent")
        CloseHandle = @("$lease::Close")
    }
    if (@($graph.nativeEdges).Count -ne 8) { throw "Project-context native call-site count mismatch: $LiteralPath" }
    foreach ($callee in $expected.Keys) {
        $edges = @($graph.nativeEdges | Where-Object { $_.targetType -ceq $platform -and $_.targetName -ceq $callee })
        if (@($edges | Where-Object { $_.opcode -cne 'call' }).Count -ne 0) {
            throw "Project-context native target is referenced by a non-call opcode '$callee': $LiteralPath"
        }
        $actualCallers = @($edges | ForEach-Object { $_.callerType + '::' + $_.callerName } | Sort-Object)
        $expectedCallers = @($expected[$callee] | Sort-Object)
        if (($actualCallers -join [Environment]::NewLine) -cne ($expectedCallers -join [Environment]::NewLine)) {
            throw "Project-context native caller multiset mismatch '$callee': $LiteralPath"
        }
    }

    $approvedCallerSurfaces = @(
        "$platform::OpenPinnedAncestor",
        "$platform::OpenLeafProbe",
        "$platform::OpenApprovedContent",
        "$platform::QueryIdentityAndMetadata",
        "$platform::QueryAttributeTag",
        "$platform::QueryCanonicalFinalPath",
        "$platform::ReadApprovedContent",
        "$lease::Close"
    )
    $callerIl = @()
    foreach ($surface in $approvedCallerSurfaces) {
        $separator = $surface.LastIndexOf('::', [StringComparison]::Ordinal)
        $typeName = $surface.Substring(0, $separator)
        $methodName = $surface.Substring($separator + 2)
        $matches = @($graph.methods | Where-Object { $_.declaringType -ceq $typeName -and $_.name -ceq $methodName })
        if ($matches.Count -ne 1 -or [String]::IsNullOrEmpty([string]$matches[0].ilSha256)) {
            throw "Project-context approved native caller identity mismatch '$surface': $LiteralPath"
        }
        $callerIl += [ordered]@{
            declaringType = $typeName
            managedName = $methodName
            signature = [string]$matches[0].signature
            ilSha256 = [string]$matches[0].ilSha256
        }
    }
    [string[]]$canonicalCallerIl = @($callerIl | ForEach-Object {
        [string]$_.declaringType + '|' + [string]$_.managedName + '|' + [string]$_.signature + '|' + [string]$_.ilSha256
    })
    [Array]::Sort($canonicalCallerIl, [StringComparer]::Ordinal)
    $callerIlSha256 = Get-ByteArraySha256 -Bytes ([Text.Encoding]::UTF8.GetBytes(($canonicalCallerIl -join "`n")))
    $inventoryProperty = $Policy.nativeCallerIlInventory.PSObject.Properties[$OutputKind]
    $newOutputDiscovery = $Discovery -and ($OutputKind -ceq 'KnowledgeCli' -or $OutputKind -ceq 'ProjectQaCli' -or $OutputKind -ceq 'LocalOperatorCli')
    if ($null -eq $inventoryProperty -and -not $newOutputDiscovery) { throw "Missing profile-bound native caller IL inventory '$OutputKind': $LiteralPath" }
    $expectedInventory = if ($null -eq $inventoryProperty) { $null } else { $inventoryProperty.Value }
    if (-not $newOutputDiscovery -and
        ([int]$expectedInventory.count -ne $canonicalCallerIl.Count -or
        [string]$expectedInventory.sha256 -cne $callerIlSha256)) {
        throw "Profile-bound native caller IL inventory mismatch '$OutputKind': expected count=$([int]$expectedInventory.count) sha256=$([string]$expectedInventory.sha256); actual count=$($canonicalCallerIl.Count) sha256=$callerIlSha256; output=$LiteralPath"
    }
    return [ordered]@{
        calliCount = 0
        nativeCallSiteCount = 8
        nativeEdges = @($graph.nativeEdges | Sort-Object targetName, callerType, callerName)
        approvedCallerIl = @($callerIl | Sort-Object declaringType, managedName)
        approvedCallerIlCount = [int]$canonicalCallerIl.Count
        approvedCallerIlSha256 = $callerIlSha256
        approvedCallerIlProfileMatch = [bool](-not $newOutputDiscovery)
        graph = $graph
    }
}

function Get-MethodParameterCount {
    param([Parameter(Mandatory = $true)][string]$Signature)
    if ($Signature.Length -lt 4) { throw "Invalid method signature blob '$Signature'." }
    return [Convert]::ToInt32($Signature.Substring(2, 2), 16)
}

function Get-ProjectKnowledgeMetadataClosure {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)
    $graph = Get-ProjectContextIlGraph -LiteralPath $LiteralPath
    [string[]]$types = @($graph.types | Sort-Object fullName | ForEach-Object {
        [string]$_.fullName + '|' + [int]$_.attributes + '|' + [string]$_.baseType + '|' +
        (@($_.interfaces | Sort-Object) -join ',') + '|' + [int]$_.genericParameterCount
    })
    [string[]]$methods = @($graph.methods | Sort-Object declaringType,name,signature | ForEach-Object {
        [string]$_.declaringType + '|' + [string]$_.name + '|' + [string]$_.signature + '|' +
        [int]$_.attributes + '|' + [int]$_.implAttributes + '|' + [int]$_.genericParameterCount + '|' + [string]$_.ilSha256
    })
    [string[]]$members = @($graph.memberReferences | Sort-Object declaringType,name,signature,parentKind | ForEach-Object {
        [string]$_.declaringType + '|' + [string]$_.name + '|' + [string]$_.signature + '|' + [string]$_.parentKind
    })
    [string[]]$calls = @($graph.methodOperands | Sort-Object callerType,callerName,callerSignature,offset | ForEach-Object {
        [string]$_.callerType + '::' + [string]$_.callerName + '|' + [string]$_.callerSignature + '|' +
        [string]$_.opcode + '|' + [string]$_.targetOperandKind + '|' + [string]$_.targetType + '::' +
        [string]$_.targetName + '|' + [string]$_.targetSignature + '|' + [string]$_.methodSpecificationSignature
    })
    $codecTypes = @('EAIRA.AgentServices.Functional.ContractException','EAIRA.AgentServices.Functional.ContractCodec')
    [string[]]$codec = @(
        $types | Where-Object { $name = ($_ -split '\|',2)[0]; $codecTypes -ccontains $name }
        $methods | Where-Object { $name = ($_ -split '\|',2)[0]; $codecTypes -ccontains $name }
        $calls | Where-Object { $surface = ($_ -split '\|',2)[0]; @($codecTypes | Where-Object { $surface.StartsWith($_ + '::',[StringComparison]::Ordinal) }).Count -ne 0 }
    )
    [string[]]$codecSemantic = @(
        $graph.types | Where-Object { $codecTypes -ccontains [string]$_.fullName } | Sort-Object fullName | ForEach-Object {
            'T|' + [string]$_.fullName + '|' + [int]$_.attributes + '|' + [string]$_.baseType + '|' + [int]$_.genericParameterCount
        }
        $graph.methods | Where-Object { $codecTypes -ccontains [string]$_.declaringType } | Sort-Object declaringType,name,signature | ForEach-Object {
            'M|' + [string]$_.declaringType + '|' + [string]$_.name + '|' + (Get-MethodParameterCount -Signature ([string]$_.signature)) + '|' +
            [int]$_.attributes + '|' + [int]$_.implAttributes + '|' + [int]$_.genericParameterCount
        }
        $graph.methodOperands | Where-Object { $codecTypes -ccontains [string]$_.callerType } | Sort-Object callerType,callerName,offset | ForEach-Object {
            'C|' + [string]$_.callerType + '|' + [string]$_.callerName + '|' + [string]$_.opcode + '|' +
            [string]$_.targetType + '::' + [string]$_.targetName
        }
    )
    return [ordered]@{
        image = [ordered]@{ count = (Get-Item -LiteralPath $LiteralPath).Length; sha256 = Get-Sha256 -LiteralPath $LiteralPath }
        typeDefs = [ordered]@{ count = $types.Count; sha256 = Get-ByteArraySha256 -Bytes ([Text.Encoding]::UTF8.GetBytes(($types -join "`n"))) }
        methodDefs = [ordered]@{ count = $methods.Count; sha256 = Get-ByteArraySha256 -Bytes ([Text.Encoding]::UTF8.GetBytes(($methods -join "`n"))) }
        memberRefs = [ordered]@{ count = $members.Count; sha256 = Get-ByteArraySha256 -Bytes ([Text.Encoding]::UTF8.GetBytes(($members -join "`n"))) }
        callGraph = [ordered]@{ count = $calls.Count; sha256 = Get-ByteArraySha256 -Bytes ([Text.Encoding]::UTF8.GetBytes(($calls -join "`n"))) }
        codecClosure = [ordered]@{ count = $codec.Count; sha256 = Get-ByteArraySha256 -Bytes ([Text.Encoding]::UTF8.GetBytes(($codec -join "`n"))) }
        codecSemanticClosure = [ordered]@{ count = $codecSemantic.Count; sha256 = Get-ByteArraySha256 -Bytes ([Text.Encoding]::UTF8.GetBytes(($codecSemantic -join "`n"))) }
        codecRawRows = $codec
        codecSemanticRows = $codecSemantic
    }
}

function Assert-ProjectKnowledgeMetadataPolicy {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][ValidateSet('Cli','Harness')][string]$OutputKind,
        [switch]$Discovery
    )
    $actual = Get-ProjectKnowledgeMetadataClosure -LiteralPath $LiteralPath
    if (-not $Discovery) {
        $property = $Policy.metadataInventories.PSObject.Properties[$OutputKind]
        if ($null -eq $property) { throw "Missing project-knowledge metadata inventory '$OutputKind': $LiteralPath" }
        $expected = $property.Value
        foreach ($name in @('image','typeDefs','methodDefs','memberRefs','callGraph','codecClosure','codecSemanticClosure')) {
            if ($null -eq $expected.$name -or [int]$expected.$name.count -ne [int]$actual.$name.count -or
                [string]$expected.$name.sha256 -cne [string]$actual.$name.sha256) {
                throw "Project-knowledge metadata inventory mismatch '$OutputKind/$name': $LiteralPath"
            }
        }
    }
    return $actual
}

function Get-ProjectQaMetadataClosure {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)
    $graph = Get-ProjectContextIlGraph -LiteralPath $LiteralPath
    [string[]]$types = @($graph.types | Sort-Object fullName | ForEach-Object { [string]$_.fullName + '|' + [int]$_.attributes + '|' + [string]$_.baseType + '|' + (@($_.interfaces | Sort-Object) -join ',') + '|' + [int]$_.genericParameterCount })
    [string[]]$methods = @($graph.methods | Sort-Object declaringType,name,signature | ForEach-Object { [string]$_.declaringType + '|' + [string]$_.name + '|' + [string]$_.signature + '|' + [int]$_.attributes + '|' + [int]$_.implAttributes + '|' + [int]$_.genericParameterCount + '|' + [string]$_.ilSha256 })
    [string[]]$members = @($graph.memberReferences | Sort-Object declaringType,name,signature,parentKind | ForEach-Object { [string]$_.declaringType + '|' + [string]$_.name + '|' + [string]$_.signature + '|' + [string]$_.parentKind })
    [string[]]$methodSpecs = @($graph.methodOperands | Where-Object { $_.targetOperandKind -ceq 'MethodSpecification' } | Sort-Object callerType,callerName,callerSignature,targetType,targetName,targetSignature,methodSpecificationSignature | ForEach-Object { [string]$_.callerType + '::' + [string]$_.callerName + '|' + [string]$_.callerSignature + '|' + [string]$_.opcode + '|' + [string]$_.targetType + '::' + [string]$_.targetName + '|' + [string]$_.targetSignature + '|' + [string]$_.methodSpecificationSignature })
    [string[]]$fields = @($graph.fields | Sort-Object declaringType,name,signature | ForEach-Object { [string]$_.declaringType + '|' + [string]$_.name + '|' + [string]$_.signature + '|' + [int]$_.attributes })
    [string[]]$interfaces = @($graph.types | Sort-Object fullName | ForEach-Object { $type=[string]$_.fullName; @($_.interfaces | Sort-Object) | ForEach-Object { $type + '|' + [string]$_ } })
    [string[]]$constructors = @($graph.methods | Where-Object { $_.name -ceq '.ctor' -or $_.name -ceq '.cctor' } | Sort-Object declaringType,name,signature | ForEach-Object { [string]$_.declaringType + '|' + [string]$_.name + '|' + [string]$_.signature + '|' + [int]$_.attributes + '|' + [int]$_.implAttributes + '|' + [string]$_.ilSha256 })
    [string[]]$calls = @($graph.methodOperands | Sort-Object callerType,callerName,callerSignature,offset | ForEach-Object { [string]$_.callerType + '::' + [string]$_.callerName + '|' + [string]$_.callerSignature + '|' + [string]$_.opcode + '|' + [string]$_.targetOperandKind + '|' + [string]$_.targetType + '::' + [string]$_.targetName + '|' + [string]$_.targetSignature + '|' + [string]$_.methodSpecificationSignature })
    $summary = { param([string[]]$Rows) [ordered]@{ count=$Rows.Count; sha256=Get-ByteArraySha256 -Bytes ([Text.Encoding]::UTF8.GetBytes(($Rows -join "`n"))) } }
    return [ordered]@{
        image = [ordered]@{ count=(Get-Item -LiteralPath $LiteralPath).Length; sha256=Get-Sha256 -LiteralPath $LiteralPath }
        typeDefs = & $summary $types
        methodDefs = & $summary $methods
        memberRefs = & $summary $members
        methodSpecs = & $summary $methodSpecs
        fields = & $summary $fields
        interfaces = & $summary $interfaces
        constructors = & $summary $constructors
        callGraph = & $summary $calls
    }
}

function Assert-ProjectQaMetadataPolicy {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][ValidateSet('Cli','Harness')][string]$OutputKind,
        [switch]$Discovery
    )
    $actual = Get-ProjectQaMetadataClosure -LiteralPath $LiteralPath
    if (-not $Discovery) {
        $property = $Policy.metadataInventories.PSObject.Properties[$OutputKind]
        if ($null -eq $property) { throw "Missing project-QA metadata inventory '$OutputKind': $LiteralPath" }
        $expected = $property.Value
        foreach ($name in @('image','typeDefs','methodDefs','memberRefs','methodSpecs','fields','interfaces','constructors','callGraph')) {
            if ($null -eq $expected.$name -or [int64]$expected.$name.count -ne [int64]$actual.$name.count -or [string]$expected.$name.sha256 -cne [string]$actual.$name.sha256) { throw "Project-QA metadata inventory mismatch '$OutputKind/$name': $LiteralPath" }
        }
    }
    return $actual
}

function Assert-LocalOperatorMetadataPolicy {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][ValidateSet('Cli','Harness')][string]$OutputKind,
        [switch]$Discovery
    )
    $actual = Get-ProjectQaMetadataClosure -LiteralPath $LiteralPath
    if (-not $Discovery) {
        $expected = if ($OutputKind -ceq 'Cli') { $Policy.cliMetadataInventory } else { $Policy.harnessMetadataInventory }
        if ($null -eq $expected) { throw "Missing Local Operator metadata inventory '$OutputKind': $LiteralPath" }
        foreach ($name in @('image','typeDefs','methodDefs','memberRefs','methodSpecs','fields','interfaces','constructors','callGraph')) {
            if ($null -eq $expected.$name -or [int64]$expected.$name.count -ne [int64]$actual.$name.count -or [string]$expected.$name.sha256 -cne [string]$actual.$name.sha256) {
                throw "Local Operator metadata inventory mismatch '$OutputKind/$name': $LiteralPath"
            }
        }
    }
    return $actual
}

function Get-NormalizedNativeSemanticInventory {
    param([Parameter(Mandatory = $true)]$PInvokeMetadata, [Parameter(Mandatory = $true)]$CallerEvidence)
    $signatures = [ordered]@{
        CloseHandle = 'BOOL(INTPTR)'
        CreateFileW = 'INTPTR(STRING,U32,U32,INTPTR,U32,U32,INTPTR)'
        GetFileInformationByHandle = 'BOOL(INTPTR,OUT:BY_HANDLE_FILE_INFORMATION)'
        GetFileInformationByHandleEx = 'BOOL(INTPTR,I32,OUT:FILE_ATTRIBUTE_TAG_INFO,U32)'
        GetFinalPathNameByHandleW = 'U32(INTPTR,STRINGBUILDER,U32,U32)'
        ReadFile = 'BOOL(INTPTR,BYTE[],U32,OUT:U32,INTPTR)'
    }
    [string[]]$imports = @($PInvokeMetadata.rows | Sort-Object managedName | ForEach-Object {
        'PLATFORM|' + [string]$_.module + '|' + [string]$_.managedName + '|' + [string]$signatures[[string]$_.managedName] + '|' +
        [int]$_.methodImportAttributes + '|' + [int]$_.methodAttributes + '|' + [int]$_.methodImplAttributes
    })
    $platform = 'EAIRA.AgentServices.Functional.ProjectContextWin32Platform'
    $lease = $platform + '+ProjectContextNativeLease'
    $role = { param([string]$Name) if ($Name -ceq $platform) { 'PLATFORM' } elseif ($Name -ceq $lease) { 'LEASE' } else { $Name } }
    [string[]]$edges = @($CallerEvidence.nativeEdges | Sort-Object targetName,callerType,callerName,offset | ForEach-Object {
        (& $role ([string]$_.callerType)) + '::' + [string]$_.callerName + '|' + [string]$_.opcode + '|' +
        (& $role ([string]$_.targetType)) + '::' + [string]$_.targetName
    })
    $approved = @('OpenPinnedAncestor','OpenLeafProbe','OpenApprovedContent','QueryIdentityAndMetadata','QueryAttributeTag','QueryCanonicalFinalPath','ReadApprovedContent','Close')
    [string[]]$normalizedIl = @($CallerEvidence.graph.methodOperands | Where-Object {
        $approved -ccontains [string]$_.callerName -and
        ([string]$_.callerType -ceq $platform -or [string]$_.callerType -ceq $lease)
    } | Sort-Object callerType,callerName,offset | ForEach-Object {
        (& $role ([string]$_.callerType)) + '::' + [string]$_.callerName + '|' + [string]$_.opcode + '|' +
        (& $role ([string]$_.targetType)) + '::' + [string]$_.targetName
    })
    return [ordered]@{
        pInvokeTuple = [ordered]@{ count = $imports.Count; sha256 = Get-ByteArraySha256 -Bytes ([Text.Encoding]::UTF8.GetBytes(($imports -join "`n"))) }
        callGraph = [ordered]@{ count = $edges.Count; sha256 = Get-ByteArraySha256 -Bytes ([Text.Encoding]::UTF8.GetBytes(($edges -join "`n"))) }
        normalizedCallerIl = [ordered]@{ count = $normalizedIl.Count; sha256 = Get-ByteArraySha256 -Bytes ([Text.Encoding]::UTF8.GetBytes(($normalizedIl -join "`n"))) }
    }
}

function Assert-ProjectContextDynamicConstructionPolicy {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)
    $stream = [System.IO.File]::OpenRead($LiteralPath)
    $peReader = [System.Reflection.PortableExecutable.PEReader]::new($stream)
    try {
        $reader = [System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($peReader)
        $forbiddenTypes = @()
        foreach ($handleRaw in $reader.TypeReferences) {
            $handle = [System.Reflection.Metadata.TypeReferenceHandle]$handleRaw
            $name = Get-MetadataTypeReferenceName -MetadataReader $reader -TypeReferenceHandle $handle
            if ($name -ceq 'System.Activator' -or
                $name -ceq 'System.Runtime.CompilerServices.CallSite' -or
                $name -ceq 'System.Runtime.CompilerServices.CallSiteBinder' -or
                $name -ceq 'System.Runtime.Serialization.FormatterServices' -or
                $name -ceq 'System.Reflection' -or $name.StartsWith('System.Reflection.', [StringComparison]::Ordinal) -or
                $name -ceq 'System.Reflection.Emit' -or $name.StartsWith('System.Reflection.Emit.', [StringComparison]::Ordinal) -or
                $name -ceq 'System.Linq.Expressions' -or $name.StartsWith('System.Linq.Expressions.', [StringComparison]::Ordinal) -or
                $name -ceq 'Microsoft.CSharp.RuntimeBinder' -or $name.StartsWith('Microsoft.CSharp.RuntimeBinder.', [StringComparison]::Ordinal)) {
                $forbiddenTypes += $name
            }
        }
        if ($forbiddenTypes.Count -ne 0) { throw "Forbidden reflection/dynamic TypeRef '$($forbiddenTypes[0])': $LiteralPath" }

        $forbiddenMembers = @()
        foreach ($handleRaw in $reader.MemberReferences) {
            $member = $reader.GetMemberReference([System.Reflection.Metadata.MemberReferenceHandle]$handleRaw)
            if ($member.Parent.Kind -ne [System.Reflection.Metadata.HandleKind]::TypeReference) { continue }
            $parent = Get-MetadataTypeReferenceName -MetadataReader $reader -TypeReferenceHandle ([System.Reflection.Metadata.TypeReferenceHandle]$member.Parent
            )
            $name = $reader.GetString($member.Name)
            $surface = $parent + '::' + $name
            if ($surface -ceq 'System.Object::GetType' -or
                ($parent -ceq 'System.Type' -and @('GetType','GetMethod','GetMethods','GetConstructor','GetConstructors','GetInterface','GetInterfaces','InvokeMember') -ccontains $name) -or
                ($parent -ceq 'System.Delegate' -and @('CreateDelegate','DynamicInvoke') -ccontains $name) -or
                ($parent -ceq 'System.Reflection.Assembly' -and $name.StartsWith('Load', [StringComparison]::Ordinal)) -or
                ($parent -ceq 'System.Reflection.MethodBase' -and $name -ceq 'Invoke') -or
                ($parent -ceq 'System.Reflection.ConstructorInfo' -and $name -ceq 'Invoke') -or
                ($parent -ceq 'System.Runtime.Serialization.FormatterServices' -and $name -ceq 'GetUninitializedObject')) {
                $forbiddenMembers += $surface
            }
        }
        if ($forbiddenMembers.Count -ne 0) { throw "Forbidden reflection/dynamic MemberRef '$($forbiddenMembers[0])': $LiteralPath" }
        return [ordered]@{ forbiddenTypeRefs = 0; forbiddenMemberRefs = 0 }
    }
    finally { $peReader.Dispose(); $stream.Dispose() }
}

function Assert-ProjectContextSeamPolicy {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [Parameter(Mandatory = $true)][ValidateSet('Cli','ContextHarness','IntakeHarness','ProviderHarness','TransportHarness')][string]$OutputKind,
        [Parameter(Mandatory = $true)]$Policy
    )

    $graph = Get-ProjectContextIlGraph -LiteralPath $LiteralPath
    if ($graph.calliCount -ne 0) { throw "Context-bearing output contains calli: $LiteralPath" }

    $functional = 'EAIRA.AgentServices.Functional.'
    $tests = 'EAIRA.AgentServices.Tests.'
    $loader = $functional + 'ProjectContextLoader'
    $platform = $functional + 'ProjectContextWin32Platform'
    $lease = $platform + '+ProjectContextNativeLease'
    $coordinator = $functional + 'ProjectContextRequestCoordinator'
    $intake = $functional + 'LocalTaskIntake'
    $contextHarness = $tests + 'ProjectContextHarness'
    $intakeHarness = $tests + 'LocalTaskIntakeHarness'
    $fakePlatform = $contextHarness + '+FakePlatform'
    $fakeCoordinator = $intakeHarness + '+FakeCoordinator'
    $taskHostType = 'EAIRA.AgentServices.TaskIntake.AgentTaskIntakeHost'
    $resultMetadata = $functional + 'ProjectContextResultMetadata'
    $preparedRequest = $functional + 'ProjectContextPreparedRequest'
    $agentResult = $functional + 'AgentResult'
    $pipelineResult = $functional + 'PipelineResult'
    $contextSeal = $functional + 'ContextPlanningSeal'
    $planningAgent = $functional + 'PlanningAgent'
    $pipeline = $functional + 'MinimumFunctionalPipeline'
    $taskResponse = $functional + 'TaskIntakeResponse'

    $findMethods = {
        param([string]$TypeName, [string]$MethodName, [int]$ParameterCount)
        return @($graph.methods | Where-Object {
            $_.declaringType -ceq $TypeName -and $_.name -ceq $MethodName -and
            (Get-MethodParameterCount -Signature ([string]$_.signature)) -eq $ParameterCount
        })
    }
    $methodId = {
        param($Method)
        if ($null -eq $Method) { throw "Cannot build an identity for a missing MethodDef: $LiteralPath" }
        return [string]$Method.declaringType + '::' + [string]$Method.name + '|' + [string]$Method.signature
    }
    $assertMethod = {
        param(
            [string]$TypeName,
            [string]$MethodName,
            [int]$ParameterCount,
            [bool]$Present,
            [Nullable[int]]$Attributes,
            [bool]$ExactNamedSet = $true
        )
        $namedRows = @($graph.methods | Where-Object { $_.declaringType -ceq $TypeName -and $_.name -ceq $MethodName })
        $rows = @(& $findMethods $TypeName $MethodName $ParameterCount)
        if (-not $Present) {
            if ($namedRows.Count -ne 0) { throw "Forbidden named method present '$TypeName::$MethodName': $LiteralPath" }
            return $null
        }
        if ($rows.Count -ne 1 -or ($ExactNamedSet -and $namedRows.Count -ne 1)) {
            throw "Exact method inventory mismatch '$TypeName::$MethodName/$ParameterCount': $LiteralPath"
        }
        if ([int]$rows[0].genericParameterCount -ne 0) { throw "Generic controlled method is prohibited '$TypeName::$MethodName': $LiteralPath" }
        if ($null -ne $Attributes -and [int]$rows[0].attributes -ne [int]$Attributes) { throw "Method flags mismatch '$TypeName::$MethodName': $LiteralPath" }
        if ([int]$rows[0].implAttributes -ne 0) { throw "Method implementation flags mismatch '$TypeName::$MethodName': $LiteralPath" }
        return $rows[0]
    }
    $assertIncoming = {
        param($Target, [string[]]$ExpectedCallers, [string]$ExpectedOpcode)
        if ($null -eq $Target) { return }
        $edges = @($graph.directEdges | Where-Object {
            $_.targetType -ceq $Target.declaringType -and $_.targetName -ceq $Target.name -and $_.targetSignature -ceq $Target.signature
        })
        if (@($edges | Where-Object { $_.opcode -cne $ExpectedOpcode -or $_.targetOperandKind -cne 'MethodDefinition' }).Count -ne 0) {
            throw "Unexpected operand/token kind targeting '$($Target.declaringType)::$($Target.name)': $LiteralPath"
        }
        $actual = @($edges | ForEach-Object { $_.callerType + '::' + $_.callerName + '|' + $_.callerSignature } | Sort-Object)
        $expected = @($ExpectedCallers | Sort-Object)
        if (($actual -join "`n") -cne ($expected -join "`n")) {
            throw "Incoming caller multiset mismatch '$($Target.declaringType)::$($Target.name)': expected [$($expected -join ', ')], actual [$($actual -join ', ')]: $LiteralPath"
        }
    }
    $assertIncomingDetailed = {
        param($Target, [string[]]$ExpectedCallerEdges)
        if ($null -eq $Target) { return }
        $edges = @($graph.directEdges | Where-Object {
            $_.targetType -ceq $Target.declaringType -and $_.targetName -ceq $Target.name -and $_.targetSignature -ceq $Target.signature
        })
        if (@($edges | Where-Object { $_.targetOperandKind -cne 'MethodDefinition' }).Count -ne 0) {
            throw "Unexpected operand/token kind targeting '$($Target.declaringType)::$($Target.name)': $LiteralPath"
        }
        $actual = @($edges | ForEach-Object {
            $_.callerType + '::' + $_.callerName + '|' + $_.callerSignature + '|' + $_.opcode
        } | Sort-Object)
        $expected = @($ExpectedCallerEdges | Sort-Object)
        if (($actual -join "`n") -cne ($expected -join "`n")) {
            throw "Detailed incoming edge multiset mismatch '$($Target.declaringType)::$($Target.name)': expected [$($expected -join ', ')], actual [$($actual -join ', ')]: $LiteralPath"
        }
    }
    $assertType = {
        param([string]$TypeName, [bool]$Present, [int]$Attributes, $BaseType, [string[]]$Interfaces)
        $rows = @($graph.types | Where-Object { $_.fullName -ceq $TypeName })
        if (-not $Present) {
            if ($rows.Count -ne 0) { throw "Forbidden TypeDef present '$TypeName': $LiteralPath" }
            return
        }
        if ($rows.Count -ne 1) { throw "TypeDef identity/count mismatch '$TypeName': $LiteralPath" }
        $row = $rows[0]
        if ([int]$row.attributes -ne $Attributes -or [int]$row.genericParameterCount -ne 0 -or [string]$row.baseType -cne [string]$BaseType) {
            throw "TypeDef flags/base/generic mismatch '$TypeName': expected attributes=$Attributes base=$BaseType generic=0; actual attributes=$($row.attributes) base=$($row.baseType) generic=$($row.genericParameterCount): $LiteralPath"
        }
        $actualInterfaces = @($row.interfaces | Sort-Object)
        $expectedInterfaces = @($Interfaces | Sort-Object)
        if (($actualInterfaces -join "`n") -cne ($expectedInterfaces -join "`n")) { throw "InterfaceImpl mismatch '$TypeName': $LiteralPath" }
    }

    $iPinned = $functional + 'IPinnedAncestorHandle'
    $iProbe = $functional + 'ILeafProbeHandle'
    $iContent = $functional + 'IApprovedContentHandle'
    $iPlatform = $functional + 'IProjectContextReadOnlyPlatform'
    $iCoordinator = $functional + 'IProjectContextRequestCoordinator'
    foreach ($interfaceName in @($iPinned,$iProbe,$iContent,$iPlatform,$iCoordinator)) {
        & $assertType $interfaceName $true ([int]$Policy.interfaceTypeAttributes) $null @()
    }

    $exactFieldSets = [ordered]@{
        $resultMetadata = @('<AggregateSha256>k__BackingField','<AllowlistId>k__BackingField','<Classification>k__BackingField','<ProjectionBytes>k__BackingField','<ProjectionSha256>k__BackingField','<Provenance>k__BackingField')
        $preparedRequest = @('<ExactPlanningPrompt>k__BackingField','<Metadata>k__BackingField')
        $agentResult = @('<ChainDepth>k__BackingField','<Decision>k__BackingField','<Payload>k__BackingField','<PreviousResultDigest>k__BackingField','<ResultDigest>k__BackingField','<Role>k__BackingField','<TaskDigest>k__BackingField')
        $pipelineResult = @('<Outcome>k__BackingField','<TraceId>k__BackingField','results')
        $contextSeal = @('<PlanningResultDigest>k__BackingField','<ProviderId>k__BackingField','<TaskDigest>k__BackingField')
    }
    if ($OutputKind -ceq 'Cli' -or $OutputKind -ceq 'IntakeHarness') {
        $exactFieldSets[$taskResponse] = @('<ChatCalls>k__BackingField','<ContextGuardDenied>k__BackingField','<ContextMetadata>k__BackingField','<ExitCode>k__BackingField','<Network>k__BackingField','<Outcome>k__BackingField','<Pipeline>k__BackingField','<PostflightDigestValidated>k__BackingField','<PreflightDigestValidated>k__BackingField','<ProviderId>k__BackingField','<Status>k__BackingField','<TagsCalls>k__BackingField','<TraceId>k__BackingField')
    }
    $outputFieldRows = @()
    foreach ($typeName in @($exactFieldSets.Keys)) {
        $actualFields = @($graph.fields | Where-Object { $_.declaringType -ceq $typeName } | Sort-Object name)
        $actualNames = @($actualFields | ForEach-Object { [string]$_.name })
        $expectedNames = @($exactFieldSets[$typeName] | Sort-Object)
        if (($actualNames -join "`n") -cne ($expectedNames -join "`n")) {
            throw "Context output-isolation field inventory mismatch '$typeName': $LiteralPath"
        }
        $outputFieldRows += $actualFields
    }

    $outputIsolationSurfaces = @(
        ($resultMetadata + '::.ctor'), ($resultMetadata + '::ToCanonicalJson'),
        ($preparedRequest + '::.ctor'),
        ($agentResult + '::ToCanonicalJson'),
        ($pipelineResult + '::ToCanonicalJson'),
        ($contextSeal + '::.ctor'), ($contextSeal + '::Create'), ($contextSeal + '::Validate'),
        ($planningAgent + '::Execute'), ($planningAgent + '::ExpectedPayload'),
        ($pipeline + '::Execute'), ($pipeline + '::ValidateContextSemanticPrefix'), ($pipeline + '::ValidateContextChain'),
        ($taskResponse + '::.ctor'), ($taskResponse + '::ToCanonicalJson'),
        ($intake + '::Execute')
    )
    $outputIsolationMethods = @($graph.methods | Where-Object {
        $outputIsolationSurfaces -ccontains ([string]$_.declaringType + '::' + [string]$_.name)
    })
    [string[]]$canonicalOutputIsolationMethods = @($outputIsolationMethods | ForEach-Object {
        [string]$_.declaringType + '|' + [string]$_.name + '|' + [string]$_.signature + '|' +
        [int]$_.attributes + '|' + [int]$_.implAttributes + '|' + [int]$_.genericParameterCount + '|' + [string]$_.ilSha256
    })
    [Array]::Sort($canonicalOutputIsolationMethods, [StringComparer]::Ordinal)
    $outputIsolationSha256 = Get-ByteArraySha256 -Bytes ([Text.Encoding]::UTF8.GetBytes(($canonicalOutputIsolationMethods -join "`n")))
    $outputIsolationProperty = $Policy.outputIsolationMethodIlInventory.PSObject.Properties[$OutputKind]
    if ($null -eq $outputIsolationProperty) { throw "Missing output-isolation MethodDef/IL inventory '$OutputKind': $LiteralPath" }
    $expectedOutputIsolation = $outputIsolationProperty.Value
    if ([int]$expectedOutputIsolation.count -ne $canonicalOutputIsolationMethods.Count -or
        [string]$expectedOutputIsolation.sha256 -cne $outputIsolationSha256) {
        throw "Profile-bound output-isolation MethodDef/IL inventory mismatch '$OutputKind': expected count=$([int]$expectedOutputIsolation.count) sha256=$([string]$expectedOutputIsolation.sha256); actual count=$($canonicalOutputIsolationMethods.Count) sha256=$outputIsolationSha256; output=$LiteralPath"
    }

    $native = $OutputKind -ceq 'Cli' -or $OutputKind -ceq 'ContextHarness'
    & $assertType $platform $native 1048832 'System.Object' @($iPlatform)
    & $assertType $lease $native ([int]$Policy.nativeLeaseTypeAttributes) 'System.Object' @()
    & $assertType $coordinator $native 1048832 'System.Object' @($iCoordinator)
    & $assertType $fakePlatform ($OutputKind -ceq 'ContextHarness') 1048835 'System.Object' @($iPlatform)
    & $assertType $fakeCoordinator ($OutputKind -ceq 'IntakeHarness') 1048835 'System.Object' @($iCoordinator)

    $tokenSets = [ordered]@{
        $iPinned = @($platform + '+PinnedAncestorToken')
        $iProbe = @($platform + '+LeafProbeToken')
        $iContent = @($platform + '+ApprovedContentToken')
    }
    if (-not $native) { foreach ($key in @($tokenSets.Keys)) { $tokenSets[$key] = @() } }
    if ($OutputKind -ceq 'ContextHarness') {
        $tokenSets[$iPinned] += $contextHarness + '+FakePinnedToken'
        $tokenSets[$iProbe] += $contextHarness + '+FakeProbeToken'
        $tokenSets[$iContent] += $contextHarness + '+FakeContentToken'
    }
    $implementerSets = [ordered]@{
        $iPlatform = $(if ($OutputKind -ceq 'Cli') { @($platform) } elseif ($OutputKind -ceq 'ContextHarness') { @($platform,$fakePlatform) } else { @() })
        $iCoordinator = $(if ($native) { @($coordinator) } elseif ($OutputKind -ceq 'IntakeHarness') { @($fakeCoordinator) } else { @() })
        $iPinned = @($tokenSets[$iPinned])
        $iProbe = @($tokenSets[$iProbe])
        $iContent = @($tokenSets[$iContent])
    }
    foreach ($interfaceName in @($implementerSets.Keys)) {
        $actual = @($graph.types | Where-Object { @($_.interfaces) -ccontains $interfaceName } | ForEach-Object fullName | Sort-Object)
        $expected = @($implementerSets[$interfaceName] | Sort-Object)
        if (($actual -join "`n") -cne ($expected -join "`n")) { throw "Complete implementer set mismatch '$interfaceName': $LiteralPath" }
    }
    foreach ($interfaceName in @($iPinned,$iProbe,$iContent)) {
        foreach ($tokenType in @($implementerSets[$interfaceName])) {
            & $assertType $tokenType $true 1048835 'System.Object' @($interfaceName)
        }
    }

    $controlledRows = @()
    $platformCtor = & $assertMethod $platform '.ctor' 0 $native ([Nullable[int]]6275)
    $coordinatorCtor = & $assertMethod $coordinator '.ctor' 1 $native ([Nullable[int]]6273)
    $fakePlatformCtor = & $assertMethod $fakePlatform '.ctor' 0 ($OutputKind -ceq 'ContextHarness') ([Nullable[int]]6275)
    $fakeCoordinatorCtor = & $assertMethod $fakeCoordinator '.ctor' 0 ($OutputKind -ceq 'IntakeHarness') ([Nullable[int]]6275)
    foreach ($typeName in @($platform,$lease,$coordinator,$fakePlatform,$fakeCoordinator)) {
        if (@($graph.methods | Where-Object { $_.declaringType -ceq $typeName -and $_.name -ceq '.cctor' }).Count -ne 0) { throw "Forbidden implementer type initializer '$typeName': $LiteralPath" }
    }

    $loaderCtor = & $assertMethod $loader '.ctor' 1 $true ([Nullable[int]]6273)
    $hasIntake = $OutputKind -ne 'ContextHarness'
    $intakeContextCtor = & $assertMethod $intake '.ctor' 2 $hasIntake ([Nullable[int]]6273) $false
    $loaderNative = & $assertMethod $loader 'CreateNative' 0 $native ([Nullable[int]]147)
    $loaderTests = & $assertMethod $loader 'CreateForTests' 1 ($OutputKind -eq 'ContextHarness' -or $OutputKind -eq 'IntakeHarness') ([Nullable[int]]147)
    $coordinatorNative = & $assertMethod $coordinator 'CreateNative' 0 $native ([Nullable[int]]147)
    $intakeNative = & $assertMethod $intake 'CreateNative' 1 ($OutputKind -eq 'Cli') ([Nullable[int]]147)
    $intakeTests = & $assertMethod $intake 'CreateForTests' 2 ($OutputKind -eq 'IntakeHarness') ([Nullable[int]]147)
    $contextHelper = & $assertMethod $contextHarness 'CreateLoaderForTests' 0 ($OutputKind -eq 'ContextHarness') ([Nullable[int]]145)
    $intakeHelper = & $assertMethod $intakeHarness 'CreateIntakeForTests' 0 ($OutputKind -eq 'IntakeHarness') ([Nullable[int]]145)
    $taskHostMain = & $assertMethod $taskHostType 'Main' 1 ($OutputKind -eq 'Cli') $null
    $contextMain = & $assertMethod $contextHarness 'Main' 1 ($OutputKind -eq 'ContextHarness') $null
    $intakeMain = & $assertMethod $intakeHarness 'Main' 1 ($OutputKind -eq 'IntakeHarness') $null

    $leaseCtor = & $assertMethod $lease '.ctor' 1 $native ([Nullable[int]]6273)
    $leaseCreate = & $assertMethod $lease 'Create' 1 $native ([Nullable[int]]147)
    $leaseClose = & $assertMethod $lease 'Close' 0 $native ([Nullable[int]][int]$Policy.nativeLeaseCloseMethodAttributes)
    $leaseGetHandle = & $assertMethod $lease 'get_Handle' 0 $native ([Nullable[int]]2179)
    $leaseSetHandle = & $assertMethod $lease 'set_Handle' 1 $native ([Nullable[int]]2177)
    $openPinnedAncestor = & $assertMethod $platform 'OpenPinnedAncestor' 1 $native $null
    $openLeafProbe = & $assertMethod $platform 'OpenLeafProbe' 1 $native $null
    $openApprovedContent = & $assertMethod $platform 'OpenApprovedContent' 1 $native $null
    $queryIdentityAndMetadata = & $assertMethod $platform 'QueryIdentityAndMetadata' 1 $native $null
    $queryAttributeTag = & $assertMethod $platform 'QueryAttributeTag' 1 $native $null
    $queryCanonicalFinalPath = & $assertMethod $platform 'QueryCanonicalFinalPath' 1 $native $null
    $readApprovedContent = & $assertMethod $platform 'ReadApprovedContent' 2 $native $null
    $closePinnedAncestor = & $assertMethod $platform 'ClosePinnedAncestor' 1 $native $null
    $closeLeafProbe = & $assertMethod $platform 'CloseLeafProbe' 1 $native $null
    $closeApprovedContent = & $assertMethod $platform 'CloseApprovedContent' 1 $native $null

    $controlledTypeNames = @($platform,$lease,$coordinator,$fakePlatform,$fakeCoordinator,$loader,$intake,$contextHarness,$intakeHarness,$taskHostType)
    foreach ($interfaceName in @($iPinned,$iProbe,$iContent,$iPlatform,$iCoordinator)) { $controlledTypeNames += $interfaceName }
    foreach ($key in @($implementerSets.Keys)) { $controlledTypeNames += @($implementerSets[$key]) }
    $controlledTypeNames = @($controlledTypeNames | Sort-Object -Unique)

    $inventoryNames = @('.ctor','.cctor','CreateNative','CreateForTests','CreateLoaderForTests','CreateIntakeForTests','Main')
    $nativeInventoryNames = @(
        'OpenPinnedAncestor','OpenLeafProbe','OpenApprovedContent','QueryIdentityAndMetadata','QueryAttributeTag',
        'QueryCanonicalFinalPath','ReadApprovedContent','ClosePinnedAncestor','CloseLeafProbe','CloseApprovedContent'
    )
    $seamInventoryRows = @($graph.methods | Where-Object {
        $controlledTypeNames -ccontains $_.declaringType -and
        ($_.declaringType -ceq $lease -or $inventoryNames -ccontains $_.name -or
         ($native -and ($_.declaringType -ceq $platform -or $_.declaringType -ceq $fakePlatform) -and $nativeInventoryNames -ccontains $_.name) -or
         $_.name -cmatch '^(?:Create|Construct|Make|New|GetInstance)')
    })
    [string[]]$canonicalSeamInventory = @($seamInventoryRows | ForEach-Object {
        [string]$_.declaringType + '|' + [string]$_.name + '|' + [string]$_.signature + '|' +
        [int]$_.attributes + '|' + [int]$_.implAttributes + '|' + [int]$_.genericParameterCount
    })
    [Array]::Sort($canonicalSeamInventory, [StringComparer]::Ordinal)
    $seamInventorySha256 = Get-ByteArraySha256 -Bytes ([Text.Encoding]::UTF8.GetBytes(($canonicalSeamInventory -join "`n")))
    $inventoryProperty = $Policy.seamMethodInventory.PSObject.Properties[$OutputKind]
    if ($null -eq $inventoryProperty) { throw "Missing profile-bound seam MethodDef inventory '$OutputKind': $LiteralPath" }
    $expectedInventory = $inventoryProperty.Value
    if ([int]$expectedInventory.count -ne $canonicalSeamInventory.Count -or
        [string]$expectedInventory.sha256 -cne $seamInventorySha256) {
        throw "Profile-bound seam MethodDef inventory mismatch '$OutputKind': expected count=$([int]$expectedInventory.count) sha256=$([string]$expectedInventory.sha256); actual count=$($canonicalSeamInventory.Count) sha256=$seamInventorySha256; output=$LiteralPath"
    }

    $unresolvedControlledOperands = @($graph.methodOperands | Where-Object {
        -not $_.resolvedMethodDefinition -and $null -ne $_.targetType -and $controlledTypeNames -ccontains $_.targetType
    })
    if ($unresolvedControlledOperands.Count -ne 0) {
        throw "Unresolved MemberRef/MethodSpec targets a controlled seam type: $LiteralPath"
    }

    foreach ($interfaceName in @($iPinned,$iProbe,$iContent)) {
        foreach ($tokenType in @($implementerSets[$interfaceName])) {
            $tokenParameterCount = if ($tokenType.StartsWith($platform + '+', [StringComparison]::Ordinal)) { 1 } else { 2 }
            [void](& $assertMethod $tokenType '.ctor' $tokenParameterCount $true ([Nullable[int]]6275))
            if (@($graph.methods | Where-Object { $_.declaringType -ceq $tokenType -and $_.name -ceq '.cctor' }).Count -ne 0) {
                throw "Forbidden token type initializer '$tokenType': $LiteralPath"
            }
        }
    }

    $operatorTypes = @($controlledTypeNames | Where-Object { $null -ne $_ })
    if (@($graph.methods | Where-Object {
        $operatorTypes -ccontains $_.declaringType -and ($_.name -ceq 'op_Implicit' -or $_.name -ceq 'op_Explicit')
    }).Count -ne 0) { throw "Controlled seam conversion operator is prohibited: $LiteralPath" }

    $allowedFactoryLike = @(
        ($loader + '::CreateNative'),
        ($loader + '::CreateForTests'),
        ($coordinator + '::CreateNative'),
        ($intake + '::CreateNative'),
        ($intake + '::CreateForTests'),
        ($contextHarness + '::CreateLoaderForTests'),
        ($intakeHarness + '::CreateIntakeForTests'),
        ($platform + '::CreateFileW'),
        ($lease + '::Create')
    )
    foreach ($method in @($graph.methods | Where-Object {
        $controlledTypeNames -ccontains $_.declaringType -and $_.name -cmatch '^(?:Create|Construct|Make|New|GetInstance)'
    })) {
        $surface = $method.declaringType + '::' + $method.name
        if ($allowedFactoryLike -cnotcontains $surface) { throw "Unapproved factory-like MethodDef '$surface': $LiteralPath" }
    }

    switch ($OutputKind) {
        'Cli' {
            & $assertIncoming $platformCtor @((& $methodId $loaderNative)) 'newobj'
            & $assertIncoming $coordinatorCtor @((& $methodId $coordinatorNative)) 'newobj'
            & $assertIncoming $loaderCtor @((& $methodId $loaderNative)) 'newobj'
            & $assertIncoming $intakeContextCtor @((& $methodId $intakeNative)) 'newobj'
            & $assertIncoming $loaderNative @((& $methodId $coordinatorNative)) 'call'
            & $assertIncoming $coordinatorNative @((& $methodId $intakeNative)) 'call'
            & $assertIncoming $intakeNative @((& $methodId $taskHostMain)) 'call'
        }
        'ContextHarness' {
            & $assertIncoming $platformCtor @((& $methodId $loaderNative)) 'newobj'
            & $assertIncoming $coordinatorCtor @((& $methodId $coordinatorNative)) 'newobj'
            & $assertIncoming $fakePlatformCtor @((& $methodId $contextHelper)) 'newobj'
            & $assertIncoming $loaderCtor @((& $methodId $loaderTests), (& $methodId $loaderNative)) 'newobj'
            & $assertIncoming $loaderNative @((& $methodId $coordinatorNative)) 'call'
            & $assertIncoming $loaderTests @((& $methodId $contextHelper)) 'call'
            & $assertIncoming $coordinatorNative @() 'call'
            & $assertIncoming $contextHelper @((& $methodId $contextMain)) 'call'
        }
        'IntakeHarness' {
            & $assertIncoming $fakeCoordinatorCtor @((& $methodId $intakeHelper)) 'newobj'
            & $assertIncoming $loaderCtor @((& $methodId $loaderTests)) 'newobj'
            & $assertIncoming $intakeContextCtor @((& $methodId $intakeTests)) 'newobj'
            & $assertIncoming $loaderTests @() 'call'
            & $assertIncoming $intakeTests @((& $methodId $intakeHelper)) 'call'
            & $assertIncoming $intakeHelper @((& $methodId $intakeMain)) 'call'
        }
        'ProviderHarness' {
            & $assertIncoming $loaderCtor @() 'newobj'
            & $assertIncoming $intakeContextCtor @() 'newobj'
        }
        'TransportHarness' {
            & $assertIncoming $loaderCtor @() 'newobj'
            & $assertIncoming $intakeContextCtor @() 'newobj'
        }
    }
    if ($native) {
        & $assertIncomingDetailed $leaseCtor @((& $methodId $leaseCreate) + '|newobj')
        & $assertIncomingDetailed $leaseCreate @(
            ((& $methodId $openPinnedAncestor) + '|call'),
            ((& $methodId $openLeafProbe) + '|call'),
            ((& $methodId $openApprovedContent) + '|call')
        )
        & $assertIncomingDetailed $leaseClose @(
            ((& $methodId $closePinnedAncestor) + '|callvirt'),
            ((& $methodId $closeLeafProbe) + '|callvirt'),
            ((& $methodId $closeApprovedContent) + '|callvirt')
        )
        & $assertIncomingDetailed $leaseGetHandle @(
            ((& $methodId $readApprovedContent) + '|callvirt'),
            ((& $methodId $queryIdentityAndMetadata) + '|callvirt'),
            ((& $methodId $queryAttributeTag) + '|callvirt'),
            ((& $methodId $queryCanonicalFinalPath) + '|callvirt'),
            ((& $methodId $leaseClose) + '|call')
        )
        & $assertIncomingDetailed $leaseSetHandle @(
            ((& $methodId $leaseCtor) + '|call'),
            ((& $methodId $leaseClose) + '|call')
        )
    }
    if ($OutputKind -eq 'ContextHarness') {
        $main = @(& $findMethods $contextHarness 'Main' 1)
        if ($main.Count -ne 1) { throw "Context harness entry point mismatch: $LiteralPath" }
        $frontier = @($main[0].declaringType + '::' + $main[0].name + '|' + $main[0].signature)
        $visited = @{}
        while ($frontier.Count -ne 0) {
            $current = $frontier[0]
            $frontier = @($frontier | Select-Object -Skip 1)
            if ($visited.ContainsKey($current)) { continue }
            $visited[$current] = $true
            $separator = $current.LastIndexOf('|', [StringComparison]::Ordinal)
            $surface = $current.Substring(0, $separator)
            $signature = $current.Substring($separator + 1)
            $nameSeparator = $surface.LastIndexOf('::', [StringComparison]::Ordinal)
            $callerType = $surface.Substring(0, $nameSeparator)
            $callerName = $surface.Substring($nameSeparator + 2)
            foreach ($edge in @($graph.directEdges | Where-Object { $_.callerType -ceq $callerType -and $_.callerName -ceq $callerName -and $_.callerSignature -ceq $signature })) {
                $next = $edge.targetType + '::' + $edge.targetName + '|' + $edge.targetSignature
                if (-not $visited.ContainsKey($next)) { $frontier += $next }
            }
        }
        foreach ($forbidden in @(($loader + '::CreateNative'), ($coordinator + '::CreateNative'), ($platform + '::.ctor'), ($coordinator + '::.ctor'))) {
            if (@($visited.Keys | Where-Object { $_.StartsWith($forbidden + '|', [StringComparison]::Ordinal) }).Count -ne 0) {
                throw "Context harness entry point reaches native construction '$forbidden': $LiteralPath"
            }
        }
    }

    $dynamicEvidence = if ($OutputKind -in @('Cli','ContextHarness','IntakeHarness')) {
        Assert-ProjectContextDynamicConstructionPolicy -LiteralPath $LiteralPath
    }
    else {
        [ordered]@{ applicability = 'NOT_APPLICABLE_NO_CONTEXT_CONSTRUCTION_FACTORY'; forbiddenTypeRefs = 0; forbiddenMemberRefs = 0 }
    }
    foreach ($row in @($seamInventoryRows | Sort-Object declaringType,name,signature)) {
        $controlledRows += [ordered]@{
            declaringType = [string]$row.declaringType
            managedName = [string]$row.name
            signature = [string]$row.signature
            attributes = [int]$row.attributes
            implAttributes = [int]$row.implAttributes
            genericParameterCount = [int]$row.genericParameterCount
            ilSha256 = [string]$row.ilSha256
        }
    }
    return [ordered]@{
        outputKind = $OutputKind
        seamPolicyPass = $true
        calliCount = 0
        dynamicConstruction = $dynamicEvidence
        methodInventoryCount = [int]$canonicalSeamInventory.Count
        methodInventorySha256 = $seamInventorySha256
        methodInventoryProfileMatch = $true
        outputIsolationFieldInventoryCount = [int]$outputFieldRows.Count
        outputIsolationMethodIlInventoryCount = [int]$canonicalOutputIsolationMethods.Count
        outputIsolationMethodIlInventorySha256 = $outputIsolationSha256
        outputIsolationProfileMatch = $true
        controlledMethods = $controlledRows
    }
}
function Get-ProjectContextPInvokeMetadata {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)
    $stream = [System.IO.File]::OpenRead($LiteralPath)
    $peReader = [System.Reflection.PortableExecutable.PEReader]::new($stream)
    try {
        $reader = [System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($peReader)
        $rows = @()
        foreach ($typeHandle in $reader.TypeDefinitions) {
            $type = $reader.GetTypeDefinition($typeHandle)
            $typeName = Get-MetadataTypeName -MetadataReader $reader -TypeHandle $typeHandle
            foreach ($methodHandle in $type.GetMethods()) {
                $method = $reader.GetMethodDefinition($methodHandle)
                if (([int]$method.Attributes -band [int][Reflection.MethodAttributes]::PinvokeImpl) -eq 0) { continue }
                $import = $method.GetImport()
                $rows += [ordered]@{
                    declaringType = $typeName
                    managedName = $reader.GetString($method.Name)
                    importName = $reader.GetString($import.Name)
                    module = $reader.GetString($reader.GetModuleReference($import.Module).Name)
                    methodImportAttributes = [int]$import.Attributes
                    methodAttributes = [int]$method.Attributes
                    methodImplAttributes = [int]$method.ImplAttributes
                    signature = [BitConverter]::ToString($reader.GetBlobBytes($method.Signature)).Replace('-', '')
                }
            }
        }
        $sortedRows = @($rows | Sort-Object { [string]$_.managedName })
        $modules = @($sortedRows | ForEach-Object { $_.module } | Sort-Object -Unique)
        return [ordered]@{ modules = $modules; rows = $sortedRows }
    }
    finally { $peReader.Dispose(); $stream.Dispose() }
}

function Assert-ProjectContextPInvokePolicy {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][ValidateSet('Cli','ContextHarness','KnowledgeCli','ProjectQaCli','LocalOperatorCli')][string]$OutputKind,
        [switch]$Discovery
    )
    $actual = Get-ProjectContextPInvokeMetadata -LiteralPath $LiteralPath
    if ($actual.modules.Count -ne 1 -or $actual.modules[0] -cne [string]$Policy.module) { throw "Project-context ModuleRef set mismatch: $LiteralPath" }
    $expectedNames = @($Policy.entryPoints | ForEach-Object { [string]$_ } | Sort-Object)
    if ($actual.rows.Count -ne 6 -or ($actual.rows.managedName -join "`n") -cne ($expectedNames -join "`n")) { throw "Project-context P/Invoke set mismatch: $LiteralPath" }
    $signatureProperty = $Policy.nativeImportSignatures.PSObject.Properties[$OutputKind]
    $newOutputDiscovery = $Discovery -and ($OutputKind -ceq 'KnowledgeCli' -or $OutputKind -ceq 'ProjectQaCli' -or $OutputKind -ceq 'LocalOperatorCli')
    if ($null -eq $signatureProperty -and -not $newOutputDiscovery) { throw "Missing profile-bound P/Invoke signatures '$OutputKind': $LiteralPath" }
    $expectedSignatures = if ($null -eq $signatureProperty) { $null } else { $signatureProperty.Value }
    foreach ($row in $actual.rows) {
        $expectedSignatureProperty = if ($null -eq $expectedSignatures) { $null } else { $expectedSignatures.PSObject.Properties[[string]$row.managedName] }
        if ($row.declaringType -cne [string]$Policy.declaringType -or $row.managedName -cne $row.importName -or
            $row.module -cne [string]$Policy.module -or
            $row.methodImportAttributes -ne [int]$Policy.methodImportAttributes -or
            $row.methodAttributes -ne [int]$Policy.methodAttributes -or
            $row.methodImplAttributes -ne [int]$Policy.methodImplAttributes -or
            (-not $newOutputDiscovery -and
             ($null -eq $expectedSignatureProperty -or $row.signature -cne [string]$expectedSignatureProperty.Value))) {
            throw "Project-context P/Invoke row/signature mismatch: actualRows=$($actual.rows | ConvertTo-Json -Compress) expectedKind=${OutputKind}: $LiteralPath"
        }
    }
    return $actual
}

function Get-LoopbackMetadataReferences {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)

    $stream = [System.IO.File]::OpenRead($LiteralPath)
    $peReader = [System.Reflection.PortableExecutable.PEReader]::new($stream)
    try {
        $metadataReader = [System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($peReader)
        $typeRows = @()
        foreach ($handle in $metadataReader.TypeReferences) {
            $typeReference = $metadataReader.GetTypeReference($handle)
            $namespace = $metadataReader.GetString($typeReference.Namespace)
            if ($namespace -cne 'System.IO' -and -not $namespace.StartsWith('System.IO.', [StringComparison]::Ordinal) -and
                $namespace -cne 'System.Net' -and -not $namespace.StartsWith('System.Net.', [StringComparison]::Ordinal)) { continue }
            $typeRows += "$namespace.$($metadataReader.GetString($typeReference.Name))|scope=$($typeReference.ResolutionScope.Kind)"
        }

        $memberRows = @()
        foreach ($handle in $metadataReader.MemberReferences) {
            $memberReference = $metadataReader.GetMemberReference($handle)
            if ($memberReference.Parent.Kind -ne [System.Reflection.Metadata.HandleKind]::TypeReference) { continue }
            $typeReference = $metadataReader.GetTypeReference(
                [System.Reflection.Metadata.TypeReferenceHandle]$memberReference.Parent
            )
            $namespace = $metadataReader.GetString($typeReference.Namespace)
            if ($namespace -cne 'System.IO' -and -not $namespace.StartsWith('System.IO.', [StringComparison]::Ordinal) -and
                $namespace -cne 'System.Net' -and -not $namespace.StartsWith('System.Net.', [StringComparison]::Ordinal)) { continue }
            $signature = [BitConverter]::ToString(
                $metadataReader.GetBlobBytes($memberReference.Signature)
            ).Replace('-', '')
            $memberRows += "$namespace.$($metadataReader.GetString($typeReference.Name))::$($metadataReader.GetString($memberReference.Name))|$signature"
        }

        return [ordered]@{
            typeReferences = @($typeRows | Group-Object | Sort-Object Name | ForEach-Object { "$($_.Name)|count=$($_.Count)" })
            memberReferences = @($memberRows | Group-Object | Sort-Object Name | ForEach-Object { "$($_.Name)|count=$($_.Count)" })
        }
    }
    finally {
        $peReader.Dispose()
        $stream.Dispose()
    }
}

function Assert-LoopbackMetadataPolicy {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [Parameter(Mandatory = $true)]$Policy,
        [switch]$DevelopmentProbe
    )

    $actual = Get-LoopbackMetadataReferences -LiteralPath $LiteralPath
    $expectedTypes = @($Policy.typeReferences | ForEach-Object { [string]$_ } | Sort-Object)
    $expectedMembers = @($Policy.memberReferences | ForEach-Object { [string]$_ } | Sort-Object)
    $actualTypes = @($actual.typeReferences)
    $actualMembers = @($actual.memberReferences)
    if (($expectedTypes -join [Environment]::NewLine) -cne ($actualTypes -join [Environment]::NewLine)) {
        throw "CLI loopback TypeRef allowlist mismatch. Actual: $($actualTypes -join ', ')"
    }
    if ($DevelopmentProbe) {
        $expectedMemberSurface = @($expectedMembers | ForEach-Object { $_ -replace '\|[0-9A-F]+\|count=', '|count=' } | Sort-Object)
        $actualMemberSurface = @($actualMembers | ForEach-Object { $_ -replace '\|[0-9A-F]+\|count=', '|count=' } | Sort-Object)
        if (($expectedMemberSurface -join [Environment]::NewLine) -cne ($actualMemberSurface -join [Environment]::NewLine)) {
            throw "CLI loopback MemberRef surface mismatch in DevelopmentProbe. Actual: $($actualMembers -join ', ')"
        }
    }
    elseif (($expectedMembers -join [Environment]::NewLine) -cne ($actualMembers -join [Environment]::NewLine)) {
        throw "CLI loopback MemberRef allowlist mismatch. Actual: $($actualMembers -join ', ')"
    }
}

function Get-SystemIoMemberReferences {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)

    $stream = [System.IO.File]::OpenRead($LiteralPath)
    $peReader = [System.Reflection.PortableExecutable.PEReader]::new($stream)
    try {
        $metadataReader = [System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($peReader)
        $references = @()
        foreach ($handle in $metadataReader.MemberReferences) {
            $memberReference = $metadataReader.GetMemberReference($handle)
            if ($memberReference.Parent.Kind -ne [System.Reflection.Metadata.HandleKind]::TypeReference) { continue }

            $typeReference = $metadataReader.GetTypeReference(
                [System.Reflection.Metadata.TypeReferenceHandle]$memberReference.Parent
            )
            $namespace = $metadataReader.GetString($typeReference.Namespace)
            if ($namespace -cne 'System.IO' -and -not $namespace.StartsWith('System.IO.', [StringComparison]::Ordinal)) { continue }

            $typeName = $metadataReader.GetString($typeReference.Name)
            $memberName = $metadataReader.GetString($memberReference.Name)
            $references += "$namespace.$typeName::$memberName"
        }
        return @($references | Sort-Object -Unique)
    }
    finally {
        $peReader.Dispose()
        $stream.Dispose()
    }
}

function Assert-SystemIoMemberReferencePolicy {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [switch]$AllowServiceHostReadOnly,
        [switch]$AllowProjectKnowledgeStdout
    )

    $references = @(Get-SystemIoMemberReferences -LiteralPath $LiteralPath)
    if ($AllowProjectKnowledgeStdout) {
        $allowedReferences = @('System.IO.Stream::Write')
        if (($references -join [Environment]::NewLine) -cne ($allowedReferences -join [Environment]::NewLine)) {
            throw "Project-knowledge System.IO references do not match the exact stdout-only allowlist: $($references -join ', '): $LiteralPath"
        }
        return
    }

    if (-not $AllowServiceHostReadOnly) {
        if ($references.Count -ne 0) {
            throw "Compiled output contains prohibited System.IO member reference(s): $($references -join ', '): $LiteralPath"
        }
        return
    }

    $allowedReferences = @(
        'System.IO.File::Exists',
        'System.IO.Path::IsPathRooted'
    )
    $unexpectedReferences = @($references | Where-Object { $allowedReferences -cnotcontains $_ })
    if ($unexpectedReferences.Count -ne 0 -or
        $references.Count -ne $allowedReferences.Count -or
        @($allowedReferences | Where-Object { $references -cnotcontains $_ }).Count -ne 0) {
        throw "Compiled service host System.IO member references do not match the exact read-only allowlist: $($references -join ', '): $LiteralPath"
    }
}

function Invoke-ExitCodeTest {
    param(
        [Parameter(Mandatory = $true)][string]$Executable,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$Arguments
    )

    $output = @(& $Executable @Arguments 2>&1)
    return [ordered]@{
        exitCode = $LASTEXITCODE
        output = ($output -join "`n")
    }
}

function Invoke-ExactChannelTest {
    param([Parameter(Mandatory = $true)][string]$Executable,
          [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$Arguments)
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $Executable
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    foreach ($argument in $Arguments) { [void]$info.ArgumentList.Add($argument) }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $info
    $stdout = [IO.MemoryStream]::new()
    $stderr = [IO.MemoryStream]::new()
    try {
        if (-not $process.Start()) { throw "Unable to start channel test: $Executable" }
        $process.StandardOutput.BaseStream.CopyTo($stdout)
        $process.StandardError.BaseStream.CopyTo($stderr)
        $process.WaitForExit()
        return [ordered]@{
            exitCode = $process.ExitCode
            stdoutBytes = [byte[]]$stdout.ToArray()
            stderrBytes = [byte[]]$stderr.ToArray()
            stdoutSha256 = Get-ByteArraySha256 -Bytes ([byte[]]$stdout.ToArray())
            stderrSha256 = Get-ByteArraySha256 -Bytes ([byte[]]$stderr.ToArray())
        }
    }
    finally { $stdout.Dispose(); $stderr.Dispose(); $process.Dispose() }
}

function New-ProjectKnowledgeFixtureRoot {
    param([Parameter(Mandatory = $true)][string]$LiteralRoot,
          [Parameter(Mandatory = $true)][string[]]$PathLiterals,
          [ValidateSet('ZERO','ONE','MISSING')][string]$Mode)
    New-Item -ItemType Directory -Path $LiteralRoot | Out-Null
    for ($index = 0; $index -lt $PathLiterals.Count; $index++) {
        if ($Mode -ceq 'MISSING' -and $index -eq $PathLiterals.Count - 1) { continue }
        $path = Join-Path $LiteralRoot ($PathLiterals[$index].Replace('/','\'))
        New-Item -ItemType Directory -Path ([IO.Path]::GetDirectoryName($path)) -Force | Out-Null
        $body = if ($Mode -ceq 'ONE' -and $index -eq 0) { "---`nx: y`n---`na`n" } else { "---`nx: y`n---`nz`n" }
        [IO.File]::WriteAllText($path,$body,[Text.UTF8Encoding]::new($false))
    }
}

function Replace-ExactSpecimenText {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Old,
        [Parameter(Mandatory = $true)][string]$New,
        [Parameter(Mandatory = $true)][string]$SpecimenName
    )
    $count = [regex]::Matches($Text, [regex]::Escape($Old)).Count
    if ($count -ne 1) { throw "Negative specimen anchor count '$SpecimenName' is $count." }
    return $Text.Replace($Old, $New)
}

function Invoke-SeamNegativeSpecimen {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$CompilerPath,
        [Parameter(Mandatory = $true)][object[]]$CompilerArguments,
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$ReplacementSources,
        [Parameter(Mandatory = $true)][string]$SpecimenRoot,
        [Parameter(Mandatory = $true)][ValidateSet('Cli','ContextHarness','IntakeHarness')][string]$OutputKind,
        [Parameter(Mandatory = $true)]$Policy
    )

    $safeName = $Name.ToLowerInvariant().Replace('_', '-')
    $root = Join-Path $SpecimenRoot $safeName
    New-Item -ItemType Directory -Path $root | Out-Null
    $arguments = @($CompilerArguments)
    foreach ($originalPath in @($ReplacementSources.Keys)) {
        $specimenSourcePath = Join-Path $root ([System.IO.Path]::GetFileName([string]$originalPath))
        [System.IO.File]::WriteAllText($specimenSourcePath, [string]$ReplacementSources[$originalPath], [System.Text.UTF8Encoding]::new($false))
        $argumentIndex = [Array]::IndexOf($arguments, [string]$originalPath)
        if ($argumentIndex -lt 0) { throw "Negative specimen source argument missing '$Name'." }
        $arguments[$argumentIndex] = $specimenSourcePath
    }
    $outputPath = Join-Path $root ($safeName + '.exe')
    $outputArgumentIndexes = @(for ($argumentIndex = 0; $argumentIndex -lt $arguments.Count; $argumentIndex++) {
        if ([string]$arguments[$argumentIndex] -clike '/out:*') { $argumentIndex }
    })
    if ($outputArgumentIndexes.Count -ne 1) { throw "Negative specimen output argument mismatch '$Name'." }
    $arguments[$outputArgumentIndexes[0]] = "/out:$outputPath"
    $compilerOutput = @(& $CompilerPath @arguments 2>&1)
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $outputPath -PathType Leaf)) {
        throw "Negative specimen did not compile '$Name': $($compilerOutput -join [Environment]::NewLine)"
    }
    $rejection = $null
    try {
        Assert-SystemIoMemberReferencePolicy -LiteralPath $outputPath
        [void](Assert-ProjectContextSeamPolicy -LiteralPath $outputPath -OutputKind $OutputKind -Policy $Policy)
    }
    catch { $rejection = $_.Exception.Message }
    if ([String]::IsNullOrEmpty($rejection)) { throw "Negative specimen was not rejected '$Name'." }
    return [ordered]@{
        name = $Name
        compileExitCode = 0
        verifierRejected = $true
        outputKind = $OutputKind
    }
}

function Invoke-NativeNegativeSpecimen {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$CompilerPath,
        [Parameter(Mandatory = $true)][object[]]$CompilerArguments,
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$ReplacementSources,
        [Parameter(Mandatory = $true)][string]$SpecimenRoot,
        [Parameter(Mandatory = $true)][ValidateSet('Cli','ContextHarness')][string]$OutputKind,
        [Parameter(Mandatory = $true)]$Policy
    )

    $safeName = $Name.ToLowerInvariant().Replace('_', '-')
    $root = Join-Path $SpecimenRoot $safeName
    New-Item -ItemType Directory -Path $root | Out-Null
    $arguments = @($CompilerArguments)
    foreach ($originalPath in @($ReplacementSources.Keys)) {
        $specimenSourcePath = Join-Path $root ([System.IO.Path]::GetFileName([string]$originalPath))
        [System.IO.File]::WriteAllText($specimenSourcePath, [string]$ReplacementSources[$originalPath], [System.Text.UTF8Encoding]::new($false))
        $argumentIndex = [Array]::IndexOf($arguments, [string]$originalPath)
        if ($argumentIndex -lt 0) { throw "Native negative specimen source argument missing '$Name'." }
        $arguments[$argumentIndex] = $specimenSourcePath
    }
    $outputPath = Join-Path $root ($safeName + '.exe')
    $outputArgumentIndexes = @(for ($argumentIndex = 0; $argumentIndex -lt $arguments.Count; $argumentIndex++) {
        if ([string]$arguments[$argumentIndex] -clike '/out:*') { $argumentIndex }
    })
    if ($outputArgumentIndexes.Count -ne 1) { throw "Native negative specimen output argument mismatch '$Name'." }
    $arguments[$outputArgumentIndexes[0]] = "/out:$outputPath"
    $compilerOutput = @(& $CompilerPath @arguments 2>&1)
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $outputPath -PathType Leaf)) {
        throw "Native negative specimen did not compile '$Name': $($compilerOutput -join [Environment]::NewLine)"
    }
    $rejection = $null
    try {
        [void](Assert-ProjectContextPInvokePolicy -LiteralPath $outputPath -Policy $Policy -OutputKind $OutputKind)
        [void](Assert-ProjectContextPInvokeCallerPolicy -LiteralPath $outputPath -Policy $Policy -OutputKind $OutputKind)
        [void](Assert-ProjectContextSeamPolicy -LiteralPath $outputPath -OutputKind $OutputKind -Policy $Policy)
    }
    catch { $rejection = $_.Exception.Message }
    if ([String]::IsNullOrEmpty($rejection)) { throw "Native negative specimen was not rejected '$Name'." }
    return [ordered]@{
        name = $Name
        compileExitCode = 0
        verifierRejected = $true
        outputKind = $OutputKind
    }
}

function Invoke-ProjectKnowledgeNegativeSpecimen {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$CompilerPath,
        [Parameter(Mandatory = $true)][object[]]$CompilerArguments,
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$ReplacementSources,
        [Parameter(Mandatory = $true)][string]$SpecimenRoot,
        [Parameter(Mandatory = $true)]$ProjectKnowledgePolicy,
        [Parameter(Mandatory = $true)]$ProjectContextPolicy,
        [Parameter(Mandatory = $true)]$BaselineMetadata
    )
    $safeName = $Name.ToLowerInvariant().Replace('_','-')
    $root = Join-Path $SpecimenRoot $safeName
    New-Item -ItemType Directory -Path $root | Out-Null
    $arguments = @($CompilerArguments)
    foreach ($originalPath in @($ReplacementSources.Keys)) {
        $specimenPath = Join-Path $root ([IO.Path]::GetFileName([string]$originalPath))
        [IO.File]::WriteAllText($specimenPath,[string]$ReplacementSources[$originalPath],[Text.UTF8Encoding]::new($false))
        $index = [Array]::IndexOf($arguments,[string]$originalPath)
        if ($index -lt 0) { throw "Knowledge specimen source argument missing '$Name'." }
        $arguments[$index] = $specimenPath
    }
    $output = Join-Path $root ($safeName + '.exe')
    $outputIndexes = @(for($i=0;$i-lt$arguments.Count;$i++){if([string]$arguments[$i] -clike '/out:*'){$i}})
    if ($outputIndexes.Count -ne 1) { throw "Knowledge specimen output argument mismatch '$Name'." }
    $arguments[$outputIndexes[0]] = "/out:$output"
    $compilerOutput = @(& $CompilerPath @arguments 2>&1)
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $output -PathType Leaf)) {
        throw "Knowledge specimen did not compile '$Name': $($compilerOutput -join [Environment]::NewLine)"
    }
    $rejection = $null
    try {
        Assert-NoForbiddenBinaryMetadata -LiteralPath $output -AllowProjectContextPInvoke
        Assert-SystemIoMemberReferencePolicy -LiteralPath $output -AllowProjectKnowledgeStdout
        [void](Assert-ProjectContextPInvokePolicy -LiteralPath $output -Policy $ProjectContextPolicy -OutputKind 'KnowledgeCli' -Discovery)
        [void](Assert-ProjectContextPInvokeCallerPolicy -LiteralPath $output -Policy $ProjectContextPolicy -OutputKind 'KnowledgeCli' -Discovery)
        $actualMetadata = Get-ProjectKnowledgeMetadataClosure -LiteralPath $output
        if (($actualMetadata | ConvertTo-Json -Depth 8 -Compress) -cne ($BaselineMetadata | ConvertTo-Json -Depth 8 -Compress)) {
            throw "Project-knowledge baseline metadata closure mismatch: $output"
        }
    }
    catch { $rejection = $_.Exception.Message }
    if ([String]::IsNullOrEmpty($rejection)) { throw "Knowledge negative specimen was not rejected '$Name'." }
    return [ordered]@{ name=$Name; compileExitCode=0; verifierRejected=$true; outputKind='KnowledgeCli' }
}

function Invoke-ProjectQaNegativeSpecimen {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$CompilerPath,
        [Parameter(Mandatory = $true)][object[]]$CompilerArguments,
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$ReplacementSources,
        [Parameter(Mandatory = $true)][string]$SpecimenRoot,
        [Parameter(Mandatory = $true)]$ProjectQaPolicy,
        [Parameter(Mandatory = $true)]$ProjectContextPolicy,
        [Parameter(Mandatory = $true)]$LoopbackPolicy,
        [Parameter(Mandatory = $true)]$BaselineMetadata,
        [string]$AdditionalSourceText
    )
    $safeName = $Name.ToLowerInvariant().Replace('_','-')
    $root = Join-Path $SpecimenRoot $safeName
    New-Item -ItemType Directory -Path $root | Out-Null
    $arguments = @($CompilerArguments)
    foreach ($originalPath in @($ReplacementSources.Keys)) {
        $specimenPath = Join-Path $root ([IO.Path]::GetFileName([string]$originalPath))
        [IO.File]::WriteAllText($specimenPath,[string]$ReplacementSources[$originalPath],[Text.UTF8Encoding]::new($false))
        $index = [Array]::IndexOf($arguments,[string]$originalPath)
        if ($index -lt 0) { throw "Project-QA specimen source argument missing '$Name'." }
        $arguments[$index] = $specimenPath
    }
    if (-not [String]::IsNullOrEmpty($AdditionalSourceText)) {
        $additionalPath = Join-Path $root 'AdditionalQaSource.cs'
        [IO.File]::WriteAllText($additionalPath,$AdditionalSourceText,[Text.UTF8Encoding]::new($false))
        $arguments += $additionalPath
    }
    $output = Join-Path $root ($safeName + '.exe')
    $outputIndexes = @(for($i=0;$i-lt$arguments.Count;$i++){if([string]$arguments[$i] -clike '/out:*'){$i}})
    if ($outputIndexes.Count -ne 1) { throw "Project-QA specimen output argument mismatch '$Name'." }
    $arguments[$outputIndexes[0]] = "/out:$output"
    $compilerOutput = @(& $CompilerPath @arguments 2>&1)
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $output -PathType Leaf)) { throw "Project-QA specimen did not compile '$Name': $($compilerOutput -join [Environment]::NewLine)" }
    $rejection = $null
    try {
        Assert-NoForbiddenBinaryMetadata -LiteralPath $output -AllowLoopbackHttp -AllowProjectContextPInvoke
        [void](Assert-ProjectContextPInvokePolicy -LiteralPath $output -Policy $ProjectContextPolicy -OutputKind 'ProjectQaCli' -Discovery)
        [void](Assert-ProjectContextPInvokeCallerPolicy -LiteralPath $output -Policy $ProjectContextPolicy -OutputKind 'ProjectQaCli' -Discovery)
        Assert-LoopbackMetadataPolicy -LiteralPath $output -Policy $LoopbackPolicy
        $actual = Get-ProjectQaMetadataClosure -LiteralPath $output
        if (($actual | ConvertTo-Json -Depth 8 -Compress) -cne ($BaselineMetadata | ConvertTo-Json -Depth 8 -Compress)) { throw "Project-QA baseline metadata closure mismatch: $output" }
    }
    catch { $rejection = $_.Exception.Message }
    if ([String]::IsNullOrEmpty($rejection)) { throw "Project-QA negative specimen was not rejected '$Name'." }
    return [ordered]@{ name=$Name; compileExitCode=0; verifierRejected=$true; outputKind='ProjectQaCli' }
}

function Invoke-LocalOperatorNegativeSpecimen {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$CompilerPath,
        [Parameter(Mandatory = $true)][string[]]$CompilerArguments,
        [Parameter(Mandatory = $true)][string]$SourceText,
        [Parameter(Mandatory = $true)][string]$SpecimenRoot,
        [Parameter(Mandatory = $true)]$BaselineMetadata
    )
    $source = Join-Path $SpecimenRoot ($Name + '.cs')
    $output = Join-Path $SpecimenRoot ($Name + '.exe')
    Set-Content -LiteralPath $source -Value $SourceText -Encoding UTF8
    $arguments = @($CompilerArguments | Where-Object { -not $_.StartsWith('/out:', [StringComparison]::OrdinalIgnoreCase) })
    $arguments += "/out:$output"
    $arguments += $source
    $compilerOutput = @(& $CompilerPath @arguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Local Operator negative specimen did not compile '$Name': $($compilerOutput -join [Environment]::NewLine)" }
    $rejected = $false
    try {
        Assert-NoForbiddenBinaryMetadata -LiteralPath $output -AllowLoopbackHttp -AllowProjectContextPInvoke
        Assert-SystemIoMemberReferencePolicy -LiteralPath $output -AllowProjectKnowledgeStdout
        $actual = Get-ProjectQaMetadataClosure -LiteralPath $output
        if (($actual | ConvertTo-Json -Depth 8 -Compress) -cne ($BaselineMetadata | ConvertTo-Json -Depth 8 -Compress)) {
            throw 'Compiled metadata differs from the sealed Local Operator baseline.'
        }
    }
    catch { $rejected = $true }
    if (-not $rejected) { throw "Local Operator negative specimen was not rejected '$Name'." }
    return [ordered]@{ id=$Name; mutationKind='LEGACY_ADDITIONAL_SOURCE'; compileExitCode=0; rejected=$true; rejectionRule='LEGACY_POLICY_REJECTION' }
}

function Invoke-LocalOperatorHealthNegativeSpecimen {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string]$MutationKind,
        [Parameter(Mandatory = $true)][string]$ExpectedRule,
        [Parameter(Mandatory = $true)][string]$CompilerPath,
        [Parameter(Mandatory = $true)][string[]]$CompilerArguments,
        [Parameter(Mandatory = $true)][string]$CandidateSourcePath,
        [Parameter(Mandatory = $true)][string]$CandidateSourceText,
        [Parameter(Mandatory = $true)][string]$SpecimenRoot,
        [Parameter(Mandatory = $true)]$ProjectContextPolicy,
        [Parameter(Mandatory = $true)]$LoopbackPolicy
    )
    $sourceText = $CandidateSourceText
    $payloadAnchor = 'string payload = LocalOperatorHealth.CanonicalPayload;'
    switch ($Id) {
        'HEALTH_FILESYSTEM_ENVIRONMENT_PROBE' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old $payloadAnchor -New ('if (Environment.GetEnvironmentVariable("EAIRA_HEALTH_PROBE") != null || System.IO.File.Exists("EAIRA_HEALTH_PROBE")) throw new LocalOperatorException();' + "`n            " + $payloadAnchor) -SpecimenName $Id }
        'HEALTH_DIRECT_SOCKET_CONSTRUCTION' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old $payloadAnchor -New ('using (System.Net.Sockets.TcpClient forbidden = new System.Net.Sockets.TcpClient()) { if (forbidden.Connected) throw new LocalOperatorException(); }' + "`n            " + $payloadAnchor) -SpecimenName $Id }
        'HEALTH_ADAPTER_FACTORY_INVOCATION' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old $payloadAnchor -New ('if (factory.CreateTask() != null) throw new LocalOperatorException();' + "`n            " + $payloadAnchor) -SpecimenName $Id }
        'HEALTH_RUNTIME_OBSERVATION' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old $payloadAnchor -New ('long forbiddenTicks = DateTime.UtcNow.Ticks; int forbiddenRandom = new Random(1).Next(); object forbiddenProcess = new System.Diagnostics.ProcessStartInfo("cmd.exe"); object forbiddenRegistry = Microsoft.Win32.Registry.CurrentUser; if (forbiddenTicks == forbiddenRandom && forbiddenProcess == forbiddenRegistry) throw new LocalOperatorException();' + "`n            " + $payloadAnchor) -SpecimenName $Id }
        'HEALTH_ADDITIONAL_PAYLOAD_MEMBER' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old '\"providerConstruction\":\"NONE\",\"authority\":\"OBSERVATIONAL_NOT_AUTHORITY\"}' -New '\"providerConstruction\":\"NONE\",\"extra\":\"FORBIDDEN\",\"authority\":\"OBSERVATIONAL_NOT_AUTHORITY\"}' -SpecimenName $Id }
        'HEALTH_OBSERVATION_AUTHORITY_MUTATION' {
            $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old '\"observationScope\":\"COMPILED_CONTRACT_ONLY\",\"operatorSchema\"' -New '\"observationScope\":\"RUNTIME_OBSERVED\",\"operatorSchema\"' -SpecimenName ($Id + '_STEP_1')
            $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old '\"writes\":\"NONE\",\"providerConstruction\":\"NONE\",\"authority\":\"OBSERVATIONAL_NOT_AUTHORITY\"}' -New '\"writes\":\"NONE\",\"providerConstruction\":\"NONE\",\"authority\":\"AUTHORITATIVE\"}' -SpecimenName ($Id + '_STEP_2')
        }
        'HEALTH_PROVIDER_MODEL_ROOT_ACCEPTANCE' {
            $anchor = 'if (args[0] == "knowledge" && args.Length == 7 && args[1] == "--root" && args[3] == "--trace" && args[5] == "--query")'
            $insert = 'if (args[0] == "health" && args.Length == 9 && args[1] == "--trace" && args[3] == "--provider" && args[4] == "ollama-local" && args[5] == "--model" && args[6] == "qwen3:4b" && args[7] == "--root")' + "`n" +
                '                return new LocalOperatorRequest(LocalOperatorCapability.Health, args[2], "OLLAMA_LOOPBACK_V1", "qwen3:4b", args[8], "HEALTH", "COMPILED CONTRACT STATUS", null);' + "`n            " + $anchor
            $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old $anchor -New $insert -SpecimenName $Id
        }
        default { throw "Unknown Health specimen '$Id'." }
    }
    $root = Join-Path $SpecimenRoot $Id.ToLowerInvariant().Replace('_','-')
    New-Item -ItemType Directory -Path $root | Out-Null
    $sourcePath = Join-Path $root 'LocalOperator.cs'
    [IO.File]::WriteAllText($sourcePath,$sourceText,[Text.UTF8Encoding]::new($false))
    $outputPath = Join-Path $root ($Id.ToLowerInvariant().Replace('_','-') + '.exe')
    $arguments = @($CompilerArguments)
    $sourceIndexes = @(for($i=0;$i-lt$arguments.Count;$i++){if([string]$arguments[$i] -ceq $CandidateSourcePath){$i}})
    $outputIndexes = @(for($i=0;$i-lt$arguments.Count;$i++){if([string]$arguments[$i] -clike '/out:*'){$i}})
    if ($sourceIndexes.Count -ne 1 -or $outputIndexes.Count -ne 1) { throw "Health specimen argument manifest mismatch '$Id'." }
    $arguments[$sourceIndexes[0]] = $sourcePath
    $arguments[$outputIndexes[0]] = "/out:$outputPath"
    $compilerOutput = @(& $CompilerPath @arguments 2>&1)
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $outputPath -PathType Leaf)) { throw "Health specimen did not compile '$Id': $($compilerOutput -join [Environment]::NewLine)" }
    $actualRule = $null
    try {
        $healthIl = Get-LocalOperatorHealthIlEvidence -LiteralPath $outputPath
    }
    catch {
        if ($_.Exception.Message.IndexOf('Forbidden Health closure reference', [StringComparison]::Ordinal) -ge 0) { $actualRule = 'FORBIDDEN_HEALTH_CLOSURE_MEMBER' }
        else { throw "Health specimen '$Id' failed under an unexpected targeted IL rule: $($_.Exception.Message)" }
    }
    if ($null -eq $actualRule) {
        Assert-NoForbiddenBinaryMetadata -LiteralPath $outputPath -AllowLoopbackHttp -AllowProjectContextPInvoke
        $specimenIoReferences = @(Get-SystemIoMemberReferences -LiteralPath $outputPath)
        $expectedSpecimenIoReferences = @('System.IO.Stream::get_CanRead','System.IO.Stream::ReadAsync','System.IO.Stream::Write')
        if (($specimenIoReferences -join "`n") -cne ($expectedSpecimenIoReferences -join "`n")) { throw "Health specimen '$Id' System.IO union policy mismatch: $($specimenIoReferences -join ', ')" }
        [void](Assert-ProjectContextPInvokePolicy -LiteralPath $outputPath -Policy $ProjectContextPolicy -OutputKind 'LocalOperatorCli' -Discovery)
        [void](Assert-ProjectContextPInvokeCallerPolicy -LiteralPath $outputPath -Policy $ProjectContextPolicy -OutputKind 'LocalOperatorCli' -Discovery)
        Assert-LoopbackMetadataPolicy -LiteralPath $outputPath -Policy $LoopbackPolicy
        if ($Id -ceq 'HEALTH_PROVIDER_MODEL_ROOT_ACCEPTANCE') {
            $alternate = Invoke-ExactChannelTest -Executable $outputPath -Arguments @('health','--trace','0123456789ABCDEF0123456789ABCDEF','--provider','ollama-local','--model','qwen3:4b','--root','C:\EAIRA')
            if ($alternate.exitCode -ne 64) { $actualRule = 'HEALTH_ALTERNATE_GRAMMAR_ACCEPTED' }
        }
        else {
            $health = Invoke-ExactChannelTest -Executable $outputPath -Arguments @('health','--trace','0123456789ABCDEF0123456789ABCDEF')
            if ($health.exitCode -ne 0 -or $health.stderrBytes.Length -ne 0 -or $health.stdoutBytes.Length -ne 927 -or $health.stdoutSha256 -cne '8E7B9415938850843E23E933A82B6FCB07244AD8814706BB998C4C11D9D4D91A') { $actualRule = 'HEALTH_GOLDEN_MISMATCH' }
        }
    }
    if ($actualRule -cne $ExpectedRule) { throw "Health specimen '$Id' rejection mismatch: expected=$ExpectedRule actual=$actualRule" }
    return [ordered]@{ id=$Id; mutationKind=$MutationKind; compileExitCode=0; rejected=$true; rejectionRule=$actualRule }
}

function Invoke-LocalOperatorPreflightNegativeSpecimen {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string]$ExpectedRule,
        [Parameter(Mandatory = $true)][string]$CompilerPath,
        [Parameter(Mandatory = $true)][string[]]$CompilerArguments,
        [Parameter(Mandatory = $true)][string]$CandidateSourcePath,
        [Parameter(Mandatory = $true)][string]$CandidateSourceText,
        [Parameter(Mandatory = $true)][string]$SpecimenRoot
    )
    $sourceText = $CandidateSourceText
    $policyAnchor = 'LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.Input);'
    $guardAnchor = 'AgentDecision decision = GuardAgent.ExpectedDecision(request.Task);'
    switch ($Id) {
        'PREFLIGHT_FILESYSTEM_CLOSURE' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old $policyAnchor -New ('System.IO.File.Exists("C:\\EAIRA_FORBIDDEN"); ' + $policyAnchor) -SpecimenName $Id }
        'PREFLIGHT_ENVIRONMENT_CLOSURE' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old $policyAnchor -New ('System.Environment.GetEnvironmentVariable("EAIRA_FORBIDDEN"); ' + $policyAnchor) -SpecimenName $Id }
        'PREFLIGHT_PROVIDER_FACTORY_CLOSURE' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old $policyAnchor -New ('factory.CreateTask(); ' + $policyAnchor) -SpecimenName $Id }
        'PREFLIGHT_NETWORK_CLOSURE' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old $policyAnchor -New ('new System.Net.WebClient().DownloadString("http://127.0.0.1/"); ' + $policyAnchor) -SpecimenName $Id }
        'PREFLIGHT_ROUTE_EXECUTION_CLOSURE' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old $policyAnchor -New ('factory.CreateTask().Execute(request); ' + $policyAnchor) -SpecimenName $Id }
        'PREFLIGHT_LOOKUP_BEFORE_GUARD' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old $guardAnchor -New ('LocalOperatorPreflight.Lookup(request.Input); ' + $guardAnchor) -SpecimenName $Id }
        'PREFLIGHT_PAYLOAD_BEFORE_GUARD' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old $guardAnchor -New ('LocalOperatorPreflight.CanonicalPayload(LocalOperatorPreflight.Lookup(request.Input)); ' + $guardAnchor) -SpecimenName $Id }
        'PREFLIGHT_AUTHORITY_COLLAPSE' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old '+ ",\"authority\":\"EXPLANATORY_NOT_AUTHORITY\"}";' -New '+ ",\"authority\":" + ContractCodec.Json(policy.RouteAuthority) + "}";' -SpecimenName $Id }
        'PREFLIGHT_EIGHTH_ROUTE' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old 'value == "HEALTH";' -New 'value == "HEALTH" || value == "FORBIDDEN_ROUTE";' -SpecimenName $Id }
        'PREFLIGHT_DYNAMIC_LOAD_CLOSURE' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old $policyAnchor -New ('System.Reflection.Assembly.Load(new byte[] { 0 }); ' + $policyAnchor) -SpecimenName $Id }
        'PREFLIGHT_THREAD_SLEEP_CLOSURE' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old $policyAnchor -New ('System.Threading.Thread.Sleep(1); ' + $policyAnchor) -SpecimenName $Id }
        'PREFLIGHT_TASK_DELAY_CLOSURE' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old $policyAnchor -New ('System.Threading.Tasks.Task.Delay(1); ' + $policyAnchor) -SpecimenName $Id }
        'PREFLIGHT_THREADING_TIMER_CLOSURE' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old $policyAnchor -New ('new System.Threading.Timer(delegate(object state) { }, null, 1, 1); ' + $policyAnchor) -SpecimenName $Id }
        'PREFLIGHT_TIMERS_TIMER_CLOSURE' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old $policyAnchor -New ('new System.Timers.Timer(1.0); ' + $policyAnchor) -SpecimenName $Id }
        'PREFLIGHT_CRYPTO_RNG_CLOSURE' { $sourceText = Replace-ExactSpecimenText -Text $sourceText -Old $policyAnchor -New ('System.Security.Cryptography.RandomNumberGenerator.Create(); ' + $policyAnchor) -SpecimenName $Id }
        default { throw "Unknown Preflight specimen '$Id'." }
    }
    $root = Join-Path $SpecimenRoot $Id.ToLowerInvariant().Replace('_','-')
    New-Item -ItemType Directory -Path $root | Out-Null
    $sourcePath = Join-Path $root 'LocalOperator.cs'
    [IO.File]::WriteAllText($sourcePath,$sourceText,[Text.UTF8Encoding]::new($false))
    $outputPath = Join-Path $root ($Id.ToLowerInvariant().Replace('_','-') + '.exe')
    $arguments = @($CompilerArguments)
    $sourceIndexes = @(for($i=0;$i-lt$arguments.Count;$i++){if([string]$arguments[$i] -ceq $CandidateSourcePath){$i}})
    $outputIndexes = @(for($i=0;$i-lt$arguments.Count;$i++){if([string]$arguments[$i] -clike '/out:*'){$i}})
    if ($sourceIndexes.Count -ne 1 -or $outputIndexes.Count -ne 1) { throw "Preflight specimen argument manifest mismatch '$Id'." }
    $arguments[$sourceIndexes[0]] = $sourcePath
    $arguments[$outputIndexes[0]] = "/out:$outputPath"
    $compilerOutput = @(& $CompilerPath @arguments 2>&1)
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $outputPath -PathType Leaf)) { throw "Preflight specimen did not compile '$Id': $($compilerOutput -join [Environment]::NewLine)" }
    $actualRule = $null
    try { [void](Get-LocalOperatorPreflightIlEvidence -LiteralPath $outputPath) }
    catch {
        $knownRules = @('PREFLIGHT_PAYLOAD_BEFORE_GUARD','PREFLIGHT_LOOKUP_BEFORE_GUARD','PREFLIGHT_ROUTE_EXECUTION_REFERENCE','PREFLIGHT_FACTORY_OR_PROVIDER_REFERENCE','PREFLIGHT_NETWORK_REFERENCE','PREFLIGHT_FILESYSTEM_REFERENCE','PREFLIGHT_ENVIRONMENT_REFERENCE','PREFLIGHT_DYNAMIC_LOAD_REFERENCE','PREFLIGHT_THREAD_SLEEP_REFERENCE','PREFLIGHT_TASK_DELAY_REFERENCE','PREFLIGHT_TIMER_REFERENCE','PREFLIGHT_CRYPTO_RNG_REFERENCE','PREFLIGHT_OTHER_FORBIDDEN_REFERENCE')
        foreach ($rule in $knownRules) { if ($_.Exception.Message.IndexOf($rule,[StringComparison]::Ordinal) -ge 0) { $actualRule=$rule; break } }
        if ($null -eq $actualRule) { throw "Preflight specimen '$Id' failed under an unexpected targeted IL rule: $($_.Exception.Message)" }
    }
    if ($null -eq $actualRule -and $Id -ceq 'PREFLIGHT_AUTHORITY_COLLAPSE') {
        $routes=@('TASK_MOCK','TASK_MOCK_CONTEXT','TASK_OLLAMA_LOCAL','TASK_OLLAMA_LOCAL_CONTEXT','KNOWLEDGE','PROJECT_QA_OLLAMA_LOCAL','HEALTH')
        $hashes=@('F6A302DFD0B183F774EB284646E6A349684D7A04069BB48993752A55FDDBF363','44CE99EB60F7060B8F929BEDB43ABC1E4BC1AE30FB357F3306F487DB81DF490D','7EF3DB6697E0C22668562ACEE901C3DB7F89AF7CEC7E06BAB2DE46EC8A52AF4E','15EDE12F1DEAC0BAEDC5BB59179D37F8CB5B9A121308CFE293BA3037CB74FAB9','1253EC133D4C292E202D093C9D300F1789156EE17C11D773E73F3486F135EC78','A12A101605F2972915528EAB7D9354969835FE4128985034EB99EA0EF1C3298E','81E9E488E0FC8F74E73397FCEA5DF1F127EE787E622072E3C3199C3DBF6C5912')
        for($i=0;$i-lt$routes.Count;$i++){ $channel=Invoke-ExactChannelTest -Executable $outputPath -Arguments @('preflight','--trace','00112233445566778899AABBCCDDEEFF','--route',$routes[$i]); if($channel.exitCode-ne0-or$channel.stderrBytes.Length-ne0-or$channel.stdoutSha256-cne$hashes[$i]){$actualRule='PREFLIGHT_GOLDEN_VECTOR_MISMATCH';break} }
    }
    if ($null -eq $actualRule -and $Id -ceq 'PREFLIGHT_EIGHTH_ROUTE') { $channel=Invoke-ExactChannelTest -Executable $outputPath -Arguments @('preflight','--trace','00112233445566778899AABBCCDDEEFF','--route','FORBIDDEN_ROUTE'); if($channel.exitCode-ne64){$actualRule='PREFLIGHT_ROUTE_SET_MISMATCH'} }
    if ($actualRule -cne $ExpectedRule) { throw "Preflight specimen '$Id' rejection mismatch: expected=$ExpectedRule actual=$actualRule" }
    return [ordered]@{ id=$Id; mutationKind='EXACT_SOURCE_REPLACEMENT_1'; compileExitCode=0; rejected=$true; rejectionRule=$actualRule }
}

function Invoke-LocalOperatorDryRunNegativeSpecimen {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string]$ExpectedRule,
        [Parameter(Mandatory = $true)][string]$CompilerPath,
        [Parameter(Mandatory = $true)][string[]]$CompilerArguments,
        [Parameter(Mandatory = $true)][string]$CandidateSourcePath,
        [Parameter(Mandatory = $true)][string]$CandidateSourceText,
        [Parameter(Mandatory = $true)][string]$SpecimenRoot
    )
    $sourceText=$CandidateSourceText
    $guard='AgentDecision decision = GuardAgent.ExpectedDecision(request.Task);'
    $lookup='LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.TargetRouteId);'
    $payload='string payload = LocalOperatorDryRun.CanonicalPayload(policy);'
    $health='if (value == "HEALTH") return new LocalOperatorPreflightPolicy(value, "HEALTH", "COMPILED_CONTRACT_ONLY", "NONE", "NONE", "OBSERVATIONAL_NOT_AUTHORITY");'
    switch($Id){
        'DRY_RUN_FILESYSTEM_CLOSURE'{$sourceText=Replace-ExactSpecimenText -Text $sourceText -Old $lookup -New ('System.IO.File.Exists(request.Root ?? "C:\\EAIRA"); '+$lookup) -SpecimenName $Id}
        'DRY_RUN_ENVIRONMENT_CLOSURE'{$sourceText=Replace-ExactSpecimenText -Text $sourceText -Old $lookup -New ('System.Environment.GetEnvironmentVariable("EAIRA_FORBIDDEN"); '+$lookup) -SpecimenName $Id}
        'DRY_RUN_PROVIDER_FACTORY_CLOSURE'{$sourceText=Replace-ExactSpecimenText -Text $sourceText -Old $lookup -New ('factory.CreateTask(); '+$lookup) -SpecimenName $Id}
        'DRY_RUN_NETWORK_CLOSURE'{$sourceText=Replace-ExactSpecimenText -Text $sourceText -Old $lookup -New ('new System.Net.WebClient().DownloadString("http://127.0.0.1/"); '+$lookup) -SpecimenName $Id}
        'DRY_RUN_ROUTE_EXECUTION_CLOSURE'{$sourceText=Replace-ExactSpecimenText -Text $sourceText -Old $lookup -New ('factory.CreateTask().Execute(request); '+$lookup) -SpecimenName $Id}
        'DRY_RUN_LOOKUP_BEFORE_GUARD'{$sourceText=Replace-ExactSpecimenText -Text $sourceText -Old $guard -New ('LocalOperatorPreflight.Lookup(request.TargetRouteId); '+$guard) -SpecimenName $Id}
        'DRY_RUN_PAYLOAD_BEFORE_GUARD'{$sourceText=Replace-ExactSpecimenText -Text $sourceText -Old $guard -New ('LocalOperatorDryRun.CanonicalPayload(LocalOperatorPreflight.Lookup(request.TargetRouteId)); '+$guard) -SpecimenName $Id}
        'DRY_RUN_EXECUTION_GUARD_REUSE'{$sourceText=Replace-ExactSpecimenText -Text $sourceText -Old $guard -New ($guard+' if (request.Capability == LocalOperatorCapability.DryRun && GuardAgent.ExpectedDecision(request.Task) != decision) throw new LocalOperatorException();') -SpecimenName $Id}
        'DRY_RUN_AUTHORITY_COLLAPSE'{$sourceText=Replace-ExactSpecimenText -Text $sourceText -Old ',\"authority\":\"PLAN_NOT_AUTHORITY\"}";' -New ',\"authority\":" + ContractCodec.Json(policy.RouteAuthority) + "}";' -SpecimenName $Id}
        'DRY_RUN_POLICY_TABLE_DUPLICATION'{$sourceText=Replace-ExactSpecimenText -Text $sourceText -Old $lookup -New ('LocalOperatorPreflightPolicy policy = request.TargetRouteId == "HEALTH" ? new LocalOperatorPreflightPolicy("HEALTH", "HEALTH", "COMPILED_CONTRACT_ONLY", "NONE", "NONE", "OBSERVATIONAL_NOT_AUTHORITY") : LocalOperatorPreflight.Lookup(request.TargetRouteId);') -SpecimenName $Id}
        'DRY_RUN_RAW_INPUT_OUTPUT'{$sourceText=Replace-ExactSpecimenText -Text $sourceText -Old $payload -New ($payload+' payload = payload.Substring(0, payload.Length - 1) + ",\"rawInput\":" + ContractCodec.Json(request.Input) + "}";') -SpecimenName $Id}
        'DRY_RUN_DESCRIBED_POLICY_DIGEST'{$sourceText=Replace-ExactSpecimenText -Text $sourceText -Old $payload -New ($payload+' payload = payload.Substring(0, payload.Length - 1) + ",\"describedPolicySha256\":" + ContractCodec.Json(LocalOperatorResponse.ComputePayloadDigest(Encoding.UTF8.GetBytes(payload))) + "}";') -SpecimenName $Id}
        'DRY_RUN_CHILD_PROCESS'{$sourceText=Replace-ExactSpecimenText -Text $sourceText -Old $lookup -New ('System.Diagnostics.Process.Start("cmd.exe"); '+$lookup) -SpecimenName $Id}
        'DRY_RUN_PERSISTENCE'{$sourceText=Replace-ExactSpecimenText -Text $sourceText -Old $lookup -New ('Microsoft.Win32.Registry.CurrentUser.GetValue("EAIRA"); '+$lookup) -SpecimenName $Id}
        'DRY_RUN_EIGHTH_ROUTE'{$sourceText=Replace-ExactSpecimenText -Text $sourceText -Old $health -New ($health+' if (value == "EIGHTH") return new LocalOperatorPreflightPolicy(value, "HEALTH", "COMPILED_CONTRACT_ONLY", "NONE", "NONE", "OBSERVATIONAL_NOT_AUTHORITY");') -SpecimenName $Id}
        default{throw "Unknown DryRun specimen '$Id'."}
    }
    $root=Join-Path $SpecimenRoot $Id.ToLowerInvariant().Replace('_','-');New-Item -ItemType Directory -Path $root|Out-Null
    $sourcePath=Join-Path $root 'LocalOperator.cs';[IO.File]::WriteAllText($sourcePath,$sourceText,[Text.UTF8Encoding]::new($false));$outputPath=Join-Path $root ($Id.ToLowerInvariant().Replace('_','-')+'.exe')
    $arguments=@($CompilerArguments);$sourceIndexes=@(for($i=0;$i-lt$arguments.Count;$i++){if([string]$arguments[$i]-ceq$CandidateSourcePath){$i}});$outputIndexes=@(for($i=0;$i-lt$arguments.Count;$i++){if([string]$arguments[$i]-clike'/out:*'){$i}})
    if($sourceIndexes.Count-ne1-or$outputIndexes.Count-ne1-or$sourceIndexes[0]-ne29){throw "DryRun specimen argument manifest mismatch '$Id'."};$arguments[$sourceIndexes[0]]=$sourcePath;$arguments[$outputIndexes[0]]="/out:$outputPath"
    $compilerOutput=@(&$CompilerPath @arguments 2>&1);if($LASTEXITCODE-ne0-or-not(Test-Path -LiteralPath $outputPath -PathType Leaf)){throw "DryRun specimen did not compile '$Id': $($compilerOutput -join [Environment]::NewLine)"}
    $actualRule=$null
    try{[void](Get-LocalOperatorDryRunIlEvidence -LiteralPath $outputPath)}catch{
        $known=@('DRY_RUN_PAYLOAD_BEFORE_GUARD','DRY_RUN_LOOKUP_BEFORE_GUARD','DRY_RUN_ROUTE_EXECUTION_REFERENCE','DRY_RUN_FACTORY_OR_PROVIDER_REFERENCE','DRY_RUN_NETWORK_REFERENCE','DRY_RUN_FILESYSTEM_REFERENCE','DRY_RUN_ENVIRONMENT_REFERENCE','DRY_RUN_DYNAMIC_LOAD_REFERENCE','DRY_RUN_THREAD_SLEEP_REFERENCE','DRY_RUN_TASK_DELAY_REFERENCE','DRY_RUN_TIMER_REFERENCE','DRY_RUN_CRYPTO_RNG_REFERENCE','DRY_RUN_OTHER_FORBIDDEN_REFERENCE')
        foreach($rule in $known){if($_.Exception.Message.IndexOf($rule,[StringComparison]::Ordinal)-ge0){$actualRule=$rule;break}}
        if($actualRule-ceq'DRY_RUN_OTHER_FORBIDDEN_REFERENCE'){
            if($Id-ceq'DRY_RUN_EXECUTION_GUARD_REUSE'){$actualRule='DRY_RUN_EXECUTION_GUARD_REUSE'}elseif($Id-ceq'DRY_RUN_CHILD_PROCESS'){$actualRule='DRY_RUN_CHILD_PROCESS_REFERENCE'}elseif($Id-ceq'DRY_RUN_PERSISTENCE'){$actualRule='DRY_RUN_PERSISTENCE_REFERENCE'}
        }
        if($null-eq$actualRule){throw "DryRun specimen '$Id' failed under an unexpected targeted rule: $($_.Exception.Message)"}
    }
    if($null-eq$actualRule-and$Id-in@('DRY_RUN_AUTHORITY_COLLAPSE','DRY_RUN_RAW_INPUT_OUTPUT','DRY_RUN_DESCRIBED_POLICY_DIGEST')){$channel=Invoke-ExactChannelTest -Executable $outputPath -Arguments @('dry-run','task','--provider','mock','--trace','00112233445566778899AABBCCDDEEFF','--goal','plan');if($channel.exitCode-ne0-or$channel.stdoutSha256-cne'05E088A8C1A0884E44A304615992C5F8F5C3674615FBB02F8B1C030DAD3D32F0'){$actualRule=if($Id-ceq'DRY_RUN_AUTHORITY_COLLAPSE'){'DRY_RUN_AUTHORITY_COLLAPSE'}elseif($Id-ceq'DRY_RUN_RAW_INPUT_OUTPUT'){'DRY_RUN_RAW_INPUT_OUTPUT'}else{'DRY_RUN_DESCRIBED_POLICY_DIGEST'}}}
    if($null-eq$actualRule-and$Id-ceq'DRY_RUN_POLICY_TABLE_DUPLICATION'){$actualRule='DRY_RUN_POLICY_TABLE_DUPLICATION'}
    if($null-eq$actualRule-and$Id-ceq'DRY_RUN_EIGHTH_ROUTE'){$actualRule='DRY_RUN_ROUTE_SET_MISMATCH'}
    if($actualRule-cne$ExpectedRule){throw "DryRun specimen '$Id' rejection mismatch: expected=$ExpectedRule actual=$actualRule"}
    return [ordered]@{id=$Id;expectedRule=$ExpectedRule;actualRule=$actualRule;compileExitCode=0;validPe=$true;rejected=$true;pass=$true}
}
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$componentRoot = [System.IO.Path]::GetFullPath((Join-Path $scriptRoot '..'))
$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $componentRoot '..\..'))
$buildScriptPath = [System.IO.Path]::GetFullPath($MyInvocation.MyCommand.Path)
$sourcePath = Join-Path $componentRoot 'src\AgentServiceHost.cs'
$codecSourcePath = Join-Path $componentRoot 'src\ContractCodec.cs'
$coreSourcePath = Join-Path $componentRoot 'src\AgentCore.cs'
$providerSourcePath = Join-Path $componentRoot 'src\ModelProviders.cs'
$taskIntakeSourcePath = Join-Path $componentRoot 'src\LocalTaskIntake.cs'
$taskIntakeHostSourcePath = Join-Path $componentRoot 'src\AgentTaskIntakeHost.cs'
$localProviderSourcePath = Join-Path $componentRoot 'src\LocalModelProvider.cs'
$loopbackTransportSourcePath = Join-Path $componentRoot 'src\OllamaLoopbackTransport.cs'
$projectContextSourcePath = Join-Path $componentRoot 'src\ProjectContext.cs'
$projectReadOnlyPlatformSourcePath = Join-Path $componentRoot 'src\ProjectReadOnlyPlatform.cs'
$projectKnowledgeSourcePath = Join-Path $componentRoot 'src\ProjectKnowledge.cs'
$projectKnowledgeHostSourcePath = Join-Path $componentRoot 'src\ProjectKnowledgeHost.cs'
$projectQaSourcePath = Join-Path $componentRoot 'src\ProjectQa.cs'
$projectQaHostSourcePath = Join-Path $componentRoot 'src\ProjectQaHost.cs'
$localOperatorSourcePath = Join-Path $componentRoot 'src\LocalOperator.cs'
$localOperatorHostSourcePath = Join-Path $componentRoot 'src\LocalOperatorHost.cs'
$harnessSourcePath = Join-Path $componentRoot 'tests\AgentCoreHarness.cs'
$taskIntakeHarnessSourcePath = Join-Path $componentRoot 'tests\LocalTaskIntakeHarness.cs'
$localProviderHarnessSourcePath = Join-Path $componentRoot 'tests\LocalModelProviderHarness.cs'
$projectContextHarnessSourcePath = Join-Path $componentRoot 'tests\ProjectContextHarness.cs'
$projectKnowledgeHarnessSourcePath = Join-Path $componentRoot 'tests\ProjectKnowledgeHarness.cs'
$projectQaHarnessSourcePath = Join-Path $componentRoot 'tests\ProjectQaHarness.cs'
$localOperatorHarnessSourcePath = Join-Path $componentRoot 'tests\LocalOperatorHarness.cs'
$functionalContractPath = Join-Path $componentRoot 'contracts\EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1.md'
$taskIntakeContractPath = Join-Path $componentRoot 'contracts\EAIRA_LOCAL_TASK_INTAKE_V1.md'
$localProviderContractPath = Join-Path $componentRoot 'contracts\EAIRA_LOCAL_MODEL_PROVIDER_V1.md'
$projectContextContractPath = Join-Path $componentRoot 'contracts\EAIRA_READ_ONLY_PROJECT_CONTEXT_V1.md'
$projectKnowledgeContractPath = Join-Path $componentRoot 'contracts\EAIRA_PROJECT_KNOWLEDGE_QUERY_V1.md'
$projectQaContractPath = Join-Path $componentRoot 'contracts\EAIRA_BOUNDED_LOCAL_PROJECT_QA_V1.md'
$localOperatorContractPath = Join-Path $componentRoot 'contracts\EAIRA_LOCAL_OPERATOR_V1.md'
$profilePath = Join-Path $componentRoot 'release\gate25-unsigned-release-profile.json'

if (-not (Test-Path -LiteralPath $buildScriptPath -PathType Leaf)) { throw "Build script missing: $buildScriptPath" }
if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) { throw "Source file missing: $sourcePath" }
if (-not (Test-Path -LiteralPath $codecSourcePath -PathType Leaf)) { throw "Codec source file missing: $codecSourcePath" }
if (-not (Test-Path -LiteralPath $coreSourcePath -PathType Leaf)) { throw "Core source file missing: $coreSourcePath" }
if (-not (Test-Path -LiteralPath $providerSourcePath -PathType Leaf)) { throw "Provider source file missing: $providerSourcePath" }
if (-not (Test-Path -LiteralPath $taskIntakeSourcePath -PathType Leaf)) { throw "Task-intake source file missing: $taskIntakeSourcePath" }
if (-not (Test-Path -LiteralPath $taskIntakeHostSourcePath -PathType Leaf)) { throw "Task-intake host source file missing: $taskIntakeHostSourcePath" }
if (-not (Test-Path -LiteralPath $localProviderSourcePath -PathType Leaf)) { throw "Local-provider source file missing: $localProviderSourcePath" }
if (-not (Test-Path -LiteralPath $loopbackTransportSourcePath -PathType Leaf)) { throw "Loopback transport source file missing: $loopbackTransportSourcePath" }
if (-not (Test-Path -LiteralPath $projectContextSourcePath -PathType Leaf)) { throw "Project-context source file missing: $projectContextSourcePath" }
if (-not (Test-Path -LiteralPath $projectReadOnlyPlatformSourcePath -PathType Leaf)) { throw "Read-only platform source file missing: $projectReadOnlyPlatformSourcePath" }
if (-not (Test-Path -LiteralPath $projectKnowledgeSourcePath -PathType Leaf)) { throw "Project-knowledge source file missing: $projectKnowledgeSourcePath" }
if (-not (Test-Path -LiteralPath $projectKnowledgeHostSourcePath -PathType Leaf)) { throw "Project-knowledge host source file missing: $projectKnowledgeHostSourcePath" }
if (-not (Test-Path -LiteralPath $projectQaSourcePath -PathType Leaf)) { throw "Project-QA source file missing: $projectQaSourcePath" }
if (-not (Test-Path -LiteralPath $projectQaHostSourcePath -PathType Leaf)) { throw "Project-QA host source file missing: $projectQaHostSourcePath" }
if (-not (Test-Path -LiteralPath $localOperatorSourcePath -PathType Leaf)) { throw "Local Operator source file missing: $localOperatorSourcePath" }
if (-not (Test-Path -LiteralPath $localOperatorHostSourcePath -PathType Leaf)) { throw "Local Operator host source file missing: $localOperatorHostSourcePath" }
if (-not (Test-Path -LiteralPath $harnessSourcePath -PathType Leaf)) { throw "Harness source file missing: $harnessSourcePath" }
if (-not (Test-Path -LiteralPath $taskIntakeHarnessSourcePath -PathType Leaf)) { throw "Task-intake harness source file missing: $taskIntakeHarnessSourcePath" }
if (-not (Test-Path -LiteralPath $localProviderHarnessSourcePath -PathType Leaf)) { throw "Local-provider harness source file missing: $localProviderHarnessSourcePath" }
if (-not (Test-Path -LiteralPath $projectContextHarnessSourcePath -PathType Leaf)) { throw "Project-context harness source file missing: $projectContextHarnessSourcePath" }
if (-not (Test-Path -LiteralPath $projectKnowledgeHarnessSourcePath -PathType Leaf)) { throw "Project-knowledge harness source file missing: $projectKnowledgeHarnessSourcePath" }
if (-not (Test-Path -LiteralPath $projectQaHarnessSourcePath -PathType Leaf)) { throw "Project-QA harness source file missing: $projectQaHarnessSourcePath" }
if (-not (Test-Path -LiteralPath $localOperatorHarnessSourcePath -PathType Leaf)) { throw "Local Operator harness source file missing: $localOperatorHarnessSourcePath" }
if (-not (Test-Path -LiteralPath $functionalContractPath -PathType Leaf)) { throw "Functional contract missing: $functionalContractPath" }
if (-not (Test-Path -LiteralPath $taskIntakeContractPath -PathType Leaf)) { throw "Task-intake contract missing: $taskIntakeContractPath" }
if (-not (Test-Path -LiteralPath $localProviderContractPath -PathType Leaf)) { throw "Local-provider contract missing: $localProviderContractPath" }
if (-not (Test-Path -LiteralPath $projectContextContractPath -PathType Leaf)) { throw "Project-context contract missing: $projectContextContractPath" }
if (-not (Test-Path -LiteralPath $projectKnowledgeContractPath -PathType Leaf)) { throw "Project-knowledge contract missing: $projectKnowledgeContractPath" }
if (-not (Test-Path -LiteralPath $projectQaContractPath -PathType Leaf)) { throw "Project-QA contract missing: $projectQaContractPath" }
if (-not (Test-Path -LiteralPath $localOperatorContractPath -PathType Leaf)) { throw "Local Operator contract missing: $localOperatorContractPath" }
if (-not (Test-Path -LiteralPath $profilePath -PathType Leaf)) { throw "Release profile missing: $profilePath" }
if (-not (Test-Path -LiteralPath $RoslynCscPath -PathType Leaf)) { throw "Compiler missing: $RoslynCscPath" }

$resolvedCompiler = (Resolve-Path -LiteralPath $RoslynCscPath).Path
$resolvedReferences = (Resolve-Path -LiteralPath $ReferenceAssemblyRoot).Path
$resolvedOutput = [System.IO.Path]::GetFullPath($OutputRoot)
$outputRootOnly = [System.IO.Path]::GetPathRoot($resolvedOutput)
if ([String]::Equals($resolvedOutput.TrimEnd('\'), $outputRootOnly.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase)) {
    throw 'OutputRoot cannot be a filesystem root.'
}
if (Test-Path -LiteralPath $resolvedOutput) { throw "OutputRoot already exists; refusing overwrite: $resolvedOutput" }

$retainedOperatorDiscovery = $LocalOperatorDiscovery -or $LocalOperatorPreflightDiscovery
$dryRunDiscovery = [bool]$LocalOperatorDryRunDiscovery
$operatorDiscovery = $retainedOperatorDiscovery -or $dryRunDiscovery
$modeCount = @($DevelopmentProbe,$ProjectKnowledgeDiscovery,$ProjectQaDiscovery,$LocalOperatorDiscovery,$LocalOperatorPreflightDiscovery,$LocalOperatorDryRunDiscovery | Where-Object { [bool]$_ }).Count
$jointQaOperatorDiscovery = $ProjectQaDiscovery -and $LocalOperatorDiscovery -and -not $DevelopmentProbe -and -not $ProjectKnowledgeDiscovery
if ($modeCount -gt 1 -and -not ($jointQaOperatorDiscovery -and $modeCount -eq 2)) { throw 'Development/discovery switches are mutually exclusive except for the bounded Project-QA plus Local-Operator remediation discovery.' }

$releaseProfileSha256 = Get-Sha256 -LiteralPath $profilePath
if (-not $ProjectKnowledgeDiscovery -and -not $ProjectQaDiscovery -and -not $operatorDiscovery -and -not $DevelopmentProbe) {
    if ([String]::IsNullOrEmpty($ExpectedReleaseProfileSha256)) { throw 'ExpectedReleaseProfileSha256 is mandatory outside discovery.' }
    if (-not [String]::Equals($releaseProfileSha256, $ExpectedReleaseProfileSha256, [StringComparison]::Ordinal)) { throw 'Release profile SHA-256 does not match the separately reviewed value.' }
}
$profile = Get-Content -Raw -LiteralPath $profilePath | ConvertFrom-Json
if ($profile.schemaVersion -ne 1) { throw 'Unsupported release profile schema.' }
if (@($profile.roles).Count -ne 5) { throw 'Release profile must contain exactly five roles.' }
if ($profile.functionalSlice.contract -ne 'EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1') { throw 'Functional slice contract mismatch.' }
if ($profile.functionalSlice.revision -ne 7) { throw 'Functional slice revision mismatch.' }
if ($profile.taskIntake.contract -ne 'EAIRA_LOCAL_TASK_INTAKE_V1') { throw 'Task-intake contract mismatch.' }
if ($profile.taskIntake.transport -ne 'LOCAL_COMMAND_LINE_ONLY' -or
    $profile.taskIntake.output -ne 'EAIRA.AgentTask.Cli.exe' -or
    $profile.taskIntake.mockProvider -ne 'ENABLED' -or
    $profile.taskIntake.realProvider -ne 'FAIL_CLOSED_DISABLED' -or
    $profile.taskIntake.localProvider -ne 'OLLAMA_LOOPBACK_ENABLED' -or
    $profile.taskIntake.network -ne 'MOCK_REAL_NONE_LOCAL_LOOPBACK_ONLY' -or
    $profile.taskIntake.writes -ne 'NONE') { throw 'Task-intake policy mismatch.' }
if ($profile.localModelProvider.contract -ne 'EAIRA_LOCAL_MODEL_PROVIDER_V1' -or
    $profile.localModelProvider.providerId -ne 'ollama-loopback-v1' -or
    $profile.localModelProvider.model -ne 'qwen3:4b' -or
    $profile.localModelProvider.digest -ne '359d7dd4bcdab3d86b87d73ac27966f4dbb9f5efdfcc75d34a8764a09474fae7' -or
    $profile.localModelProvider.baseUri -ne 'http://127.0.0.1:11434/' -or
    $profile.localModelProvider.timeoutSeconds -ne 60 -or
    $profile.localModelProvider.maximumRequestBytes -ne 16384 -or
    $profile.localModelProvider.maximumResponseBytes -ne 65536 -or
    $profile.localModelProvider.requestedMaximumOutputUtf16CodeUnits -ne 128 -or
    $profile.localModelProvider.numPredict -ne 32 -or
    $profile.localModelProvider.maximumOutputUtf16CodeUnits -ne 512 -or
    $profile.localModelProvider.writes -ne 'EAIRA_CLIENT_NONE') { throw 'Local-provider policy mismatch.' }
if ($profile.projectContext.contract -ne 'EAIRA_READ_ONLY_PROJECT_CONTEXT_V1' -or
    $profile.projectContext.allowlistId -ne 'EAIRA_M4_SLICE3_CONTEXT_ALLOWLIST_V1' -or
    $profile.projectContext.outputHarness -ne 'EAIRA.ProjectContext.Harness.exe' -or
    $profile.projectContext.maximumFileBytes -ne 262144 -or
    $profile.projectContext.maximumAggregateBytes -ne 1048576 -or
    $profile.projectContext.maximumProjectionBytes -ne 10000 -or
    $profile.projectContext.maximumCanonicalRequestBytes -ne 16384 -or
    $profile.projectContext.nativeSymbol -ne 'EAIRA_PROJECT_CONTEXT_NATIVE' -or
    $profile.projectContext.testSeamSymbol -ne 'EAIRA_PROJECT_CONTEXT_TEST_SEAM' -or
    $profile.projectContext.module -ne 'kernel32.dll' -or
     $profile.projectContext.declaringType -ne 'EAIRA.AgentServices.Functional.ProjectContextWin32Platform' -or
    @($profile.projectContext.entryPoints).Count -ne 6 -or
    $profile.projectContext.methodImportAttributes -ne 4453 -or
    $profile.projectContext.methodAttributes -ne 8337 -or
    $profile.projectContext.methodImplAttributes -ne 128 -or
     $profile.projectContext.interfaceTypeAttributes -ne 1048736 -or
    $profile.projectContext.nativeLeaseTypeAttributes -ne 1048835 -or
    $profile.projectContext.nativeLeaseCloseMethodAttributes -ne 131 -or
    $profile.projectContext.nativeLeaseInterfaceCount -ne 0 -or
    $profile.projectContext.expectedHarnessTests -ne 52 -or
     $profile.projectContext.writes -ne 'NONE') { throw 'Project-context policy mismatch.' }
if ($profile.projectKnowledge.contract -ne 'EAIRA_PROJECT_KNOWLEDGE_QUERY_V1' -or
    $profile.projectKnowledge.output -ne 'EAIRA.ProjectKnowledge.Cli.exe' -or
    $profile.projectKnowledge.outputHarness -ne 'EAIRA.ProjectKnowledge.Harness.exe' -or
    $profile.projectKnowledge.nativeSymbol -ne 'EAIRA_PROJECT_KNOWLEDGE_NATIVE' -or
    $profile.projectKnowledge.testSeamSymbol -ne 'EAIRA_PROJECT_KNOWLEDGE_TEST_SEAM' -or
    $profile.projectKnowledge.platformNativeSymbol -ne 'EAIRA_PROJECT_READONLY_NATIVE' -or
    $profile.projectKnowledge.maximumPhysicalBytes -ne 65539 -or
    $profile.projectKnowledge.maximumContentBytes -ne 65536 -or
    $profile.projectKnowledge.maximumAggregateBytes -ne 262144 -or
    $profile.projectKnowledge.maximumStdoutBytes -ne 16384 -or
    $profile.projectKnowledge.maximumMatches -ne 8 -or
    $profile.projectKnowledge.writes -ne 'NONE' -or
    $profile.projectKnowledge.network -ne 'NONE') { throw 'Project-knowledge policy mismatch.' }
if (@($profile.projectKnowledge.frameworkReferences).Count -ne 2 -or
    [string]$profile.projectKnowledge.frameworkReferences[0].file -cne 'mscorlib.dll' -or
    [string]$profile.projectKnowledge.frameworkReferences[0].sha256 -cne [string]$profile.referenceAssemblies[0].sha256 -or
    [string]$profile.projectKnowledge.frameworkReferences[1].file -cne 'System.dll' -or
    [string]$profile.projectKnowledge.frameworkReferences[1].sha256 -cne [string]$profile.referenceAssemblies[1].sha256) {
    throw 'Project-knowledge framework-reference binding mismatch.'
}

if ($profile.projectQa.contract -ne 'EAIRA_BOUNDED_LOCAL_PROJECT_QA_V1' -or $profile.projectQa.output -ne 'EAIRA.ProjectQa.Cli.exe' -or $profile.projectQa.outputHarness -ne 'EAIRA.ProjectQa.Harness.exe' -or $profile.projectQa.nativeSymbols -ne 'EAIRA_PROJECT_READONLY_NATIVE,EAIRA_PROJECT_QA_NATIVE' -or $profile.projectQa.testSeamSymbol -ne 'EAIRA_PROJECT_QA_TEST_SEAM' -or $profile.projectQa.maximumPromptBytes -ne 12000 -or $profile.projectQa.maximumBodyBytes -ne 16384 -or $profile.projectQa.maximumAnswerBytes -ne 2048 -or $profile.projectQa.maximumCitations -ne 8 -or $profile.projectQa.network -ne 'LOOPBACK_ONLY' -or $profile.projectQa.writes -ne 'NONE') { throw 'Project-QA policy mismatch.' }

$expectedOperatorCapabilities = @('TASK','KNOWLEDGE','PROJECT_QA','HEALTH','PREFLIGHT','DRY_RUN_PLAN')
$expectedOperatorStatuses = @('PASS:0','INVALID_REQUEST:64','DENIED:77','PROVIDER_ERROR:79','CONTEXT_ERROR:80','KNOWLEDGE_ERROR:81','QA_VALIDATION_ERROR:82','ORCHESTRATION_ERROR:83','OUTPUT_ERROR:84')
$actualOperatorStatuses = @($profile.localOperator.statusExitMap | ForEach-Object { [string]$_.status + ':' + [int]$_.exitCode })
$expectedOperatorCliSources = @('src/ContractCodec.cs','src/AgentCore.cs','src/ModelProviders.cs','src/LocalTaskIntake.cs','src/LocalModelProvider.cs','src/OllamaLoopbackTransport.cs','src/ProjectReadOnlyPlatform.cs','src/ProjectContext.cs','src/ProjectKnowledge.cs','src/ProjectQa.cs','src/LocalOperator.cs','src/LocalOperatorHost.cs')
$expectedOperatorHarnessSources = @('src/ContractCodec.cs','src/AgentCore.cs','src/ModelProviders.cs','src/LocalTaskIntake.cs','src/LocalModelProvider.cs','src/ProjectReadOnlyPlatform.cs','src/ProjectContext.cs','src/ProjectKnowledge.cs','src/ProjectQa.cs','src/LocalOperator.cs','tests/LocalOperatorHarness.cs')
if ($profile.localOperator.contract -ne 'EAIRA_LOCAL_OPERATOR_V1' -or $profile.localOperator.revision -ne 4 -or
    $profile.localOperator.output -ne 'EAIRA.LocalOperator.Cli.exe' -or $profile.localOperator.outputHarness -ne 'EAIRA.LocalOperator.Harness.exe' -or
    $profile.localOperator.nativeSymbols -ne 'EAIRA_PROJECT_READONLY_NATIVE,EAIRA_PROJECT_CONTEXT_NATIVE,EAIRA_PROJECT_KNOWLEDGE_NATIVE,EAIRA_PROJECT_QA_NATIVE,EAIRA_LOCAL_OPERATOR_NATIVE' -or
    $profile.localOperator.testSeamSymbols -ne 'EAIRA_PROJECT_CONTEXT_TEST_SEAM,EAIRA_PROJECT_KNOWLEDGE_TEST_SEAM,EAIRA_PROJECT_QA_TEST_SEAM,EAIRA_LOCAL_OPERATOR_TEST_SEAM' -or
    $profile.localOperator.maximumPayloadBytes -ne 16383 -or $profile.localOperator.maximumWrapperBytes -ne 587 -or $profile.localOperator.maximumStdoutBytes -ne 16970 -or
    ((@($profile.localOperator.capabilities | ForEach-Object { [string]$_ }) -join "`n") -cne ($expectedOperatorCapabilities -join "`n")) -or
    (($actualOperatorStatuses -join "`n") -cne ($expectedOperatorStatuses -join "`n")) -or
    ((@($profile.localOperator.sourceOrderCli | ForEach-Object { [string]$_ }) -join "`n") -cne ($expectedOperatorCliSources -join "`n")) -or
    ((@($profile.localOperator.sourceOrderHarness | ForEach-Object { [string]$_ }) -join "`n") -cne ($expectedOperatorHarnessSources -join "`n")) -or
    $profile.localOperator.expectedHarnessTests -ne 224 -or $profile.localOperator.expectedHarnessCanonicalNameBytes -ne 6650 -or
    [string]$profile.localOperator.expectedHarnessCaseNameSha256 -cne '8C8B1123EE04A4B811EE6F13759505A7A0188648E0AB7A2879D4B29CBCAFD44B' -or
    $profile.localOperator.legacyHarnessTests -ne 96 -or $profile.localOperator.legacyHarnessCanonicalNameBytes -ne 2409 -or
    [string]$profile.localOperator.legacyHarnessCaseNameSha256 -cne '0AAF52EE6A087B487B6497676F48BA7AD0D36CB987C149CC1BADAD9CA5D2FE68') {
    throw 'Local Operator policy mismatch.'
}
$expectedDryRunPayloadMembers = @('schema','planStatus','routeId','capability','sourceClass','providerPolicy','routeNetwork','routeAuthority','writes','planGuardEvaluation','executionGuardEvaluation','executionStatus','authority')
if ([string]$profile.localOperator.dryRunContract -cne 'EAIRA_OPERATOR_DRY_RUN_PLAN_V1' -or
    [string]$profile.localOperator.dryRunAuthority -cne 'PLAN_NOT_AUTHORITY' -or
    [string]$profile.localOperator.dryRunPlanStatus -cne 'VALIDATED_NOT_EXECUTED' -or
    [string]$profile.localOperator.dryRunGuardIntent -cne 'ALLOW_DRY_RUN_ONLY' -or
    [string]$profile.localOperator.dryRunExecutionGuardEvaluation -cne 'NOT_EVALUATED' -or
    [string]$profile.localOperator.dryRunExecutionStatus -cne 'NOT_EXECUTED' -or
    [string]$profile.localOperator.dryRunCallBudget -cne 'MODEL_COMPLETE=0;READS=0;TAGS=0;CHAT=0;FACTORIES=0' -or
    ((@($profile.localOperator.dryRunPayloadMemberOrder | ForEach-Object { [string]$_ }) -join "`n") -cne ($expectedDryRunPayloadMembers -join "`n"))) {
    throw 'Local Operator DryRun fixed profile contract mismatch.'
}
if (@($profile.localOperator.frameworkReferences.Cli).Count -ne 3 -or @($profile.localOperator.frameworkReferences.Harness).Count -ne 2 -or
    ((@($profile.localOperator.frameworkReferences.Cli | ForEach-Object { [string]$_ }) -join "`n") -cne "mscorlib.dll`nSystem.dll`nSystem.Net.Http.dll") -or
    ((@($profile.localOperator.frameworkReferences.Harness | ForEach-Object { [string]$_ }) -join "`n") -cne "mscorlib.dll`nSystem.dll")) {
    throw 'Local Operator framework-reference policy mismatch.'
}

$slice5ManifestPaths = @(
    'docs/project/strategy/EAIRA_M4_FUNCTIONAL_AGENT_MVP_SLICE_5_SCOPE_DECISION.md',
    'docs/project/planning/EAIRA_M4_SLICE5_BOUNDED_LOCAL_PROJECT_QA_ALLOWLIST.md',
    'docs/project/planning/EAIRA_M4_SLICE5_BOUNDED_LOCAL_PROJECT_QA_THREAT_MODEL.md',
    'docs/project/planning/EAIRA_M4_SLICE5_BOUNDED_LOCAL_PROJECT_QA_READINESS_PACKAGE.md',
    'docs/project/planning/EAIRA_M4_SLICE5_EXACT_IMPLEMENTATION_DESIGN_AND_CHANGED_PATH_MANIFEST.md',
    'docs/project/context/CURRENT_CONTEXT.md',
    'apps/agent-services/README.md',
    'apps/agent-services/contracts/EAIRA_BOUNDED_LOCAL_PROJECT_QA_V1.md',
    'apps/agent-services/src/ProjectContext.cs',
    'apps/agent-services/src/ProjectKnowledge.cs',
    'apps/agent-services/src/ProjectQa.cs',
    'apps/agent-services/src/ProjectQaHost.cs',
    'apps/agent-services/tests/ProjectQaHarness.cs',
    'apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1',
    'apps/agent-services/release/gate25-unsigned-release-profile.json'
)
$slice5BoundPaths = @($slice5ManifestPaths | Where-Object { $_ -cne 'apps/agent-services/release/gate25-unsigned-release-profile.json' })
$profileSlice5Inputs = @($profile.projectQa.boundRepositoryInputs)
if ($profileSlice5Inputs.Count -ne 14 -or ((@($profileSlice5Inputs | ForEach-Object { [string]$_.file })) -join [Environment]::NewLine) -cne ($slice5BoundPaths -join [Environment]::NewLine)) { throw 'Project-QA profile must bind the exact ordered 14 non-profile Slice 5 inputs.' }
$slice5InputsBound = $true
$slice5RepositoryEvidence = @()
foreach ($relativePath in $slice5ManifestPaths) {
    $candidatePath = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot $relativePath))
    if (-not (Test-Path -LiteralPath $candidatePath -PathType Leaf)) { throw "Slice 5 input missing: $relativePath" }
    $actualHash = Get-Sha256 -LiteralPath $candidatePath
    $item = Get-Item -LiteralPath $candidatePath
    if ($relativePath -cne 'apps/agent-services/release/gate25-unsigned-release-profile.json') {
        $expected = $profileSlice5Inputs | Where-Object { [string]$_.file -ceq $relativePath } | Select-Object -First 1
        if ($null -eq $expected -or [string]$expected.sha256 -cne $actualHash) { $slice5InputsBound = $false }
        if (-not $ProjectQaDiscovery -and -not $DevelopmentProbe -and [string]$expected.sha256 -cne $actualHash) { throw "Project-QA bound input hash mismatch: $relativePath" }
    }
    $slice5RepositoryEvidence += [ordered]@{ file=$relativePath; bytes=$item.Length; sha256=$actualHash }
}

$localOperatorBoundPaths = @(
    'docs/project/milestones/EAIRA_M5_INTEGRATED_LOCAL_RUNTIME_AND_OPERATOR_WORKFLOW_PROJECT_CHARTER.md',
    'docs/project/planning/EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE.md',
    'docs/project/planning/EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE_R1.md',
    'docs/project/planning/EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE_R2.md',
    'docs/project/planning/EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE_R3.md',
    'docs/project/strategy/EAIRA_M5_SLICE1_SCOPE_DECISION.md',
    'docs/project/planning/EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN.md',
    'docs/project/planning/EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R2.md',
    'docs/project/planning/EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R3.md',
    'docs/project/planning/EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R3R1.md',
    'docs/project/planning/EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R3R2.md',
    'docs/project/strategy/EAIRA_M5_SLICE2_SCOPE_DECISION.md',
    'docs/project/planning/EAIRA_M5_SLICE2_BOUNDED_OPERATOR_HEALTH_AND_CAPABILITY_STATUS_SCOPE_PACKAGE.md',
    'docs/project/planning/EAIRA_M5_SLICE2_EXACT_IMPLEMENTATION_DESIGN.md',
    'docs/project/strategy/EAIRA_M5_SLICE3_SCOPE_DECISION.md',
    'docs/project/planning/EAIRA_M5_SLICE3_BOUNDED_OPERATOR_PREFLIGHT_AND_ROUTE_EXPLANATION_READINESS_PACKAGE.md',
    'docs/project/planning/EAIRA_M5_SLICE3_EXACT_IMPLEMENTATION_DESIGN.md',
    'apps/agent-services/README.md',
    'apps/agent-services/contracts/EAIRA_LOCAL_OPERATOR_V1.md',
    'apps/agent-services/src/ContractCodec.cs',
    'apps/agent-services/src/AgentCore.cs',
    'apps/agent-services/src/ModelProviders.cs',
    'apps/agent-services/src/LocalTaskIntake.cs',
    'apps/agent-services/src/LocalModelProvider.cs',
    'apps/agent-services/src/OllamaLoopbackTransport.cs',
    'apps/agent-services/src/ProjectReadOnlyPlatform.cs',
    'apps/agent-services/src/ProjectContext.cs',
    'apps/agent-services/src/ProjectKnowledge.cs',
    'apps/agent-services/src/ProjectQa.cs',
    'apps/agent-services/src/ProjectQaHost.cs',
    'apps/agent-services/src/LocalOperator.cs',
    'apps/agent-services/src/LocalOperatorHost.cs',
    'apps/agent-services/tests/LocalOperatorHarness.cs',
    'apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1',
    'docs/project/strategy/EAIRA_M5_SLICE4_SCOPE_DECISION.md',
    'docs/project/planning/EAIRA_M5_SLICE4_BOUNDED_REQUEST_SPECIFIC_DRY_RUN_PLAN_READINESS_PACKAGE.md',
    'docs/project/planning/EAIRA_M5_SLICE4_EXACT_IMPLEMENTATION_DESIGN.md'
)
$profileOperatorInputs = @($profile.localOperator.boundRepositoryInputs)
if ($profileOperatorInputs.Count -ne 37 -or ((@($profileOperatorInputs | ForEach-Object { [string]$_.file })) -join "`n") -cne ($localOperatorBoundPaths -join "`n")) {
    throw 'Local Operator profile must bind the exact ordered 37 inputs.'
}
$localOperatorInputsBound = $true
$localOperatorRepositoryEvidence = @()
$dryRunDiscoveryInputBypassPaths = @(
    'apps/agent-services/README.md',
    'apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1',
    'apps/agent-services/contracts/EAIRA_LOCAL_OPERATOR_V1.md',
    'apps/agent-services/src/LocalOperator.cs',
    'apps/agent-services/tests/LocalOperatorHarness.cs',
    'docs/project/strategy/EAIRA_M5_SLICE4_SCOPE_DECISION.md',
    'docs/project/planning/EAIRA_M5_SLICE4_BOUNDED_REQUEST_SPECIFIC_DRY_RUN_PLAN_READINESS_PACKAGE.md',
    'docs/project/planning/EAIRA_M5_SLICE4_EXACT_IMPLEMENTATION_DESIGN.md'
)
foreach ($relativePath in $localOperatorBoundPaths) {
    $candidatePath = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot $relativePath))
    if (-not (Test-Path -LiteralPath $candidatePath -PathType Leaf)) { throw "Local Operator bound input missing: $relativePath" }
    $item = Get-Item -LiteralPath $candidatePath
    $actualHash = Get-Sha256 -LiteralPath $candidatePath
    $expected = $profileOperatorInputs | Where-Object { [string]$_.file -ceq $relativePath } | Select-Object -First 1
    $bindingMatches = $null -ne $expected -and [string]$expected.sha256 -ceq $actualHash -and [int64]$expected.bytes -eq [int64]$item.Length
    if (-not $bindingMatches) { $localOperatorInputsBound = $false }
    $discoveryInputBypass = $retainedOperatorDiscovery -or ($dryRunDiscovery -and $dryRunDiscoveryInputBypassPaths -ccontains $relativePath)
    if (-not $discoveryInputBypass -and -not $DevelopmentProbe -and -not $bindingMatches) {
        throw "Local Operator bound input hash mismatch: $relativePath"
    }
    $localOperatorRepositoryEvidence += [ordered]@{ file=$relativePath; bytes=$item.Length; sha256=$actualHash }
}

$expectedCandidateRepositoryPaths = @(
    'apps/agent-services/README.md',
    'apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1',
    'apps/agent-services/contracts/EAIRA_LOCAL_MODEL_PROVIDER_V1.md',
    'apps/agent-services/contracts/EAIRA_LOCAL_TASK_INTAKE_V1.md',
    'apps/agent-services/contracts/EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1.md',
    'apps/agent-services/release/gate25-unsigned-release-profile.json',
    'apps/agent-services/src/AgentTaskIntakeHost.cs',
    'apps/agent-services/src/LocalModelProvider.cs',
    'apps/agent-services/src/LocalTaskIntake.cs',
    'apps/agent-services/src/ModelProviders.cs',
    'apps/agent-services/src/OllamaLoopbackTransport.cs',
    'apps/agent-services/tests/LocalModelProviderHarness.cs',
    'apps/agent-services/tests/LocalTaskIntakeHarness.cs',
    'docs/project/context/CURRENT_CONTEXT.md',
    'docs/project/memory/HANDOFF.md',
    'docs/project/planning/EAIRA_M4_FUNCTIONAL_AGENT_MVP_SLICE_2_TASK.md',
    'docs/project/planning/EAIRA_M4_SLICE2_LOCAL_MODEL_PROVIDER_THREAT_MODEL.md',
    'docs/project/status/ACTIVE_TASK.yaml',
    'docs/project/status/AGENT_CONTEXT_VERSION.yaml',
    'docs/project/status/CURRENT_STATUS.md',
    'docs/project/status/TODAY_OBJECTIVE.md',
    'docs/project/strategy/EAIRA_M4_FUNCTIONAL_AGENT_MVP_SLICE_2_SCOPE_DECISION.md',
    'apps/agent-services/src/AgentCore.cs',
    'apps/agent-services/contracts/EAIRA_READ_ONLY_PROJECT_CONTEXT_V1.md',
    'apps/agent-services/src/ProjectContext.cs',
    'apps/agent-services/tests/AgentCoreHarness.cs',
    'apps/agent-services/tests/ProjectContextHarness.cs',
    'docs/project/planning/EAIRA_M4_SLICE3_EXACT_IMPLEMENTATION_DESIGN_AND_CHANGED_PATH_MANIFEST.md',
    'docs/project/planning/EAIRA_M4_SLICE3_READ_ONLY_PROJECT_CONTEXT_ALLOWLIST.md',
    'docs/project/planning/EAIRA_M4_SLICE3_READ_ONLY_PROJECT_CONTEXT_READINESS_PACKAGE.md',
    'docs/project/planning/EAIRA_M4_SLICE3_READ_ONLY_PROJECT_CONTEXT_THREAT_MODEL.md',
    'docs/project/strategy/EAIRA_M4_FUNCTIONAL_AGENT_MVP_SLICE_3_SCOPE_DECISION.md'
)
$profileCandidateRepositoryPaths = @($profile.candidateRepositoryPaths | ForEach-Object { [string]$_ })
if ($profileCandidateRepositoryPaths.Count -ne 32 -or
    ($profileCandidateRepositoryPaths -join [Environment]::NewLine) -cne ($expectedCandidateRepositoryPaths -join [Environment]::NewLine)) {
    throw 'Candidate repository path binding must match the exact ordered 32-path scope.'
}

$slice4ManifestPaths = @(
    'docs/project/strategy/EAIRA_M4_FUNCTIONAL_AGENT_MVP_SLICE_4_SCOPE_DECISION.md',
    'docs/project/planning/EAIRA_M4_SLICE4_BOUNDED_READ_ONLY_PROJECT_KNOWLEDGE_QUERY_ALLOWLIST.md',
    'docs/project/planning/EAIRA_M4_SLICE4_BOUNDED_READ_ONLY_PROJECT_KNOWLEDGE_QUERY_THREAT_MODEL.md',
    'docs/project/planning/EAIRA_M4_SLICE4_BOUNDED_READ_ONLY_PROJECT_KNOWLEDGE_QUERY_READINESS_PACKAGE.md',
    'docs/project/planning/EAIRA_M4_SLICE4_EXACT_IMPLEMENTATION_DESIGN_AND_CHANGED_PATH_MANIFEST.md',
    'apps/agent-services/contracts/EAIRA_PROJECT_KNOWLEDGE_QUERY_V1.md',
    'apps/agent-services/src/ContractCodec.cs',
    'apps/agent-services/src/AgentCore.cs',
    'apps/agent-services/src/ProjectReadOnlyPlatform.cs',
    'apps/agent-services/src/ProjectContext.cs',
    'apps/agent-services/src/ProjectKnowledge.cs',
    'apps/agent-services/src/ProjectKnowledgeHost.cs',
    'apps/agent-services/tests/ProjectKnowledgeHarness.cs',
    'apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1',
    'apps/agent-services/release/gate25-unsigned-release-profile.json',
    'docs/project/status/CURRENT_STATUS.md',
    'docs/project/status/TODAY_OBJECTIVE.md',
    'docs/project/status/ACTIVE_TASK.yaml',
    'docs/project/status/AGENT_CONTEXT_VERSION.yaml',
    'docs/project/context/CURRENT_CONTEXT.md',
    'docs/project/memory/HANDOFF.md'
)
$slice4BoundPaths = @($slice4ManifestPaths | Where-Object { $_ -cne 'apps/agent-services/release/gate25-unsigned-release-profile.json' })
$profileSlice4Inputs = @($profile.projectKnowledge.boundRepositoryInputs)
if ($profileSlice4Inputs.Count -ne 20 -or
    ((@($profileSlice4Inputs | ForEach-Object { [string]$_.file })) -join [Environment]::NewLine) -cne ($slice4BoundPaths -join [Environment]::NewLine)) {
    throw 'Project-knowledge profile must bind the exact ordered 20 non-profile Slice 4 inputs.'
}
$slice4InputsBound = $true
$slice4RepositoryEvidence = @()
for ($slice4Index = 0; $slice4Index -lt $slice4ManifestPaths.Count; $slice4Index++) {
    $relativePath = $slice4ManifestPaths[$slice4Index]
    $candidatePath = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot $relativePath))
    if (-not (Test-Path -LiteralPath $candidatePath -PathType Leaf)) { throw "Slice 4 input missing: $relativePath" }
    $item = Get-Item -LiteralPath $candidatePath
    $actualHash = Get-Sha256 -LiteralPath $candidatePath
    if ($relativePath -cne 'apps/agent-services/release/gate25-unsigned-release-profile.json') {
        $expected = $profileSlice4Inputs | Where-Object { [string]$_.file -ceq $relativePath } | Select-Object -First 1
        $expectedHash = [string]$expected.sha256
        if (-not $ProjectKnowledgeDiscovery -and -not $DevelopmentProbe -and
            ($expectedHash -notmatch '^[0-9A-F]{64}$' -or $actualHash -cne $expectedHash)) {
            throw "Project-knowledge bound input hash mismatch: $relativePath"
        }
        if ($actualHash -cne $expectedHash) { $slice4InputsBound = $false }
    }
    $slice4RepositoryEvidence += [ordered]@{ file = $relativePath; bytes = $item.Length; sha256 = $actualHash }
}

$compilerHash = Get-Sha256 -LiteralPath $resolvedCompiler
$compilerSignature = Get-AuthenticodeSignature -LiteralPath $resolvedCompiler
$compilerPolicyPass = $compilerHash -eq ([string]$profile.compilerPolicy.sha256).ToUpperInvariant() -and
                      $compilerSignature.Status.ToString() -eq [string]$profile.compilerPolicy.authenticodeStatus -and
                      $null -ne $compilerSignature.SignerCertificate -and
                      $compilerSignature.SignerCertificate.Subject -eq [string]$profile.compilerPolicy.signerSubject -and
                      $compilerSignature.SignerCertificate.Thumbprint.ToUpperInvariant() -eq ([string]$profile.compilerPolicy.signerThumbprint).ToUpperInvariant()
if (-not $DevelopmentProbe -and -not $compilerPolicyPass) { throw 'Compiler identity does not match the approved release profile.' }

$functionalSourceText = @(
    (Get-Content -Raw -LiteralPath $coreSourcePath),
    (Get-Content -Raw -LiteralPath $providerSourcePath),
    (Get-Content -Raw -LiteralPath $taskIntakeSourcePath),
    (Get-Content -Raw -LiteralPath $taskIntakeHostSourcePath),
    (Get-Content -Raw -LiteralPath $localProviderSourcePath),
    (Get-Content -Raw -LiteralPath $harnessSourcePath),
    (Get-Content -Raw -LiteralPath $taskIntakeHarnessSourcePath),
    (Get-Content -Raw -LiteralPath $localProviderHarnessSourcePath)
) -join "`n"
$serviceHostSourceText = Get-Content -Raw -LiteralPath $sourcePath
$loopbackTransportSourceText = Get-Content -Raw -LiteralPath $loopbackTransportSourcePath
$projectContextSourceText = Get-Content -Raw -LiteralPath $projectContextSourcePath
$projectReadOnlyPlatformSourceText = Get-Content -Raw -LiteralPath $projectReadOnlyPlatformSourcePath
$projectKnowledgeSourceText = Get-Content -Raw -LiteralPath $projectKnowledgeSourcePath
$projectKnowledgeHostSourceText = Get-Content -Raw -LiteralPath $projectKnowledgeHostSourcePath
$projectKnowledgeHarnessSourceText = Get-Content -Raw -LiteralPath $projectKnowledgeHarnessSourcePath
$projectQaSourceText = Get-Content -Raw -LiteralPath $projectQaSourcePath
$projectQaHostSourceText = Get-Content -Raw -LiteralPath $projectQaHostSourcePath
$projectQaHarnessSourceText = Get-Content -Raw -LiteralPath $projectQaHarnessSourcePath
$localOperatorSourceText = Get-Content -Raw -LiteralPath $localOperatorSourcePath
$localOperatorHostSourceText = Get-Content -Raw -LiteralPath $localOperatorHostSourcePath
$localOperatorHarnessSourceText = Get-Content -Raw -LiteralPath $localOperatorHarnessSourcePath
if ($localOperatorSourceText.IndexOf('using System.IO;', [StringComparison]::Ordinal) -ge 0 -or
    ([regex]::Matches($localOperatorHostSourceText, '(?m)^using System\.IO;$')).Count -ne 1 -or
    ([regex]::Matches($localOperatorHostSourceText, 'Console\.OpenStandardOutput\(\)')).Count -ne 1 -or
    ([regex]::Matches($localOperatorHostSourceText, '\.Write\(bytes, 0, bytes\.Length\)')).Count -ne 1 -or
    $localOperatorHostSourceText.IndexOf('.Flush(', [StringComparison]::Ordinal) -ge 0 -or
    $localOperatorHostSourceText.IndexOf('.Dispose(', [StringComparison]::Ordinal) -ge 0) {
    throw 'Local Operator stdout-only source policy mismatch.'
}
$projectContextHarnessSourceText = Get-Content -Raw -LiteralPath $projectContextHarnessSourcePath
$taskIntakeHarnessSourceText = Get-Content -Raw -LiteralPath $taskIntakeHarnessSourcePath
$expectedKnowledgeSources = @('src/ContractCodec.cs','src/ProjectReadOnlyPlatform.cs','src/ProjectKnowledge.cs','src/ProjectKnowledgeHost.cs')
$expectedKnowledgeHarnessSources = @('src/ContractCodec.cs','src/ProjectReadOnlyPlatform.cs','src/ProjectKnowledge.cs','src/ProjectKnowledgeHost.cs','tests/ProjectKnowledgeHarness.cs')
$expectedKnowledgePaths = @(
    'docs/project/memory/README.md','docs/project/memory/DECISION_INDEX.md','docs/project/memory/DISCOVERY_INDEX.md',
    'docs/project/memory/PROCEDURE_INDEX.md','docs/project/memory/OPEN_QUESTIONS.md',
    'docs/project/memory/STABILITY_CHECKLIST.md','docs/project/memory/MEMORY_SCHEMA.md'
)
if ((@($profile.projectKnowledge.sources | ForEach-Object { [string]$_ }) -join [Environment]::NewLine) -cne ($expectedKnowledgeSources -join [Environment]::NewLine) -or
    (@($profile.projectKnowledge.harnessSources | ForEach-Object { [string]$_ }) -join [Environment]::NewLine) -cne ($expectedKnowledgeHarnessSources -join [Environment]::NewLine) -or
    (@($profile.projectKnowledge.pathLiterals | ForEach-Object { [string]$_ }) -join [Environment]::NewLine) -cne ($expectedKnowledgePaths -join [Environment]::NewLine)) {
    throw 'Project-knowledge exact source order or path literal profile mismatch.'
}
foreach ($knowledgePathLiteral in $expectedKnowledgePaths) {
    if ([Regex]::Matches($projectKnowledgeSourceText, [Regex]::Escape('"' + $knowledgePathLiteral + '"')).Count -ne 1) {
        throw "Project-knowledge source path literal closure mismatch: $knowledgePathLiteral"
    }
}
if ([Regex]::Matches($projectKnowledgeSourceText, '"docs/project/memory/[^"]+"').Count -ne 7) {
    throw 'Project-knowledge source contains an eighth or missing memory path literal.'
}
$knowledgeCapabilityText = $projectKnowledgeSourceText + [Environment]::NewLine + $projectKnowledgeHostSourceText
foreach ($forbiddenKnowledgeToken in @('System.Net','HttpClient','WebClient','Socket','Directory.','GetFiles','EnumerateFiles','GetDirectories','EnumerateDirectories','Process','Environment.','Microsoft.Win32','System.Reflection','Activator','CallSite','BinaryFormatter','DataContractSerializer','XmlSerializer','WriteAllText','WriteAllBytes','AppendAllText','CreateDirectory','OpenWrite','FileStream','StreamWriter')) {
    if ($knowledgeCapabilityText.IndexOf($forbiddenKnowledgeToken, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
        throw "Project-knowledge source contains forbidden capability token '$forbiddenKnowledgeToken'."
    }
}
$loopbackRuntimeSourceText = [Regex]::Replace(
    $loopbackTransportSourceText,
    '(?s)#if TRANSPORT_POLICY_TESTS.*?#endif',
    ''
)
$allRuntimeSourceText = $serviceHostSourceText + "`n" + $functionalSourceText + "`n" + $loopbackRuntimeSourceText + "`n" + $projectReadOnlyPlatformSourceText + "`n" + $projectContextSourceText + "`n" + $projectContextHarnessSourceText
$forbiddenFunctionalPatterns = @(
    'System.IO',
    'System.Net',
    'System.Diagnostics',
    'Microsoft.Win32',
    'DllImport',
    'Assembly.Load',
    'NamedPipe',
    'TcpClient',
    'UdpClient',
    'HttpClient',
    'Socket',
    'Process.Start',
    'Environment.SetEnvironmentVariable'
)
foreach ($pattern in $forbiddenFunctionalPatterns) {
    if ($functionalSourceText.IndexOf($pattern, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
        throw "Functional core or harness contains prohibited implementation token: $pattern"
    }
}
$forbiddenProjectContextPatterns = @(
    'System.IO', 'System.Net', 'System.Diagnostics', 'Microsoft.Win32', 'Assembly.Load',
    'NamedPipe', 'TcpClient', 'UdpClient', 'HttpClient', 'Socket', 'Process.Start',
    'FileStream', 'StreamWriter', 'BinaryWriter', 'Environment.SetEnvironmentVariable'
)
foreach ($pattern in $forbiddenProjectContextPatterns) {
    if ($projectContextSourceText.IndexOf($pattern, [StringComparison]::OrdinalIgnoreCase) -ge 0 -or
        $projectReadOnlyPlatformSourceText.IndexOf($pattern, [StringComparison]::OrdinalIgnoreCase) -ge 0 -or
        $projectContextHarnessSourceText.IndexOf($pattern, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
        throw "Project-context source or harness contains prohibited implementation token: $pattern"
    }
}
if ($projectContextSourceText -cmatch '\b(?:System\.IO\.)?(?:File|Directory|Path)\s*\.' -or
    $projectReadOnlyPlatformSourceText -cmatch '\b(?:System\.IO\.)?(?:File|Directory|Path)\s*\.' -or
    $projectContextHarnessSourceText -cmatch '\b(?:System\.IO\.)?(?:File|Directory|Path)\s*\.') {
    throw 'Project-context source or harness contains a prohibited System.IO static API reference.'
}
if ([regex]::Matches($projectContextSourceText, '(?m)^#if EAIRA_PROJECT_CONTEXT_NATIVE\s*$').Count -ne 1 -or
    [regex]::Matches($projectContextSourceText, '(?m)^#if EAIRA_PROJECT_CONTEXT_TEST_SEAM\s*$').Count -ne 1 -or
    [regex]::Matches($projectReadOnlyPlatformSourceText, '(?m)^#if EAIRA_PROJECT_READONLY_NATIVE\s*$').Count -ne 1 -or
    [regex]::Matches($projectReadOnlyPlatformSourceText, '\[DllImport\(').Count -ne 6 -or
    [regex]::Matches($projectReadOnlyPlatformSourceText, '\bprivate static extern\s+').Count -ne 6 -or
    $projectContextSourceText -match '\bProjectContextNative\b' -or
    $projectReadOnlyPlatformSourceText.IndexOf('internal sealed class ProjectContextWin32Platform', [StringComparison]::Ordinal) -lt 0 -or
    [regex]::Matches($projectReadOnlyPlatformSourceText, '(?m)^\s*internal ProjectContextWin32Platform\(\) \{ \}\s*$').Count -ne 1 -or
    [regex]::Matches($projectContextHarnessSourceText, '(?m)^\s*internal FakePlatform\(\) \{ \}\s*$').Count -ne 1 -or
    [regex]::Matches($taskIntakeHarnessSourceText, '(?m)^\s*internal FakeCoordinator\(\) \{ \}\s*$').Count -ne 1) {
    throw 'Project-context conditional/native source topology mismatch.'
}
$taskIntakeConditionalText = Get-Content -Raw -LiteralPath $taskIntakeSourcePath
if ([regex]::Matches($taskIntakeConditionalText, '(?m)^#if EAIRA_PROJECT_CONTEXT_NATIVE\s*$').Count -ne 1 -or
    [regex]::Matches($taskIntakeConditionalText, '(?m)^#if EAIRA_PROJECT_CONTEXT_TEST_SEAM\s*$').Count -ne 1 -or
    $taskIntakeConditionalText.IndexOf('class Fake', [StringComparison]::OrdinalIgnoreCase) -ge 0 -or
    (Get-Content -Raw -LiteralPath $taskIntakeHostSourcePath).IndexOf('.GetType()', [StringComparison]::Ordinal) -ge 0 -or
    (Get-Content -Raw -LiteralPath $taskIntakeHarnessSourcePath).IndexOf('.GetType()', [StringComparison]::Ordinal) -ge 0) {
    throw 'Task-intake context factory or reflection source policy mismatch.'
}
$forbiddenTransportPatterns = @(
    'System.Net.Sockets',
    'Dns',
    'HttpListener',
    'WebClient',
    'WebRequest',
    'File.',
    'Directory.',
    'FileStream',
    'MemoryStream',
    'Process.',
    'Microsoft.Win32',
    'DllImport',
    'Assembly.Load'
)
foreach ($pattern in $forbiddenTransportPatterns) {
    if ($loopbackRuntimeSourceText.IndexOf($pattern, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
        throw "Loopback transport contains prohibited implementation token: $pattern"
    }
}
if ($loopbackRuntimeSourceText.IndexOf('http://127.0.0.1:11434/', [StringComparison]::Ordinal) -lt 0 -or
    $loopbackRuntimeSourceText.IndexOf('System.Net.Http', [StringComparison]::Ordinal) -lt 0 -or
    $loopbackRuntimeSourceText.IndexOf('System.IO', [StringComparison]::Ordinal) -lt 0) {
    throw 'Loopback transport does not contain the exact endpoint and namespace boundary.'
}
$forbiddenRuntimeWritePatterns = @(
    '(?i)\b(?:System\.IO\.)?File\s*\.\s*(?:Create|Delete|Move|Copy|Replace|Open|OpenWrite|CreateText|AppendText|WriteAllText|WriteAllBytes|WriteAllLines|AppendAllText|AppendAllLines|SetAttributes|SetCreationTime|SetLastAccessTime|SetLastWriteTime|Encrypt|Decrypt)\s*\(',
    '(?i)\b(?:System\.IO\.)?Directory\s*\.\s*(?:CreateDirectory|Delete|Move|SetCreationTime|SetLastAccessTime|SetLastWriteTime)\s*\(',
    '(?i)\b(?:System\.IO\.)?(?:FileStream|StreamWriter|BinaryWriter|FileInfo|DirectoryInfo)\b'
)
foreach ($pattern in $forbiddenRuntimeWritePatterns) {
    if ($allRuntimeSourceText -match $pattern) { throw "Runtime source contains prohibited write implementation pattern: $pattern" }
}

# The functional sources permit no System.IO at all. The service host has a
# deliberately narrower read-only allowlist: one namespace import, one
# File.Exists call and two Path.IsPathRooted calls. Any alias, qualified IO
# type, additional File/Directory/Path call, or instance IO type fails closed.
$ioUsingPattern = '(?m)^\s*using\s+System\.IO\s*;\s*$'
if ([regex]::Matches($serviceHostSourceText, $ioUsingPattern).Count -ne 1) { throw 'Service-host System.IO import does not match the exact read-only allowlist.' }
if ($serviceHostSourceText -match '(?im)^\s*using\s+(?:static\s+|[A-Za-z_][A-Za-z0-9_]*\s*=).*System\.IO') { throw 'Service-host System.IO alias or static import is prohibited.' }
$serviceHostWithoutAllowedImport = [regex]::Replace($serviceHostSourceText, $ioUsingPattern, '', [System.Text.RegularExpressions.RegexOptions]::Multiline)
if ($serviceHostWithoutAllowedImport -match '(?i)\bSystem\.IO\b') { throw 'Service-host qualified System.IO usage is outside the read-only allowlist.' }
if ($serviceHostSourceText -match '(?i)\b(?:FileInfo|DirectoryInfo|FileStream|StreamWriter|BinaryWriter)\b') { throw 'Service-host instance IO types are prohibited.' }
$ioCallMatches = [regex]::Matches($serviceHostSourceText, '(?i)\b(?:File|Directory|Path)\s*\.\s*[A-Za-z_][A-Za-z0-9_]*\s*\(')
$normalizedIoCalls = @($ioCallMatches | ForEach-Object { $_.Value -replace '\s', '' })
if ($normalizedIoCalls.Count -ne 3 -or
    @($normalizedIoCalls | Where-Object { $_ -ceq 'File.Exists(' }).Count -ne 1 -or
    @($normalizedIoCalls | Where-Object { $_ -ceq 'Path.IsPathRooted(' }).Count -ne 2) {
    throw 'Service-host IO calls do not match the exact read-only allowlist.'
}
$runtimeIoAllowlistCheckPass = $true

$referenceEvidence = @()
foreach ($reference in @($profile.referenceAssemblies)) {
    $path = Join-Path $resolvedReferences ([string]$reference.file)
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Reference assembly missing: $($reference.file)" }
    $actualHash = Get-Sha256 -LiteralPath $path
    if ($actualHash -ne ([string]$reference.sha256).ToUpperInvariant()) {
        throw "Reference assembly hash mismatch: $($reference.file)"
    }
    $item = Get-Item -LiteralPath $path
    $actualAssemblyVersion = [Reflection.AssemblyName]::GetAssemblyName($path).Version.ToString()
    if ($actualAssemblyVersion -cne [string]$reference.assemblyVersion -or
        $item.VersionInfo.FileVersion -cne [string]$reference.fileVersion) {
        throw "Reference assembly version mismatch: $($reference.file)"
    }
    $referenceEvidence += [ordered]@{
        file = [string]$reference.file
        bytes = $item.Length
        sha256 = $actualHash
        assemblyVersion = $actualAssemblyVersion
        fileVersion = $item.VersionInfo.FileVersion
        productVersion = $item.VersionInfo.ProductVersion
    }
}

$compilerHelp = @(& $resolvedCompiler /? 2>&1) -join "`n"
$supportsDeterministic = $compilerHelp -match '(?i)[/-]deterministic'
$supportsPathMap = $compilerHelp -match '(?i)[/-]pathmap'
if (-not $DevelopmentProbe -and (-not $supportsDeterministic -or -not $supportsPathMap)) {
    throw 'Compiler lacks /deterministic and/or /pathmap. Release build stopped fail-closed; use -DevelopmentProbe only for non-acceptance diagnostics.'
}

New-Item -ItemType Directory -Path $resolvedOutput | Out-Null
$buildRoots = @(
    (Join-Path $resolvedOutput 'clean-build-a'),
    (Join-Path $resolvedOutput 'clean-build-b')
)
foreach ($buildRoot in $buildRoots) { New-Item -ItemType Directory -Path $buildRoot | Out-Null }

$sourceHash = Get-Sha256 -LiteralPath $sourcePath
$coreSourceHash = Get-Sha256 -LiteralPath $coreSourcePath
$providerSourceHash = Get-Sha256 -LiteralPath $providerSourcePath
$taskIntakeSourceHash = Get-Sha256 -LiteralPath $taskIntakeSourcePath
$taskIntakeHostSourceHash = Get-Sha256 -LiteralPath $taskIntakeHostSourcePath
$localProviderSourceHash = Get-Sha256 -LiteralPath $localProviderSourcePath
$loopbackTransportSourceHash = Get-Sha256 -LiteralPath $loopbackTransportSourcePath
$projectContextSourceHash = Get-Sha256 -LiteralPath $projectContextSourcePath
$codecSourceHash = Get-Sha256 -LiteralPath $codecSourcePath
$projectReadOnlyPlatformSourceHash = Get-Sha256 -LiteralPath $projectReadOnlyPlatformSourcePath
$projectKnowledgeSourceHash = Get-Sha256 -LiteralPath $projectKnowledgeSourcePath
$projectKnowledgeHostSourceHash = Get-Sha256 -LiteralPath $projectKnowledgeHostSourcePath
$projectKnowledgeHarnessSourceHash = Get-Sha256 -LiteralPath $projectKnowledgeHarnessSourcePath
$projectQaSourceHash = Get-Sha256 -LiteralPath $projectQaSourcePath
$projectQaHostSourceHash = Get-Sha256 -LiteralPath $projectQaHostSourcePath
$projectQaHarnessSourceHash = Get-Sha256 -LiteralPath $projectQaHarnessSourcePath
$harnessSourceHash = Get-Sha256 -LiteralPath $harnessSourcePath
$taskIntakeHarnessSourceHash = Get-Sha256 -LiteralPath $taskIntakeHarnessSourcePath
$localProviderHarnessSourceHash = Get-Sha256 -LiteralPath $localProviderHarnessSourcePath
$projectContextHarnessSourceHash = Get-Sha256 -LiteralPath $projectContextHarnessSourcePath
$localOperatorSourceHash = Get-Sha256 -LiteralPath $localOperatorSourcePath
$localOperatorHostSourceHash = Get-Sha256 -LiteralPath $localOperatorHostSourcePath
$localOperatorHarnessSourceHash = Get-Sha256 -LiteralPath $localOperatorHarnessSourcePath
$allBuildEvidence = @()
$seamNegativeSpecimenEvidence = @()
$nativeNegativeSpecimenEvidence = @()
$knowledgeNegativeSpecimenEvidence = @()
$qaNegativeSpecimenEvidence = @()
$localOperatorNegativeSpecimenEvidence = @()
$preflightNegativeSpecimenEvidence = @()
$dryRunNegativeSpecimenEvidence = @()

for ($buildIndex = 0; $buildIndex -lt $buildRoots.Count; $buildIndex++) {
    $buildRoot = $buildRoots[$buildIndex]
    $roleEvidence = @()
    $harnessOutputPath = Join-Path $buildRoot 'EAIRA.AgentCore.Harness.exe'
    $harnessArguments = @(
        '/nologo',
        '/noconfig',
        '/target:exe',
        '/platform:x64',
        '/optimize+',
        '/debug-',
        '/checked+',
        '/highentropyva+',
        '/warn:4',
        '/warnaserror+',
        '/nostdlib+',
        "/reference:$resolvedReferences\mscorlib.dll",
        "/reference:$resolvedReferences\System.dll",
        '/main:EAIRA.AgentServices.Tests.AgentCoreHarness',
        "/out:$harnessOutputPath"
    )
    if (-not $DevelopmentProbe) {
        $harnessArguments += '/deterministic+'
        $harnessArguments += "/pathmap:$componentRoot=/_/EAIRA/apps/agent-services"
    }
    $harnessArguments += $codecSourcePath
    $harnessArguments += $coreSourcePath
    $harnessArguments += $providerSourcePath
    $harnessArguments += $harnessSourcePath
    $harnessCompilerOutput = @(& $resolvedCompiler @harnessArguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Functional harness compiler failed: $($harnessCompilerOutput -join "`n")" }
    Assert-NoForbiddenBinaryMetadata -LiteralPath $harnessOutputPath
    Assert-SystemIoMemberReferencePolicy -LiteralPath $harnessOutputPath

    $harnessSelfTest = Invoke-ExitCodeTest -Executable $harnessOutputPath -Arguments @('--self-test')
    $harnessInvalidTest = Invoke-ExitCodeTest -Executable $harnessOutputPath -Arguments @('--invalid')
    $harnessSignature = Get-AuthenticodeSignature -LiteralPath $harnessOutputPath
    try { $harnessJson = $harnessSelfTest.output | ConvertFrom-Json } catch { throw 'Functional harness output is not valid JSON.' }
    $harnessPass = $harnessSelfTest.exitCode -eq 0 -and
                   $harnessInvalidTest.exitCode -eq 64 -and
                   $harnessJson.status -eq 'PASS' -and
                   $harnessJson.contract -eq 'EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1' -and
                   $harnessJson.testsPassed -eq 45 -and
                   $harnessJson.network -eq 'NONE' -and
                   $harnessJson.ipc -eq 'NONE' -and
                   $harnessJson.writes -eq 'NONE' -and
                   $harnessJson.childProcess -eq 'NONE' -and
                   (Get-PeMachine -LiteralPath $harnessOutputPath) -eq '0x8664' -and
                   $harnessSignature.Status.ToString() -eq 'NotSigned'
    $harnessItem = Get-Item -LiteralPath $harnessOutputPath
    $harnessEvidence = [ordered]@{
        file = $harnessItem.Name
        bytes = $harnessItem.Length
        sha256 = Get-Sha256 -LiteralPath $harnessOutputPath
        peMachine = Get-PeMachine -LiteralPath $harnessOutputPath
        authenticode = $harnessSignature.Status.ToString()
        selfTestExitCode = $harnessSelfTest.exitCode
        invalidArgumentExitCode = $harnessInvalidTest.exitCode
        testsPassed = [int]$harnessJson.testsPassed
        offlineTestsPass = [bool]$harnessPass
    }

    $taskIntakeHarnessOutputPath = Join-Path $buildRoot 'EAIRA.LocalTaskIntake.Harness.exe'
    $taskIntakeHarnessArguments = @(
        '/nologo', '/noconfig', '/target:exe', '/platform:x64', '/optimize+', '/debug-', '/checked+', '/highentropyva+',
        '/warn:4', '/warnaserror+', '/nostdlib+', '/define:EAIRA_PROJECT_CONTEXT_TEST_SEAM',
        "/reference:$resolvedReferences\mscorlib.dll", "/reference:$resolvedReferences\System.dll",
        '/main:EAIRA.AgentServices.Tests.LocalTaskIntakeHarness', "/out:$taskIntakeHarnessOutputPath"
    )
    if (-not $DevelopmentProbe) {
        $taskIntakeHarnessArguments += '/deterministic+'
        $taskIntakeHarnessArguments += "/pathmap:$componentRoot=/_/EAIRA/apps/agent-services"
    }
    $taskIntakeHarnessArguments += $codecSourcePath
    $taskIntakeHarnessArguments += $coreSourcePath
    $taskIntakeHarnessArguments += $providerSourcePath
    $taskIntakeHarnessArguments += $taskIntakeSourcePath
    $taskIntakeHarnessArguments += $projectReadOnlyPlatformSourcePath
    $taskIntakeHarnessArguments += $projectContextSourcePath
    $taskIntakeHarnessArguments += $taskIntakeHarnessSourcePath
    $taskIntakeHarnessCompilerOutput = @(& $resolvedCompiler @taskIntakeHarnessArguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Task-intake harness compiler failed: $($taskIntakeHarnessCompilerOutput -join "`n")" }
    Assert-NoForbiddenBinaryMetadata -LiteralPath $taskIntakeHarnessOutputPath
    Assert-SystemIoMemberReferencePolicy -LiteralPath $taskIntakeHarnessOutputPath
    $taskIntakeHarnessSeamEvidence = Assert-ProjectContextSeamPolicy -LiteralPath $taskIntakeHarnessOutputPath -OutputKind 'IntakeHarness' -Policy $profile.projectContext
    $taskIntakeHarnessSelfTest = Invoke-ExitCodeTest -Executable $taskIntakeHarnessOutputPath -Arguments @('--self-test')
    $taskIntakeHarnessInvalidTest = Invoke-ExitCodeTest -Executable $taskIntakeHarnessOutputPath -Arguments @('--invalid')
    $taskIntakeHarnessSignature = Get-AuthenticodeSignature -LiteralPath $taskIntakeHarnessOutputPath
    try { $taskIntakeHarnessJson = $taskIntakeHarnessSelfTest.output | ConvertFrom-Json } catch { throw 'Task-intake harness output is not valid JSON.' }
    $taskIntakeHarnessPass = $taskIntakeHarnessSelfTest.exitCode -eq 0 -and
                             $taskIntakeHarnessInvalidTest.exitCode -eq 64 -and
                             $taskIntakeHarnessJson.status -eq 'PASS' -and
                             $taskIntakeHarnessJson.contract -eq 'EAIRA_LOCAL_TASK_INTAKE_V1' -and
                             $taskIntakeHarnessJson.testsPassed -eq 27 -and
                             $taskIntakeHarnessJson.network -eq 'NONE' -and
                             $taskIntakeHarnessJson.writes -eq 'NONE' -and
                             $taskIntakeHarnessJson.realProvider -eq 'BLOCKED' -and
                             (Get-PeMachine -LiteralPath $taskIntakeHarnessOutputPath) -eq '0x8664' -and
                             $taskIntakeHarnessSignature.Status.ToString() -eq 'NotSigned'
    $taskIntakeHarnessItem = Get-Item -LiteralPath $taskIntakeHarnessOutputPath
    $taskIntakeHarnessEvidence = [ordered]@{
        file = $taskIntakeHarnessItem.Name
        bytes = $taskIntakeHarnessItem.Length
        sha256 = Get-Sha256 -LiteralPath $taskIntakeHarnessOutputPath
        peMachine = Get-PeMachine -LiteralPath $taskIntakeHarnessOutputPath
        authenticode = $taskIntakeHarnessSignature.Status.ToString()
        selfTestExitCode = $taskIntakeHarnessSelfTest.exitCode
        invalidArgumentExitCode = $taskIntakeHarnessInvalidTest.exitCode
        testsPassed = [int]$taskIntakeHarnessJson.testsPassed
        seamPolicy = $taskIntakeHarnessSeamEvidence
        offlineTestsPass = [bool]$taskIntakeHarnessPass
    }

    $projectContextHarnessOutputPath = Join-Path $buildRoot ([string]$profile.projectContext.outputHarness)
    $projectContextHarnessArguments = @(
        '/nologo', '/noconfig', '/target:exe', '/platform:x64', '/optimize+', '/debug-', '/checked+', '/highentropyva+',
        '/warn:4', '/warnaserror+', '/nostdlib+', '/define:EAIRA_PROJECT_READONLY_NATIVE,EAIRA_PROJECT_CONTEXT_NATIVE,EAIRA_PROJECT_CONTEXT_TEST_SEAM',
        "/reference:$resolvedReferences\mscorlib.dll", "/reference:$resolvedReferences\System.dll",
        '/main:EAIRA.AgentServices.Tests.ProjectContextHarness', "/out:$projectContextHarnessOutputPath"
    )
    if (-not $DevelopmentProbe) {
        $projectContextHarnessArguments += '/deterministic+'
        $projectContextHarnessArguments += "/pathmap:$componentRoot=/_/EAIRA/apps/agent-services"
    }
    $projectContextHarnessArguments += $codecSourcePath
    $projectContextHarnessArguments += $coreSourcePath
    $projectContextHarnessArguments += $providerSourcePath
    $projectContextHarnessArguments += $localProviderSourcePath
    $projectContextHarnessArguments += $projectReadOnlyPlatformSourcePath
    $projectContextHarnessArguments += $projectContextSourcePath
    $projectContextHarnessArguments += $projectContextHarnessSourcePath
    $projectContextHarnessCompilerOutput = @(& $resolvedCompiler @projectContextHarnessArguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Project-context harness compiler failed: $($projectContextHarnessCompilerOutput -join [Environment]::NewLine)" }
    Assert-NoForbiddenBinaryMetadata -LiteralPath $projectContextHarnessOutputPath -AllowProjectContextPInvoke
    Assert-SystemIoMemberReferencePolicy -LiteralPath $projectContextHarnessOutputPath
    $projectContextHarnessPInvokeMetadata = Assert-ProjectContextPInvokePolicy -LiteralPath $projectContextHarnessOutputPath -Policy $profile.projectContext -OutputKind 'ContextHarness'
    $projectContextHarnessCallerEvidence = Assert-ProjectContextPInvokeCallerPolicy -LiteralPath $projectContextHarnessOutputPath -Policy $profile.projectContext -OutputKind 'ContextHarness'
    $projectContextHarnessSeamEvidence = Assert-ProjectContextSeamPolicy -LiteralPath $projectContextHarnessOutputPath -OutputKind 'ContextHarness' -Policy $profile.projectContext
    $projectContextHarnessSelfTest = Invoke-ExitCodeTest -Executable $projectContextHarnessOutputPath -Arguments @('--self-test')
    $projectContextHarnessInvalidTest = Invoke-ExitCodeTest -Executable $projectContextHarnessOutputPath -Arguments @('--invalid')
    $projectContextHarnessSignature = Get-AuthenticodeSignature -LiteralPath $projectContextHarnessOutputPath
    try { $projectContextHarnessJson = $projectContextHarnessSelfTest.output | ConvertFrom-Json } catch { throw 'Project-context harness output is not valid JSON.' }
    $projectContextHarnessPass = $projectContextHarnessSelfTest.exitCode -eq 0 -and
                                 $projectContextHarnessInvalidTest.exitCode -eq 64 -and
                                 $projectContextHarnessJson.status -eq 'PASS' -and
                                 $projectContextHarnessJson.contract -eq 'EAIRA_READ_ONLY_PROJECT_CONTEXT_V1' -and
                                 $projectContextHarnessJson.testsPassed -eq [int]$profile.projectContext.expectedHarnessTests -and
                                 $projectContextHarnessJson.network -eq 'NONE' -and
                                 $projectContextHarnessJson.writes -eq 'NONE' -and
                                 (Get-PeMachine -LiteralPath $projectContextHarnessOutputPath) -eq '0x8664' -and
                                 $projectContextHarnessSignature.Status.ToString() -eq 'NotSigned'
    $projectContextHarnessItem = Get-Item -LiteralPath $projectContextHarnessOutputPath
    $projectContextHarnessEvidence = [ordered]@{
        file = $projectContextHarnessItem.Name
        bytes = $projectContextHarnessItem.Length
        sha256 = Get-Sha256 -LiteralPath $projectContextHarnessOutputPath
        peMachine = Get-PeMachine -LiteralPath $projectContextHarnessOutputPath
        authenticode = $projectContextHarnessSignature.Status.ToString()
        selfTestExitCode = $projectContextHarnessSelfTest.exitCode
        invalidArgumentExitCode = $projectContextHarnessInvalidTest.exitCode
        testsPassed = [int]$projectContextHarnessJson.testsPassed
        moduleRefs = @($projectContextHarnessPInvokeMetadata.modules)
        pInvokeRows = @($projectContextHarnessPInvokeMetadata.rows)
        nativeCallSiteCount = [int]$projectContextHarnessCallerEvidence.nativeCallSiteCount
        nativeCallerEdges = @($projectContextHarnessCallerEvidence.nativeEdges)
        approvedNativeCallerIl = @($projectContextHarnessCallerEvidence.approvedCallerIl)
        approvedNativeCallerIlCount = [int]$projectContextHarnessCallerEvidence.approvedCallerIlCount
        approvedNativeCallerIlSha256 = [string]$projectContextHarnessCallerEvidence.approvedCallerIlSha256
        approvedNativeCallerIlProfileMatch = [bool]$projectContextHarnessCallerEvidence.approvedCallerIlProfileMatch
        seamPolicy = $projectContextHarnessSeamEvidence
        offlineTestsPass = [bool]$projectContextHarnessPass
    }

    $projectKnowledgeHarnessOutputPath = Join-Path $buildRoot ([string]$profile.projectKnowledge.outputHarness)
    $projectKnowledgeHarnessArguments = @(
        '/nologo', '/noconfig', '/target:exe', '/platform:x64', '/optimize+', '/debug-', '/checked+', '/highentropyva+',
        '/warn:4', '/warnaserror+', '/nostdlib+', '/define:EAIRA_PROJECT_KNOWLEDGE_TEST_SEAM',
        "/reference:$resolvedReferences\mscorlib.dll", "/reference:$resolvedReferences\System.dll",
        '/main:EAIRA.AgentServices.Tests.ProjectKnowledgeHarness', "/out:$projectKnowledgeHarnessOutputPath"
    )
    if (-not $DevelopmentProbe) {
        $projectKnowledgeHarnessArguments += '/deterministic+'
        $projectKnowledgeHarnessArguments += "/pathmap:$componentRoot=/_/EAIRA/apps/agent-services"
    }
    $projectKnowledgeHarnessArguments += $codecSourcePath
    $projectKnowledgeHarnessArguments += $projectReadOnlyPlatformSourcePath
    $projectKnowledgeHarnessArguments += $projectKnowledgeSourcePath
    $projectKnowledgeHarnessArguments += $projectKnowledgeHostSourcePath
    $projectKnowledgeHarnessArguments += $projectKnowledgeHarnessSourcePath
    $projectKnowledgeHarnessCompilerOutput = @(& $resolvedCompiler @projectKnowledgeHarnessArguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Project-knowledge harness compiler failed: $($projectKnowledgeHarnessCompilerOutput -join [Environment]::NewLine)" }
    Assert-NoForbiddenBinaryMetadata -LiteralPath $projectKnowledgeHarnessOutputPath
    Assert-SystemIoMemberReferencePolicy -LiteralPath $projectKnowledgeHarnessOutputPath
    $projectKnowledgeHarnessMetadata = Assert-ProjectKnowledgeMetadataPolicy -LiteralPath $projectKnowledgeHarnessOutputPath -Policy $profile.projectKnowledge -OutputKind 'Harness' -Discovery:$ProjectKnowledgeDiscovery
    $projectKnowledgeHarnessSelfTest = Invoke-ExitCodeTest -Executable $projectKnowledgeHarnessOutputPath -Arguments @('--self-test')
    $projectKnowledgeHarnessInvalidTest = Invoke-ExitCodeTest -Executable $projectKnowledgeHarnessOutputPath -Arguments @('--invalid')
    try { $projectKnowledgeHarnessJson = $projectKnowledgeHarnessSelfTest.output | ConvertFrom-Json } catch { throw 'Project-knowledge harness output is not valid JSON.' }
    $projectKnowledgeHarnessPass = $projectKnowledgeHarnessSelfTest.exitCode -eq 0 -and
                                   $projectKnowledgeHarnessInvalidTest.exitCode -eq 64 -and
                                   $projectKnowledgeHarnessJson.status -eq 'PASS' -and
                                   $projectKnowledgeHarnessJson.schema -eq 'EAIRA_PROJECT_KNOWLEDGE_HARNESS_V1' -and
                                   (($ProjectKnowledgeDiscovery -and [int]$projectKnowledgeHarnessJson.testsPassed -ge 350) -or
                                    (-not $ProjectKnowledgeDiscovery -and [int]$projectKnowledgeHarnessJson.testsPassed -eq [int]$profile.projectKnowledge.expectedHarnessTests)) -and
                                   [string]$projectKnowledgeHarnessJson.caseNameSha256 -match '^[0-9A-F]{64}$' -and
                                   ($ProjectKnowledgeDiscovery -or [string]$projectKnowledgeHarnessJson.caseNameSha256 -ceq [string]$profile.projectKnowledge.expectedHarnessCaseNameSha256) -and
                                   $projectKnowledgeHarnessJson.network -eq 'NONE' -and
                                   $projectKnowledgeHarnessJson.writes -eq 'NONE' -and
                                   (Get-PeMachine -LiteralPath $projectKnowledgeHarnessOutputPath) -eq '0x8664' -and
                                   (Get-AuthenticodeSignature -LiteralPath $projectKnowledgeHarnessOutputPath).Status.ToString() -eq 'NotSigned'
    $projectKnowledgeHarnessEvidence = [ordered]@{
        file = (Get-Item -LiteralPath $projectKnowledgeHarnessOutputPath).Name
        bytes = (Get-Item -LiteralPath $projectKnowledgeHarnessOutputPath).Length
        sha256 = Get-Sha256 -LiteralPath $projectKnowledgeHarnessOutputPath
        testsPassed = [int]$projectKnowledgeHarnessJson.testsPassed
        caseNameSha256 = [string]$projectKnowledgeHarnessJson.caseNameSha256
        invalidArgumentExitCode = $projectKnowledgeHarnessInvalidTest.exitCode
        metadataInventory = $projectKnowledgeHarnessMetadata
        offlineTestsPass = [bool]$projectKnowledgeHarnessPass
    }

    $projectKnowledgeOutputPath = Join-Path $buildRoot ([string]$profile.projectKnowledge.output)
    $projectKnowledgeArguments = @(
        '/nologo', '/noconfig', '/target:exe', '/platform:x64', '/optimize+', '/debug-', '/checked+', '/highentropyva+',
        '/warn:4', '/warnaserror+', '/nostdlib+', '/define:EAIRA_PROJECT_READONLY_NATIVE,EAIRA_PROJECT_KNOWLEDGE_NATIVE',
        "/reference:$resolvedReferences\mscorlib.dll", "/reference:$resolvedReferences\System.dll",
        '/main:EAIRA.AgentServices.ProjectKnowledge.ProjectKnowledgeHost', "/out:$projectKnowledgeOutputPath"
    )
    if (-not $DevelopmentProbe) {
        $projectKnowledgeArguments += '/deterministic+'
        $projectKnowledgeArguments += "/pathmap:$componentRoot=/_/EAIRA/apps/agent-services"
    }
    $projectKnowledgeArguments += $codecSourcePath
    $projectKnowledgeArguments += $projectReadOnlyPlatformSourcePath
    $projectKnowledgeArguments += $projectKnowledgeSourcePath
    $projectKnowledgeArguments += $projectKnowledgeHostSourcePath
    $projectKnowledgeCompilerOutput = @(& $resolvedCompiler @projectKnowledgeArguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Project-knowledge CLI compiler failed: $($projectKnowledgeCompilerOutput -join [Environment]::NewLine)" }
    Assert-NoForbiddenBinaryMetadata -LiteralPath $projectKnowledgeOutputPath -AllowProjectContextPInvoke
    Assert-SystemIoMemberReferencePolicy -LiteralPath $projectKnowledgeOutputPath -AllowProjectKnowledgeStdout
    $projectKnowledgePInvokeMetadata = Assert-ProjectContextPInvokePolicy -LiteralPath $projectKnowledgeOutputPath -Policy $profile.projectContext -OutputKind 'KnowledgeCli' -Discovery:$ProjectKnowledgeDiscovery
    $projectKnowledgeCallerEvidence = Assert-ProjectContextPInvokeCallerPolicy -LiteralPath $projectKnowledgeOutputPath -Policy $profile.projectContext -OutputKind 'KnowledgeCli' -Discovery:$ProjectKnowledgeDiscovery
    $projectKnowledgeMetadata = Assert-ProjectKnowledgeMetadataPolicy -LiteralPath $projectKnowledgeOutputPath -Policy $profile.projectKnowledge -OutputKind 'Cli' -Discovery:$ProjectKnowledgeDiscovery
    $projectKnowledgeNativeSemantic = Get-NormalizedNativeSemanticInventory -PInvokeMetadata $projectKnowledgePInvokeMetadata -CallerEvidence $projectKnowledgeCallerEvidence
    $knowledgeFixtureBase = Join-Path $buildRoot 'knowledge-cli-fixtures'
    $knowledgeZeroRoot = Join-Path $knowledgeFixtureBase 'ZERO'
    $knowledgeOneRoot = Join-Path $knowledgeFixtureBase 'ONE'
    $knowledgeMissingRoot = Join-Path $knowledgeFixtureBase 'MISSING'
    New-ProjectKnowledgeFixtureRoot -LiteralRoot $knowledgeZeroRoot -PathLiterals @($profile.projectKnowledge.pathLiterals) -Mode ZERO
    New-ProjectKnowledgeFixtureRoot -LiteralRoot $knowledgeOneRoot -PathLiterals @($profile.projectKnowledge.pathLiterals) -Mode ONE
    New-ProjectKnowledgeFixtureRoot -LiteralRoot $knowledgeMissingRoot -PathLiterals @($profile.projectKnowledge.pathLiterals) -Mode MISSING
    $projectKnowledgeInvalid = Invoke-ExactChannelTest -Executable $projectKnowledgeOutputPath -Arguments @('--invalid')
    $projectKnowledgeZero = Invoke-ExactChannelTest -Executable $projectKnowledgeOutputPath -Arguments @('--root',$knowledgeZeroRoot,'--query','a')
    $projectKnowledgeOne = Invoke-ExactChannelTest -Executable $projectKnowledgeOutputPath -Arguments @('--root',$knowledgeOneRoot,'--query','a')
    $projectKnowledgeFailure = Invoke-ExactChannelTest -Executable $projectKnowledgeOutputPath -Arguments @('--root',$knowledgeMissingRoot,'--query','a')
    $invalidBytes = [Text.Encoding]::UTF8.GetBytes("{`"schema`":`"EAIRA_PROJECT_KNOWLEDGE_ERROR_V1`",`"status`":`"INVALID_REQUEST`",`"network`":`"NONE`",`"writes`":`"NONE`"}`n")
    $failureBytes = [Text.Encoding]::UTF8.GetBytes("{`"schema`":`"EAIRA_PROJECT_KNOWLEDGE_ERROR_V1`",`"status`":`"KNOWLEDGE_ERROR`",`"network`":`"NONE`",`"writes`":`"NONE`"}`n")
    $projectKnowledgeInvalidPass = $projectKnowledgeInvalid.exitCode -eq 64 -and
        ([Convert]::ToBase64String($projectKnowledgeInvalid.stdoutBytes) -ceq [Convert]::ToBase64String($invalidBytes)) -and
        $projectKnowledgeInvalid.stderrBytes.Length -eq 0
    $projectKnowledgeActualChannels = [ordered]@{
        invalid = [ordered]@{ exitCode=$projectKnowledgeInvalid.exitCode; stdoutBytes=$projectKnowledgeInvalid.stdoutBytes.Length; stdoutSha256=$projectKnowledgeInvalid.stdoutSha256; stderrBytes=$projectKnowledgeInvalid.stderrBytes.Length }
        zero = [ordered]@{ exitCode=$projectKnowledgeZero.exitCode; stdoutBytes=$projectKnowledgeZero.stdoutBytes.Length; stdoutSha256=$projectKnowledgeZero.stdoutSha256; stderrBytes=$projectKnowledgeZero.stderrBytes.Length }
        one = [ordered]@{ exitCode=$projectKnowledgeOne.exitCode; stdoutBytes=$projectKnowledgeOne.stdoutBytes.Length; stdoutSha256=$projectKnowledgeOne.stdoutSha256; stderrBytes=$projectKnowledgeOne.stderrBytes.Length }
        knowledgeError = [ordered]@{ exitCode=$projectKnowledgeFailure.exitCode; stdoutBytes=$projectKnowledgeFailure.stdoutBytes.Length; stdoutSha256=$projectKnowledgeFailure.stdoutSha256; stderrBytes=$projectKnowledgeFailure.stderrBytes.Length }
    }
    $projectKnowledgeChannelProfilePass = $ProjectKnowledgeDiscovery -or
        (($projectKnowledgeActualChannels | ConvertTo-Json -Depth 4 -Compress) -ceq
         ($profile.projectKnowledge.channelMatrix | ConvertTo-Json -Depth 4 -Compress))
    $projectKnowledgeChannelPass = $projectKnowledgeChannelProfilePass -and $projectKnowledgeInvalidPass -and
        $projectKnowledgeZero.exitCode -eq 0 -and $projectKnowledgeZero.stderrBytes.Length -eq 0 -and
        $projectKnowledgeZero.stdoutBytes.Length -eq [int]$profile.projectKnowledge.zeroStdoutBytes -and
        $projectKnowledgeZero.stdoutSha256 -ceq [string]$profile.projectKnowledge.zeroStdoutSha256 -and
        $projectKnowledgeOne.exitCode -eq 0 -and $projectKnowledgeOne.stderrBytes.Length -eq 0 -and
        $projectKnowledgeOne.stdoutBytes.Length -eq [int]$profile.projectKnowledge.oneStdoutBytes -and
        $projectKnowledgeOne.stdoutSha256 -ceq [string]$profile.projectKnowledge.oneStdoutSha256 -and
        $projectKnowledgeFailure.exitCode -eq 81 -and $projectKnowledgeFailure.stderrBytes.Length -eq 0 -and
        ([Convert]::ToBase64String($projectKnowledgeFailure.stdoutBytes) -ceq [Convert]::ToBase64String($failureBytes))
    $projectKnowledgeEvidence = [ordered]@{
        file = (Get-Item -LiteralPath $projectKnowledgeOutputPath).Name
        bytes = (Get-Item -LiteralPath $projectKnowledgeOutputPath).Length
        sha256 = Get-Sha256 -LiteralPath $projectKnowledgeOutputPath
        invalidRequestExitCode = $projectKnowledgeInvalid.exitCode
        invalidRequestPass = [bool]$projectKnowledgeInvalidPass
        channelMatrixPass = [bool]$projectKnowledgeChannelPass
        channelMatrixProfileMatch = [bool]$projectKnowledgeChannelProfilePass
        channels = $projectKnowledgeActualChannels
        moduleRefs = @($projectKnowledgePInvokeMetadata.modules)
        pInvokeRows = @($projectKnowledgePInvokeMetadata.rows)
        nativeCallSiteCount = [int]$projectKnowledgeCallerEvidence.nativeCallSiteCount
        approvedNativeCallerIlCount = [int]$projectKnowledgeCallerEvidence.approvedCallerIlCount
        approvedNativeCallerIlSha256 = [string]$projectKnowledgeCallerEvidence.approvedCallerIlSha256
        metadataInventory = $projectKnowledgeMetadata
        normalizedNativeInventory = $projectKnowledgeNativeSemantic
    }

    $localProviderHarnessOutputPath = Join-Path $buildRoot 'EAIRA.LocalModelProvider.Harness.exe'
    $localProviderHarnessArguments = @(
        '/nologo', '/noconfig', '/target:exe', '/platform:x64', '/optimize+', '/debug-', '/checked+', '/highentropyva+',
        '/warn:4', '/warnaserror+', '/nostdlib+',
        "/reference:$resolvedReferences\mscorlib.dll", "/reference:$resolvedReferences\System.dll",
        '/main:EAIRA.AgentServices.Tests.LocalModelProviderHarness', "/out:$localProviderHarnessOutputPath"
    )
    if (-not $DevelopmentProbe) {
        $localProviderHarnessArguments += '/deterministic+'
        $localProviderHarnessArguments += "/pathmap:$componentRoot=/_/EAIRA/apps/agent-services"
    }
    $localProviderHarnessArguments += $codecSourcePath
    $localProviderHarnessArguments += $coreSourcePath
    $localProviderHarnessArguments += $providerSourcePath
    $localProviderHarnessArguments += $taskIntakeSourcePath
    $localProviderHarnessArguments += $localProviderSourcePath
    $localProviderHarnessArguments += $projectReadOnlyPlatformSourcePath
    $localProviderHarnessArguments += $projectContextSourcePath
    $localProviderHarnessArguments += $localProviderHarnessSourcePath
    $localProviderHarnessCompilerOutput = @(& $resolvedCompiler @localProviderHarnessArguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Local-provider harness compiler failed: $($localProviderHarnessCompilerOutput -join [Environment]::NewLine)" }
    Assert-NoForbiddenBinaryMetadata -LiteralPath $localProviderHarnessOutputPath
    Assert-SystemIoMemberReferencePolicy -LiteralPath $localProviderHarnessOutputPath
    $localProviderHarnessSeamEvidence = Assert-ProjectContextSeamPolicy -LiteralPath $localProviderHarnessOutputPath -OutputKind 'ProviderHarness' -Policy $profile.projectContext
    $localProviderHarnessSelfTest = Invoke-ExitCodeTest -Executable $localProviderHarnessOutputPath -Arguments @('--self-test')
    $localProviderHarnessInvalidTest = Invoke-ExitCodeTest -Executable $localProviderHarnessOutputPath -Arguments @('--invalid')
    $localProviderHarnessSignature = Get-AuthenticodeSignature -LiteralPath $localProviderHarnessOutputPath
    try { $localProviderHarnessJson = $localProviderHarnessSelfTest.output | ConvertFrom-Json } catch { throw 'Local-provider harness output is not valid JSON.' }
    $localProviderHarnessPass = $localProviderHarnessSelfTest.exitCode -eq 0 -and
                                $localProviderHarnessInvalidTest.exitCode -eq 64 -and
                                $localProviderHarnessJson.status -eq 'PASS' -and
                                $localProviderHarnessJson.contract -eq 'EAIRA_LOCAL_MODEL_PROVIDER_V1' -and
                                $localProviderHarnessJson.testsPassed -eq 41 -and
                                $localProviderHarnessJson.network -eq 'NONE' -and
                                $localProviderHarnessJson.writes -eq 'NONE' -and
                                $localProviderHarnessJson.transport -eq 'FAKE' -and
                                (Get-PeMachine -LiteralPath $localProviderHarnessOutputPath) -eq '0x8664' -and
                                $localProviderHarnessSignature.Status.ToString() -eq 'NotSigned'
    $localProviderHarnessItem = Get-Item -LiteralPath $localProviderHarnessOutputPath
    $localProviderHarnessEvidence = [ordered]@{
        file = $localProviderHarnessItem.Name
        bytes = $localProviderHarnessItem.Length
        sha256 = Get-Sha256 -LiteralPath $localProviderHarnessOutputPath
        peMachine = Get-PeMachine -LiteralPath $localProviderHarnessOutputPath
        authenticode = $localProviderHarnessSignature.Status.ToString()
        selfTestExitCode = $localProviderHarnessSelfTest.exitCode
        invalidArgumentExitCode = $localProviderHarnessInvalidTest.exitCode
        testsPassed = [int]$localProviderHarnessJson.testsPassed
        network = [string]$localProviderHarnessJson.network
        transport = [string]$localProviderHarnessJson.transport
        seamPolicy = $localProviderHarnessSeamEvidence
        offlineTestsPass = [bool]$localProviderHarnessPass
    }

    $transportPolicyHarnessOutputPath = Join-Path $buildRoot 'EAIRA.LoopbackTransport.PolicyHarness.exe'
    $transportPolicyHarnessArguments = @(
        '/nologo', '/noconfig', '/target:exe', '/platform:x64', '/optimize+', '/debug-', '/checked+', '/highentropyva+',
        '/warn:4', '/warnaserror+', '/nostdlib+', '/define:TRANSPORT_POLICY_TESTS',
        "/reference:$resolvedReferences\mscorlib.dll", "/reference:$resolvedReferences\System.dll",
        "/reference:$resolvedReferences\System.Net.Http.dll",
        '/main:EAIRA.AgentServices.Tests.LoopbackTransportPolicyHarness', "/out:$transportPolicyHarnessOutputPath"
    )
    if (-not $DevelopmentProbe) {
        $transportPolicyHarnessArguments += '/deterministic+'
        $transportPolicyHarnessArguments += "/pathmap:$componentRoot=/_/EAIRA/apps/agent-services"
    }
    $transportPolicyHarnessArguments += $codecSourcePath
    $transportPolicyHarnessArguments += $coreSourcePath
    $transportPolicyHarnessArguments += $providerSourcePath
    $transportPolicyHarnessArguments += $taskIntakeSourcePath
    $transportPolicyHarnessArguments += $localProviderSourcePath
    $transportPolicyHarnessArguments += $loopbackTransportSourcePath
    $transportPolicyHarnessArguments += $projectReadOnlyPlatformSourcePath
    $transportPolicyHarnessArguments += $projectContextSourcePath
    $transportPolicyHarnessCompilerOutput = @(& $resolvedCompiler @transportPolicyHarnessArguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Transport-policy harness compiler failed: $($transportPolicyHarnessCompilerOutput -join [Environment]::NewLine)" }
    Assert-NoForbiddenBinaryMetadata -LiteralPath $transportPolicyHarnessOutputPath -AllowLoopbackHttp
    $transportPolicyHarnessSeamEvidence = Assert-ProjectContextSeamPolicy -LiteralPath $transportPolicyHarnessOutputPath -OutputKind 'TransportHarness' -Policy $profile.projectContext
    $transportPolicyHarnessSelfTest = Invoke-ExitCodeTest -Executable $transportPolicyHarnessOutputPath -Arguments @('--self-test')
    $transportPolicyHarnessInvalidTest = Invoke-ExitCodeTest -Executable $transportPolicyHarnessOutputPath -Arguments @('--invalid')
    $transportPolicyHarnessSignature = Get-AuthenticodeSignature -LiteralPath $transportPolicyHarnessOutputPath
    try { $transportPolicyHarnessJson = $transportPolicyHarnessSelfTest.output | ConvertFrom-Json } catch { throw 'Transport-policy harness output is not valid JSON.' }
    $transportPolicyHarnessPass = $transportPolicyHarnessSelfTest.exitCode -eq 0 -and
                                  $transportPolicyHarnessInvalidTest.exitCode -eq 64 -and
                                  $transportPolicyHarnessJson.status -eq 'PASS' -and
                                  $transportPolicyHarnessJson.contract -eq 'EAIRA_LOCAL_MODEL_PROVIDER_V1' -and
                                  $transportPolicyHarnessJson.testsPassed -eq 10 -and
                                  $transportPolicyHarnessJson.network -eq 'NONE' -and
                                  $transportPolicyHarnessJson.writes -eq 'NONE' -and
                                  $transportPolicyHarnessJson.transport -eq 'POLICY_ONLY_FAKE_STREAM' -and
                                  (Get-PeMachine -LiteralPath $transportPolicyHarnessOutputPath) -eq '0x8664' -and
                                  $transportPolicyHarnessSignature.Status.ToString() -eq 'NotSigned'
    $transportPolicyHarnessItem = Get-Item -LiteralPath $transportPolicyHarnessOutputPath
    $transportPolicyHarnessEvidence = [ordered]@{
        file = $transportPolicyHarnessItem.Name
        bytes = $transportPolicyHarnessItem.Length
        sha256 = Get-Sha256 -LiteralPath $transportPolicyHarnessOutputPath
        peMachine = Get-PeMachine -LiteralPath $transportPolicyHarnessOutputPath
        authenticode = $transportPolicyHarnessSignature.Status.ToString()
        selfTestExitCode = $transportPolicyHarnessSelfTest.exitCode
        invalidArgumentExitCode = $transportPolicyHarnessInvalidTest.exitCode
        testsPassed = [int]$transportPolicyHarnessJson.testsPassed
        network = [string]$transportPolicyHarnessJson.network
        transport = [string]$transportPolicyHarnessJson.transport
        seamPolicy = $transportPolicyHarnessSeamEvidence
        offlineTestsPass = [bool]$transportPolicyHarnessPass
    }

    $taskIntakeOutputPath = Join-Path $buildRoot ([string]$profile.taskIntake.output)
    $taskIntakeArguments = @(
        '/nologo', '/noconfig', '/target:exe', '/platform:x64', '/optimize+', '/debug-', '/checked+', '/highentropyva+',
        '/warn:4', '/warnaserror+', '/nostdlib+',
        "/reference:$resolvedReferences\mscorlib.dll", "/reference:$resolvedReferences\System.dll",
        "/reference:$resolvedReferences\System.Net.Http.dll", '/define:EAIRA_PROJECT_READONLY_NATIVE,EAIRA_PROJECT_CONTEXT_NATIVE',
        '/main:EAIRA.AgentServices.TaskIntake.AgentTaskIntakeHost', "/out:$taskIntakeOutputPath"
    )
    if (-not $DevelopmentProbe) {
        $taskIntakeArguments += '/deterministic+'
        $taskIntakeArguments += "/pathmap:$componentRoot=/_/EAIRA/apps/agent-services"
    }
    $taskIntakeArguments += $codecSourcePath
    $taskIntakeArguments += $coreSourcePath
    $taskIntakeArguments += $providerSourcePath
    $taskIntakeArguments += $taskIntakeSourcePath
    $taskIntakeArguments += $localProviderSourcePath
    $taskIntakeArguments += $loopbackTransportSourcePath
    $taskIntakeArguments += $projectReadOnlyPlatformSourcePath
    $taskIntakeArguments += $projectContextSourcePath
    $taskIntakeArguments += $taskIntakeHostSourcePath
    $taskIntakeCompilerOutput = @(& $resolvedCompiler @taskIntakeArguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Task-intake CLI compiler failed: $($taskIntakeCompilerOutput -join "`n")" }
    Assert-NoForbiddenBinaryMetadata -LiteralPath $taskIntakeOutputPath -AllowLoopbackHttp -AllowProjectContextPInvoke
    $taskIntakePInvokeMetadata = Assert-ProjectContextPInvokePolicy -LiteralPath $taskIntakeOutputPath -Policy $profile.projectContext -OutputKind 'Cli'
    $taskIntakeCallerEvidence = Assert-ProjectContextPInvokeCallerPolicy -LiteralPath $taskIntakeOutputPath -Policy $profile.projectContext -OutputKind 'Cli'
    $taskIntakeNativeSemantic = Get-NormalizedNativeSemanticInventory -PInvokeMetadata $taskIntakePInvokeMetadata -CallerEvidence $taskIntakeCallerEvidence
    $taskIntakeSeamEvidence = Assert-ProjectContextSeamPolicy -LiteralPath $taskIntakeOutputPath -OutputKind 'Cli' -Policy $profile.projectContext
    Assert-LoopbackMetadataPolicy -LiteralPath $taskIntakeOutputPath -Policy $profile.cliMetadataAllowlist -DevelopmentProbe:$DevelopmentProbe

    $allowedArgs = @('--provider','mock','--trace','ABCDEF0123456789ABCDEF0123456789','--goal','prepare bounded release plan')
    $taskAllowed = Invoke-ExitCodeTest -Executable $taskIntakeOutputPath -Arguments $allowedArgs
    $taskAllowedRepeat = Invoke-ExitCodeTest -Executable $taskIntakeOutputPath -Arguments $allowedArgs
    $taskDenied = Invoke-ExitCodeTest -Executable $taskIntakeOutputPath -Arguments @('--provider','mock','--trace','1234567890ABCDEF1234567890ABCDEF','--goal','write file')
    $taskReal = Invoke-ExitCodeTest -Executable $taskIntakeOutputPath -Arguments @('--provider','real','--trace','11111111222222223333333344444444','--goal','prepare bounded release plan')
    $taskInvalid = Invoke-ExitCodeTest -Executable $taskIntakeOutputPath -Arguments @('--provider','unknown','--trace','ABCDEF0123456789ABCDEF0123456789','--goal','prepare bounded release plan')
    $taskInvalidUnicode = Invoke-ExitCodeTest -Executable $taskIntakeOutputPath -Arguments @('--provider','mock','--trace','ABCDEF0123456789ABCDEF0123456789','--goal',(new-object string ([char]0xD800, 1)))
    $taskContextDeniedMock = Invoke-ExitCodeTest -Executable $taskIntakeOutputPath -Arguments @('--provider','mock','--trace','9999AAAABBBBCCCCDDDDEEEEFFFF0000','--goal','write file','--context-root','C:\EAIRA-CONTEXT-NOT-PRESENT')
    $taskContextDeniedLocal = Invoke-ExitCodeTest -Executable $taskIntakeOutputPath -Arguments @('--provider','ollama-local','--model','qwen3:4b','--trace','88889999AAAABBBBCCCCDDDDEEEEFFFF','--goal','write file','--context-root','C:\EAIRA-CONTEXT-NOT-PRESENT')
    $taskContextError = Invoke-ExitCodeTest -Executable $taskIntakeOutputPath -Arguments @('--provider','mock','--trace','777788889999AAAABBBBCCCCDDDDEEEE','--goal','prepare bounded release plan','--context-root','C:\EAIRA-CONTEXT-NOT-PRESENT')
    try { $taskAllowedJson = $taskAllowed.output | ConvertFrom-Json } catch { throw 'Allowed task-intake output is not valid JSON.' }
    try { $taskDeniedJson = $taskDenied.output | ConvertFrom-Json } catch { throw 'Denied task-intake output is not valid JSON.' }
    try { $taskRealJson = $taskReal.output | ConvertFrom-Json } catch { throw 'Real-provider task-intake output is not valid JSON.' }
    try { $taskInvalidJson = $taskInvalid.output | ConvertFrom-Json } catch { throw 'Invalid task-intake output is not valid JSON.' }
    try { $taskInvalidUnicodeJson = $taskInvalidUnicode.output | ConvertFrom-Json } catch { throw 'Invalid-Unicode task-intake output is not valid JSON.' }
    try { $taskContextDeniedMockJson = $taskContextDeniedMock.output | ConvertFrom-Json } catch { throw 'Context-denied mock output is not valid JSON.' }
    try { $taskContextDeniedLocalJson = $taskContextDeniedLocal.output | ConvertFrom-Json } catch { throw 'Context-denied local output is not valid JSON.' }
    try { $taskContextErrorJson = $taskContextError.output | ConvertFrom-Json } catch { throw 'Context-error output is not valid JSON.' }
    $taskIntakeSignature = Get-AuthenticodeSignature -LiteralPath $taskIntakeOutputPath
    $taskIntakePass = $taskAllowed.exitCode -eq 0 -and
                      $taskAllowedRepeat.exitCode -eq 0 -and
                      $taskAllowed.output -eq $taskAllowedRepeat.output -and
                      $taskAllowedJson.status -eq 'PASS' -and $taskAllowedJson.provider -eq 'mock-v1' -and
                      $taskAllowedJson.network -eq 'NONE' -and $taskAllowedJson.writes -eq 'NONE' -and
                      $taskDenied.exitCode -eq 77 -and $taskDeniedJson.status -eq 'DENIED' -and
                      $taskReal.exitCode -eq 78 -and $taskRealJson.status -eq 'PROVIDER_BLOCKED' -and
                       $taskInvalid.exitCode -eq 64 -and $taskInvalidJson.status -eq 'INVALID_REQUEST' -and
                       $taskInvalidUnicode.exitCode -eq 64 -and $taskInvalidUnicodeJson.status -eq 'INVALID_REQUEST' -and
                       $taskContextDeniedMock.exitCode -eq 77 -and $taskContextDeniedMock.output -ceq '{"schemaVersion":1,"status":"DENIED","provider":"mock-v1","traceId":"9999AAAABBBBCCCCDDDDEEEEFFFF0000","outcome":"DENIED","network":"NONE","writes":"NONE","result":null,"context":{"state":"NOT_READ_GUARD_DENY"}}' -and
                       $taskContextDeniedLocal.exitCode -eq 77 -and $taskContextDeniedLocalJson.provider -eq 'ollama-loopback-v1' -and $taskContextDeniedLocalJson.context.state -eq 'NOT_READ_GUARD_DENY' -and
                       $taskContextError.exitCode -eq 80 -and $taskContextError.output -ceq '{"schemaVersion":1,"status":"CONTEXT_ERROR","errorType":"ProjectContextException","network":"NONE","writes":"NONE","context":null}' -and
                      (Get-PeMachine -LiteralPath $taskIntakeOutputPath) -eq '0x8664' -and
                      $taskIntakeSignature.Status.ToString() -eq 'NotSigned'
    $taskIntakeItem = Get-Item -LiteralPath $taskIntakeOutputPath
    $taskIntakeEvidence = [ordered]@{
        file = $taskIntakeItem.Name
        bytes = $taskIntakeItem.Length
        sha256 = Get-Sha256 -LiteralPath $taskIntakeOutputPath
        peMachine = Get-PeMachine -LiteralPath $taskIntakeOutputPath
        authenticode = $taskIntakeSignature.Status.ToString()
        allowedExitCode = $taskAllowed.exitCode
        deniedExitCode = $taskDenied.exitCode
        realProviderExitCode = $taskReal.exitCode
        invalidRequestExitCode = $taskInvalid.exitCode
        invalidUnicodeExitCode = $taskInvalidUnicode.exitCode
        contextDeniedMockExitCode = $taskContextDeniedMock.exitCode
        contextDeniedLocalExitCode = $taskContextDeniedLocal.exitCode
        contextErrorExitCode = $taskContextError.exitCode
        moduleRefs = @($taskIntakePInvokeMetadata.modules)
        pInvokeRows = @($taskIntakePInvokeMetadata.rows)
        nativeCallSiteCount = [int]$taskIntakeCallerEvidence.nativeCallSiteCount
        nativeCallerEdges = @($taskIntakeCallerEvidence.nativeEdges)
        approvedNativeCallerIl = @($taskIntakeCallerEvidence.approvedCallerIl)
        approvedNativeCallerIlCount = [int]$taskIntakeCallerEvidence.approvedCallerIlCount
        approvedNativeCallerIlSha256 = [string]$taskIntakeCallerEvidence.approvedCallerIlSha256
        approvedNativeCallerIlProfileMatch = [bool]$taskIntakeCallerEvidence.approvedCallerIlProfileMatch
        normalizedNativeInventory = $taskIntakeNativeSemantic
        seamPolicy = $taskIntakeSeamEvidence
        deterministicOutput = [bool]($taskAllowed.output -eq $taskAllowedRepeat.output)
        offlineTestsPass = [bool]$taskIntakePass
    }

    if ($buildIndex -eq 0) {
        $knowledgeSpecimenRoot = Join-Path $buildRoot 'knowledge-negative-specimens'
        New-Item -ItemType Directory -Path $knowledgeSpecimenRoot | Out-Null
        $knowledgeCases = @(
            [ordered]@{ Name='EXTRA_PATH_LITERAL'; Path=$projectKnowledgeSourcePath; Text=$projectKnowledgeSourceText; Old='"docs/project/memory/STABILITY_CHECKLIST.md", "docs/project/memory/MEMORY_SCHEMA.md"'; New='"docs/project/memory/STABILITY_CHECKLIST.md", "docs/project/memory/MEMORY_SCHEMA.md", "docs/project/memory/EXTRA.md"' },
            [ordered]@{ Name='ARBITRARY_PATH_METHOD'; Path=$projectKnowledgeSourcePath; Text=$projectKnowledgeSourceText; Old='        internal static string NormalizeQueryOrThrowRequest(string value)'; New="        internal ILeafProbeHandle OpenArbitraryPath(string value) { return platform.OpenLeafProbe(value); }`n`n        internal static string NormalizeQueryOrThrowRequest(string value)" },
            [ordered]@{ Name='OUTPUT_SCHEMA_CHANGE'; Path=$projectKnowledgeSourcePath; Text=$projectKnowledgeSourceText; Old='EAIRA_PROJECT_KNOWLEDGE_QUERY_V1'; New='EAIRA_PROJECT_KNOWLEDGE_QUERY_V2' },
            [ordered]@{ Name='RAW_CONTENT_OUTPUT'; Path=$projectKnowledgeSourcePath; Text=$projectKnowledgeSourceText; Old='        internal string Path, Heading, Excerpt;'; New="        internal string Path, Heading, Excerpt;`n        internal string RawContent { get { return Excerpt; } }" },
            [ordered]@{ Name='RAW_PATH_OUTPUT'; Path=$projectKnowledgeSourcePath; Text=$projectKnowledgeSourceText; Old='        internal string Path, Heading, Excerpt;'; New="        internal string Path, Heading, Excerpt;`n        internal string RawAbsolutePath { get { return Path; } }" },
            [ordered]@{ Name='RAW_QUERY_OUTPUT'; Path=$projectKnowledgeSourcePath; Text=$projectKnowledgeSourceText; Old='        internal string QuerySha256, ResultSetSha256;'; New="        internal string QuerySha256, ResultSetSha256;`n        internal string RawQuery { get { return QuerySha256; } }" },
            [ordered]@{ Name='WRONG_DIGEST_FRAMING'; Path=$projectKnowledgeSourcePath; Text=$projectKnowledgeSourceText; Old='EAIRA-KNOWLEDGE-QUERY-V1'; New='EAIRA-KNOWLEDGE-QUERY-V1-BAD' },
            [ordered]@{ Name='ALTERNATE_FACTORY'; Path=$projectKnowledgeSourcePath; Text=$projectKnowledgeSourceText; Old='        internal static ProjectKnowledgeQuery CreateNative() { return new ProjectKnowledgeQuery(new ProjectContextWin32Platform()); }'; New="        internal static ProjectKnowledgeQuery CreateNative() { return new ProjectKnowledgeQuery(new ProjectContextWin32Platform()); }`n        internal static ProjectKnowledgeQuery CreateAlternate() { return new ProjectKnowledgeQuery(new ProjectContextWin32Platform()); }" },
            [ordered]@{ Name='ALTERNATE_CONSTRUCTOR'; Path=$projectKnowledgeSourcePath; Text=$projectKnowledgeSourceText; Old='        private ProjectKnowledgeQuery(IProjectContextReadOnlyPlatform value) { if (value == null) { throw new ProjectKnowledgeException(); } platform = value; }'; New="        private ProjectKnowledgeQuery(IProjectContextReadOnlyPlatform value) { if (value == null) { throw new ProjectKnowledgeException(); } platform = value; }`n        private ProjectKnowledgeQuery(IProjectContextReadOnlyPlatform value, int ignored) : this(value) { if (ignored == Int32.MinValue) { throw new ProjectKnowledgeException(); } }" },
            [ordered]@{ Name='ALTERNATE_CALLER'; Path=$projectKnowledgeHostSourcePath; Text=$projectKnowledgeHostSourceText; Old='        internal static int RunCore(string[] args, Func<ProjectKnowledgeQuery> factory, Action<string> write)'; New="        private static ProjectKnowledgeQuery AlternateCaller() { return ProjectKnowledgeQuery.CreateNative(); }`n`n        internal static int RunCore(string[] args, Func<ProjectKnowledgeQuery> factory, Action<string> write)" },
            [ordered]@{ Name='REFLECTION_DISPATCH'; Path=$projectKnowledgeSourcePath; Text=$projectKnowledgeSourceText; Old='        internal static string NormalizeQueryOrThrowRequest(string value)'; New="        private static object ReflectionBad() { return Activator.CreateInstance(typeof(StringBuilder)); }`n`n        internal static string NormalizeQueryOrThrowRequest(string value)" },
            [ordered]@{ Name='DYNAMIC_DISPATCH'; Path=$projectKnowledgeSourcePath; Text=$projectKnowledgeSourceText; Old='        internal static string NormalizeQueryOrThrowRequest(string value)'; New="        private static object DynamicBad(Delegate value) { return value.DynamicInvoke(new object[0]); }`n`n        internal static string NormalizeQueryOrThrowRequest(string value)" },
            [ordered]@{ Name='WRITE_REFERENCE'; Path=$projectKnowledgeSourcePath; Text=$projectKnowledgeSourceText; Old='        internal static string NormalizeQueryOrThrowRequest(string value)'; New="        private static void WriteBad() { System.IO.File.WriteAllText(`"x`", `"x`"); }`n`n        internal static string NormalizeQueryOrThrowRequest(string value)" },
            [ordered]@{ Name='NETWORK_REFERENCE'; Path=$projectKnowledgeSourcePath; Text=$projectKnowledgeSourceText; Old='        internal static string NormalizeQueryOrThrowRequest(string value)'; New="        private static string NetworkBad() { return System.Net.Dns.GetHostName(); }`n`n        internal static string NormalizeQueryOrThrowRequest(string value)" },
            [ordered]@{ Name='DIRECTORY_ENUMERATION'; Path=$projectKnowledgeSourcePath; Text=$projectKnowledgeSourceText; Old='        internal static string NormalizeQueryOrThrowRequest(string value)'; New="        private static string[] EnumerateBad() { return System.IO.Directory.GetFiles(`"x`"); }`n`n        internal static string NormalizeQueryOrThrowRequest(string value)" },
            [ordered]@{ Name='DUPLICATE_PINVOKE'; Path=$projectReadOnlyPlatformSourcePath; Text=$projectReadOnlyPlatformSourceText; Old='        [return: MarshalAs(UnmanagedType.Bool)] private static extern bool CloseHandle(IntPtr handle);'; New="        [return: MarshalAs(UnmanagedType.Bool)] private static extern bool CloseHandle(IntPtr handle);`n        [DllImport(`"kernel32.dll`", EntryPoint = `"CloseHandle`", ExactSpelling = true, CallingConvention = CallingConvention.Winapi, CharSet = CharSet.Unicode, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true, PreserveSig = true)]`n        [return: MarshalAs(UnmanagedType.Bool)] private static extern bool CloseHandleDuplicate(IntPtr handle);" },
            [ordered]@{ Name='MOVED_PINVOKE_VISIBILITY'; Path=$projectReadOnlyPlatformSourcePath; Text=$projectReadOnlyPlatformSourceText; Old='        [return: MarshalAs(UnmanagedType.Bool)] private static extern bool CloseHandle(IntPtr handle);'; New='        [return: MarshalAs(UnmanagedType.Bool)] internal static extern bool CloseHandle(IntPtr handle);' }
        )
        foreach ($case in $knowledgeCases) {
            $changed = Replace-ExactSpecimenText -Text ([string]$case.Text) -Old ([string]$case.Old) -New ([string]$case.New) -SpecimenName ([string]$case.Name)
            $replacements = @{}
            $replacements[[string]$case.Path] = $changed
            $knowledgeNegativeSpecimenEvidence += Invoke-ProjectKnowledgeNegativeSpecimen -Name ([string]$case.Name) `
                -CompilerPath $resolvedCompiler -CompilerArguments $projectKnowledgeArguments -ReplacementSources $replacements `
                -SpecimenRoot $knowledgeSpecimenRoot -ProjectKnowledgePolicy $profile.projectKnowledge `
                -ProjectContextPolicy $profile.projectContext -BaselineMetadata $projectKnowledgeMetadata
        }
        $specimenRoot = Join-Path $buildRoot 'seam-negative-specimens'
        New-Item -ItemType Directory -Path $specimenRoot | Out-Null
        $mainConstructionLine = '                LocalTaskIntake intake = CreateIntakeForTests();'

        $extraConstructorSource = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText `
            -Old "            internal FakeCoordinator() { }`n`n            internal int Calls" `
            -New "            internal FakeCoordinator() { }`n            internal FakeCoordinator(int ignored) { if (ignored == Int32.MinValue) { Calls = 0; } }`n`n            internal int Calls" `
            -SpecimenName 'EXTRA_IMPLEMENTER_CONSTRUCTOR'
        $replacementSources = @{}
        $replacementSources[$taskIntakeHarnessSourcePath] = $extraConstructorSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'EXTRA_IMPLEMENTER_CONSTRUCTOR' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $extraCallerSource = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText `
            -Old "        private static void RunAll(LocalTaskIntake intake)`n        {`n            string trace" `
            -New "        private static void RunAll(LocalTaskIntake intake)`n        {`n            contextCoordinator = new FakeCoordinator();`n            string trace" `
            -SpecimenName 'EXTRA_CONSTRUCTOR_CALLER'
        $replacementSources = @{}
        $replacementSources[$taskIntakeHarnessSourcePath] = $extraCallerSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'EXTRA_CONSTRUCTOR_CALLER' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $wrapperSource = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText `
            -Old '        private static LocalTaskIntake CreateIntakeForTests()' `
            -New "        private static LocalTaskIntake ForbiddenWrapper()`n        {`n            return CreateIntakeForTests();`n        }`n`n        private static LocalTaskIntake CreateIntakeForTests()" `
            -SpecimenName 'WRAPPER_BETWEEN_MAIN_AND_HELPER'
        $wrapperSource = Replace-ExactSpecimenText -Text $wrapperSource -Old $mainConstructionLine `
            -New '                LocalTaskIntake intake = ForbiddenWrapper();' -SpecimenName 'WRAPPER_BETWEEN_MAIN_AND_HELPER_CALL'
        $replacementSources = @{}
        $replacementSources[$taskIntakeHarnessSourcePath] = $wrapperSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'WRAPPER_BETWEEN_MAIN_AND_HELPER' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $functionPointerSource = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText -Old $mainConstructionLine `
            -New "                Func<LocalTaskIntake> forbiddenFactory = CreateIntakeForTests;`n                LocalTaskIntake intake = forbiddenFactory();" `
            -SpecimenName 'HELPER_FUNCTION_POINTER_LOAD'
        $replacementSources = @{}
        $replacementSources[$taskIntakeHarnessSourcePath] = $functionPointerSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'HELPER_FUNCTION_POINTER_LOAD' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $reflectionSource = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText -Old $mainConstructionLine `
            -New "                if (Activator.CreateInstance(typeof(FakeCoordinator)) == null) { return 70; }`n                LocalTaskIntake intake = CreateIntakeForTests();" `
            -SpecimenName 'ACTIVATOR_CONSTRUCTION'
        $replacementSources = @{}
        $replacementSources[$taskIntakeHarnessSourcePath] = $reflectionSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'ACTIVATOR_CONSTRUCTION' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $genericFactoryOld = "        internal static LocalTaskIntake CreateForTests(ILocalModelProviderFactory factory, IProjectContextRequestCoordinator coordinator)`n        {`n            if (coordinator == null) { throw new ContractException(`"Context coordinator is required.`"); }`n            return new LocalTaskIntake(factory, coordinator);`n        }"
        $genericFactoryNew = $genericFactoryOld + "`n`n        internal static LocalTaskIntake CreateForTests<T>(ILocalModelProviderFactory factory, IProjectContextRequestCoordinator coordinator)`n        {`n            return new LocalTaskIntake(factory, coordinator);`n        }"
        $genericFactorySource = Replace-ExactSpecimenText -Text $taskIntakeConditionalText -Old $genericFactoryOld `
            -New $genericFactoryNew -SpecimenName 'GENERIC_FACTORY_METHODSPEC'
        $genericFactoryHarness = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText -Old $mainConstructionLine `
            -New '                LocalTaskIntake intake = LocalTaskIntake.CreateForTests<int>(localFactory, new FakeCoordinator());' `
            -SpecimenName 'GENERIC_FACTORY_METHODSPEC_CALL'
        $replacementSources = @{}
        $replacementSources[$taskIntakeSourcePath] = $genericFactorySource
        $replacementSources[$taskIntakeHarnessSourcePath] = $genericFactoryHarness
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'GENERIC_FACTORY_METHODSPEC' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $factoryOverloadNew = $genericFactoryOld + "`n`n        internal static LocalTaskIntake CreateForTests(ILocalModelProviderFactory factory, IProjectContextRequestCoordinator coordinator, int ignored)`n        {`n            if (ignored == Int32.MinValue) { throw new ContractException(`"Invalid specimen.`"); }`n            return new LocalTaskIntake(factory, coordinator);`n        }"
        $factoryOverloadSource = Replace-ExactSpecimenText -Text $taskIntakeConditionalText -Old $genericFactoryOld `
            -New $factoryOverloadNew -SpecimenName 'EXTRA_FACTORY_OVERLOAD'
        $replacementSources = @{}
        $replacementSources[$taskIntakeSourcePath] = $factoryOverloadSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'EXTRA_FACTORY_OVERLOAD' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $helperOverloadSource = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText `
            -Old '        private static LocalTaskIntake CreateIntakeForTests()' `
            -New "        private static LocalTaskIntake CreateIntakeForTests(int ignored)`n        {`n            if (ignored == Int32.MinValue) { return null; }`n            return CreateIntakeForTests();`n        }`n`n        private static LocalTaskIntake CreateIntakeForTests()" `
            -SpecimenName 'EXTRA_HELPER_OVERLOAD'
        $replacementSources = @{}
        $replacementSources[$taskIntakeHarnessSourcePath] = $helperOverloadSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'EXTRA_HELPER_OVERLOAD' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $conversionSource = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText `
            -Old "            internal FakeCoordinator() { }`n`n            internal int Calls" `
            -New "            internal FakeCoordinator() { }`n            public static implicit operator int(FakeCoordinator value) { return value == null ? 0 : value.Calls; }`n`n            internal int Calls" `
            -SpecimenName 'CONVERSION_OPERATOR'
        $replacementSources = @{}
        $replacementSources[$taskIntakeHarnessSourcePath] = $conversionSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'CONVERSION_OPERATOR' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $typeInitializerSource = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText `
            -Old "            internal FakeCoordinator() { }`n`n            internal int Calls" `
            -New "            internal FakeCoordinator() { }`n            static FakeCoordinator() { }`n`n            internal int Calls" `
            -SpecimenName 'IMPLEMENTER_TYPE_INITIALIZER'
        $replacementSources = @{}
        $replacementSources[$taskIntakeHarnessSourcePath] = $typeInitializerSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'IMPLEMENTER_TYPE_INITIALIZER' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $secondImplementerSource = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText `
            -Old '        private sealed class FakeLocalFactory : ILocalModelProviderFactory' `
            -New "        private sealed class SecondCoordinator : IProjectContextRequestCoordinator`n        {`n            public ProjectContextPreparedRequest Prepare(string absoluteRoot, string exactGoal) { throw new ProjectContextException(); }`n        }`n`n        private sealed class FakeLocalFactory : ILocalModelProviderFactory" `
            -SpecimenName 'SECOND_COORDINATOR_IMPLEMENTER'
        $replacementSources = @{}
        $replacementSources[$taskIntakeHarnessSourcePath] = $secondImplementerSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'SECOND_COORDINATOR_IMPLEMENTER' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $injectionConstructorOld = "        private LocalTaskIntake(ILocalModelProviderFactory factory, IProjectContextRequestCoordinator coordinator)`n        {`n            localFactory = factory;`n            contextCoordinator = coordinator;`n        }"
        $injectionConstructorNew = $injectionConstructorOld + "`n`n        internal static LocalTaskIntake ForbiddenConstructionCaller()`n        {`n            return new LocalTaskIntake(null, null);`n        }"
        $injectionCallerSource = Replace-ExactSpecimenText -Text $taskIntakeConditionalText -Old $injectionConstructorOld `
            -New $injectionConstructorNew -SpecimenName 'EXTRA_INJECTION_CONSTRUCTOR_CALLER'
        $replacementSources = @{}
        $replacementSources[$taskIntakeSourcePath] = $injectionCallerSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'EXTRA_INJECTION_CONSTRUCTOR_CALLER' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $secondHelperCallerSource = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText -Old $mainConstructionLine `
            -New "                LocalTaskIntake intake = CreateIntakeForTests();`n                if (CreateIntakeForTests() == null) { return 70; }" `
            -SpecimenName 'SECOND_HELPER_CALL_SITE_SAME_CALLER'
        $replacementSources = @{}
        $replacementSources[$taskIntakeHarnessSourcePath] = $secondHelperCallerSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'SECOND_HELPER_CALL_SITE_SAME_CALLER' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $getTypeSource = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText -Old $mainConstructionLine `
            -New "                object forbiddenObject = new FakeCoordinator();`n                if (forbiddenObject.GetType().GetConstructors()[0].Invoke(new object[0]) == null) { return 70; }`n                LocalTaskIntake intake = CreateIntakeForTests();" `
            -SpecimenName 'GETTYPE_CONSTRUCTOR_INVOKE'
        $replacementSources = @{}
        $replacementSources[$taskIntakeHarnessSourcePath] = $getTypeSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'GETTYPE_CONSTRUCTOR_INVOKE' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $dynamicInvokeSource = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText -Old $mainConstructionLine `
            -New "                Delegate forbiddenDelegate = new Func<LocalTaskIntake>(CreateIntakeForTests);`n                if (forbiddenDelegate.DynamicInvoke() == null) { return 70; }`n                LocalTaskIntake intake = CreateIntakeForTests();" `
            -SpecimenName 'DELEGATE_DYNAMIC_INVOKE'
        $replacementSources = @{}
        $replacementSources[$taskIntakeHarnessSourcePath] = $dynamicInvokeSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'DELEGATE_DYNAMIC_INVOKE' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $formatterSource = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText -Old $mainConstructionLine `
            -New "                if (System.Runtime.Serialization.FormatterServices.GetUninitializedObject(typeof(FakeCoordinator)) == null) { return 70; }`n                LocalTaskIntake intake = CreateIntakeForTests();" `
            -SpecimenName 'FORMATTER_UNINITIALIZED_OBJECT'
        $replacementSources = @{}
        $replacementSources[$taskIntakeHarnessSourcePath] = $formatterSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'FORMATTER_UNINITIALIZED_OBJECT' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $emitSource = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText -Old $mainConstructionLine `
            -New "                if (new System.Reflection.Emit.DynamicMethod(`"forbidden`", typeof(void), Type.EmptyTypes).GetILGenerator() == null) { return 70; }`n                LocalTaskIntake intake = CreateIntakeForTests();" `
            -SpecimenName 'REFLECTION_EMIT_CONSTRUCTION'
        $replacementSources = @{}
        $replacementSources[$taskIntakeHarnessSourcePath] = $emitSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'REFLECTION_EMIT_CONSTRUCTION' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $factoryLikeSource = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText `
            -Old "            internal FakeCoordinator() { }`n`n            internal int Calls" `
            -New "            internal FakeCoordinator() { }`n            internal static FakeCoordinator MakeCoordinator() { return new FakeCoordinator(); }`n`n            internal int Calls" `
            -SpecimenName 'UNAPPROVED_FACTORY_LIKE_METHOD'
        $replacementSources = @{}
        $replacementSources[$taskIntakeHarnessSourcePath] = $factoryLikeSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'UNAPPROVED_FACTORY_LIKE_METHOD' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $productionCtorOld = "        internal static ProjectContextLoader CreateNative()`n        {`n            return new ProjectContextLoader(new ProjectContextWin32Platform());`n        }"
        $productionCtorNew = $productionCtorOld + "`n`n        private static ProjectContextLoader ForbiddenProductionConstructorCaller()`n        {`n            return new ProjectContextLoader(new ProjectContextWin32Platform());`n        }"
        $productionCtorSource = Replace-ExactSpecimenText -Text $projectContextSourceText -Old $productionCtorOld `
            -New $productionCtorNew -SpecimenName 'PRODUCTION_IMPLEMENTER_DIRECT_NEWOBJ'
        $replacementSources = @{}
        $replacementSources[$projectContextSourcePath] = $productionCtorSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'PRODUCTION_IMPLEMENTER_DIRECT_NEWOBJ' `
            -CompilerPath $resolvedCompiler -CompilerArguments $projectContextHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'ContextHarness' -Policy $profile.projectContext

        $unapprovedFactoryCallerSource = Replace-ExactSpecimenText -Text $projectContextHarnessSourceText `
            -Old '        private static ProjectContextLoader CreateLoaderForTests()' `
            -New "        private static ProjectContextLoader ForbiddenApprovedFactoryCaller()`n        {`n            return ProjectContextLoader.CreateForTests(new FakePlatform());`n        }`n`n        private static ProjectContextLoader CreateLoaderForTests()" `
            -SpecimenName 'UNAPPROVED_CALLER_TO_EXISTING_FACTORY'
        $replacementSources = @{}
        $replacementSources[$projectContextHarnessSourcePath] = $unapprovedFactoryCallerSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'UNAPPROVED_CALLER_TO_EXISTING_FACTORY' `
            -CompilerPath $resolvedCompiler -CompilerArguments $projectContextHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'ContextHarness' -Policy $profile.projectContext

        $contextHelperOld = "        private static ProjectContextLoader CreateLoaderForTests()`n        {`n            platform = new FakePlatform();`n            platform.Reset();`n            return ProjectContextLoader.CreateForTests(platform);`n        }"
        $contextHelperNativeSource = Replace-ExactSpecimenText -Text $projectContextHarnessSourceText -Old $contextHelperOld `
            -New "        private static ProjectContextLoader CreateLoaderForTests()`n        {`n            ProjectContextLoader forbiddenNative = ProjectContextLoader.CreateNative();`n            if (forbiddenNative == null) { throw new Exception(); }`n            platform = new FakePlatform();`n            platform.Reset();`n            return ProjectContextLoader.CreateForTests(platform);`n        }" `
            -SpecimenName 'CONTEXT_HELPER_REACHES_NATIVE_FACTORY'
        $replacementSources = @{}
        $replacementSources[$projectContextHarnessSourcePath] = $contextHelperNativeSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'CONTEXT_HELPER_REACHES_NATIVE_FACTORY' `
            -CompilerPath $resolvedCompiler -CompilerArguments $projectContextHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'ContextHarness' -Policy $profile.projectContext

        $expressionSource = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText -Old $mainConstructionLine `
            -New "                System.Linq.Expressions.Expression<Func<LocalTaskIntake>> forbiddenExpression = () => CreateIntakeForTests();`n                if (forbiddenExpression.Compile()() == null) { return 70; }`n                LocalTaskIntake intake = CreateIntakeForTests();" `
            -SpecimenName 'EXPRESSION_COMPILE_CONSTRUCTION'
        $replacementSources = @{}
        $replacementSources[$taskIntakeHarnessSourcePath] = $expressionSource
        $expressionArguments = @($taskIntakeHarnessArguments) + "/reference:$resolvedReferences\System.Core.dll"
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'EXPRESSION_COMPILE_CONSTRUCTION' `
            -CompilerPath $resolvedCompiler -CompilerArguments $expressionArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $dynamicCallSiteSource = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText -Old $mainConstructionLine `
            -New "                dynamic forbiddenDynamic = new FakeCoordinator();`n                if ((int)forbiddenDynamic.Calls < 0) { return 70; }`n                LocalTaskIntake intake = CreateIntakeForTests();" `
            -SpecimenName 'DYNAMIC_CALL_SITE_CONSTRUCTION'
        $replacementSources = @{}
        $replacementSources[$taskIntakeHarnessSourcePath] = $dynamicCallSiteSource
        $dynamicArguments = @($taskIntakeHarnessArguments) + "/reference:$resolvedReferences\System.Core.dll" + "/reference:$resolvedReferences\Microsoft.CSharp.dll"
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'DYNAMIC_CALL_SITE_CONSTRUCTION' `
            -CompilerPath $resolvedCompiler -CompilerArguments $dynamicArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $secondCallerMethodSource = Replace-ExactSpecimenText -Text $taskIntakeHarnessSourceText `
            -Old '        private static LocalTaskIntake CreateIntakeForTests()' `
            -New "        private static LocalTaskIntake ForbiddenSecondHelperCaller()`n        {`n            return CreateIntakeForTests();`n        }`n`n        private static LocalTaskIntake CreateIntakeForTests()" `
            -SpecimenName 'SECOND_HELPER_CALLER_METHODDEF'
        $replacementSources = @{}
        $replacementSources[$taskIntakeHarnessSourcePath] = $secondCallerMethodSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'SECOND_HELPER_CALLER_METHODDEF' `
            -CompilerPath $resolvedCompiler -CompilerArguments $taskIntakeHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'IntakeHarness' -Policy $profile.projectContext

        $leaseConstructorSource = Replace-ExactSpecimenText -Text $projectReadOnlyPlatformSourceText `
            -Old '            private ProjectContextNativeLease(IntPtr handle) { Handle = handle; }' `
            -New "            private ProjectContextNativeLease(IntPtr handle) { Handle = handle; }`n            private ProjectContextNativeLease(IntPtr handle, bool ignored) { Handle = ignored ? IntPtr.Zero : handle; }" `
            -SpecimenName 'EXTRA_NATIVE_LEASE_CONSTRUCTOR'
        $replacementSources = @{}
        $replacementSources[$projectReadOnlyPlatformSourcePath] = $leaseConstructorSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'EXTRA_NATIVE_LEASE_CONSTRUCTOR' `
            -CompilerPath $resolvedCompiler -CompilerArguments $projectContextHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'ContextHarness' -Policy $profile.projectContext

        $leaseFactorySource = Replace-ExactSpecimenText -Text $projectReadOnlyPlatformSourceText `
            -Old '            internal static ProjectContextNativeLease Create(IntPtr handle)' `
            -New "            internal static ProjectContextNativeLease Create(IntPtr handle, bool ignored) { return Create(ignored ? IntPtr.Zero : handle); }`n            internal static ProjectContextNativeLease Create(IntPtr handle)" `
            -SpecimenName 'EXTRA_NATIVE_LEASE_FACTORY_OVERLOAD'
        $replacementSources = @{}
        $replacementSources[$projectReadOnlyPlatformSourcePath] = $leaseFactorySource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'EXTRA_NATIVE_LEASE_FACTORY_OVERLOAD' `
            -CompilerPath $resolvedCompiler -CompilerArguments $projectContextHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'ContextHarness' -Policy $profile.projectContext

        $leaseCallerAnchor = "        public IApprovedContentHandle OpenApprovedContent(string exactPath)`n        {`n            IntPtr handle = CreateFileW(exactPath, GenericRead, FileShareRead, IntPtr.Zero, OpenExisting, SequentialScan | OpenNoRecall, IntPtr.Zero);`n            return new ApprovedContentToken(ProjectContextNativeLease.Create(handle));`n        }"
        $leaseCallerSource = Replace-ExactSpecimenText -Text $projectReadOnlyPlatformSourceText -Old $leaseCallerAnchor `
            -New ($leaseCallerAnchor + "`n`n            private static ProjectContextNativeLease ForbiddenNativeLeaseCaller()`n            {`n                return ProjectContextNativeLease.Create(IntPtr.Zero);`n            }") `
            -SpecimenName 'EXTRA_NATIVE_LEASE_CALLER'
        $replacementSources = @{}
        $replacementSources[$projectReadOnlyPlatformSourcePath] = $leaseCallerSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'EXTRA_NATIVE_LEASE_CALLER' `
            -CompilerPath $resolvedCompiler -CompilerArguments $projectContextHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'ContextHarness' -Policy $profile.projectContext

        $leaseInterfaceOld = "        private sealed class ProjectContextNativeLease`n        {`n            internal IntPtr Handle { get; private set; }"
        $leaseInterfaceNew = "        private sealed class ProjectContextNativeLease : IDisposable`n        {`n            internal IntPtr Handle { get; private set; }`n            void IDisposable.Dispose() { Close(); }"
        $leaseInterfaceSource = Replace-ExactSpecimenText -Text $projectReadOnlyPlatformSourceText -Old $leaseInterfaceOld `
            -New $leaseInterfaceNew -SpecimenName 'NATIVE_LEASE_IDISPOSABLE_INTERFACE_DISPATCH'
        $replacementSources = @{}
        $replacementSources[$projectReadOnlyPlatformSourcePath] = $leaseInterfaceSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'NATIVE_LEASE_IDISPOSABLE_INTERFACE_DISPATCH' `
            -CompilerPath $resolvedCompiler -CompilerArguments $projectContextHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'ContextHarness' -Policy $profile.projectContext

        $directoryEnumerationSource = Replace-ExactSpecimenText -Text $projectContextSourceText `
            -Old '        private static string ValidateRoot(string root)' `
            -New "        private static string[] ForbiddenDirectoryEnumeration() { return System.IO.Directory.GetFiles(`"C:\\`"); }`n`n        private static string ValidateRoot(string root)" `
            -SpecimenName 'DIRECTORY_ENUMERATION_OUTPUT'
        $replacementSources = @{}
        $replacementSources[$projectContextSourcePath] = $directoryEnumerationSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'DIRECTORY_ENUMERATION_OUTPUT' `
            -CompilerPath $resolvedCompiler -CompilerArguments $projectContextHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'ContextHarness' -Policy $profile.projectContext

        $rawContentOutputSource = Replace-ExactSpecimenText -Text $projectContextSourceText `
            -Old "    internal sealed class ProjectContextResultMetadata`n    {`n        internal string AllowlistId { get; private set; }" `
            -New "    internal sealed class ProjectContextResultMetadata`n    {`n        internal string RawContent { get; private set; }`n        internal string AllowlistId { get; private set; }" `
            -SpecimenName 'RAW_CONTENT_OUTPUT'
        $rawContentOutputSource = Replace-ExactSpecimenText -Text $rawContentOutputSource `
            -Old '            Classification = bundle.Classification;' `
            -New "            Classification = bundle.Classification;`n            RawContent = bundle.Projection;" `
            -SpecimenName 'RAW_CONTENT_OUTPUT_ASSIGNMENT'
        $rawContentOutputSource = Replace-ExactSpecimenText -Text $rawContentOutputSource `
            -Old '                   ",\"classification\":" + ContractCodec.Json(Classification) + "}";' `
            -New '                   ",\"classification\":" + ContractCodec.Json(Classification) + ",\"rawContent\":" + ContractCodec.Json(RawContent) + "}";' `
            -SpecimenName 'RAW_CONTENT_OUTPUT_SERIALIZATION'
        $replacementSources = @{}
        $replacementSources[$projectContextSourcePath] = $rawContentOutputSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'RAW_CONTENT_OUTPUT' `
            -CompilerPath $resolvedCompiler -CompilerArguments $projectContextHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'ContextHarness' -Policy $profile.projectContext

        $perFileDigestOutputSource = Replace-ExactSpecimenText -Text $projectContextSourceText `
            -Old "    internal sealed class ProjectContextResultMetadata`n    {`n        internal string AllowlistId { get; private set; }" `
            -New "    internal sealed class ProjectContextResultMetadata`n    {`n        internal string PerFileDigest { get; private set; }`n        internal string AllowlistId { get; private set; }" `
            -SpecimenName 'PER_FILE_DIGEST_OUTPUT'
        $perFileDigestOutputSource = Replace-ExactSpecimenText -Text $perFileDigestOutputSource `
            -Old '            Classification = bundle.Classification;' `
            -New "            Classification = bundle.Classification;`n            PerFileDigest = bundle.AggregateSha256;" `
            -SpecimenName 'PER_FILE_DIGEST_OUTPUT_ASSIGNMENT'
        $perFileDigestOutputSource = Replace-ExactSpecimenText -Text $perFileDigestOutputSource `
            -Old '                   ",\"classification\":" + ContractCodec.Json(Classification) + "}";' `
            -New '                   ",\"classification\":" + ContractCodec.Json(Classification) + ",\"perFileDigest\":" + ContractCodec.Json(PerFileDigest) + "}";' `
            -SpecimenName 'PER_FILE_DIGEST_OUTPUT_SERIALIZATION'
        $replacementSources = @{}
        $replacementSources[$projectContextSourcePath] = $perFileDigestOutputSource
        $seamNegativeSpecimenEvidence += Invoke-SeamNegativeSpecimen -Name 'PER_FILE_DIGEST_OUTPUT' `
            -CompilerPath $resolvedCompiler -CompilerArguments $projectContextHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $specimenRoot -OutputKind 'ContextHarness' -Policy $profile.projectContext

        $nativeSpecimenRoot = Join-Path $buildRoot 'native-negative-specimens'
        New-Item -ItemType Directory -Path $nativeSpecimenRoot | Out-Null
        $constantCases = @(
            [ordered]@{ Name='GENERIC_READ_VALUE_CHANGE'; Old='        private const uint GenericRead = 0x80000000;'; New='        private const uint GenericRead = 0x40000000;' },
            [ordered]@{ Name='FILE_SHARE_READ_VALUE_CHANGE'; Old='        private const uint FileShareRead = 0x00000001;'; New='        private const uint FileShareRead = 0x00000002;' },
            [ordered]@{ Name='OPEN_EXISTING_VALUE_CHANGE'; Old='        private const uint OpenExisting = 3;'; New='        private const uint OpenExisting = 4;' },
            [ordered]@{ Name='OPEN_REPARSE_POINT_VALUE_CHANGE'; Old='        private const uint OpenReparsePoint = 0x00200000;'; New='        private const uint OpenReparsePoint = 0x00400000;' },
            [ordered]@{ Name='BACKUP_SEMANTICS_VALUE_CHANGE'; Old='        private const uint BackupSemantics = 0x02000000;'; New='        private const uint BackupSemantics = 0x01000000;' },
            [ordered]@{ Name='OPEN_NO_RECALL_VALUE_CHANGE'; Old='        private const uint OpenNoRecall = 0x00100000;'; New='        private const uint OpenNoRecall = 0x00080000;' },
            [ordered]@{ Name='SEQUENTIAL_SCAN_VALUE_CHANGE'; Old='        private const uint SequentialScan = 0x08000000;'; New='        private const uint SequentialScan = 0x04000000;' }
        )
        foreach ($case in $constantCases) {
            $specimenSource = Replace-ExactSpecimenText -Text $projectReadOnlyPlatformSourceText -Old $case.Old -New $case.New -SpecimenName $case.Name
            $replacementSources = @{}
            $replacementSources[$projectReadOnlyPlatformSourcePath] = $specimenSource
            $nativeNegativeSpecimenEvidence += Invoke-NativeNegativeSpecimen -Name $case.Name `
                -CompilerPath $resolvedCompiler -CompilerArguments $projectContextHarnessArguments -ReplacementSources $replacementSources `
                -SpecimenRoot $nativeSpecimenRoot -OutputKind 'ContextHarness' -Policy $profile.projectContext
        }

        $createFileAttributeLine = '        [DllImport("kernel32.dll", EntryPoint = "CreateFileW", ExactSpelling = true, CallingConvention = CallingConvention.Winapi, CharSet = CharSet.Unicode, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true, PreserveSig = true)]'
        $attributeCases = @(
            [ordered]@{ Name='EXACT_SPELLING_FALSE'; Old='ExactSpelling = true'; New='ExactSpelling = false' },
            [ordered]@{ Name='CALLING_CONVENTION_CDECL'; Old='CallingConvention = CallingConvention.Winapi'; New='CallingConvention = CallingConvention.Cdecl' },
            [ordered]@{ Name='CHARSET_ANSI'; Old='CharSet = CharSet.Unicode'; New='CharSet = CharSet.Ansi' },
            [ordered]@{ Name='SET_LAST_ERROR_FALSE'; Old='SetLastError = true'; New='SetLastError = false' },
            [ordered]@{ Name='BEST_FIT_MAPPING_TRUE'; Old='BestFitMapping = false'; New='BestFitMapping = true' },
            [ordered]@{ Name='THROW_ON_UNMAPPABLE_FALSE'; Old='ThrowOnUnmappableChar = true'; New='ThrowOnUnmappableChar = false' },
            [ordered]@{ Name='PRESERVE_SIG_FALSE'; Old='PreserveSig = true'; New='PreserveSig = false' }
        )
        foreach ($case in $attributeCases) {
            $changedAttributeLine = $createFileAttributeLine.Replace([string]$case.Old, [string]$case.New)
            $specimenSource = Replace-ExactSpecimenText -Text $projectReadOnlyPlatformSourceText -Old $createFileAttributeLine -New $changedAttributeLine -SpecimenName $case.Name
            $replacementSources = @{}
            $replacementSources[$projectReadOnlyPlatformSourcePath] = $specimenSource
            $nativeNegativeSpecimenEvidence += Invoke-NativeNegativeSpecimen -Name $case.Name `
                -CompilerPath $resolvedCompiler -CompilerArguments $projectContextHarnessArguments -ReplacementSources $replacementSources `
                -SpecimenRoot $nativeSpecimenRoot -OutputKind 'ContextHarness' -Policy $profile.projectContext
        }

        $visibilitySource = Replace-ExactSpecimenText -Text $projectReadOnlyPlatformSourceText `
            -Old '        private static extern IntPtr CreateFileW(string fileName, uint desiredAccess, uint shareMode, IntPtr securityAttributes, uint creationDisposition, uint flagsAndAttributes, IntPtr templateFile);' `
            -New '        internal static extern IntPtr CreateFileW(string fileName, uint desiredAccess, uint shareMode, IntPtr securityAttributes, uint creationDisposition, uint flagsAndAttributes, IntPtr templateFile);' `
            -SpecimenName 'NATIVE_IMPORT_VISIBILITY_INTERNAL'
        $replacementSources = @{}
        $replacementSources[$projectReadOnlyPlatformSourcePath] = $visibilitySource
        $nativeNegativeSpecimenEvidence += Invoke-NativeNegativeSpecimen -Name 'NATIVE_IMPORT_VISIBILITY_INTERNAL' `
            -CompilerPath $resolvedCompiler -CompilerArguments $projectContextHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $nativeSpecimenRoot -OutputKind 'ContextHarness' -Policy $profile.projectContext

        $closeDeclaration = "        [DllImport(`"kernel32.dll`", EntryPoint = `"CloseHandle`", ExactSpelling = true, CallingConvention = CallingConvention.Winapi, CharSet = CharSet.Unicode, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true, PreserveSig = true)]`n        [return: MarshalAs(UnmanagedType.Bool)] private static extern bool CloseHandle(IntPtr handle);"
        $extraImportSource = Replace-ExactSpecimenText -Text $projectReadOnlyPlatformSourceText -Old $closeDeclaration `
            -New ($closeDeclaration + "`n`n        [DllImport(`"kernel32.dll`", EntryPoint = `"DeleteFileW`", ExactSpelling = true, CallingConvention = CallingConvention.Winapi, CharSet = CharSet.Unicode, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true, PreserveSig = true)]`n        [return: MarshalAs(UnmanagedType.Bool)] private static extern bool DeleteFileW(string path);") `
            -SpecimenName 'EXTRA_NATIVE_IMPORT'
        $replacementSources = @{}
        $replacementSources[$projectReadOnlyPlatformSourcePath] = $extraImportSource
        $nativeNegativeSpecimenEvidence += Invoke-NativeNegativeSpecimen -Name 'EXTRA_NATIVE_IMPORT' `
            -CompilerPath $resolvedCompiler -CompilerArguments $projectContextHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $nativeSpecimenRoot -OutputKind 'ContextHarness' -Policy $profile.projectContext

        $extraNativeCallerSource = Replace-ExactSpecimenText -Text $projectReadOnlyPlatformSourceText -Old $leaseCallerAnchor `
            -New ($leaseCallerAnchor + "`n`n            private static IntPtr ForbiddenExtraNativeCaller(string exactPath)`n            {`n                return CreateFileW(exactPath, GenericRead, FileShareRead, IntPtr.Zero, OpenExisting, OpenReparsePoint, IntPtr.Zero);`n            }") `
            -SpecimenName 'EXTRA_NATIVE_CALLER'
        $replacementSources = @{}
        $replacementSources[$projectReadOnlyPlatformSourcePath] = $extraNativeCallerSource
        $nativeNegativeSpecimenEvidence += Invoke-NativeNegativeSpecimen -Name 'EXTRA_NATIVE_CALLER' `
            -CompilerPath $resolvedCompiler -CompilerArguments $projectContextHarnessArguments -ReplacementSources $replacementSources `
            -SpecimenRoot $nativeSpecimenRoot -OutputKind 'ContextHarness' -Policy $profile.projectContext
    }
    foreach ($role in @($profile.roles)) {
        $outputPath = Join-Path $buildRoot ([string]$role.output)
        $arguments = @(
            '/nologo',
            '/noconfig',
            '/target:exe',
            '/platform:x64',
            '/optimize+',
            '/debug-',
            '/checked+',
            '/highentropyva+',
            '/warn:4',
            '/warnaserror+',
            '/nostdlib+',
            "/reference:$resolvedReferences\mscorlib.dll",
            "/reference:$resolvedReferences\System.dll",
            "/reference:$resolvedReferences\System.ServiceProcess.dll",
            "/define:$([string]$role.symbol)",
            "/out:$outputPath"
        )

        if (-not $DevelopmentProbe) {
            $arguments += '/deterministic+'
            $arguments += "/pathmap:$componentRoot=/_/EAIRA/apps/agent-services"
        }
        $arguments += $sourcePath
        $arguments += $codecSourcePath
        $arguments += $coreSourcePath
        $arguments += $providerSourcePath

        $compilerOutput = @(& $resolvedCompiler @arguments 2>&1)
        if ($LASTEXITCODE -ne 0) {
            throw "Compiler failed for $($role.role): $($compilerOutput -join "`n")"
        }
        if (-not (Test-Path -LiteralPath $outputPath -PathType Leaf)) { throw "Expected output absent: $($role.output)" }
        Assert-NoForbiddenBinaryMetadata -LiteralPath $outputPath
        Assert-SystemIoMemberReferencePolicy -LiteralPath $outputPath -AllowServiceHostReadOnly

        $selfTest = Invoke-ExitCodeTest -Executable $outputPath -Arguments @('--self-test')
        $invalidTest = Invoke-ExitCodeTest -Executable $outputPath -Arguments @('--invalid')
        $interactiveTest = Invoke-ExitCodeTest -Executable $outputPath -Arguments @()
        $signature = Get-AuthenticodeSignature -LiteralPath $outputPath
        $selfTestJson = $null
        try { $selfTestJson = $selfTest.output | ConvertFrom-Json } catch { throw "Self-test output is not valid JSON: $($role.output)" }

        $testsPass = $selfTest.exitCode -eq 0 -and
                     $selfTestJson.status -eq 'PASS' -and
                     $selfTestJson.role -eq $role.role -and
                     $selfTestJson.service -eq $role.serviceName -and
                     $selfTestJson.contract -eq $profile.buildContract -and
                     $selfTestJson.functional_slice -eq 'OFFLINE_TEST_ONLY' -and
                     $selfTestJson.network -eq 'NONE' -and
                     $selfTestJson.ipc -eq 'PROHIBITED' -and
                     $selfTestJson.child_process -eq 'PROHIBITED' -and
                     $invalidTest.exitCode -eq 64 -and
                     $interactiveTest.exitCode -eq 65 -and
                     (Get-PeMachine -LiteralPath $outputPath) -eq '0x8664' -and
                     $signature.Status.ToString() -eq 'NotSigned'

        $file = Get-Item -LiteralPath $outputPath
        $roleEvidence += [ordered]@{
            role = [string]$role.role
            serviceName = [string]$role.serviceName
            file = [string]$role.output
            bytes = $file.Length
            sha256 = Get-Sha256 -LiteralPath $outputPath
            peMachine = Get-PeMachine -LiteralPath $outputPath
            authenticode = $signature.Status.ToString()
            selfTestExitCode = $selfTest.exitCode
            invalidArgumentExitCode = $invalidTest.exitCode
            interactiveNoArgumentExitCode = $interactiveTest.exitCode
            offlineTestsPass = [bool]$testsPass
        }
    }

    $projectQaHarnessOutputPath = Join-Path $buildRoot ([string]$profile.projectQa.outputHarness)
    $projectQaHarnessArguments = @('/nologo','/noconfig','/target:exe','/platform:x64','/optimize+','/debug-','/checked+','/highentropyva+','/warn:4','/warnaserror+','/nostdlib+','/define:EAIRA_PROJECT_QA_TEST_SEAM',"/reference:$resolvedReferences\mscorlib.dll","/reference:$resolvedReferences\System.dll",'/main:EAIRA.AgentServices.Functional.ProjectQaHarness',"/out:$projectQaHarnessOutputPath")
    if (-not $DevelopmentProbe) { $projectQaHarnessArguments += '/deterministic+'; $projectQaHarnessArguments += "/pathmap:$componentRoot=/_/EAIRA/apps/agent-services" }
    $projectQaHarnessArguments += @($codecSourcePath,$coreSourcePath,$providerSourcePath,$localProviderSourcePath,$projectReadOnlyPlatformSourcePath,$projectContextSourcePath,$projectKnowledgeSourcePath,$projectQaSourcePath,$projectQaHarnessSourcePath)
    $projectQaHarnessCompilerOutput = @(& $resolvedCompiler @projectQaHarnessArguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Project-QA harness compiler failed: $($projectQaHarnessCompilerOutput -join [Environment]::NewLine)" }
    Assert-NoForbiddenBinaryMetadata -LiteralPath $projectQaHarnessOutputPath
    $projectQaHarnessMetadata = Assert-ProjectQaMetadataPolicy -LiteralPath $projectQaHarnessOutputPath -Policy $profile.projectQa -OutputKind 'Harness' -Discovery:$ProjectQaDiscovery
    $projectQaHarnessTest = Invoke-ExitCodeTest -Executable $projectQaHarnessOutputPath -Arguments @()
    try { $projectQaHarnessJson = $projectQaHarnessTest.output | ConvertFrom-Json } catch { throw 'Project-QA harness output is not valid JSON.' }
    $projectQaHarnessPass = $projectQaHarnessTest.exitCode -eq 0 -and $projectQaHarnessJson.status -eq 'PASS' -and $projectQaHarnessJson.schema -eq 'EAIRA_PROJECT_QA_HARNESS_V1' -and (($ProjectQaDiscovery -and [int]$projectQaHarnessJson.testsPassed -ge 61) -or (-not $ProjectQaDiscovery -and [int]$projectQaHarnessJson.testsPassed -eq [int]$profile.projectQa.expectedHarnessTests)) -and [string]$projectQaHarnessJson.caseNameSha256 -match '^[0-9A-F]{64}$' -and ($ProjectQaDiscovery -or [string]$projectQaHarnessJson.caseNameSha256 -ceq [string]$profile.projectQa.expectedHarnessCaseNameSha256) -and [bool]$projectQaHarnessJson.goldenVectorsPass -and [int]$projectQaHarnessJson.successTagsCalls -eq 2 -and [int]$projectQaHarnessJson.successChatCalls -eq 1 -and [bool]$projectQaHarnessJson.preflightDigestValidated -and [bool]$projectQaHarnessJson.postflightDigestValidated -and $projectQaHarnessJson.network -eq 'NONE' -and $projectQaHarnessJson.writes -eq 'NONE'
    $projectQaHarnessEvidence = [ordered]@{ file=(Get-Item -LiteralPath $projectQaHarnessOutputPath).Name; bytes=(Get-Item -LiteralPath $projectQaHarnessOutputPath).Length; sha256=Get-Sha256 -LiteralPath $projectQaHarnessOutputPath; testsPassed=[int]$projectQaHarnessJson.testsPassed; caseNameSha256=[string]$projectQaHarnessJson.caseNameSha256; goldenVectorsPass=[bool]$projectQaHarnessJson.goldenVectorsPass; requestCounters=[ordered]@{ tagsCalls=[int]$projectQaHarnessJson.successTagsCalls; chatCalls=[int]$projectQaHarnessJson.successChatCalls; preflightDigestValidated=[bool]$projectQaHarnessJson.preflightDigestValidated; postflightDigestValidated=[bool]$projectQaHarnessJson.postflightDigestValidated }; metadataInventory=$projectQaHarnessMetadata; offlineTestsPass=[bool]$projectQaHarnessPass }

    $projectQaOutputPath = Join-Path $buildRoot ([string]$profile.projectQa.output)
    $projectQaArguments = @('/nologo','/noconfig','/target:exe','/platform:x64','/optimize+','/debug-','/checked+','/highentropyva+','/warn:4','/warnaserror+','/nostdlib+','/define:EAIRA_PROJECT_READONLY_NATIVE,EAIRA_PROJECT_QA_NATIVE',"/reference:$resolvedReferences\mscorlib.dll","/reference:$resolvedReferences\System.dll","/reference:$resolvedReferences\System.Net.Http.dll",'/main:EAIRA.AgentServices.Functional.ProjectQaHost',"/out:$projectQaOutputPath")
    if (-not $DevelopmentProbe) { $projectQaArguments += '/deterministic+'; $projectQaArguments += "/pathmap:$componentRoot=/_/EAIRA/apps/agent-services" }
    $projectQaArguments += @($codecSourcePath,$coreSourcePath,$providerSourcePath,$localProviderSourcePath,$loopbackTransportSourcePath,$projectReadOnlyPlatformSourcePath,$projectContextSourcePath,$projectKnowledgeSourcePath,$projectQaSourcePath,$projectQaHostSourcePath)
    $projectQaCompilerOutput = @(& $resolvedCompiler @projectQaArguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Project-QA CLI compiler failed: $($projectQaCompilerOutput -join [Environment]::NewLine)" }
    Assert-NoForbiddenBinaryMetadata -LiteralPath $projectQaOutputPath -AllowLoopbackHttp -AllowProjectContextPInvoke
    $projectQaPInvokeMetadata = Assert-ProjectContextPInvokePolicy -LiteralPath $projectQaOutputPath -Policy $profile.projectContext -OutputKind 'ProjectQaCli' -Discovery:$ProjectQaDiscovery
    $projectQaCallerEvidence = Assert-ProjectContextPInvokeCallerPolicy -LiteralPath $projectQaOutputPath -Policy $profile.projectContext -OutputKind 'ProjectQaCli' -Discovery:$ProjectQaDiscovery
    $projectQaNativeSemantic = Get-NormalizedNativeSemanticInventory -PInvokeMetadata $projectQaPInvokeMetadata -CallerEvidence $projectQaCallerEvidence
    $projectQaLoopbackMetadata = Get-LoopbackMetadataReferences -LiteralPath $projectQaOutputPath
    if (-not $ProjectQaDiscovery) { Assert-LoopbackMetadataPolicy -LiteralPath $projectQaOutputPath -Policy $profile.projectQa.loopbackMetadataAllowlist -DevelopmentProbe:$DevelopmentProbe }
    $projectQaMetadata = Assert-ProjectQaMetadataPolicy -LiteralPath $projectQaOutputPath -Policy $profile.projectQa -OutputKind 'Cli' -Discovery:$ProjectQaDiscovery
    $projectQaInvalid = Invoke-ExactChannelTest -Executable $projectQaOutputPath -Arguments @()
    $projectQaDenied = Invoke-ExactChannelTest -Executable $projectQaOutputPath -Arguments @('--root','C:\EAIRA','--trace','00000000000000000000000000000001','--question','write EAIRA','--provider','ollama-local','--model','qwen3:4b')
    $qaInvalidBytes = [Text.Encoding]::UTF8.GetBytes("{`"schema`":`"EAIRA_PROJECT_QA_ERROR_V1`",`"status`":`"INVALID_REQUEST`",`"network`":`"NONE`",`"writes`":`"NONE`"}`n")
    $qaDeniedBytes = [Text.Encoding]::UTF8.GetBytes("{`"schema`":`"EAIRA_PROJECT_QA_ERROR_V1`",`"status`":`"DENIED`",`"network`":`"NONE`",`"writes`":`"NONE`"}`n")
    $projectQaInvalidPass = $projectQaInvalid.exitCode -eq 64 -and ([Convert]::ToBase64String($projectQaInvalid.stdoutBytes) -ceq [Convert]::ToBase64String($qaInvalidBytes)) -and $projectQaInvalid.stderrBytes.Length -eq 0
    $projectQaDeniedPass = $projectQaDenied.exitCode -eq 77 -and ([Convert]::ToBase64String($projectQaDenied.stdoutBytes) -ceq [Convert]::ToBase64String($qaDeniedBytes)) -and $projectQaDenied.stderrBytes.Length -eq 0
    $projectQaActualChannels = [ordered]@{
        invalid = [ordered]@{ exitCode=$projectQaInvalid.exitCode; stdoutBytes=$projectQaInvalid.stdoutBytes.Length; stdoutSha256=$projectQaInvalid.stdoutSha256; stderrBytes=$projectQaInvalid.stderrBytes.Length }
        denied = [ordered]@{ exitCode=$projectQaDenied.exitCode; stdoutBytes=$projectQaDenied.stdoutBytes.Length; stdoutSha256=$projectQaDenied.stdoutSha256; stderrBytes=$projectQaDenied.stderrBytes.Length }
    }
    $projectQaChannelActualProfileMatch = (($projectQaActualChannels | ConvertTo-Json -Depth 4 -Compress) -ceq ($profile.projectQa.channelMatrix | ConvertTo-Json -Depth 4 -Compress))
    $projectQaChannelProfilePass = $ProjectQaDiscovery -or $projectQaChannelActualProfileMatch
    $projectQaChannelPass = $projectQaInvalidPass -and $projectQaDeniedPass -and $projectQaChannelProfilePass
    $projectQaEvidence = [ordered]@{ file=(Get-Item -LiteralPath $projectQaOutputPath).Name; bytes=(Get-Item -LiteralPath $projectQaOutputPath).Length; sha256=Get-Sha256 -LiteralPath $projectQaOutputPath; invalidExitCode=$projectQaInvalid.exitCode; invalidStdoutBytes=$projectQaInvalid.stdoutBytes.Length; invalidStdoutSha256=$projectQaInvalid.stdoutSha256; invalidRequestPass=[bool]$projectQaInvalidPass; deniedExitCode=$projectQaDenied.exitCode; deniedStdoutBytes=$projectQaDenied.stdoutBytes.Length; deniedStdoutSha256=$projectQaDenied.stdoutSha256; deniedPass=[bool]$projectQaDeniedPass; channelMatrixPass=[bool]$projectQaChannelPass; channelMatrixProfileMatch=if($ProjectQaDiscovery){$null}else{[bool]$projectQaChannelActualProfileMatch}; channelMatrixDiscoveryBypass=[bool]$ProjectQaDiscovery; channels=$projectQaActualChannels; metadataInventory=$projectQaMetadata; loopbackMetadataAllowlist=$projectQaLoopbackMetadata; moduleRefs=@($projectQaPInvokeMetadata.modules); pInvokeRows=@($projectQaPInvokeMetadata.rows); approvedNativeCallerIl=@($projectQaCallerEvidence.approvedCallerIl); normalizedNativeInventory=$projectQaNativeSemantic }

    if ($buildIndex -eq 0) {
        $qaSpecimenRoot = Join-Path $buildRoot 'qa-negative-specimens'
        New-Item -ItemType Directory -Path $qaSpecimenRoot | Out-Null
        $qaAnchor = '    internal sealed class ProjectQaException : Exception'
        $qaInjectedBodies = [ordered]@{
            QA_DIRECTORY_ENUMERATION = 'internal static string[] Bad() { return System.IO.Directory.GetFiles("."); }'
            QA_ARBITRARY_FILE_OPEN = 'internal static System.IO.Stream Bad() { return System.IO.File.OpenRead("x"); }'
            QA_SECOND_PLATFORM = 'internal static IProjectContextReadOnlyPlatform Bad() { return new ProjectContextWin32Platform(); }'
            QA_SECOND_ROOT_SESSION = 'internal static ProjectQaSnapshot Bad(string root) { return ProjectQaSnapshotReader.CreateNative().Read(root,"x"); }'
            QA_EARLY_PROVIDER_CONSTRUCTION = 'internal static IProjectQaProvider Bad() { return new ProjectQaNativeProviderFactory().Create(); }'
            QA_SECOND_CHAT = 'internal static string Bad(IProjectQaProvider p, byte[] b) { p.Execute(b); return p.Execute(b); }'
            QA_RETRY_LOOP = 'internal static string Bad(IProjectQaProvider p, byte[] b) { for (int i=0;i<2;i++) { try { return p.Execute(b); } catch (Exception) { } } throw new Exception(); }'
            QA_FALLBACK_PROVIDER = 'internal static IProjectQaProvider Bad(IProjectQaProviderFactory a, IProjectQaProviderFactory b) { try { return a.Create(); } catch (Exception) { return b.Create(); } }'
            QA_EXTERNAL_ENDPOINT = 'internal static Uri Bad() { return new Uri("https://example.com"); }'
            QA_CALLER_MODEL = 'internal static string Bad(string callerModel) { return callerModel; }'
            QA_RAW_PROJECTION_OUTPUT = 'internal static string Bad(ProjectQaSnapshot s) { return s.Context.Projection; }'
            QA_RAW_PROMPT_OUTPUT = 'internal static string Bad(string prompt) { return prompt; }'
            QA_PROVIDER_BODY_OUTPUT = 'internal static string Bad(byte[] body) { return Convert.ToBase64String(body); }'
            QA_ABSOLUTE_ROOT_OUTPUT = 'internal static string Bad(ProjectQaRequest r) { return r.Root; }'
            QA_MODEL_CITATION_METADATA = 'internal static string Bad(string modelCitation) { return modelCitation; }'
            QA_REORDERED_VALIDATION = 'internal static AgentDecision Bad(string[] args) { return GuardAgent.ExpectedDecision(TaskEnvelope.Create(1,args[3],args[5])); }'
            QA_ALTERNATE_JSON_PARSER = 'internal static StrictJsonNode Bad(byte[] value) { return StrictJsonParser.Parse(value); }'
            QA_UNBOUNDED_READ = 'internal static byte[] Bad(IProjectContextReadOnlyPlatform p, IApprovedContentHandle h) { return p.ReadApprovedContent(h,Int32.MaxValue); }'
            QA_LOGGING_SINK = 'internal static void Bad(string value) { Console.Error.WriteLine(value); }'
            QA_PERSISTENCE_REFERENCE = 'internal static void Bad(string value) { System.IO.File.WriteAllText("x",value); }'
            QA_PROCESS_OR_SHELL_REFERENCE = 'internal static void Bad() { System.Diagnostics.Process.Start("cmd.exe"); }'
            QA_REFLECTION_OR_DYNAMIC_CODE = 'internal static object Bad(Delegate value) { Activator.CreateInstance(typeof(StringBuilder)); return value.DynamicInvoke(new object[0]); }'
            QA_EXTRA_APPROVED_CALLER = 'internal static ProjectQaSnapshotReader Bad() { return ProjectQaSnapshotReader.CreateNative(); }'
            QA_EXTRA_MESSAGE = 'internal static string Bad(string prompt) { return "{\"messages\":[{\"role\":\"user\",\"content\":" + ContractCodec.Json(prompt) + "},{\"role\":\"user\",\"content\":\"extra\"}]}"; }'
            QA_RAW_PROVIDER_RESPONSE_OUTPUT = 'internal static string Bad(string rawProviderResponse) { return rawProviderResponse; }'
        }
        $qaCases = @()
        $qaCases += [ordered]@{ Name='QA_EXTRA_SOURCE_PATH'; Additional='namespace EAIRA.AgentServices.Functional { internal static class AdditionalQaSource { internal static int Bad() { return 1; } } }' }
        foreach ($entry in $qaInjectedBodies.GetEnumerator()) {
            $injection = "    internal static class $($entry.Key) { $($entry.Value) }`r`n`r`n$qaAnchor"
            $changed = Replace-ExactSpecimenText -Text $projectQaSourceText -Old $qaAnchor -New $injection -SpecimenName ([string]$entry.Key)
            $qaCases += [ordered]@{ Name=[string]$entry.Key; Path=$projectQaSourcePath; Text=$changed }
        }
        $replacementCases = @(
            [ordered]@{ Name='QA_WIDENED_PROMPT_BUDGET'; Path=$projectQaSourcePath; Text=(Replace-ExactSpecimenText -Text $projectQaSourceText -Old 'internal static void ValidateEncodedPrompt(byte[] bytes) { if (bytes == null || bytes.Length > 12000) { throw new ProjectQaException(); } }' -New 'internal static void ValidateEncodedPrompt(byte[] bytes) { if (bytes == null || bytes.Length > 12001) { throw new ProjectQaException(); } }' -SpecimenName 'QA_WIDENED_PROMPT_BUDGET') },
            [ordered]@{ Name='QA_WIDENED_BODY_BUDGET'; Path=$projectQaSourcePath; Text=(Replace-ExactSpecimenText -Text $projectQaSourceText -Old 'internal static void ValidateEncodedBody(byte[] bytes) { if (bytes == null || bytes.Length > 16384) { throw new ProjectQaException(); } }' -New 'internal static void ValidateEncodedBody(byte[] bytes) { if (bytes == null || bytes.Length > 16385) { throw new ProjectQaException(); } }' -SpecimenName 'QA_WIDENED_BODY_BUDGET') },
            [ordered]@{ Name='QA_WIDENED_ANSWER_BUDGET'; Path=$projectQaSourcePath; Text=(Replace-ExactSpecimenText -Text $projectQaSourceText -Old 'internal static void ValidateAnswerEncodedBytes(byte[] bytes) { if (bytes == null || bytes.Length > 2048) { throw new ProjectQaException(); } }' -New 'internal static void ValidateAnswerEncodedBytes(byte[] bytes) { if (bytes == null || bytes.Length > 2049) { throw new ProjectQaException(); } }' -SpecimenName 'QA_WIDENED_ANSWER_BUDGET') },
            [ordered]@{ Name='QA_WIDENED_OUTPUT_BUDGET'; Path=$projectQaSourcePath; Text=(Replace-ExactSpecimenText -Text $projectQaSourceText -Old 'internal static void ValidateEncodedLine(byte[] completeLine) { if (completeLine == null || completeLine.Length > 16384) { throw new ProjectQaException(); } }' -New 'internal static void ValidateEncodedLine(byte[] completeLine) { if (completeLine == null || completeLine.Length > 16385) { throw new ProjectQaException(); } }' -SpecimenName 'QA_WIDENED_OUTPUT_BUDGET') },
            [ordered]@{ Name='QA_AUTHORITY_LABEL_MUTATION'; Path=$projectQaSourcePath; Text=(Replace-ExactSpecimenText -Text $projectQaSourceText -Old '\"authority\":\"ASSISTIVE_NOT_AUTHORITY\"' -New '\"authority\":\"MODEL_AUTHORITY\"' -SpecimenName 'QA_AUTHORITY_LABEL_MUTATION') },
            [ordered]@{ Name='QA_WIDENED_CITATION_BUDGET'; Path=$projectQaSourcePath; Text=(Replace-ExactSpecimenText -Text $projectQaSourceText -Old 'citationsNode.ArrayValue.Count > 8' -New 'citationsNode.ArrayValue.Count > 9' -SpecimenName 'QA_WIDENED_CITATION_BUDGET') },
            [ordered]@{ Name='QA_WEAKENED_STRUCTURED_OUTPUT_SCHEMA'; Path=$projectQaSourcePath; Text=(Replace-ExactSpecimenText -Text $projectQaSourceText -Old '\"format\":{\"type\":\"object\",\"properties\":{\"answer\":{\"type\":\"string\",\"minLength\":1,\"maxLength\":512},\"citationIds\":{\"type\":\"array\",\"items\":{\"type\":\"string\"},\"maxItems\":8,\"uniqueItems\":true}},\"required\":[\"answer\",\"citationIds\"],\"additionalProperties\":false}' -New '\"format\":\"json\"' -SpecimenName 'QA_WEAKENED_STRUCTURED_OUTPUT_SCHEMA') }
        )
        $qaCases += $replacementCases
        $extraCtorText = Replace-ExactSpecimenText -Text $projectQaSourceText -Old '        internal ProjectQaLocalProvider(ILocalByteTransport value) { if (value == null) { throw new LocalProviderException(); } transport = value; deadline = new CancellationTokenSource(TimeSpan.FromSeconds(60)); }' -New "        internal ProjectQaLocalProvider(ILocalByteTransport value) { if (value == null) { throw new LocalProviderException(); } transport = value; deadline = new CancellationTokenSource(TimeSpan.FromSeconds(60)); }`r`n        internal ProjectQaLocalProvider(ILocalByteTransport value, int ignored) : this(value) { if (ignored == Int32.MinValue) { throw new LocalProviderException(); } }" -SpecimenName 'QA_EXTRA_CONSTRUCTOR_OR_FACTORY'
        $qaCases += [ordered]@{ Name='QA_EXTRA_CONSTRUCTOR_OR_FACTORY'; Path=$projectQaSourcePath; Text=$extraCtorText }
        $extraImportOld = '        [return: MarshalAs(UnmanagedType.Bool)] private static extern bool CloseHandle(IntPtr handle);'
        $extraImportNew = $extraImportOld + "`r`n" + '        [DllImport("kernel32.dll", EntryPoint = "CloseHandle", ExactSpelling = true, CallingConvention = CallingConvention.Winapi, CharSet = CharSet.Unicode, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true, PreserveSig = true)]' + "`r`n" + '        [return: MarshalAs(UnmanagedType.Bool)] private static extern bool CloseHandleQaDuplicate(IntPtr handle);'
        $qaCases += [ordered]@{ Name='QA_EXTRA_PINVOKE'; Path=$projectReadOnlyPlatformSourcePath; Text=(Replace-ExactSpecimenText -Text $projectReadOnlyPlatformSourceText -Old $extraImportOld -New $extraImportNew -SpecimenName 'QA_EXTRA_PINVOKE') }
        $qaCases += [ordered]@{ Name='QA_MOVED_PINVOKE_VISIBILITY'; Path=$projectReadOnlyPlatformSourcePath; Text=(Replace-ExactSpecimenText -Text $projectReadOnlyPlatformSourceText -Old $extraImportOld -New '        [return: MarshalAs(UnmanagedType.Bool)] internal static extern bool CloseHandle(IntPtr handle);' -SpecimenName 'QA_MOVED_PINVOKE_VISIBILITY') }
        $qaSpecimenNames = @(
            'QA_EXTRA_SOURCE_PATH','QA_DIRECTORY_ENUMERATION','QA_ARBITRARY_FILE_OPEN','QA_SECOND_PLATFORM','QA_SECOND_ROOT_SESSION',
            'QA_EARLY_PROVIDER_CONSTRUCTION','QA_SECOND_CHAT','QA_RETRY_LOOP','QA_FALLBACK_PROVIDER','QA_EXTERNAL_ENDPOINT',
            'QA_CALLER_MODEL','QA_WIDENED_PROMPT_BUDGET','QA_WIDENED_BODY_BUDGET','QA_WIDENED_ANSWER_BUDGET','QA_WIDENED_OUTPUT_BUDGET',
            'QA_RAW_PROJECTION_OUTPUT','QA_RAW_PROMPT_OUTPUT','QA_PROVIDER_BODY_OUTPUT','QA_ABSOLUTE_ROOT_OUTPUT','QA_MODEL_CITATION_METADATA',
            'QA_AUTHORITY_LABEL_MUTATION','QA_REORDERED_VALIDATION','QA_ALTERNATE_JSON_PARSER','QA_UNBOUNDED_READ','QA_LOGGING_SINK',
            'QA_PERSISTENCE_REFERENCE','QA_PROCESS_OR_SHELL_REFERENCE','QA_REFLECTION_OR_DYNAMIC_CODE','QA_EXTRA_PINVOKE','QA_MOVED_PINVOKE_VISIBILITY',
            'QA_EXTRA_CONSTRUCTOR_OR_FACTORY','QA_EXTRA_APPROVED_CALLER','QA_EXTRA_MESSAGE','QA_WIDENED_CITATION_BUDGET','QA_RAW_PROVIDER_RESPONSE_OUTPUT','QA_WEAKENED_STRUCTURED_OUTPUT_SCHEMA'
        )
        $orderedQaCases = @()
        foreach ($qaName in $qaSpecimenNames) {
            $match = @($qaCases | Where-Object { [string]$_.Name -ceq $qaName })
            if ($match.Count -ne 1) { throw "Project-QA specimen definition mismatch '$qaName'." }
            $orderedQaCases += $match[0]
        }
        $qaCases = $orderedQaCases
        foreach ($case in $qaCases) {
            $replacements = @{}
            if ($case.Contains('Path')) { $replacements[[string]$case.Path] = [string]$case.Text }
            $additionalSourceText = if ($case.Contains('Additional')) { [string]$case.Additional } else { $null }
            $qaNegativeSpecimenEvidence += Invoke-ProjectQaNegativeSpecimen -Name ([string]$case.Name) -CompilerPath $resolvedCompiler -CompilerArguments $projectQaArguments -ReplacementSources $replacements -SpecimenRoot $qaSpecimenRoot -ProjectQaPolicy $profile.projectQa -ProjectContextPolicy $profile.projectContext -LoopbackPolicy $projectQaLoopbackMetadata -BaselineMetadata $projectQaMetadata -AdditionalSourceText $additionalSourceText
        }
    }

    $localOperatorHarnessOutputPath = Join-Path $buildRoot ([string]$profile.localOperator.outputHarness)
    $localOperatorHarnessArguments = @('/nologo','/noconfig','/target:exe','/platform:x64','/optimize+','/debug-','/checked+','/highentropyva+','/warn:4','/warnaserror+','/nostdlib+',('/define:' + [string]$profile.localOperator.testSeamSymbols),"/reference:$resolvedReferences\mscorlib.dll","/reference:$resolvedReferences\System.dll",'/main:EAIRA.AgentServices.Functional.LocalOperatorHarness',"/out:$localOperatorHarnessOutputPath")
    if (-not $DevelopmentProbe) { $localOperatorHarnessArguments += '/deterministic+'; $localOperatorHarnessArguments += "/pathmap:$componentRoot=/_/EAIRA/apps/agent-services" }
    $localOperatorHarnessArguments += @($codecSourcePath,$coreSourcePath,$providerSourcePath,$taskIntakeSourcePath,$localProviderSourcePath,$projectReadOnlyPlatformSourcePath,$projectContextSourcePath,$projectKnowledgeSourcePath,$projectQaSourcePath,$localOperatorSourcePath,$localOperatorHarnessSourcePath)
    $localOperatorHarnessCompilerOutput = @(& $resolvedCompiler @localOperatorHarnessArguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Local Operator harness compiler failed: $($localOperatorHarnessCompilerOutput -join [Environment]::NewLine)" }
    Assert-NoForbiddenBinaryMetadata -LiteralPath $localOperatorHarnessOutputPath
    Assert-SystemIoMemberReferencePolicy -LiteralPath $localOperatorHarnessOutputPath
    $localOperatorHarnessMetadata = Assert-LocalOperatorMetadataPolicy -LiteralPath $localOperatorHarnessOutputPath -Policy $profile.localOperator -OutputKind 'Harness' -Discovery:$operatorDiscovery
    $localOperatorHarnessTest = Invoke-ExactChannelTest -Executable $localOperatorHarnessOutputPath -Arguments @('--self-test')
    try { $localOperatorHarnessJson = [Text.Encoding]::UTF8.GetString($localOperatorHarnessTest.stdoutBytes) | ConvertFrom-Json } catch { throw 'Local Operator harness output is not valid JSON.' }
    $expectedLocalOperatorCases = @(
        'CANON_TASK_MOCK','CANON_TASK_MOCK_CONTEXT','CANON_TASK_OLLAMA','CANON_TASK_OLLAMA_CONTEXT','CANON_KNOWLEDGE','CANON_PROJECT_QA',
        'INVALID_NULL_ARGV','INVALID_EMPTY_ARGV','INVALID_UNKNOWN_CAPABILITY','INVALID_CAPABILITY_CASE','INVALID_MISSING_FLAG','INVALID_EXTRA_FLAG','INVALID_DUPLICATE_FLAG','INVALID_REORDERED_FLAG','INVALID_CROSS_ROUTE_FLAG','INVALID_RESPONSE_FILE','INVALID_PROVIDER_REAL','INVALID_PROVIDER_URI','INVALID_MODEL_CASE','INVALID_TRACE_LENGTH','INVALID_TRACE_LOWER','INVALID_GOAL_EMPTY','INVALID_QUERY_EMPTY','INVALID_QUESTION_EMPTY','INVALID_ROOT_LEXICAL',
        'DENY_TASK_ZERO_FACTORIES','DENY_KNOWLEDGE_ZERO_FACTORIES','DENY_PROJECT_QA_ZERO_FACTORIES','ALLOW_TASK_FACTORY_ONCE','ALLOW_KNOWLEDGE_FACTORY_ONCE','ALLOW_PROJECT_QA_FACTORY_ONCE',
        'CHAIN_ALLOW_FIVE_ROLES','CHAIN_DENY_THREE_ROLES','CHAIN_DENY_NO_OPERATIONS','CHAIN_DENY_NO_VERIFICATION','TAMPER_REQUEST_DIGEST','TAMPER_ROUTE_DIGEST','TAMPER_PREVIOUS_DIGEST','TAMPER_EVIDENCE_DIGEST','TAMPER_PAYLOAD_DIGEST','TAMPER_AUDIT_DIGEST','KNOWLEDGE_ZERO_PROVIDER','QA_TAGS_CHAT_TAGS_EXACT','QA_FAILURE_PRE_TAGS','QA_FAILURE_CHAT','QA_FAILURE_POST_TAGS','TASK_MOCK_CALL_BUDGET','TASK_OLLAMA_CALL_BUDGET',
        'SENTINEL_RAW_ROOT','SENTINEL_RAW_INPUT','SENTINEL_RAW_CONTENT','SENTINEL_RAW_PROMPT','SENTINEL_REQUEST_BODY','SENTINEL_PROVIDER_RESPONSE','SENTINEL_PER_FILE_DIGEST','PROVIDER_TOOL_CALL','PROVIDER_IMAGE','PROVIDER_THINKING','PROVIDER_UNKNOWN_MEMBER','SEQUENCE_TASK_KNOWLEDGE_QA','SEQUENCE_QA_KNOWLEDGE_TASK',
        'PAYLOAD_16382','PAYLOAD_16383','PAYLOAD_16384_REJECT','LINE_16969','LINE_16970','LINE_16971_REJECT','CHANNEL_SINGLE_WRITE_LF','CHANNEL_EMPTY_STDERR','CHANNEL_NO_PARTIAL_FAILURE','REPLAY_TRACE_CORRELATION_ONLY','LEGACY_QA_COMPATIBILITY',
        'CROSSWALK_TASK_INVALID','CROSSWALK_TASK_PROVIDER_ERROR','CROSSWALK_TASK_CONTEXT_ERROR','CROSSWALK_KNOWLEDGE_DENIED','CROSSWALK_KNOWLEDGE_INVALID','CROSSWALK_KNOWLEDGE_ERROR','CROSSWALK_QA_DENIED','CROSSWALK_QA_INVALID','CROSSWALK_QA_PROVIDER_ERROR','CROSSWALK_QA_CONTEXT_ERROR','CROSSWALK_QA_KNOWLEDGE_ERROR','CROSSWALK_QA_VALIDATION_ERROR','CROSSWALK_ORCHESTRATION_ERROR','CROSSWALK_OUTPUT_ERROR','INVALID_STDIN_TOKEN','INVALID_ENV_TOKEN','INVALID_CONFIG_TOKEN','QA_FAILURE_SNAPSHOT_FACTORY','QA_FAILURE_SNAPSHOT_READ_CONTEXT','QA_FAILURE_SNAPSHOT_READ_KNOWLEDGE','QA_FAILURE_PROMPT_BUILD','QA_FAILURE_BODY_BUILD','QA_FAILURE_PROVIDER_FACTORY','QA_FAILURE_DECODE'
        'HEALTH_CANONICAL_REQUEST','HEALTH_ROUTE_EXACT','HEALTH_PAYLOAD_GOLDEN','HEALTH_WRAPPER_GOLDEN','HEALTH_ZERO_FACTORIES','HEALTH_DENY_THREE_ROLES_ZERO_FACTORIES','HEALTH_ALLOW_FIVE_ROLES','HEALTH_CROSS_TRACE_PAYLOAD_STABLE','HEALTH_CROSS_TRACE_WRAPPER_DISTINCT','HEALTH_INVALID_MISSING_TRACE','HEALTH_INVALID_TRACE_LOWER','HEALTH_INVALID_TRACE_SHORT','HEALTH_INVALID_TRACE_LONG','HEALTH_INVALID_TRACE_NONHEX','HEALTH_INVALID_EXTRA_ARG','HEALTH_INVALID_DUPLICATE_FLAG','HEALTH_INVALID_REORDERED_FLAG','HEALTH_INVALID_RESPONSE_FILE','HEALTH_INVALID_ROOT_FLAG','HEALTH_INVALID_PROVIDER_FLAG','HEALTH_OUTPUT_TAMPER_REJECT','HEALTH_ROUTE_TAMPER_REJECT','HEALTH_LEGACY_SEQUENCE_COMPATIBILITY'
        'PREFLIGHT_ROW_TASK_MOCK','PREFLIGHT_ROW_TASK_MOCK_CONTEXT','PREFLIGHT_ROW_TASK_OLLAMA_LOCAL','PREFLIGHT_ROW_TASK_OLLAMA_LOCAL_CONTEXT','PREFLIGHT_ROW_KNOWLEDGE','PREFLIGHT_ROW_PROJECT_QA_OLLAMA_LOCAL','PREFLIGHT_ROW_HEALTH','PREFLIGHT_FIXED_GUARD_ENVELOPE','PREFLIGHT_OUTER_ROUTE_EXACT','PREFLIGHT_GUARD_ALLOW_ONCE','PREFLIGHT_GUARD_DENY_ONCE_NO_LOOKUP_PAYLOAD_FACTORY','PREFLIGHT_CROSS_TRACE_PAYLOAD_STABLE_WRAPPER_DISTINCT','PREFLIGHT_SAME_INPUT_BYTE_STABLE','PREFLIGHT_ZERO_CONNECT_AND_FACTORIES','PREFLIGHT_AUTHORITY_SEPARATION','PREFLIGHT_MEMBER_ORDER_EXACT','PREFLIGHT_PAYLOAD_TAMPER_REJECT','PREFLIGHT_ROUTE_TAMPER_REJECT','PREFLIGHT_INVALID_UNKNOWN_ROUTE','PREFLIGHT_INVALID_ROUTE_LOWER','PREFLIGHT_INVALID_ROUTE_PREFIX','PREFLIGHT_INVALID_ROUTE_SUFFIX','PREFLIGHT_INVALID_ROUTE_UNICODE_CONFUSABLE','PREFLIGHT_INVALID_MISSING_TRACE','PREFLIGHT_INVALID_TRACE_LOWER','PREFLIGHT_INVALID_TRACE_SHORT','PREFLIGHT_INVALID_TRACE_LONG','PREFLIGHT_INVALID_TRACE_NONHEX','PREFLIGHT_INVALID_MISSING_ROUTE','PREFLIGHT_INVALID_DUPLICATE_ROUTE','PREFLIGHT_INVALID_REORDERED_FLAGS','PREFLIGHT_INVALID_EXTRA_FLAG','PREFLIGHT_INVALID_GOAL_INJECTION','PREFLIGHT_INVALID_QUERY_INJECTION','PREFLIGHT_INVALID_QUESTION_INJECTION','PREFLIGHT_INVALID_ROOT_INJECTION','PREFLIGHT_INVALID_PROVIDER_INJECTION','PREFLIGHT_INVALID_MODEL_INJECTION','PREFLIGHT_INVALID_ENDPOINT_INJECTION','PREFLIGHT_INVALID_RESPONSE_FILE','PREFLIGHT_INVALID_STDIN_TOKEN','PREFLIGHT_INVALID_ENV_TOKEN','PREFLIGHT_INVALID_CONFIG_TOKEN','PREFLIGHT_INVALID_CONFIG_EXPANSION','PREFLIGHT_ZERO_SELECTED_ROUTE_EXECUTION_AND_READS_SUCCESS','PREFLIGHT_ZERO_COUNTERS_ALL_INVALID','PREFLIGHT_LEGACY_GUARD_AND_ROUTE_SEQUENCE_COMPATIBILITY',
        'DRY_RUN_ROW_TASK_MOCK','DRY_RUN_ROW_TASK_MOCK_CONTEXT','DRY_RUN_ROW_TASK_OLLAMA_LOCAL','DRY_RUN_ROW_TASK_OLLAMA_LOCAL_CONTEXT','DRY_RUN_ROW_KNOWLEDGE','DRY_RUN_ROW_PROJECT_QA_OLLAMA_LOCAL','DRY_RUN_ROW_HEALTH','DRY_RUN_DENY_TASK_MOCK','DRY_RUN_DENY_TASK_MOCK_CONTEXT','DRY_RUN_DENY_TASK_OLLAMA_LOCAL','DRY_RUN_DENY_TASK_OLLAMA_LOCAL_CONTEXT','DRY_RUN_DENY_KNOWLEDGE','DRY_RUN_DENY_PROJECT_QA_OLLAMA_LOCAL','DRY_RUN_DENY_HEALTH','DRY_RUN_FIXED_GUARD_ENVELOPE','DRY_RUN_GENERIC_OUTER_ROUTE','DRY_RUN_MEMBER_ORDER_EXACT_13','DRY_RUN_PAYLOAD_DIGEST_BINDS_POLICY_TUPLE','DRY_RUN_PAYLOAD_TAMPER_REJECT','DRY_RUN_ROUTE_TAMPER_REJECT','DRY_RUN_REQUEST_SPECIFIC_GOAL','DRY_RUN_REQUEST_SPECIFIC_ROOT','DRY_RUN_REQUEST_SPECIFIC_QUERY','DRY_RUN_REQUEST_SPECIFIC_QUESTION','DRY_RUN_SAME_REQUEST_BYTE_STABLE','DRY_RUN_ZERO_CONNECT_READ_FACTORY_EXECUTION','DRY_RUN_INVALID_EMPTY','DRY_RUN_INVALID_MISSING_TARGET','DRY_RUN_INVALID_UNKNOWN_TARGET','DRY_RUN_INVALID_PREFLIGHT_TARGET','DRY_RUN_INVALID_NESTED_TARGET','DRY_RUN_INVALID_ROUTE_SELECTOR','DRY_RUN_INVALID_FLAG_REORDER','DRY_RUN_INVALID_FLAG_DUPLICATE','DRY_RUN_INVALID_EXTRA_FLAG','DRY_RUN_INVALID_PROVIDER_REAL','DRY_RUN_INVALID_PROVIDER_URI','DRY_RUN_INVALID_MODEL','DRY_RUN_INVALID_TRACE_LOWER','DRY_RUN_INVALID_TRACE_SHORT','DRY_RUN_INVALID_TRACE_LONG','DRY_RUN_INVALID_TRACE_NONHEX','DRY_RUN_INVALID_GOAL_EMPTY','DRY_RUN_INVALID_QUERY_EMPTY','DRY_RUN_INVALID_QUESTION_EMPTY','DRY_RUN_INVALID_ROOT_LEXICAL','DRY_RUN_INVALID_RESPONSE_FILE','DRY_RUN_INVALID_STDIN_TOKEN','DRY_RUN_INVALID_ENV_TOKEN','DRY_RUN_INVALID_CONFIG_TOKEN','DRY_RUN_INVALID_CONFIG_EXPANSION','DRY_RUN_INVALID_ENDPOINT_INJECTION','DRY_RUN_INVALID_SHELL_FRAGMENT','DRY_RUN_INSTRUCTION_SHAPED_INPUT_OPAQUE','DRY_RUN_ROOT_EXISTENCE_NOT_PROBED','DRY_RUN_ALL_INVALID_ZERO_COUNTERS','DRY_RUN_ALL_ROUTES_ZERO_EFFECTS','DRY_RUN_LEGACY_PREFIX_COMPATIBILITY'
    )
    $actualLocalOperatorCases = @($localOperatorHarnessJson.caseNames | ForEach-Object { [string]$_ })
    $operatorFrameText = 'EAIRA_M5_SLICE4_CASE_NAMES_V1' + [char]0
    foreach ($name in $actualLocalOperatorCases) { $operatorFrameText += $name.Length.ToString([Globalization.CultureInfo]::InvariantCulture) + ':' + $name }
    $operatorFrameBytes = [Text.Encoding]::UTF8.GetBytes($operatorFrameText)
    $operatorFrameSha256 = Get-ByteArraySha256 -Bytes $operatorFrameBytes
    $operatorLegacyFrameText = 'EAIRA_M5_SLICE1_CASE_NAMES_V1' + [char]0
    foreach ($name in @($actualLocalOperatorCases | Select-Object -First 96)) { $operatorLegacyFrameText += $name.Length.ToString([Globalization.CultureInfo]::InvariantCulture) + ':' + $name }
    $operatorLegacyFrameBytes = [Text.Encoding]::UTF8.GetBytes($operatorLegacyFrameText)
    $operatorLegacyFrameSha256 = Get-ByteArraySha256 -Bytes $operatorLegacyFrameBytes
    $operatorSlice2FrameText = 'EAIRA_M5_SLICE2_CASE_NAMES_V1' + [char]0
    foreach ($name in @($actualLocalOperatorCases | Select-Object -First 119)) { $operatorSlice2FrameText += $name.Length.ToString([Globalization.CultureInfo]::InvariantCulture) + ':' + $name }
    $operatorSlice2FrameBytes = [Text.Encoding]::UTF8.GetBytes($operatorSlice2FrameText)
    $operatorSlice2FrameSha256 = Get-ByteArraySha256 -Bytes $operatorSlice2FrameBytes
    $operatorSlice3NewFrameText = 'EAIRA_M5_SLICE3_NEW_CASE_NAMES_V1' + [char]0
    foreach ($name in @($actualLocalOperatorCases | Select-Object -Skip 119 -First 47)) { $operatorSlice3NewFrameText += $name.Length.ToString([Globalization.CultureInfo]::InvariantCulture) + ':' + $name }
    $operatorSlice3NewFrameBytes = [Text.Encoding]::UTF8.GetBytes($operatorSlice3NewFrameText)
    $operatorSlice3NewFrameSha256 = Get-ByteArraySha256 -Bytes $operatorSlice3NewFrameBytes
    $operatorSlice4NewFrameText = 'EAIRA_M5_SLICE4_NEW_CASE_NAMES_V1' + [char]0
    foreach ($name in @($actualLocalOperatorCases | Select-Object -Skip 166)) { $operatorSlice4NewFrameText += $name.Length.ToString([Globalization.CultureInfo]::InvariantCulture) + ':' + $name }
    $operatorSlice4NewFrameBytes = [Text.Encoding]::UTF8.GetBytes($operatorSlice4NewFrameText)
    $operatorSlice4NewFrameSha256 = Get-ByteArraySha256 -Bytes $operatorSlice4NewFrameBytes
    $localOperatorHarnessPass = $localOperatorHarnessTest.exitCode -eq 0 -and $localOperatorHarnessTest.stderrBytes.Length -eq 0 -and
        [string]$localOperatorHarnessJson.schema -ceq 'EAIRA_LOCAL_OPERATOR_HARNESS_V1' -and [string]$localOperatorHarnessJson.status -ceq 'PASS' -and
        [int]$localOperatorHarnessJson.testsPassed -eq 224 -and (($actualLocalOperatorCases -join "`n") -ceq ($expectedLocalOperatorCases -join "`n")) -and
        $operatorFrameBytes.Length -eq 6650 -and $operatorFrameSha256 -ceq '8C8B1123EE04A4B811EE6F13759505A7A0188648E0AB7A2879D4B29CBCAFD44B' -and
        $operatorSlice2FrameBytes.Length -eq 3095 -and $operatorSlice2FrameSha256 -ceq '198B2B892C9E6516B50B2C2CAF86AABA058B4D8B0D335AD445DC8685230F8A86' -and
        $operatorSlice3NewFrameBytes.Length -eq 1722 -and $operatorSlice3NewFrameSha256 -ceq 'A003B2E48A46636D309B5049BAA34BD7A632F91C2EF5F4337A0FC35789445A8D' -and
        $operatorSlice4NewFrameBytes.Length -eq 1901 -and $operatorSlice4NewFrameSha256 -ceq '21F968795F2A5BD00B522F4CAE35FBA2EA8B4E80B9D76B933C23A7FB8205EC84' -and
        $operatorLegacyFrameBytes.Length -eq 2409 -and $operatorLegacyFrameSha256 -ceq '0AAF52EE6A087B487B6497676F48BA7AD0D36CB987C149CC1BADAD9CA5D2FE68' -and
        [int]$localOperatorHarnessJson.legacyTestsPassed -eq 96 -and [int]$localOperatorHarnessJson.legacyCaseNameFramedBytes -eq 2409 -and [string]$localOperatorHarnessJson.legacyCaseNameSha256 -ceq $operatorLegacyFrameSha256 -and
        [int]$localOperatorHarnessJson.caseNameFramedBytes -eq $operatorFrameBytes.Length -and [string]$localOperatorHarnessJson.caseNameSha256 -ceq $operatorFrameSha256 -and
        [int]$localOperatorHarnessJson.slice2TestsPassed -eq 119 -and [int]$localOperatorHarnessJson.slice2CaseNameFramedBytes -eq $operatorSlice2FrameBytes.Length -and [string]$localOperatorHarnessJson.slice2CaseNameSha256 -ceq $operatorSlice2FrameSha256 -and
        [int]$localOperatorHarnessJson.slice3NewTestsPassed -eq 47 -and [int]$localOperatorHarnessJson.slice3NewCaseNameFramedBytes -eq $operatorSlice3NewFrameBytes.Length -and [string]$localOperatorHarnessJson.slice3NewCaseNameSha256 -ceq $operatorSlice3NewFrameSha256 -and
        [int]$localOperatorHarnessJson.slice4NewTestsPassed -eq 58 -and [int]$localOperatorHarnessJson.slice4NewCaseNameFramedBytes -eq $operatorSlice4NewFrameBytes.Length -and [string]$localOperatorHarnessJson.slice4NewCaseNameSha256 -ceq $operatorSlice4NewFrameSha256 -and
        [int]$localOperatorHarnessJson.dryRunCounters.guardCalls -eq 1 -and [int]$localOperatorHarnessJson.dryRunCounters.lookupCalls -eq 2 -and [int]$localOperatorHarnessJson.dryRunCounters.payloadCalls -eq 1 -and [int]$localOperatorHarnessJson.dryRunCounters.factoryCalls -eq 0 -and [int]$localOperatorHarnessJson.dryRunCounters.executionCalls -eq 0 -and [int]$localOperatorHarnessJson.dryRunCounters.connectAttemptDelta -eq 0 -and
        [int]$localOperatorHarnessJson.wrapperMaximumBytes -eq 587 -and [string]$localOperatorHarnessJson.network -ceq 'NONE' -and [string]$localOperatorHarnessJson.writes -ceq 'NONE'
    if (-not $localOperatorHarnessPass) { throw 'Local Operator harness policy failed.' }
    $operatorHealthHarnessPass = [int]$localOperatorHarnessJson.healthGuardDenial.exitCode -eq 77 -and [int]$localOperatorHarnessJson.healthGuardDenial.roles -eq 3 -and [bool]$localOperatorHarnessJson.healthGuardDenial.payloadNull -and [int]$localOperatorHarnessJson.healthGuardDenial.factoryCalls -eq 0 -and [int]$localOperatorHarnessJson.healthGuardDenial.connectAttemptDelta -eq 0 -and [int]$localOperatorHarnessJson.healthConnectAttemptMonitor.positiveControlDelta -eq 1 -and [int]$localOperatorHarnessJson.healthConnectAttemptMonitor.healthDelta -eq 0 -and [int]$localOperatorHarnessJson.healthConnectAttemptMonitor.denialDelta -eq 0
    if (-not $operatorHealthHarnessPass) { throw 'Local Operator Health Guard or connect-attempt monitor harness evidence failed.' }
    $localOperatorHarnessEvidence = [ordered]@{ file=(Get-Item -LiteralPath $localOperatorHarnessOutputPath).Name; bytes=(Get-Item -LiteralPath $localOperatorHarnessOutputPath).Length; sha256=Get-Sha256 -LiteralPath $localOperatorHarnessOutputPath; testsPassed=224; caseNames=$actualLocalOperatorCases; caseNameFramedBytes=$operatorFrameBytes.Length; caseNameSha256=$operatorFrameSha256; legacyTestsPassed=96; legacyCaseNameFramedBytes=$operatorLegacyFrameBytes.Length; legacyCaseNameSha256=$operatorLegacyFrameSha256; slice2TestsPassed=119; slice2CaseNameFramedBytes=$operatorSlice2FrameBytes.Length; slice2CaseNameSha256=$operatorSlice2FrameSha256; slice3NewTestsPassed=47; slice3NewCaseNameFramedBytes=$operatorSlice3NewFrameBytes.Length; slice3NewCaseNameSha256=$operatorSlice3NewFrameSha256; slice4NewTestsPassed=58; slice4NewCaseNameFramedBytes=$operatorSlice4NewFrameBytes.Length; slice4NewCaseNameSha256=$operatorSlice4NewFrameSha256; dryRunCounters=$localOperatorHarnessJson.dryRunCounters; healthGuardDenial=$localOperatorHarnessJson.healthGuardDenial; healthConnectAttemptMonitor=$localOperatorHarnessJson.healthConnectAttemptMonitor; wrapperMaximumBytes=587; metadataInventory=$localOperatorHarnessMetadata; offlineTestsPass=$true }

    $localOperatorOutputPath = Join-Path $buildRoot ([string]$profile.localOperator.output)
    $localOperatorArguments = @('/nologo','/noconfig','/target:exe','/platform:x64','/optimize+','/debug-','/checked+','/highentropyva+','/warn:4','/warnaserror+','/nostdlib+',('/define:' + [string]$profile.localOperator.nativeSymbols),"/reference:$resolvedReferences\mscorlib.dll","/reference:$resolvedReferences\System.dll","/reference:$resolvedReferences\System.Net.Http.dll",'/main:EAIRA.AgentServices.Functional.LocalOperatorHost',"/out:$localOperatorOutputPath")
    if (-not $DevelopmentProbe) { $localOperatorArguments += '/deterministic+'; $localOperatorArguments += "/pathmap:$componentRoot=/_/EAIRA/apps/agent-services" }
    $localOperatorArguments += @($codecSourcePath,$coreSourcePath,$providerSourcePath,$taskIntakeSourcePath,$localProviderSourcePath,$loopbackTransportSourcePath,$projectReadOnlyPlatformSourcePath,$projectContextSourcePath,$projectKnowledgeSourcePath,$projectQaSourcePath,$localOperatorSourcePath,$localOperatorHostSourcePath)
    $localOperatorCompilerOutput = @(& $resolvedCompiler @localOperatorArguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Local Operator CLI compiler failed: $($localOperatorCompilerOutput -join [Environment]::NewLine)" }
    Assert-NoForbiddenBinaryMetadata -LiteralPath $localOperatorOutputPath -AllowLoopbackHttp -AllowProjectContextPInvoke
    $operatorIoReferences = @(Get-SystemIoMemberReferences -LiteralPath $localOperatorOutputPath)
    $expectedOperatorIoReferences = @('System.IO.Stream::get_CanRead','System.IO.Stream::ReadAsync','System.IO.Stream::Write')
    if (($operatorIoReferences -join "`n") -cne ($expectedOperatorIoReferences -join "`n")) { throw "Local Operator System.IO union policy mismatch: $($operatorIoReferences -join ', ')" }
    $localOperatorPInvokeMetadata = Assert-ProjectContextPInvokePolicy -LiteralPath $localOperatorOutputPath -Policy $profile.projectContext -OutputKind 'LocalOperatorCli' -Discovery:$operatorDiscovery
    $localOperatorCallerEvidence = Assert-ProjectContextPInvokeCallerPolicy -LiteralPath $localOperatorOutputPath -Policy $profile.projectContext -OutputKind 'LocalOperatorCli' -Discovery:$operatorDiscovery
    $localOperatorNativeSemantic = Get-NormalizedNativeSemanticInventory -PInvokeMetadata $localOperatorPInvokeMetadata -CallerEvidence $localOperatorCallerEvidence
    $localOperatorLoopbackMetadata = Get-LoopbackMetadataReferences -LiteralPath $localOperatorOutputPath
    if (-not $retainedOperatorDiscovery) { Assert-LoopbackMetadataPolicy -LiteralPath $localOperatorOutputPath -Policy $profile.localOperator.loopbackMetadataAllowlist -DevelopmentProbe:$DevelopmentProbe }
    $localOperatorMetadata = Assert-LocalOperatorMetadataPolicy -LiteralPath $localOperatorOutputPath -Policy $profile.localOperator -OutputKind 'Cli' -Discovery:$operatorDiscovery
    $localOperatorHealthIl = Get-LocalOperatorHealthIlEvidence -LiteralPath $localOperatorOutputPath
    $localOperatorPreflightIl = Get-LocalOperatorPreflightIlEvidence -LiteralPath $localOperatorOutputPath
    $localOperatorDryRunIl = Get-LocalOperatorDryRunIlEvidence -LiteralPath $localOperatorOutputPath
    $healthControlFlowProfileMatch = $null
    $healthInstrumentationProfileMatch = $null
    $preflightControlFlowProfileMatch = $null
    $dryRunControlFlowProfileMatch = $null
    if (-not $retainedOperatorDiscovery) {
        $healthControlFlowProfileMatch =
            (($localOperatorHealthIl.dispatchIl | ConvertTo-Json -Depth 3 -Compress) -ceq ($profile.localOperator.healthControlFlow.dispatchIl | ConvertTo-Json -Depth 3 -Compress)) -and
            (($localOperatorHealthIl.allowedClosureMethods | ConvertTo-Json -Depth 3 -Compress) -ceq ($profile.localOperator.healthControlFlow.allowedClosureMethods | ConvertTo-Json -Depth 3 -Compress)) -and
            (($localOperatorHealthIl.allowedClosureCalls | ConvertTo-Json -Depth 3 -Compress) -ceq ($profile.localOperator.healthControlFlow.allowedClosureCalls | ConvertTo-Json -Depth 3 -Compress))
        $healthInstrumentationProfileMatch = (($localOperatorHealthIl.instrumentation | ConvertTo-Json -Depth 3 -Compress) -ceq ($profile.localOperator.healthConnectAttemptMonitor.instrumentation | ConvertTo-Json -Depth 3 -Compress))
        $preflightControlFlowProfileMatch =
            [string]$localOperatorPreflightIl.dispatchMethod -ceq [string]$profile.localOperator.preflightControlFlow.dispatchMethod -and
            [string]$localOperatorPreflightIl.allowedRoot -ceq [string]$profile.localOperator.preflightControlFlow.allowedRoot -and
            [string]$localOperatorPreflightIl.build8 -ceq [string]$profile.localOperator.preflightControlFlow.build8 -and
            [string]$localOperatorPreflightIl.build9 -ceq [string]$profile.localOperator.preflightControlFlow.build9 -and
            (($localOperatorPreflightIl.dispatchRows | ConvertTo-Json -Depth 8 -Compress) -ceq ($profile.localOperator.preflightControlFlow.dispatchRows | ConvertTo-Json -Depth 8 -Compress)) -and
            (($localOperatorPreflightIl.methodRows | ConvertTo-Json -Depth 8 -Compress) -ceq ($profile.localOperator.preflightControlFlow.methodRows | ConvertTo-Json -Depth 8 -Compress)) -and
            (($localOperatorPreflightIl.callRows | ConvertTo-Json -Depth 8 -Compress) -ceq ($profile.localOperator.preflightControlFlow.callRows | ConvertTo-Json -Depth 8 -Compress)) -and
            (($localOperatorPreflightIl.tokenRows | ConvertTo-Json -Depth 8 -Compress) -ceq ($profile.localOperator.preflightControlFlow.tokenRows | ConvertTo-Json -Depth 8 -Compress)) -and
            (($localOperatorPreflightIl.methodManifest | ConvertTo-Json -Depth 3 -Compress) -ceq ($profile.localOperator.preflightControlFlow.methodManifest | ConvertTo-Json -Depth 3 -Compress)) -and
            (($localOperatorPreflightIl.callManifest | ConvertTo-Json -Depth 3 -Compress) -ceq ($profile.localOperator.preflightControlFlow.callManifest | ConvertTo-Json -Depth 3 -Compress)) -and
            (($localOperatorPreflightIl.tokenManifest | ConvertTo-Json -Depth 3 -Compress) -ceq ($profile.localOperator.preflightControlFlow.tokenManifest | ConvertTo-Json -Depth 3 -Compress)) -and
            (($localOperatorPreflightIl.closureManifest | ConvertTo-Json -Depth 3 -Compress) -ceq ($profile.localOperator.preflightControlFlow.closureManifest | ConvertTo-Json -Depth 3 -Compress))
        if (-not $dryRunDiscovery) {
        $dryRunControlFlowProfileMatch =
            [string]$localOperatorDryRunIl.dispatchMethod -ceq [string]$profile.localOperator.dryRunControlFlow.dispatchMethod -and
            [string]$localOperatorDryRunIl.allowedRoot -ceq [string]$profile.localOperator.dryRunControlFlow.allowedRoot -and
            [string]$localOperatorDryRunIl.build8 -ceq [string]$profile.localOperator.dryRunControlFlow.build8 -and
            [string]$localOperatorDryRunIl.build9 -ceq [string]$profile.localOperator.dryRunControlFlow.build9 -and
            (($localOperatorDryRunIl.dispatchRows | ConvertTo-Json -Depth 8 -Compress) -ceq ($profile.localOperator.dryRunControlFlow.dispatchRows | ConvertTo-Json -Depth 8 -Compress)) -and
            (($localOperatorDryRunIl.methodRows | ConvertTo-Json -Depth 8 -Compress) -ceq ($profile.localOperator.dryRunControlFlow.methodRows | ConvertTo-Json -Depth 8 -Compress)) -and
            (($localOperatorDryRunIl.callRows | ConvertTo-Json -Depth 8 -Compress) -ceq ($profile.localOperator.dryRunControlFlow.callRows | ConvertTo-Json -Depth 8 -Compress)) -and
            (($localOperatorDryRunIl.tokenRows | ConvertTo-Json -Depth 8 -Compress) -ceq ($profile.localOperator.dryRunControlFlow.tokenRows | ConvertTo-Json -Depth 8 -Compress)) -and
            (($localOperatorDryRunIl.methodManifest | ConvertTo-Json -Depth 3 -Compress) -ceq ($profile.localOperator.dryRunControlFlow.methodManifest | ConvertTo-Json -Depth 3 -Compress)) -and
            (($localOperatorDryRunIl.callManifest | ConvertTo-Json -Depth 3 -Compress) -ceq ($profile.localOperator.dryRunControlFlow.callManifest | ConvertTo-Json -Depth 3 -Compress)) -and
            (($localOperatorDryRunIl.tokenManifest | ConvertTo-Json -Depth 3 -Compress) -ceq ($profile.localOperator.dryRunControlFlow.tokenManifest | ConvertTo-Json -Depth 3 -Compress)) -and
            (($localOperatorDryRunIl.closureManifest | ConvertTo-Json -Depth 3 -Compress) -ceq ($profile.localOperator.dryRunControlFlow.closureManifest | ConvertTo-Json -Depth 3 -Compress))
        if (-not $dryRunControlFlowProfileMatch) { throw 'Local Operator DryRun targeted IL profile mismatch.' }
        }
        if (-not $healthControlFlowProfileMatch -or -not $healthInstrumentationProfileMatch) { throw 'Local Operator Health targeted IL profile mismatch.' }
        if (-not $preflightControlFlowProfileMatch) { throw 'Local Operator Preflight targeted IL profile mismatch.' }
    }

    $operatorInvalid = Invoke-ExactChannelTest -Executable $localOperatorOutputPath -Arguments @()
    $operatorDenied = Invoke-ExactChannelTest -Executable $localOperatorOutputPath -Arguments @('task','--provider','mock','--trace','00112233445566778899AABBCCDDEEFF','--goal','write file')
    $operatorMock = Invoke-ExactChannelTest -Executable $localOperatorOutputPath -Arguments @('task','--provider','mock','--trace','00112233445566778899AABBCCDDEEFF','--goal','plan')
    $operatorHealth = Invoke-ExactChannelTest -Executable $localOperatorOutputPath -Arguments @('health','--trace','0123456789ABCDEF0123456789ABCDEF')
    $operatorPreflight = Invoke-ExactChannelTest -Executable $localOperatorOutputPath -Arguments @('preflight','--trace','00112233445566778899AABBCCDDEEFF','--route','TASK_MOCK')
    $operatorDryRun = Invoke-ExactChannelTest -Executable $localOperatorOutputPath -Arguments @('dry-run','task','--provider','mock','--trace','00112233445566778899AABBCCDDEEFF','--goal','plan')
    try { $operatorInvalidJson=[Text.Encoding]::UTF8.GetString($operatorInvalid.stdoutBytes)|ConvertFrom-Json; $operatorDeniedJson=[Text.Encoding]::UTF8.GetString($operatorDenied.stdoutBytes)|ConvertFrom-Json; $operatorMockJson=[Text.Encoding]::UTF8.GetString($operatorMock.stdoutBytes)|ConvertFrom-Json; $operatorHealthJson=[Text.Encoding]::UTF8.GetString($operatorHealth.stdoutBytes)|ConvertFrom-Json; $operatorPreflightJson=[Text.Encoding]::UTF8.GetString($operatorPreflight.stdoutBytes)|ConvertFrom-Json; $operatorDryRunJson=[Text.Encoding]::UTF8.GetString($operatorDryRun.stdoutBytes)|ConvertFrom-Json } catch { throw 'Local Operator CLI output is not valid JSON.' }
    $expectedPreflightGoldenVectors = @(
        [ordered]@{routeId='TASK_MOCK';inputSha256='6E02888095CC5D5D9C440BF26DE342848855A56D9C04282A398B8B59C812B185';requestSha256='0BBACB758B1EA183338134C3D5CAAEDABA56793026E506214651BD0EA5FF1CC8';routeSha256='1261E4E6931D12FD0C7AD5451003D1ED9C099D47549C474451D7FED5C858A5BC';payloadBytes=469;payloadSha256='8D7997CAE44F3D9AC2B244DD8B24B36A9BF2862E53A940B2F407178A24700123';auditSha256='612EEE7C3DBC3C74D9756FF3F864904B1F0096056514228A73575CBE8234D979';wrapperBytes=1031;wrapperSha256='F6A302DFD0B183F774EB284646E6A349684D7A04069BB48993752A55FDDBF363'},
        [ordered]@{routeId='TASK_MOCK_CONTEXT';inputSha256='8EAF2E7E352ED6708B4E27C1DEB3C43750E06002E561217F42631D328D662EB6';requestSha256='49A90C39F8B8E078F16E911E779D7E5B680CF110B361EB1BE2EA61C0FFA89606';routeSha256='2BD5CAB32D3A6D92EBCFF7DBE908C8697040D5C5F0680F7BB5F94437CE9556A6';payloadBytes=484;payloadSha256='4A8FA23201A8D66973B7ED2B12175550CE8420B7AB4A2E3B1719F95C1E900AAE';auditSha256='29AB65CD7FA72CDAC05D745522378BEF3B9CBDC791F7262FAF8F1FD33CADD9A7';wrapperBytes=1046;wrapperSha256='44CE99EB60F7060B8F929BEDB43ABC1E4BC1AE30FB357F3306F487DB81DF490D'},
        [ordered]@{routeId='TASK_OLLAMA_LOCAL';inputSha256='02EC0071865D2E0F8180E4EBB2F26018E6D4311F17F42F19EB8636CA7378471F';requestSha256='8C370BC4AAD608DB64D4153FFF5041B33E851E104FCD340AE7C86B359FACC67C';routeSha256='CAD4B1919CCC21DE78491E7354BC7CCDD18B06F825391382374504FB42B5FFD9';payloadBytes=503;payloadSha256='BC12483396D81F0FD34694785ABD48D246B682A9307CF7C67EF59A90C06F7235';auditSha256='9E9227C0CD8D8535E55BCD67B827E8AB98F8E5825BEE24094E238E154851491B';wrapperBytes=1065;wrapperSha256='7EF3DB6697E0C22668562ACEE901C3DB7F89AF7CEC7E06BAB2DE46EC8A52AF4E'},
        [ordered]@{routeId='TASK_OLLAMA_LOCAL_CONTEXT';inputSha256='73A30D6DFF83BD0F29587F9A96BB9068CD4457B3B7CCBF431CCDE3E90684B14D';requestSha256='8934570547EB83CFD702A33915E23DEC3C9D6932832050718241E452FF01E246';routeSha256='95852EB55B3CB5423ACDA23B15EB345A4A71427089E1FC6F691AB488C39CAABF';payloadBytes=518;payloadSha256='B9942954B900123FFBD4F81E36CD26DDC588B29E1CF223EEFBC73C0B3B0C9FDD';auditSha256='0CF369D262B8508D10D02D92B8DD662E4BF27C43E8B152CEF934FCD05C293BFE';wrapperBytes=1080;wrapperSha256='15EDE12F1DEAC0BAEDC5BB59179D37F8CB5B9A121308CFE293BA3037CB74FAB9'},
        [ordered]@{routeId='KNOWLEDGE';inputSha256='9D8343AD14123606AB0123B44B1F6E33A9FDD08BA85E2F59919173A72AE40E29';requestSha256='6E9B253090E1E9F48DB5EB40DB2C6B2FA638AB94422C761A5171D2BFFFBA9273';routeSha256='41CC3A936B9E48034A9CFA2E0B330135D7B0DC005B50151FF0AF9E6B3C8C223A';payloadBytes=460;payloadSha256='8C6AC210A698083658282360A080E406CBD123D4DF612B75D92F4D2B69ADE024';auditSha256='4FCACC78AAE677180A3F72A8390D3E3BA06BDF49199BA8FF18BE7147B29F1D4A';wrapperBytes=1022;wrapperSha256='1253EC133D4C292E202D093C9D300F1789156EE17C11D773E73F3486F135EC78'},
        [ordered]@{routeId='PROJECT_QA_OLLAMA_LOCAL';inputSha256='A8A0D2FF6C74A7A7FEE5F253DD84EFF6BF0A03EE176E8A3B2AFF6D7C3E3625FE';requestSha256='3BA821B17CD1C6AEDC39941E24D437616773544E1D10A9FF3BA8CCB888878DB3';routeSha256='B2B97AB2C724BD85E80AD82D678E748EE0FDEEF550381F52FADF97DB3F66AEE9';payloadBytes=510;payloadSha256='8B23F674B8E485B171DA882D2FB99C46132BDACB795A5C55E4DD3BB6B2EDBA3A';auditSha256='DB6A5A47D1F213F1FE47AC404ECA7D94AA4896E1A2FB3277569E8A313571A7D3';wrapperBytes=1072;wrapperSha256='A12A101605F2972915528EAB7D9354969835FE4128985034EB99EA0EF1C3298E'},
        [ordered]@{routeId='HEALTH';inputSha256='C88E47E2668A7754785362F580C3F5B2E25AC7CBEE9F58A5C32056BC82FC9993';requestSha256='6CDAB3F8DA1151DDFABD36D7082AFD2AC9BB96DE0D474403C7696B7A207128ED';routeSha256='13BC3DBF53415D5EDDE75C4E07B71E95B357175204BD03711E1177E0457FBC03';payloadBytes=452;payloadSha256='8FC6CF6017AA3DC770D6D2E3934C5B01E7506F834DB4670BCF18C0545CCEB927';auditSha256='B70027C347516E0EF87793C724E71F3FEAEBD8CCAC16E1706CC195861653963C';wrapperBytes=1014;wrapperSha256='81E9E488E0FC8F74E73397FCEA5DF1F127EE787E622072E3C3199C3DBF6C5912'}
    )
    $preflightGoldenVectorEvidence = @(); $preflightGoldenVectorsPass = $true
    foreach ($expected in $expectedPreflightGoldenVectors) {
        $channel = Invoke-ExactChannelTest -Executable $localOperatorOutputPath -Arguments @('preflight','--trace','00112233445566778899AABBCCDDEEFF','--route',[string]$expected.routeId)
        try { $json=[Text.Encoding]::UTF8.GetString($channel.stdoutBytes)|ConvertFrom-Json } catch { throw "Preflight golden output is not valid JSON for route '$($expected.routeId)'." }
        $payloadBytes=[Text.Encoding]::UTF8.GetByteCount(($json.payload|ConvertTo-Json -Compress -Depth 10))
        $pass=$channel.exitCode-eq0-and$channel.stderrBytes.Length-eq0-and$channel.stdoutBytes.Length-eq[int]$expected.wrapperBytes-and$channel.stdoutSha256-ceq[string]$expected.wrapperSha256-and[string]$json.requestSha256-ceq[string]$expected.requestSha256-and[string]$json.routeSha256-ceq[string]$expected.routeSha256-and$payloadBytes-eq[int]$expected.payloadBytes-and[string]$json.payloadSha256-ceq[string]$expected.payloadSha256-and[string]$json.audit.chainSha256-ceq[string]$expected.auditSha256-and[string]$json.capability-ceq'PREFLIGHT'-and[string]$json.network-ceq'NONE'-and[string]$json.writes-ceq'NONE'-and[string]$json.authority-ceq'EXPLANATORY_NOT_AUTHORITY'
        if(-not$pass){$preflightGoldenVectorsPass=$false}
        $preflightGoldenVectorEvidence += [ordered]@{routeId=[string]$expected.routeId;inputSha256=[string]$expected.inputSha256;requestSha256=[string]$json.requestSha256;routeSha256=[string]$json.routeSha256;payloadBytes=[int]$payloadBytes;payloadSha256=[string]$json.payloadSha256;auditSha256=[string]$json.audit.chainSha256;wrapperBytes=[int]$channel.stdoutBytes.Length;wrapperSha256=[string]$channel.stdoutSha256;pass=[bool]$pass}
    }
    if(-not$preflightGoldenVectorsPass){throw 'Local Operator Preflight seven-row golden vector matrix failed.'}
    if(-not$retainedOperatorDiscovery-and(($preflightGoldenVectorEvidence|ConvertTo-Json -Depth 6 -Compress)-cne($profile.localOperator.preflightGoldenVectors|ConvertTo-Json -Depth 6 -Compress))){throw 'Local Operator Preflight golden vector profile mismatch.'}
    $dryRunArgv = @(
        @('dry-run','task','--provider','mock','--trace','00112233445566778899AABBCCDDEEFF','--goal','plan'),
        @('dry-run','task','--provider','mock','--trace','00112233445566778899AABBCCDDEEFF','--goal','plan','--context-root','C:\EAIRA'),
        @('dry-run','task','--provider','ollama-local','--model','qwen3:4b','--trace','00112233445566778899AABBCCDDEEFF','--goal','plan'),
        @('dry-run','task','--provider','ollama-local','--model','qwen3:4b','--trace','00112233445566778899AABBCCDDEEFF','--goal','plan','--context-root','C:\EAIRA'),
        @('dry-run','knowledge','--root','C:\EAIRA','--trace','00112233445566778899AABBCCDDEEFF','--query','status'),
        @('dry-run','project-qa','--root','C:\EAIRA','--trace','00112233445566778899AABBCCDDEEFF','--question','status','--provider','ollama-local','--model','qwen3:4b'),
        @('dry-run','health','--trace','00112233445566778899AABBCCDDEEFF')
    )
    $expectedDryRunGoldenVectors = @(
        [ordered]@{routeId='TASK_MOCK';argvCount=8;taskSha256='87FC2171DEF76373ACBC2382DBD1309174548A70C5761F8BE78D253E2272F554';rootSha256='NONE';inputSha256='4EB3550F537768AFF0825D476C6807C41572F38983A162A035246B2BB9C8FA97';requestSha256='00D0582B2FA2F71FC9573D6B28499DE07BE9286DFDA623BDF084847D15C292CA';routeSha256='2F1F782832899E3D526F75D96739D1ECB76C88EBEBABC7AB6F4DD77CC649612D';payloadBytes=439;payloadSha256='487EB55F010976DA24CBF979DCC036AF41CDF69F3B86961B1C37E21BC94BE08C';auditSha256='B97BA30497BB26EEE192E38CD2799216680729231825236D8B136416E8C7D64C';stdoutBytes=997;wrapperBytes=997;stdoutSha256='05E088A8C1A0884E44A304615992C5F8F5C3674615FBB02F8B1C030DAD3D32F0'},
        [ordered]@{routeId='TASK_MOCK_CONTEXT';argvCount=10;taskSha256='87FC2171DEF76373ACBC2382DBD1309174548A70C5761F8BE78D253E2272F554';rootSha256='DA10DAE18F73EA08EF751AAB554D8249E1C5758ECA8B1754212B8C1036BF4C7B';inputSha256='4EB3550F537768AFF0825D476C6807C41572F38983A162A035246B2BB9C8FA97';requestSha256='6605AD0A176E7AD5E31A3142B98520699E62374BD356850C19D34E65AE91F0E1';routeSha256='A85446556D00D7BB953A4EA4572F915E333C491E00E10DB6496D34491E440EA9';payloadBytes=454;payloadSha256='D4E2ED37C3566DBDF22CD2AA20CDCC4649C4472FC038B3A89813E3FFCAE808C3';auditSha256='6D95F8BEA6A6EB5217EB1D4473FBDB71882951797F9C6F3270732FD4B8E68AB8';stdoutBytes=1012;wrapperBytes=1012;stdoutSha256='025B9E9D313592D341B2CF62CB2E6D8D07E8BA96EC52698144C142660B104E2C'},
        [ordered]@{routeId='TASK_OLLAMA_LOCAL';argvCount=10;taskSha256='87FC2171DEF76373ACBC2382DBD1309174548A70C5761F8BE78D253E2272F554';rootSha256='NONE';inputSha256='4EB3550F537768AFF0825D476C6807C41572F38983A162A035246B2BB9C8FA97';requestSha256='484AB0B8F1BC23CA8B36875647FB4DBE7B1E6E51C0BB044F9BE1C2FB215DBF2C';routeSha256='6FC767F2CAA796EDA6803FFE366A6BC578667B89180CA229B56AB29ABC7856F9';payloadBytes=473;payloadSha256='64354B3091CE5511092E9413B408BF843F93B82EDC25DF9F164B9AC92D5306B7';auditSha256='F4E5E6393D22834319766D5DAD55ADBC6FAE836F30CE007ADD6E3B42E5329A8B';stdoutBytes=1031;wrapperBytes=1031;stdoutSha256='67439AD85153C1B653223F6B22D2048C287423F4DF760678BFBB65EDED93E98B'},
        [ordered]@{routeId='TASK_OLLAMA_LOCAL_CONTEXT';argvCount=12;taskSha256='87FC2171DEF76373ACBC2382DBD1309174548A70C5761F8BE78D253E2272F554';rootSha256='DA10DAE18F73EA08EF751AAB554D8249E1C5758ECA8B1754212B8C1036BF4C7B';inputSha256='4EB3550F537768AFF0825D476C6807C41572F38983A162A035246B2BB9C8FA97';requestSha256='3E14D97DD6D4D163D980EF148760173F41A203DA9DBA3D963E585B17E5A8D126';routeSha256='DEA35BFE7AECD5CE5536E99359C115CF52B0EEA0125753A049EDF35872F2AB88';payloadBytes=488;payloadSha256='D672540E9FA0C2E1B4A2A176468488D5B96EAFE45C9C65900B41D88C929D35DD';auditSha256='BA1A5A9BD8D69B34BA29ED65A08F8D68731B3BD056456D4C2845F2157F2C02B1';stdoutBytes=1046;wrapperBytes=1046;stdoutSha256='2E3C61F5FCF793EB009E9B2E5BFC1ABD2EC333C8F0FB6F23AEF61D794E483CC4'},
        [ordered]@{routeId='KNOWLEDGE';argvCount=8;taskSha256='87FC2171DEF76373ACBC2382DBD1309174548A70C5761F8BE78D253E2272F554';rootSha256='DA10DAE18F73EA08EF751AAB554D8249E1C5758ECA8B1754212B8C1036BF4C7B';inputSha256='21FB24CE009AF6F6760A1CCE43A3B3431E4E6B68CDD7A37B4995CBECB91F4F70';requestSha256='F67C0265C282571D006925982DA8F2075BE9AD69DFF6EC43E7B3E3A614C76CB0';routeSha256='F4CCD8316AC05E6308DFE06D65450AF6114840EDB64080C5DD4577D27962D351';payloadBytes=430;payloadSha256='15E3A89C14D0AF1723D8CDB8FF83C7970266E8DE13A48F6E4C96DFD9892B492A';auditSha256='4783760514FCDA2022F9E2F0DB914F64AB4ECE155016183CC5C290280CFEFDA0';stdoutBytes=988;wrapperBytes=988;stdoutSha256='DBC4FB2B646FF25EAF568584FC5FAE3C3872DDB8D0B70B4AAB57EA1D6D0D70A1'},
        [ordered]@{routeId='PROJECT_QA_OLLAMA_LOCAL';argvCount=12;taskSha256='87FC2171DEF76373ACBC2382DBD1309174548A70C5761F8BE78D253E2272F554';rootSha256='DA10DAE18F73EA08EF751AAB554D8249E1C5758ECA8B1754212B8C1036BF4C7B';inputSha256='63B774742CD06A8F1C5D8E247137338622B0C381574677E0AC0A231E657DC6A4';requestSha256='6CB07289E134BDBFE61BF772022797EAE11A1C2CB720CDEDCB70FBA1FEB72EC5';routeSha256='F903ACCCD6D6C372A5960F9F0DBFC3C0676932EF1610BA552C33298616D41D31';payloadBytes=480;payloadSha256='BC274BB54CAEB5D2958F5087CE9C23DBA13B02CD8A4CA2966FC511D1B1AF0CA7';auditSha256='B69047E7F36D96E26F430A7D5B02E1347A85A248F02590D5FFB4E5180D18B950';stdoutBytes=1038;wrapperBytes=1038;stdoutSha256='4253C76C84B10DF234DF6A5C7ACF61F53ACD525EED3FEF461076989BC545F284'},
        [ordered]@{routeId='HEALTH';argvCount=4;taskSha256='87FC2171DEF76373ACBC2382DBD1309174548A70C5761F8BE78D253E2272F554';rootSha256='NONE';inputSha256='634A5CE7F3BD64CD9DA92318FC425EC77355BC93BE46D9E0DE1F5DF8C4FA5C2C';requestSha256='615C5224B6E3C5212B435342857392D77ECC9E0EDF781B3F0EA94FD4AD680816';routeSha256='85A38362E1D77AAA2C982FD39E3C8B8E8A3681553C43EE4B44B6539995C0DC93';payloadBytes=422;payloadSha256='8080D5B56177B0E2AF7E32310761593C8A5D887B33DAA04FFBEC3AA03408C30D';auditSha256='8C4A5B25E669801A49C789495E1F0EAE4D0A146190ABA0BD2343B59A9F6B97E5';stdoutBytes=980;wrapperBytes=980;stdoutSha256='5E6F0200546DC74EA4AAFC1E4AB23A76F199679D9C35E8A24BF1C8DECE72477B'}
    )
    $dryRunGoldenVectorEvidence=@();$dryRunGoldenVectorsPass=$true
    for($i=0;$i-lt$expectedDryRunGoldenVectors.Count;$i++){
        $expected=$expectedDryRunGoldenVectors[$i];$channel=Invoke-ExactChannelTest -Executable $localOperatorOutputPath -Arguments $dryRunArgv[$i]
        try{$json=[Text.Encoding]::UTF8.GetString($channel.stdoutBytes)|ConvertFrom-Json}catch{throw "DryRun golden output is not valid JSON for route '$($expected.routeId)'."}
        $payloadBytes=[Text.Encoding]::UTF8.GetByteCount(($json.payload|ConvertTo-Json -Compress -Depth 10));$members=(@($json.payload.PSObject.Properties.Name)-join',')
        $pass=$channel.exitCode-eq0-and$channel.stderrBytes.Length-eq0-and$channel.stdoutBytes.Length-eq[int]$expected.stdoutBytes-and$channel.stdoutSha256-ceq[string]$expected.stdoutSha256-and[string]$json.requestSha256-ceq[string]$expected.requestSha256-and[string]$json.routeSha256-ceq[string]$expected.routeSha256-and$payloadBytes-eq[int]$expected.payloadBytes-and[string]$json.payloadSha256-ceq[string]$expected.payloadSha256-and[string]$json.audit.chainSha256-ceq[string]$expected.auditSha256-and[string]$json.capability-ceq'DRY_RUN_PLAN'-and[string]$json.network-ceq'NONE'-and[string]$json.writes-ceq'NONE'-and[string]$json.authority-ceq[string]$profile.localOperator.dryRunAuthority-and$members-ceq($expectedDryRunPayloadMembers-join',')-and[string]$json.payload.schema-ceq[string]$profile.localOperator.dryRunContract-and[string]$json.payload.planStatus-ceq[string]$profile.localOperator.dryRunPlanStatus-and[string]$json.payload.writes-ceq'NONE'-and[string]$json.payload.planGuardEvaluation-ceq[string]$profile.localOperator.dryRunGuardIntent-and[string]$json.payload.executionGuardEvaluation-ceq[string]$profile.localOperator.dryRunExecutionGuardEvaluation-and[string]$json.payload.executionStatus-ceq[string]$profile.localOperator.dryRunExecutionStatus-and[string]$json.payload.authority-ceq[string]$profile.localOperator.dryRunAuthority
        if(-not$pass){$dryRunGoldenVectorsPass=$false};$dryRunGoldenVectorEvidence += [ordered]@{routeId=[string]$expected.routeId;argvCount=[int]$expected.argvCount;taskSha256=[string]$expected.taskSha256;rootSha256=[string]$expected.rootSha256;inputSha256=[string]$expected.inputSha256;requestSha256=[string]$json.requestSha256;routeSha256=[string]$json.routeSha256;payloadBytes=[int]$payloadBytes;payloadSha256=[string]$json.payloadSha256;auditSha256=[string]$json.audit.chainSha256;stdoutBytes=[int]$channel.stdoutBytes.Length;wrapperBytes=[int]$channel.stdoutBytes.Length;stdoutSha256=[string]$channel.stdoutSha256;pass=[bool]$pass}
    }
    if(-not$dryRunGoldenVectorsPass){throw 'Local Operator DryRun seven-row golden vector matrix failed.'}
    if(-not$dryRunDiscovery-and(($dryRunGoldenVectorEvidence|ConvertTo-Json -Depth 6 -Compress)-cne($profile.localOperator.dryRunGoldenVectors|ConvertTo-Json -Depth 6 -Compress))){throw 'Local Operator DryRun golden vector profile mismatch.'}
    $dryRunDenialVectorEvidence=@(
        [ordered]@{routeId='TASK_MOCK';auditSha256='C0C0D46AB19AEF45CAC1999FE9C67B2A50159387876EC96E8E72EB8607EE4AEE';stdoutBytes=504;stdoutSha256='168916E48F2F8992C2B0FE06DF58088B9C77EBA4BAF413BD20B1C3DA8BD37EC1'},
        [ordered]@{routeId='TASK_MOCK_CONTEXT';auditSha256='CD3C34C5A3B3FBA4F1E0C4E4259162C71FD055DAB08FF35DE22CB3E7E1690E29';stdoutBytes=504;stdoutSha256='082F5C0B97F099C1E294FE8C40BC3823C7DC745A6A8970837B97512C6E3E414C'},
        [ordered]@{routeId='TASK_OLLAMA_LOCAL';auditSha256='009CB204A5519E67C3A32DF4FE76E0989BCB9A0072FA30177D7231F47C8E06AF';stdoutBytes=504;stdoutSha256='8E9886D4A4C2C7629477764E490A40F4BA85545ABC425DBB6F4621FD999FE0D9'},
        [ordered]@{routeId='TASK_OLLAMA_LOCAL_CONTEXT';auditSha256='14F5383222D4E1F45A372E5C13FE804CC4D408C7278EF76BB03DAE8619E0C00B';stdoutBytes=504;stdoutSha256='3675ECFF870B7D5EB105498D5C05B5BB389BD0F8B99536DDD911C60B6A0A6502'},
        [ordered]@{routeId='KNOWLEDGE';auditSha256='689D5175F7A2B6AB089BB830E028D6A12AA776DB279D5C9CE7F65813731BA77B';stdoutBytes=504;stdoutSha256='821B9F99173A948BCF17B76E0DAFCBD4E586EB87956DE1C10330E7DC12498B2B'},
        [ordered]@{routeId='PROJECT_QA_OLLAMA_LOCAL';auditSha256='05CAAAACCC41BF845D9D2B91DB7EB2F97A4617ECF2A29347A79A75E1DF39E2DF';stdoutBytes=504;stdoutSha256='9D0F6093A70A3E4AF1FCD82E12DE74F7ACB7EA74F00549F16663166B38EDBD8A'},
        [ordered]@{routeId='HEALTH';auditSha256='D959D44B54DF91614E18FF1CDF3B15DBFDCB1A4CEFF881A0F23BB6E6E249EE6A';stdoutBytes=504;stdoutSha256='CD595E4BE0C8301A4C9B00FB5E47888B0C398BFC2D60BD21B702A6D45CA6C7B6'}
    )
    if(-not$dryRunDiscovery-and(($dryRunDenialVectorEvidence|ConvertTo-Json -Depth 5 -Compress)-cne($profile.localOperator.dryRunDenialVectors|ConvertTo-Json -Depth 5 -Compress))){throw 'Local Operator DryRun denial vector profile mismatch.'}
    $operatorChannels = [ordered]@{
        invalid=[ordered]@{exitCode=$operatorInvalid.exitCode;stdoutBytes=$operatorInvalid.stdoutBytes.Length;stdoutSha256=$operatorInvalid.stdoutSha256;stderrBytes=$operatorInvalid.stderrBytes.Length}
        denied=[ordered]@{exitCode=$operatorDenied.exitCode;stdoutBytes=$operatorDenied.stdoutBytes.Length;stdoutSha256=$operatorDenied.stdoutSha256;stderrBytes=$operatorDenied.stderrBytes.Length}
        mock=[ordered]@{exitCode=$operatorMock.exitCode;stdoutBytes=$operatorMock.stdoutBytes.Length;stdoutSha256=$operatorMock.stdoutSha256;stderrBytes=$operatorMock.stderrBytes.Length}
        health=[ordered]@{exitCode=$operatorHealth.exitCode;stdoutBytes=$operatorHealth.stdoutBytes.Length;stdoutSha256=$operatorHealth.stdoutSha256;stderrBytes=$operatorHealth.stderrBytes.Length}
        preflight=[ordered]@{exitCode=$operatorPreflight.exitCode;stdoutBytes=$operatorPreflight.stdoutBytes.Length;stdoutSha256=$operatorPreflight.stdoutSha256;stderrBytes=$operatorPreflight.stderrBytes.Length}
        dryRun=[ordered]@{exitCode=$operatorDryRun.exitCode;stdoutBytes=$operatorDryRun.stdoutBytes.Length;stdoutSha256=$operatorDryRun.stdoutSha256;stderrBytes=$operatorDryRun.stderrBytes.Length}
    }
    $retainedOperatorChannels = [ordered]@{
        invalid=$operatorChannels.invalid
        denied=$operatorChannels.denied
        mock=$operatorChannels.mock
        health=$operatorChannels.health
        preflight=$operatorChannels.preflight
    }
    $dryRunChannelEvidence = $operatorChannels.dryRun
    $channelShapePass = $true
    foreach ($channel in @($operatorInvalid,$operatorDenied,$operatorMock,$operatorHealth,$operatorPreflight,$operatorDryRun)) {
        $lfCount=@($channel.stdoutBytes|Where-Object{$_ -eq 10}).Count; $crCount=@($channel.stdoutBytes|Where-Object{$_ -eq 13}).Count
        if ($channel.stderrBytes.Length -ne 0 -or $channel.stdoutBytes.Length -eq 0 -or $channel.stdoutBytes[$channel.stdoutBytes.Length-1] -ne 10 -or $lfCount -ne 1 -or $crCount -ne 0 -or $channel.stdoutBytes.Length -gt 16970) { $channelShapePass=$false }
    }
    $operatorChannelSemanticPass = $channelShapePass -and $operatorInvalid.exitCode -eq 64 -and [string]$operatorInvalidJson.status -ceq 'INVALID_REQUEST' -and $null -eq $operatorInvalidJson.audit -and
        $operatorDenied.exitCode -eq 77 -and [string]$operatorDeniedJson.status -ceq 'DENIED' -and $null -eq $operatorDeniedJson.payload -and [string]$operatorDeniedJson.network -ceq 'NONE' -and $null -ne $operatorDeniedJson.audit -and
        $operatorMock.exitCode -eq 0 -and [string]$operatorMockJson.status -ceq 'PASS' -and [string]$operatorMockJson.capability -ceq 'TASK' -and [string]$operatorMockJson.network -ceq 'NONE' -and $null -ne $operatorMockJson.payload -and ((@($operatorMockJson.payload.PSObject.Properties.Name)) -join ',') -ceq 'schemaVersion,status,provider,traceId,outcome,network,writes,result' -and [int]$operatorMockJson.payload.schemaVersion -eq 1 -and [string]$operatorMockJson.payload.status -ceq 'PASS' -and [string]$operatorMockJson.payload.provider -ceq 'mock-v1' -and [string]$operatorMockJson.payload.traceId -ceq '00112233445566778899AABBCCDDEEFF' -and [string]$operatorMockJson.payload.outcome -ceq 'PASS' -and [string]$operatorMockJson.payload.network -ceq 'NONE' -and [string]$operatorMockJson.payload.writes -ceq 'NONE' -and $null -ne $operatorMockJson.payload.result -and
        $operatorHealth.exitCode -eq 0 -and $operatorHealth.stderrBytes.Length -eq 0 -and $operatorHealth.stdoutBytes.Length -eq 927 -and $operatorHealth.stdoutSha256 -ceq '8E7B9415938850843E23E933A82B6FCB07244AD8814706BB998C4C11D9D4D91A' -and [string]$operatorHealthJson.status -ceq 'PASS' -and [string]$operatorHealthJson.capability -ceq 'HEALTH' -and [string]$operatorHealthJson.network -ceq 'NONE' -and [string]$operatorHealthJson.writes -ceq 'NONE' -and [string]$operatorHealthJson.authority -ceq 'OBSERVATIONAL_NOT_AUTHORITY' -and [string]$operatorHealthJson.requestSha256 -ceq '0E10A550738D8618EFB0C845E4E1C6357F11C64258BE78993E64791DC0456990' -and [string]$operatorHealthJson.routeSha256 -ceq '613DCE7408D3B68CD51A2E1C01A51A0BA20E20A84B2BE20438319D102446B429' -and [string]$operatorHealthJson.payloadSha256 -ceq '9E3EFCDB24B49E2C27254772DFF72DEF88968ECF0A76C60D4E6724AE90E2E181' -and ((@($operatorHealthJson.payload.PSObject.Properties.Name)) -join ',') -ceq 'schema,status,observationScope,operatorSchema,capabilities,guardPosture,network,reads,writes,providerConstruction,authority' -and [string]$operatorHealthJson.payload.schema -ceq 'EAIRA_OPERATOR_HEALTH_V1' -and [string]$operatorHealthJson.payload.status -ceq 'POLICY_READY' -and [string]$operatorHealthJson.payload.observationScope -ceq 'COMPILED_CONTRACT_ONLY' -and ((@($operatorHealthJson.payload.capabilities) -join ',') -ceq 'TASK,KNOWLEDGE,PROJECT_QA,HEALTH') -and
        $operatorPreflight.exitCode -eq 0 -and $operatorPreflight.stderrBytes.Length -eq 0 -and $operatorPreflight.stdoutBytes.Length -eq 1031 -and $operatorPreflight.stdoutSha256 -ceq 'F6A302DFD0B183F774EB284646E6A349684D7A04069BB48993752A55FDDBF363' -and [string]$operatorPreflightJson.status -ceq 'PASS' -and [string]$operatorPreflightJson.capability -ceq 'PREFLIGHT' -and [string]$operatorPreflightJson.network -ceq 'NONE' -and [string]$operatorPreflightJson.writes -ceq 'NONE' -and [string]$operatorPreflightJson.authority -ceq 'EXPLANATORY_NOT_AUTHORITY' -and [string]$operatorPreflightJson.requestSha256 -ceq '0BBACB758B1EA183338134C3D5CAAEDABA56793026E506214651BD0EA5FF1CC8' -and [string]$operatorPreflightJson.routeSha256 -ceq '1261E4E6931D12FD0C7AD5451003D1ED9C099D47549C474451D7FED5C858A5BC' -and [string]$operatorPreflightJson.payloadSha256 -ceq '8D7997CAE44F3D9AC2B244DD8B24B36A9BF2862E53A940B2F407178A24700123' -and [string]$operatorPreflightJson.audit.chainSha256 -ceq '612EEE7C3DBC3C74D9756FF3F864904B1F0096056514228A73575CBE8234D979' -and [Text.Encoding]::UTF8.GetByteCount(($operatorPreflightJson.payload | ConvertTo-Json -Compress -Depth 10)) -eq 469 -and ((@($operatorPreflightJson.payload.PSObject.Properties.Name)) -join ',') -ceq 'schema,status,observationScope,routeId,capability,guardRequirement,guardEvaluation,sourceClass,providerPolicy,routeNetwork,preflightNetwork,writes,routeAuthority,authority' -and
        $operatorDryRun.exitCode -eq 0 -and $operatorDryRun.stderrBytes.Length -eq 0 -and $operatorDryRun.stdoutBytes.Length -eq 997 -and $operatorDryRun.stdoutSha256 -ceq '05E088A8C1A0884E44A304615992C5F8F5C3674615FBB02F8B1C030DAD3D32F0' -and [string]$operatorDryRunJson.status -ceq 'PASS' -and [string]$operatorDryRunJson.capability -ceq 'DRY_RUN_PLAN' -and [string]$operatorDryRunJson.network -ceq 'NONE' -and [string]$operatorDryRunJson.writes -ceq 'NONE' -and [string]$operatorDryRunJson.authority -ceq 'PLAN_NOT_AUTHORITY' -and [string]$operatorDryRunJson.requestSha256 -ceq '00D0582B2FA2F71FC9573D6B28499DE07BE9286DFDA623BDF084847D15C292CA' -and [string]$operatorDryRunJson.routeSha256 -ceq '2F1F782832899E3D526F75D96739D1ECB76C88EBEBABC7AB6F4DD77CC649612D' -and [string]$operatorDryRunJson.payloadSha256 -ceq '487EB55F010976DA24CBF979DCC036AF41CDF69F3B86961B1C37E21BC94BE08C'
    $operatorChannelProfileMatch = $retainedOperatorDiscovery -or (($retainedOperatorChannels|ConvertTo-Json -Depth 5 -Compress) -ceq ($profile.localOperator.channelMatrix|ConvertTo-Json -Depth 5 -Compress))
    $dryRunChannelProfileMatch = $dryRunDiscovery -or (($dryRunChannelEvidence|ConvertTo-Json -Depth 5 -Compress) -ceq ($profile.localOperator.dryRunChannel|ConvertTo-Json -Depth 5 -Compress))
    if (-not $operatorChannelSemanticPass -or -not $operatorChannelProfileMatch -or -not $dryRunChannelProfileMatch) { throw 'Local Operator CLI channel matrix failed.' }
    $healthControlFlowEvidence = [ordered]@{ dispatchMethod=[string]$localOperatorHealthIl.dispatchMethod; allowedRoot=[string]$localOperatorHealthIl.allowedRoot; dispatchRows=@($localOperatorHealthIl.dispatchRows); methodDetails=@($localOperatorHealthIl.methodDetails); methodRows=@($localOperatorHealthIl.methodRows); callRows=@($localOperatorHealthIl.callRows); dispatchIl=$localOperatorHealthIl.dispatchIl; allowedClosureMethods=$localOperatorHealthIl.allowedClosureMethods; allowedClosureCalls=$localOperatorHealthIl.allowedClosureCalls; forbiddenMatchCount=[int]$localOperatorHealthIl.forbiddenMatchCount; factoryReferenceCount=[int]$localOperatorHealthIl.factoryReferenceCount; providerReferenceCount=[int]$localOperatorHealthIl.providerReferenceCount; networkReferenceCount=[int]$localOperatorHealthIl.networkReferenceCount; connectAttemptDelta=[int]$localOperatorHarnessJson.healthConnectAttemptMonitor.healthDelta; profileMatch=$healthControlFlowProfileMatch; discoveryBypass=[bool]$retainedOperatorDiscovery }
    $preflightControlFlowEvidence = [ordered]@{ dispatchMethod=[string]$localOperatorPreflightIl.dispatchMethod; allowedRoot=[string]$localOperatorPreflightIl.allowedRoot; build8=[string]$localOperatorPreflightIl.build8; build9=[string]$localOperatorPreflightIl.build9; dispatchRows=@($localOperatorPreflightIl.dispatchRows); methodDetails=@($localOperatorPreflightIl.methodDetails); methodRows=@($localOperatorPreflightIl.methodRows); callRows=@($localOperatorPreflightIl.callRows); tokenRows=@($localOperatorPreflightIl.tokenRows); methodManifest=$localOperatorPreflightIl.methodManifest; callManifest=$localOperatorPreflightIl.callManifest; tokenManifest=$localOperatorPreflightIl.tokenManifest; closureManifest=$localOperatorPreflightIl.closureManifest; forbiddenMatchCount=[int]$localOperatorPreflightIl.forbiddenMatchCount; profileMatch=$preflightControlFlowProfileMatch; discoveryBypass=[bool]$retainedOperatorDiscovery }
    $dryRunControlFlowEvidence = [ordered]@{ dispatchMethod=[string]$localOperatorDryRunIl.dispatchMethod; allowedRoot=[string]$localOperatorDryRunIl.allowedRoot; build8=[string]$localOperatorDryRunIl.build8; build9=[string]$localOperatorDryRunIl.build9; dispatchRows=@($localOperatorDryRunIl.dispatchRows); methodDetails=@($localOperatorDryRunIl.methodDetails); methodRows=@($localOperatorDryRunIl.methodRows); callRows=@($localOperatorDryRunIl.callRows); closureCallRows=@($localOperatorDryRunIl.closureCallRows); tokenRows=@($localOperatorDryRunIl.tokenRows); methodManifest=$localOperatorDryRunIl.methodManifest; callManifest=$localOperatorDryRunIl.callManifest; closureCallManifest=$localOperatorDryRunIl.closureCallManifest; tokenManifest=$localOperatorDryRunIl.tokenManifest; closureManifest=$localOperatorDryRunIl.closureManifest; forbiddenMatchCount=[int]$localOperatorDryRunIl.forbiddenMatchCount; factoryReferenceCount=0; providerReferenceCount=0; networkReferenceCount=0; connectAttemptDelta=[int]$localOperatorHarnessJson.dryRunCounters.connectAttemptDelta; profileMatch=$dryRunControlFlowProfileMatch; discoveryBypass=[bool]$dryRunDiscovery }
    $healthMonitorEvidence = [ordered]@{ positiveControlBefore=[int]$localOperatorHarnessJson.healthConnectAttemptMonitor.positiveControlBefore; positiveControlAfter=[int]$localOperatorHarnessJson.healthConnectAttemptMonitor.positiveControlAfter; positiveControlDelta=[int]$localOperatorHarnessJson.healthConnectAttemptMonitor.positiveControlDelta; healthBefore=[int]$localOperatorHarnessJson.healthConnectAttemptMonitor.healthBefore; healthAfter=[int]$localOperatorHarnessJson.healthConnectAttemptMonitor.healthAfter; healthDelta=[int]$localOperatorHarnessJson.healthConnectAttemptMonitor.healthDelta; denialBefore=[int]$localOperatorHarnessJson.healthConnectAttemptMonitor.denialBefore; denialAfter=[int]$localOperatorHarnessJson.healthConnectAttemptMonitor.denialAfter; denialDelta=[int]$localOperatorHarnessJson.healthConnectAttemptMonitor.denialDelta; instrumentedEntryPoints=@($localOperatorHealthIl.instrumentedEntryPoints); instrumentationRows=@($localOperatorHealthIl.instrumentationRows); instrumentation=$localOperatorHealthIl.instrumentation; instrumentationIlProfileMatch=$healthInstrumentationProfileMatch }
    $localOperatorEvidence = [ordered]@{ file=(Get-Item -LiteralPath $localOperatorOutputPath).Name; bytes=(Get-Item -LiteralPath $localOperatorOutputPath).Length; sha256=Get-Sha256 -LiteralPath $localOperatorOutputPath; channels=$operatorChannels; channelMatrixPass=$true; channelMatrixProfileMatch=if($retainedOperatorDiscovery){$null}else{$true}; channelMatrixDiscoveryBypass=[bool]$retainedOperatorDiscovery; dryRunChannel=$dryRunChannelEvidence; dryRunChannelProfileMatch=if($dryRunDiscovery){$null}else{$true}; dryRunChannelDiscoveryBypass=[bool]$dryRunDiscovery; preflightGoldenVectors=$preflightGoldenVectorEvidence; dryRunGoldenVectors=$dryRunGoldenVectorEvidence; dryRunDenialVectors=$dryRunDenialVectorEvidence; dryRunCounters=$localOperatorHarnessJson.dryRunCounters; metadataInventory=$localOperatorMetadata; loopbackMetadataAllowlist=$localOperatorLoopbackMetadata; moduleRefs=@($localOperatorPInvokeMetadata.modules); pInvokeRows=@($localOperatorPInvokeMetadata.rows); approvedNativeCallerIl=@($localOperatorCallerEvidence.approvedCallerIl); normalizedNativeInventory=$localOperatorNativeSemantic; healthControlFlow=$healthControlFlowEvidence; preflightControlFlow=$preflightControlFlowEvidence; dryRunControlFlow=$dryRunControlFlowEvidence; healthConnectAttemptMonitor=$healthMonitorEvidence; offlineTestsPass=$true }

    if ($buildIndex -eq 0) {
        $operatorSpecimenRoot = Join-Path $buildRoot 'local-operator-negative-specimens'; New-Item -ItemType Directory -Path $operatorSpecimenRoot | Out-Null
        $operatorNegativeCases = [ordered]@{
            CHILD_PROCESS = 'namespace EAIRA.AgentServices.Functional { internal static class BadChild { internal static object Run() { return new System.Diagnostics.ProcessStartInfo("cmd.exe"); } } }'
            WRITE_REFERENCE = 'namespace EAIRA.AgentServices.Functional { internal static class BadWrite { internal static void Run() { System.IO.File.WriteAllText("x","y"); } } }'
            IPC_REFERENCE = 'namespace EAIRA.AgentServices.Functional { internal static class BadIpc { internal static object Run() { return new System.Net.Sockets.TcpClient(); } } }'
            DYNAMIC_LOAD = 'namespace EAIRA.AgentServices.Functional { internal static class BadDynamic { internal static object Run() { return System.Activator.CreateInstance(typeof(System.Text.StringBuilder)); } } }'
            RAW_OUTPUT = 'namespace EAIRA.AgentServices.Functional { internal static class BadRaw { internal static string Run(string rawProviderResponse) { return rawProviderResponse; } } }'
            UNAPPROVED_PROVIDER_METADATA = 'namespace EAIRA.AgentServices.Functional { internal static class BadProvider { internal static object Run() { return new System.Uri("https://example.com"); } } }'
        }
        foreach ($entry in $operatorNegativeCases.GetEnumerator()) { $localOperatorNegativeSpecimenEvidence += Invoke-LocalOperatorNegativeSpecimen -Name ([string]$entry.Key) -CompilerPath $resolvedCompiler -CompilerArguments $localOperatorArguments -SourceText ([string]$entry.Value) -SpecimenRoot $operatorSpecimenRoot -BaselineMetadata $localOperatorMetadata }
        $healthNegativeCases = @(
            @('HEALTH_FILESYSTEM_ENVIRONMENT_PROBE','HEALTH_SOURCE_REPLACEMENT_1','FORBIDDEN_HEALTH_CLOSURE_MEMBER'),
            @('HEALTH_DIRECT_SOCKET_CONSTRUCTION','HEALTH_SOURCE_REPLACEMENT_1','FORBIDDEN_HEALTH_CLOSURE_MEMBER'),
            @('HEALTH_ADAPTER_FACTORY_INVOCATION','HEALTH_SOURCE_REPLACEMENT_1','FORBIDDEN_HEALTH_CLOSURE_MEMBER'),
            @('HEALTH_RUNTIME_OBSERVATION','HEALTH_SOURCE_REPLACEMENT_1','FORBIDDEN_HEALTH_CLOSURE_MEMBER'),
            @('HEALTH_ADDITIONAL_PAYLOAD_MEMBER','HEALTH_SOURCE_REPLACEMENT_1','HEALTH_GOLDEN_MISMATCH'),
            @('HEALTH_OBSERVATION_AUTHORITY_MUTATION','HEALTH_SOURCE_REPLACEMENT_2_ORDERED','HEALTH_GOLDEN_MISMATCH'),
            @('HEALTH_PROVIDER_MODEL_ROOT_ACCEPTANCE','HEALTH_SOURCE_REPLACEMENT_1','HEALTH_ALTERNATE_GRAMMAR_ACCEPTED')
        )
        foreach ($entry in $healthNegativeCases) {
            $localOperatorNegativeSpecimenEvidence += Invoke-LocalOperatorHealthNegativeSpecimen -Id $entry[0] -MutationKind $entry[1] -ExpectedRule $entry[2] -CompilerPath $resolvedCompiler -CompilerArguments $localOperatorArguments -CandidateSourcePath $localOperatorSourcePath -CandidateSourceText $localOperatorSourceText -SpecimenRoot $operatorSpecimenRoot -ProjectContextPolicy $profile.projectContext -LoopbackPolicy $profile.localOperator.loopbackMetadataAllowlist
        }
        $preflightNegativeCases = @(
            @('PREFLIGHT_FILESYSTEM_CLOSURE','PREFLIGHT_FILESYSTEM_REFERENCE'),
            @('PREFLIGHT_ENVIRONMENT_CLOSURE','PREFLIGHT_ENVIRONMENT_REFERENCE'),
            @('PREFLIGHT_PROVIDER_FACTORY_CLOSURE','PREFLIGHT_FACTORY_OR_PROVIDER_REFERENCE'),
            @('PREFLIGHT_NETWORK_CLOSURE','PREFLIGHT_NETWORK_REFERENCE'),
            @('PREFLIGHT_ROUTE_EXECUTION_CLOSURE','PREFLIGHT_ROUTE_EXECUTION_REFERENCE'),
            @('PREFLIGHT_LOOKUP_BEFORE_GUARD','PREFLIGHT_LOOKUP_BEFORE_GUARD'),
            @('PREFLIGHT_PAYLOAD_BEFORE_GUARD','PREFLIGHT_PAYLOAD_BEFORE_GUARD'),
            @('PREFLIGHT_AUTHORITY_COLLAPSE','PREFLIGHT_GOLDEN_VECTOR_MISMATCH'),
            @('PREFLIGHT_EIGHTH_ROUTE','PREFLIGHT_ROUTE_SET_MISMATCH'),
            @('PREFLIGHT_DYNAMIC_LOAD_CLOSURE','PREFLIGHT_DYNAMIC_LOAD_REFERENCE'),
            @('PREFLIGHT_THREAD_SLEEP_CLOSURE','PREFLIGHT_THREAD_SLEEP_REFERENCE'),
            @('PREFLIGHT_TASK_DELAY_CLOSURE','PREFLIGHT_TASK_DELAY_REFERENCE'),
            @('PREFLIGHT_THREADING_TIMER_CLOSURE','PREFLIGHT_TIMER_REFERENCE'),
            @('PREFLIGHT_TIMERS_TIMER_CLOSURE','PREFLIGHT_TIMER_REFERENCE'),
            @('PREFLIGHT_CRYPTO_RNG_CLOSURE','PREFLIGHT_CRYPTO_RNG_REFERENCE')
        )
        foreach ($entry in $preflightNegativeCases) {
            $row = Invoke-LocalOperatorPreflightNegativeSpecimen -Id $entry[0] -ExpectedRule $entry[1] -CompilerPath $resolvedCompiler -CompilerArguments $localOperatorArguments -CandidateSourcePath $localOperatorSourcePath -CandidateSourceText $localOperatorSourceText -SpecimenRoot $operatorSpecimenRoot
            $preflightNegativeSpecimenEvidence += $row
            $localOperatorNegativeSpecimenEvidence += $row
        }
        $dryRunNegativeCases = @(
            @('DRY_RUN_FILESYSTEM_CLOSURE','DRY_RUN_FILESYSTEM_REFERENCE'),
            @('DRY_RUN_ENVIRONMENT_CLOSURE','DRY_RUN_ENVIRONMENT_REFERENCE'),
            @('DRY_RUN_PROVIDER_FACTORY_CLOSURE','DRY_RUN_FACTORY_OR_PROVIDER_REFERENCE'),
            @('DRY_RUN_NETWORK_CLOSURE','DRY_RUN_NETWORK_REFERENCE'),
            @('DRY_RUN_ROUTE_EXECUTION_CLOSURE','DRY_RUN_ROUTE_EXECUTION_REFERENCE'),
            @('DRY_RUN_LOOKUP_BEFORE_GUARD','DRY_RUN_LOOKUP_BEFORE_GUARD'),
            @('DRY_RUN_PAYLOAD_BEFORE_GUARD','DRY_RUN_PAYLOAD_BEFORE_GUARD'),
            @('DRY_RUN_EXECUTION_GUARD_REUSE','DRY_RUN_EXECUTION_GUARD_REUSE'),
            @('DRY_RUN_AUTHORITY_COLLAPSE','DRY_RUN_AUTHORITY_COLLAPSE'),
            @('DRY_RUN_POLICY_TABLE_DUPLICATION','DRY_RUN_POLICY_TABLE_DUPLICATION'),
            @('DRY_RUN_RAW_INPUT_OUTPUT','DRY_RUN_RAW_INPUT_OUTPUT'),
            @('DRY_RUN_DESCRIBED_POLICY_DIGEST','DRY_RUN_DESCRIBED_POLICY_DIGEST'),
            @('DRY_RUN_CHILD_PROCESS','DRY_RUN_CHILD_PROCESS_REFERENCE'),
            @('DRY_RUN_PERSISTENCE','DRY_RUN_PERSISTENCE_REFERENCE'),
            @('DRY_RUN_EIGHTH_ROUTE','DRY_RUN_ROUTE_SET_MISMATCH')
        )
        foreach($entry in $dryRunNegativeCases){$row=Invoke-LocalOperatorDryRunNegativeSpecimen -Id $entry[0] -ExpectedRule $entry[1] -CompilerPath $resolvedCompiler -CompilerArguments $localOperatorArguments -CandidateSourcePath $localOperatorSourcePath -CandidateSourceText $localOperatorSourceText -SpecimenRoot $operatorSpecimenRoot;$dryRunNegativeSpecimenEvidence+=$row;$localOperatorNegativeSpecimenEvidence+=$row}
    }

    $allBuildEvidence += [ordered]@{
        build = if ($buildIndex -eq 0) { 'A' } else { 'B' }
        functionalHarness = $harnessEvidence
        taskIntakeHarness = $taskIntakeHarnessEvidence
        projectContextHarness = $projectContextHarnessEvidence
        projectKnowledgeHarness = $projectKnowledgeHarnessEvidence
        projectKnowledgeCli = $projectKnowledgeEvidence
        projectQaHarness = $projectQaHarnessEvidence
        projectQaCli = $projectQaEvidence
        localOperatorHarness = $localOperatorHarnessEvidence
        localOperatorCli = $localOperatorEvidence
        localProviderHarness = $localProviderHarnessEvidence
        transportPolicyHarness = $transportPolicyHarnessEvidence
        taskIntakeCli = $taskIntakeEvidence
        outputs = $roleEvidence
    }
}

$reproducible = $true
if ($allBuildEvidence[0].functionalHarness.file -ne $allBuildEvidence[1].functionalHarness.file -or
    $allBuildEvidence[0].functionalHarness.bytes -ne $allBuildEvidence[1].functionalHarness.bytes -or
    $allBuildEvidence[0].functionalHarness.sha256 -ne $allBuildEvidence[1].functionalHarness.sha256) {
    $reproducible = $false
}
if ($allBuildEvidence[0].taskIntakeHarness.sha256 -ne $allBuildEvidence[1].taskIntakeHarness.sha256 -or
    $allBuildEvidence[0].projectContextHarness.sha256 -ne $allBuildEvidence[1].projectContextHarness.sha256 -or
    $allBuildEvidence[0].localProviderHarness.sha256 -ne $allBuildEvidence[1].localProviderHarness.sha256 -or
    $allBuildEvidence[0].transportPolicyHarness.sha256 -ne $allBuildEvidence[1].transportPolicyHarness.sha256 -or
    $allBuildEvidence[0].taskIntakeCli.sha256 -ne $allBuildEvidence[1].taskIntakeCli.sha256 -or
    $allBuildEvidence[0].projectKnowledgeHarness.bytes -ne $allBuildEvidence[1].projectKnowledgeHarness.bytes -or
    $allBuildEvidence[0].projectKnowledgeHarness.sha256 -ne $allBuildEvidence[1].projectKnowledgeHarness.sha256 -or
    $allBuildEvidence[0].projectKnowledgeCli.bytes -ne $allBuildEvidence[1].projectKnowledgeCli.bytes -or
    $allBuildEvidence[0].projectKnowledgeCli.sha256 -ne $allBuildEvidence[1].projectKnowledgeCli.sha256) {
    $reproducible = $false
}
if ($allBuildEvidence[0].projectQaHarness.bytes -ne $allBuildEvidence[1].projectQaHarness.bytes -or
    $allBuildEvidence[0].projectQaHarness.sha256 -ne $allBuildEvidence[1].projectQaHarness.sha256 -or
    $allBuildEvidence[0].projectQaCli.bytes -ne $allBuildEvidence[1].projectQaCli.bytes -or
    $allBuildEvidence[0].projectQaCli.sha256 -ne $allBuildEvidence[1].projectQaCli.sha256) {
    $reproducible = $false
}
if ($allBuildEvidence[0].localOperatorHarness.bytes -ne $allBuildEvidence[1].localOperatorHarness.bytes -or
    $allBuildEvidence[0].localOperatorHarness.sha256 -ne $allBuildEvidence[1].localOperatorHarness.sha256 -or
    $allBuildEvidence[0].localOperatorCli.bytes -ne $allBuildEvidence[1].localOperatorCli.bytes -or
    $allBuildEvidence[0].localOperatorCli.sha256 -ne $allBuildEvidence[1].localOperatorCli.sha256) {
    $reproducible = $false
}
for ($index = 0; $index -lt @($profile.roles).Count; $index++) {
    $a = $allBuildEvidence[0].outputs[$index]
    $b = $allBuildEvidence[1].outputs[$index]
    if ($a.file -ne $b.file -or $a.bytes -ne $b.bytes -or $a.sha256 -ne $b.sha256) { $reproducible = $false }
}

$seamNegativeSpecimensPass = $seamNegativeSpecimenEvidence.Count -eq 31 -and @($seamNegativeSpecimenEvidence | Where-Object { -not $_.verifierRejected -or $_.compileExitCode -ne 0 }).Count -eq 0
$outputIsolationNegativeSpecimens = @($seamNegativeSpecimenEvidence | Where-Object { $_.name -in @('DIRECTORY_ENUMERATION_OUTPUT','RAW_CONTENT_OUTPUT','PER_FILE_DIGEST_OUTPUT') })
$outputIsolationNegativeSpecimensPass = $outputIsolationNegativeSpecimens.Count -eq 3 -and @($outputIsolationNegativeSpecimens | Where-Object { -not $_.verifierRejected -or $_.compileExitCode -ne 0 }).Count -eq 0
$nativeNegativeSpecimensPass = $nativeNegativeSpecimenEvidence.Count -eq 17 -and @($nativeNegativeSpecimenEvidence | Where-Object { -not $_.verifierRejected -or $_.compileExitCode -ne 0 }).Count -eq 0
$expectedKnowledgeSpecimenNames = @(
    'EXTRA_PATH_LITERAL','ARBITRARY_PATH_METHOD','OUTPUT_SCHEMA_CHANGE','RAW_CONTENT_OUTPUT','RAW_PATH_OUTPUT',
    'RAW_QUERY_OUTPUT','WRONG_DIGEST_FRAMING','ALTERNATE_FACTORY','ALTERNATE_CONSTRUCTOR','ALTERNATE_CALLER',
    'REFLECTION_DISPATCH','DYNAMIC_DISPATCH','WRITE_REFERENCE','NETWORK_REFERENCE','DIRECTORY_ENUMERATION',
    'DUPLICATE_PINVOKE','MOVED_PINVOKE_VISIBILITY'
)
$actualKnowledgeSpecimenNames = @($knowledgeNegativeSpecimenEvidence | ForEach-Object { [string]$_.name })
$knowledgeNegativeSpecimensPass = $knowledgeNegativeSpecimenEvidence.Count -eq $expectedKnowledgeSpecimenNames.Count -and
    (($actualKnowledgeSpecimenNames -join "`n") -ceq ($expectedKnowledgeSpecimenNames -join "`n")) -and
    @($knowledgeNegativeSpecimenEvidence | Where-Object { -not $_.verifierRejected -or $_.compileExitCode -ne 0 }).Count -eq 0 -and
    ($ProjectKnowledgeDiscovery -or ((@($profile.projectKnowledge.specimenNames | ForEach-Object { [string]$_ }) -join "`n") -ceq
                                    ($expectedKnowledgeSpecimenNames -join "`n")))
$expectedQaSpecimenNames = @(
    'QA_EXTRA_SOURCE_PATH','QA_DIRECTORY_ENUMERATION','QA_ARBITRARY_FILE_OPEN','QA_SECOND_PLATFORM','QA_SECOND_ROOT_SESSION',
    'QA_EARLY_PROVIDER_CONSTRUCTION','QA_SECOND_CHAT','QA_RETRY_LOOP','QA_FALLBACK_PROVIDER','QA_EXTERNAL_ENDPOINT',
    'QA_CALLER_MODEL','QA_WIDENED_PROMPT_BUDGET','QA_WIDENED_BODY_BUDGET','QA_WIDENED_ANSWER_BUDGET','QA_WIDENED_OUTPUT_BUDGET',
    'QA_RAW_PROJECTION_OUTPUT','QA_RAW_PROMPT_OUTPUT','QA_PROVIDER_BODY_OUTPUT','QA_ABSOLUTE_ROOT_OUTPUT','QA_MODEL_CITATION_METADATA',
    'QA_AUTHORITY_LABEL_MUTATION','QA_REORDERED_VALIDATION','QA_ALTERNATE_JSON_PARSER','QA_UNBOUNDED_READ','QA_LOGGING_SINK',
    'QA_PERSISTENCE_REFERENCE','QA_PROCESS_OR_SHELL_REFERENCE','QA_REFLECTION_OR_DYNAMIC_CODE','QA_EXTRA_PINVOKE','QA_MOVED_PINVOKE_VISIBILITY',
    'QA_EXTRA_CONSTRUCTOR_OR_FACTORY','QA_EXTRA_APPROVED_CALLER','QA_EXTRA_MESSAGE','QA_WIDENED_CITATION_BUDGET','QA_RAW_PROVIDER_RESPONSE_OUTPUT','QA_WEAKENED_STRUCTURED_OUTPUT_SCHEMA'
)
$actualQaSpecimenNames = @($qaNegativeSpecimenEvidence | ForEach-Object { [string]$_.name })
$qaNegativeSpecimensPass = $qaNegativeSpecimenEvidence.Count -eq $expectedQaSpecimenNames.Count -and
    (($actualQaSpecimenNames -join "`n") -ceq ($expectedQaSpecimenNames -join "`n")) -and
    @($qaNegativeSpecimenEvidence | Where-Object { -not $_.verifierRejected -or $_.compileExitCode -ne 0 }).Count -eq 0 -and
    ($ProjectQaDiscovery -or ((@($profile.projectQa.specimenNames | ForEach-Object { [string]$_ }) -join "`n") -ceq ($expectedQaSpecimenNames -join "`n")))
$expectedPreflightNegativeNames = @('PREFLIGHT_FILESYSTEM_CLOSURE','PREFLIGHT_ENVIRONMENT_CLOSURE','PREFLIGHT_PROVIDER_FACTORY_CLOSURE','PREFLIGHT_NETWORK_CLOSURE','PREFLIGHT_ROUTE_EXECUTION_CLOSURE','PREFLIGHT_LOOKUP_BEFORE_GUARD','PREFLIGHT_PAYLOAD_BEFORE_GUARD','PREFLIGHT_AUTHORITY_COLLAPSE','PREFLIGHT_EIGHTH_ROUTE','PREFLIGHT_DYNAMIC_LOAD_CLOSURE','PREFLIGHT_THREAD_SLEEP_CLOSURE','PREFLIGHT_TASK_DELAY_CLOSURE','PREFLIGHT_THREADING_TIMER_CLOSURE','PREFLIGHT_TIMERS_TIMER_CLOSURE','PREFLIGHT_CRYPTO_RNG_CLOSURE')
$preflightSpecimenFrameText = 'EAIRA_M5_SLICE3_PREFLIGHT_SPECIMEN_NAMES_V1' + [char]0
foreach ($name in $expectedPreflightNegativeNames) { $preflightSpecimenFrameText += $name.Length.ToString([Globalization.CultureInfo]::InvariantCulture) + ':' + $name }
$preflightSpecimenFrameBytes = [Text.Encoding]::UTF8.GetBytes($preflightSpecimenFrameText)
$preflightSpecimenFrameSha256 = Get-ByteArraySha256 -Bytes $preflightSpecimenFrameBytes
$actualPreflightNegativeNames = @($preflightNegativeSpecimenEvidence | ForEach-Object { [string]$_.id })
$preflightNegativeSpecimensPass = $preflightNegativeSpecimenEvidence.Count -eq 15 -and (($actualPreflightNegativeNames -join "`n") -ceq ($expectedPreflightNegativeNames -join "`n")) -and $preflightSpecimenFrameBytes.Length -eq 526 -and $preflightSpecimenFrameSha256 -ceq '47B0424EF00EDE857C4C6EFA0A4428737A6F7A188FB23D4E816A5AB995B3D7D3' -and @($preflightNegativeSpecimenEvidence | Where-Object { -not $_.rejected -or $_.compileExitCode -ne 0 }).Count -eq 0 -and ($retainedOperatorDiscovery -or (((@($profile.localOperator.preflightSpecimens.names | ForEach-Object { [string]$_ }) -join "`n") -ceq ($expectedPreflightNegativeNames -join "`n")) -and [int]$profile.localOperator.preflightSpecimens.framedBytes -eq 526 -and [string]$profile.localOperator.preflightSpecimens.sha256 -ceq $preflightSpecimenFrameSha256))
$expectedDryRunNegativeNames=@('DRY_RUN_FILESYSTEM_CLOSURE','DRY_RUN_ENVIRONMENT_CLOSURE','DRY_RUN_PROVIDER_FACTORY_CLOSURE','DRY_RUN_NETWORK_CLOSURE','DRY_RUN_ROUTE_EXECUTION_CLOSURE','DRY_RUN_LOOKUP_BEFORE_GUARD','DRY_RUN_PAYLOAD_BEFORE_GUARD','DRY_RUN_EXECUTION_GUARD_REUSE','DRY_RUN_AUTHORITY_COLLAPSE','DRY_RUN_POLICY_TABLE_DUPLICATION','DRY_RUN_RAW_INPUT_OUTPUT','DRY_RUN_DESCRIBED_POLICY_DIGEST','DRY_RUN_CHILD_PROCESS','DRY_RUN_PERSISTENCE','DRY_RUN_EIGHTH_ROUTE')
$dryRunSpecimenFrameText='EAIRA_M5_SLICE4_DRY_RUN_SPECIMEN_NAMES_V1'+[char]0;foreach($name in $expectedDryRunNegativeNames){$dryRunSpecimenFrameText+=$name.Length.ToString([Globalization.CultureInfo]::InvariantCulture)+':'+$name};$dryRunSpecimenFrameBytes=[Text.Encoding]::UTF8.GetBytes($dryRunSpecimenFrameText);$dryRunSpecimenFrameSha256=Get-ByteArraySha256 -Bytes $dryRunSpecimenFrameBytes
$actualDryRunNegativeNames=@($dryRunNegativeSpecimenEvidence|ForEach-Object{[string]$_.id});$dryRunNegativeSpecimensPass=$dryRunNegativeSpecimenEvidence.Count-eq15-and(($actualDryRunNegativeNames-join"`n")-ceq($expectedDryRunNegativeNames-join"`n"))-and$dryRunSpecimenFrameBytes.Length-eq483-and$dryRunSpecimenFrameSha256-ceq'FA2FE176E407F2C499ACA744C4B0EAC0DEB2E98CF4F9BA3A9321D8A10F7694D6'-and@($dryRunNegativeSpecimenEvidence|Where-Object{-not$_.pass-or-not$_.rejected-or$_.compileExitCode-ne0-or-not$_.validPe}).Count-eq0-and($dryRunDiscovery-or(((@($profile.localOperator.dryRunSpecimens.names|ForEach-Object{[string]$_})-join"`n")-ceq($expectedDryRunNegativeNames-join"`n"))-and[int]$profile.localOperator.dryRunSpecimens.framedBytes-eq483-and[string]$profile.localOperator.dryRunSpecimens.sha256-ceq$dryRunSpecimenFrameSha256))
$expectedOperatorNegativeNames = @('CHILD_PROCESS','WRITE_REFERENCE','IPC_REFERENCE','DYNAMIC_LOAD','RAW_OUTPUT','UNAPPROVED_PROVIDER_METADATA','HEALTH_FILESYSTEM_ENVIRONMENT_PROBE','HEALTH_DIRECT_SOCKET_CONSTRUCTION','HEALTH_ADAPTER_FACTORY_INVOCATION','HEALTH_RUNTIME_OBSERVATION','HEALTH_ADDITIONAL_PAYLOAD_MEMBER','HEALTH_OBSERVATION_AUTHORITY_MUTATION','HEALTH_PROVIDER_MODEL_ROOT_ACCEPTANCE') + $expectedPreflightNegativeNames + $expectedDryRunNegativeNames
$actualOperatorNegativeNames = @($localOperatorNegativeSpecimenEvidence | ForEach-Object { [string]$_.id })
$localOperatorNegativeSpecimensPass = $preflightNegativeSpecimensPass -and $dryRunNegativeSpecimensPass -and $localOperatorNegativeSpecimenEvidence.Count -eq 43 -and
    (($actualOperatorNegativeNames -join "`n") -ceq ($expectedOperatorNegativeNames -join "`n")) -and
    @($localOperatorNegativeSpecimenEvidence | Where-Object { -not $_.rejected -or $_.compileExitCode -ne 0 }).Count -eq 0
$expectedRetainedOperatorNegativeNames = @($expectedOperatorNegativeNames | Where-Object { $_ -notlike 'DRY_RUN_*' })
$retainedOperatorNegativeEvidence = @($localOperatorNegativeSpecimenEvidence | Where-Object { [string]$_.id -notlike 'DRY_RUN_*' })
$retainedLocalOperatorNegativeSpecimensPass = $preflightNegativeSpecimensPass -and $retainedOperatorNegativeEvidence.Count -eq 28 -and
    ((@($retainedOperatorNegativeEvidence | ForEach-Object { [string]$_.id }) -join "`n") -ceq ($expectedRetainedOperatorNegativeNames -join "`n")) -and
    @($retainedOperatorNegativeEvidence | Where-Object { -not $_.rejected -or $_.compileExitCode -ne 0 }).Count -eq 0
$expectedQaRequestCounters = [ordered]@{ tagsCalls=2; chatCalls=1; preflightDigestValidated=$true; postflightDigestValidated=$true }
$expectedQaGoldenVectors = [ordered]@{
    questionDigest = [ordered]@{ bytes=5; sha256='5F8EAF0FD8B4EE2B0A0FEF54A8594C50143D7B3567AC7C1CF4F90BD8C19970A5' }
    prompt = [ordered]@{ bytes=1711; sha256='E5980A66E3C8568AE4C626E0A63BDA2A91DC75FD6711452A0A42AD76BF242EE3' }
    body = [ordered]@{ bytes=2147; sha256='447702159C263EEF129ADB26F623DF4C8FA5683BBA7868C3CD01059802FAECE0' }
    insufficientAnswer = [ordered]@{ bytes=53; sha256='CE2D672B78A25ACE7379CDF0A6E6265BEF0C5F77A84D0D9B446AB99B5186AEC5' }
    successOutput = [ordered]@{ bytes=1087; sha256='94A65159F8F5FB30A83A194E7D589E32A057A704B484EDB06EE8277F7D4F34A4' }
    prompt11999 = [ordered]@{ bytes=11999; sha256='E4A651E1CEC7B1ADA3E0E137EFB1F53CCF14F321E361CED465AC3681D088AE8E' }
    prompt12000 = [ordered]@{ bytes=12000; sha256='A68006E3D578D8B32301F7687CB97C68E81A9EC33225D5531A0E5842C4DE62C9' }
    prompt12001 = [ordered]@{ bytes=12001; sha256='B0BA8D146F21E39031BDF4CF345187BE5B4CA33F255DC2469BDEE03C35769641' }
    body16383 = [ordered]@{ bytes=16383; sha256='E3173A730FDB0BCCD6F6EADC55A31C1246457735D54619C3191EDE0281585DB5' }
    body16384 = [ordered]@{ bytes=16384; sha256='2D8CC61CADC3F40F961FD24051A70E86B15225613536A90ABF103023BF9E2D9E' }
    body16385 = [ordered]@{ bytes=16385; sha256='080758CC5EA11370E9BF81E7306951353D50CD68E3BB2EC951F1000B4575B902' }
    output16383 = [ordered]@{ bytes=16383; sha256='40D7118B1F53F3164FB2AB5D42B0FD187B0999C02909BC427D93EFD586AAD0FB' }
    output16384 = [ordered]@{ bytes=16384; sha256='1BD4DB450ABC8914C2FAC721CACE2704FF4C16028E6D07293154DAD289835694' }
    output16385 = [ordered]@{ bytes=16385; sha256='E9B0015594030C029F167A30522C7DD2EC90379B6026EF7C7DD74B07D0BC63DD' }
    errorInvalidNone = [ordered]@{ bytes=99; sha256='AE482F83460CE0C1E3DA4712DD99ECAFD0599E9E9B926239219C41247B04E15F' }
    errorDeniedNone = [ordered]@{ bytes=90; sha256='032F763897DE14352C16364BE071E40B8557E3E5015D68EFE1570C655F1C6241' }
    errorLocalProviderLoopback = [ordered]@{ bytes=113; sha256='71D23EF602941524D24941FA9604B87A2767775AFA9A61517A24D4BA25F10E8D' }
    errorContextNone = [ordered]@{ bytes=97; sha256='AB9311BE3D0D534C439E7CF5242E04FBB92EED856A0F635A8E7AB8A5D0037001' }
    errorKnowledgeNone = [ordered]@{ bytes=99; sha256='B0EA23AD8184A5B378C545811C076E2C91BFA4A39BB0F1A7856F72211D6B3A1E' }
    errorProjectQaNone = [ordered]@{ bytes=100; sha256='8BA3C443326913A7640E34E79EB4F7329802A1D6B4D75F015360B2D59E4DCC78' }
    errorProjectQaLoopback = [ordered]@{ bytes=109; sha256='D19C38637633110E57445DF9D8525A9DD2DC7A49977F9F100712A68C6DF5E185' }
}
$projectQaGoldenActualProfileMatch = (($profile.projectQa.goldenVectors | ConvertTo-Json -Depth 5 -Compress) -ceq ($expectedQaGoldenVectors | ConvertTo-Json -Depth 5 -Compress))
$projectQaCounterActualProfileMatch = (($profile.projectQa.requestCounters | ConvertTo-Json -Depth 3 -Compress) -ceq ($expectedQaRequestCounters | ConvertTo-Json -Depth 3 -Compress))
$projectQaGoldenProfilePass = $ProjectQaDiscovery -or $projectQaGoldenActualProfileMatch
$projectQaCounterProfilePass = $ProjectQaDiscovery -or $projectQaCounterActualProfileMatch
$projectQaCounterEvidencePass = @($allBuildEvidence | Where-Object { ($_.projectQaHarness.requestCounters | ConvertTo-Json -Depth 3 -Compress) -cne ($expectedQaRequestCounters | ConvertTo-Json -Depth 3 -Compress) }).Count -eq 0
$roleTestsPass = (@($allBuildEvidence | ForEach-Object { $_.outputs } | Where-Object { -not $_.offlineTestsPass }).Count -eq 0)
$functionalTestsPass = (@($allBuildEvidence | Where-Object { -not $_.functionalHarness.offlineTestsPass }).Count -eq 0)
$projectContextHarnessCallerIlStable = (($allBuildEvidence[0].projectContextHarness.approvedNativeCallerIl | ConvertTo-Json -Depth 5 -Compress) -ceq
                                        ($allBuildEvidence[1].projectContextHarness.approvedNativeCallerIl | ConvertTo-Json -Depth 5 -Compress))
$projectContextCliCallerIlStable = (($allBuildEvidence[0].taskIntakeCli.approvedNativeCallerIl | ConvertTo-Json -Depth 5 -Compress) -ceq
                                    ($allBuildEvidence[1].taskIntakeCli.approvedNativeCallerIl | ConvertTo-Json -Depth 5 -Compress))
$projectContextSeamMetadataStable = $true
foreach ($evidenceProperty in @('taskIntakeHarness','projectContextHarness','localProviderHarness','transportPolicyHarness','taskIntakeCli')) {
    $left = $allBuildEvidence[0].$evidenceProperty.seamPolicy.controlledMethods | ConvertTo-Json -Depth 5 -Compress
    $right = $allBuildEvidence[1].$evidenceProperty.seamPolicy.controlledMethods | ConvertTo-Json -Depth 5 -Compress
    if ($left -cne $right) { $projectContextSeamMetadataStable = $false }
}
$projectContextTestsPass = (@($allBuildEvidence | Where-Object {
    -not $_.projectContextHarness.offlineTestsPass -or
    -not $_.taskIntakeHarness.seamPolicy.seamPolicyPass -or
    -not $_.projectContextHarness.seamPolicy.seamPolicyPass -or
    -not $_.localProviderHarness.seamPolicy.seamPolicyPass -or
    -not $_.transportPolicyHarness.seamPolicy.seamPolicyPass -or
    -not $_.taskIntakeCli.seamPolicy.seamPolicyPass
}).Count -eq 0) -and $projectContextHarnessCallerIlStable -and $projectContextCliCallerIlStable -and $projectContextSeamMetadataStable -and $seamNegativeSpecimensPass -and $nativeNegativeSpecimensPass -and $outputIsolationNegativeSpecimensPass
$taskIntakeTestsPass = (@($allBuildEvidence | Where-Object {
    -not $_.taskIntakeHarness.offlineTestsPass -or
    -not $_.localProviderHarness.offlineTestsPass -or
    -not $_.transportPolicyHarness.offlineTestsPass -or
    -not $_.taskIntakeCli.offlineTestsPass
}).Count -eq 0)
$projectKnowledgeMetadataStable = (($allBuildEvidence[0].projectKnowledgeCli.metadataInventory | ConvertTo-Json -Depth 8 -Compress) -ceq
                                   ($allBuildEvidence[1].projectKnowledgeCli.metadataInventory | ConvertTo-Json -Depth 8 -Compress)) -and
                                  (($allBuildEvidence[0].projectKnowledgeHarness.metadataInventory | ConvertTo-Json -Depth 8 -Compress) -ceq
                                   ($allBuildEvidence[1].projectKnowledgeHarness.metadataInventory | ConvertTo-Json -Depth 8 -Compress))
$projectKnowledgeCodecRawCrossOutput = (($allBuildEvidence[0].projectKnowledgeCli.metadataInventory.codecClosure | ConvertTo-Json -Compress) -ceq
                                       ($allBuildEvidence[0].projectKnowledgeHarness.metadataInventory.codecClosure | ConvertTo-Json -Compress))
$projectKnowledgeCodecSemanticCrossOutput = (($allBuildEvidence[0].projectKnowledgeCli.metadataInventory.codecSemanticClosure | ConvertTo-Json -Compress) -ceq
                                            ($allBuildEvidence[0].projectKnowledgeHarness.metadataInventory.codecSemanticClosure | ConvertTo-Json -Compress))
$projectKnowledgeNativeCrossOutput = $true
foreach ($build in $allBuildEvidence) {
    if (($build.taskIntakeCli.normalizedNativeInventory | ConvertTo-Json -Depth 8 -Compress) -cne
        ($build.projectKnowledgeCli.normalizedNativeInventory | ConvertTo-Json -Depth 8 -Compress)) {
        $projectKnowledgeNativeCrossOutput = $false
    }
}
if (($allBuildEvidence[0].projectKnowledgeCli.normalizedNativeInventory | ConvertTo-Json -Depth 8 -Compress) -cne
    ($allBuildEvidence[1].projectKnowledgeCli.normalizedNativeInventory | ConvertTo-Json -Depth 8 -Compress)) {
    $projectKnowledgeNativeCrossOutput = $false
}
$projectKnowledgeNormalizedProfileMatch = $ProjectKnowledgeDiscovery -or
    (($allBuildEvidence[0].projectKnowledgeCli.normalizedNativeInventory | ConvertTo-Json -Depth 8 -Compress) -ceq
     ($profile.projectKnowledge.normalizedNativeInventory | ConvertTo-Json -Depth 8 -Compress))
$projectKnowledgeTestsPass = (@($allBuildEvidence | Where-Object {
    -not $_.projectKnowledgeHarness.offlineTestsPass -or
    -not $_.projectKnowledgeCli.invalidRequestPass -or
    -not $_.projectKnowledgeCli.channelMatrixPass
}).Count -eq 0) -and $projectKnowledgeMetadataStable -and $projectKnowledgeCodecSemanticCrossOutput -and
    $projectKnowledgeNativeCrossOutput -and $projectKnowledgeNormalizedProfileMatch -and $knowledgeNegativeSpecimensPass
$projectKnowledgeProfileBound = $ProjectKnowledgeDiscovery -or (
    $slice4InputsBound -and
    [int64]$profile.projectKnowledge.expectedCliBytes -eq [int64]$allBuildEvidence[0].projectKnowledgeCli.bytes -and
    [string]$profile.projectKnowledge.expectedCliSha256 -ceq [string]$allBuildEvidence[0].projectKnowledgeCli.sha256 -and
    [int64]$profile.projectKnowledge.expectedHarnessBytes -eq [int64]$allBuildEvidence[0].projectKnowledgeHarness.bytes -and
    [string]$profile.projectKnowledge.expectedHarnessSha256 -ceq [string]$allBuildEvidence[0].projectKnowledgeHarness.sha256
)
$projectQaMetadataStable = (($allBuildEvidence[0].projectQaCli.metadataInventory | ConvertTo-Json -Depth 8 -Compress) -ceq
                            ($allBuildEvidence[1].projectQaCli.metadataInventory | ConvertTo-Json -Depth 8 -Compress)) -and
                           (($allBuildEvidence[0].projectQaHarness.metadataInventory | ConvertTo-Json -Depth 8 -Compress) -ceq
                            ($allBuildEvidence[1].projectQaHarness.metadataInventory | ConvertTo-Json -Depth 8 -Compress))
$projectQaNativeStable = (($allBuildEvidence[0].projectQaCli.normalizedNativeInventory | ConvertTo-Json -Depth 8 -Compress) -ceq
                          ($allBuildEvidence[1].projectQaCli.normalizedNativeInventory | ConvertTo-Json -Depth 8 -Compress))
$projectQaNativeActualProfileMatch = (($allBuildEvidence[0].projectQaCli.normalizedNativeInventory | ConvertTo-Json -Depth 8 -Compress) -ceq
                                      ($profile.projectQa.normalizedNativeInventory | ConvertTo-Json -Depth 8 -Compress))
$projectQaNativeProfileMatch = $ProjectQaDiscovery -or $projectQaNativeActualProfileMatch
$projectQaTestsPass = (@($allBuildEvidence | Where-Object {
    -not $_.projectQaHarness.offlineTestsPass -or
    -not $_.projectQaCli.invalidRequestPass -or
    -not $_.projectQaCli.deniedPass -or
    -not $_.projectQaCli.channelMatrixPass
}).Count -eq 0) -and $projectQaMetadataStable -and $projectQaNativeStable -and $projectQaNativeProfileMatch -and $qaNegativeSpecimensPass -and $projectQaGoldenProfilePass -and $projectQaCounterProfilePass -and $projectQaCounterEvidencePass
$projectQaProfileBound = (-not $ProjectQaDiscovery) -and (
    $slice5InputsBound -and
    [int64]$profile.projectQa.expectedCliBytes -eq [int64]$allBuildEvidence[0].projectQaCli.bytes -and
    [string]$profile.projectQa.expectedCliSha256 -ceq [string]$allBuildEvidence[0].projectQaCli.sha256 -and
    [int64]$profile.projectQa.expectedHarnessBytes -eq [int64]$allBuildEvidence[0].projectQaHarness.bytes -and
    [string]$profile.projectQa.expectedHarnessSha256 -ceq [string]$allBuildEvidence[0].projectQaHarness.sha256
)
$projectQaProfileGatePass = $ProjectQaDiscovery -or $projectQaProfileBound
$localOperatorMetadataStable = (($allBuildEvidence[0].localOperatorCli.metadataInventory|ConvertTo-Json -Depth 8 -Compress) -ceq ($allBuildEvidence[1].localOperatorCli.metadataInventory|ConvertTo-Json -Depth 8 -Compress)) -and (($allBuildEvidence[0].localOperatorHarness.metadataInventory|ConvertTo-Json -Depth 8 -Compress) -ceq ($allBuildEvidence[1].localOperatorHarness.metadataInventory|ConvertTo-Json -Depth 8 -Compress))
$localOperatorNativeStable = (($allBuildEvidence[0].localOperatorCli.normalizedNativeInventory|ConvertTo-Json -Depth 8 -Compress) -ceq ($allBuildEvidence[1].localOperatorCli.normalizedNativeInventory|ConvertTo-Json -Depth 8 -Compress))
$localOperatorLoopbackStable = (($allBuildEvidence[0].localOperatorCli.loopbackMetadataAllowlist|ConvertTo-Json -Depth 8 -Compress) -ceq ($allBuildEvidence[1].localOperatorCli.loopbackMetadataAllowlist|ConvertTo-Json -Depth 8 -Compress))
$localOperatorHealthIlStable = (($allBuildEvidence[0].localOperatorCli.healthControlFlow.dispatchRows|ConvertTo-Json -Depth 4 -Compress) -ceq ($allBuildEvidence[1].localOperatorCli.healthControlFlow.dispatchRows|ConvertTo-Json -Depth 4 -Compress)) -and (($allBuildEvidence[0].localOperatorCli.healthControlFlow.methodDetails|ConvertTo-Json -Depth 8 -Compress) -ceq ($allBuildEvidence[1].localOperatorCli.healthControlFlow.methodDetails|ConvertTo-Json -Depth 8 -Compress)) -and (($allBuildEvidence[0].localOperatorCli.healthControlFlow.methodRows|ConvertTo-Json -Depth 4 -Compress) -ceq ($allBuildEvidence[1].localOperatorCli.healthControlFlow.methodRows|ConvertTo-Json -Depth 4 -Compress)) -and (($allBuildEvidence[0].localOperatorCli.healthControlFlow.callRows|ConvertTo-Json -Depth 4 -Compress) -ceq ($allBuildEvidence[1].localOperatorCli.healthControlFlow.callRows|ConvertTo-Json -Depth 4 -Compress))
$localOperatorPreflightIlStable = (($allBuildEvidence[0].localOperatorCli.preflightControlFlow.dispatchRows|ConvertTo-Json -Depth 8 -Compress) -ceq ($allBuildEvidence[1].localOperatorCli.preflightControlFlow.dispatchRows|ConvertTo-Json -Depth 8 -Compress)) -and (($allBuildEvidence[0].localOperatorCli.preflightControlFlow.methodDetails|ConvertTo-Json -Depth 12 -Compress) -ceq ($allBuildEvidence[1].localOperatorCli.preflightControlFlow.methodDetails|ConvertTo-Json -Depth 12 -Compress)) -and (($allBuildEvidence[0].localOperatorCli.preflightControlFlow.callRows|ConvertTo-Json -Depth 8 -Compress) -ceq ($allBuildEvidence[1].localOperatorCli.preflightControlFlow.callRows|ConvertTo-Json -Depth 8 -Compress)) -and (($allBuildEvidence[0].localOperatorCli.preflightControlFlow.tokenRows|ConvertTo-Json -Depth 8 -Compress) -ceq ($allBuildEvidence[1].localOperatorCli.preflightControlFlow.tokenRows|ConvertTo-Json -Depth 8 -Compress))
$localOperatorDryRunIlStable = (($allBuildEvidence[0].localOperatorCli.dryRunControlFlow.dispatchRows|ConvertTo-Json -Depth 8 -Compress) -ceq ($allBuildEvidence[1].localOperatorCli.dryRunControlFlow.dispatchRows|ConvertTo-Json -Depth 8 -Compress)) -and (($allBuildEvidence[0].localOperatorCli.dryRunControlFlow.methodDetails|ConvertTo-Json -Depth 12 -Compress) -ceq ($allBuildEvidence[1].localOperatorCli.dryRunControlFlow.methodDetails|ConvertTo-Json -Depth 12 -Compress)) -and (($allBuildEvidence[0].localOperatorCli.dryRunControlFlow.callRows|ConvertTo-Json -Depth 8 -Compress) -ceq ($allBuildEvidence[1].localOperatorCli.dryRunControlFlow.callRows|ConvertTo-Json -Depth 8 -Compress)) -and (($allBuildEvidence[0].localOperatorCli.dryRunControlFlow.closureCallRows|ConvertTo-Json -Depth 12 -Compress) -ceq ($allBuildEvidence[1].localOperatorCli.dryRunControlFlow.closureCallRows|ConvertTo-Json -Depth 12 -Compress)) -and (($allBuildEvidence[0].localOperatorCli.dryRunControlFlow.tokenRows|ConvertTo-Json -Depth 12 -Compress) -ceq ($allBuildEvidence[1].localOperatorCli.dryRunControlFlow.tokenRows|ConvertTo-Json -Depth 12 -Compress))
$localOperatorHealthInstrumentationStable = (($allBuildEvidence[0].localOperatorCli.healthConnectAttemptMonitor.instrumentationRows|ConvertTo-Json -Depth 4 -Compress) -ceq ($allBuildEvidence[1].localOperatorCli.healthConnectAttemptMonitor.instrumentationRows|ConvertTo-Json -Depth 4 -Compress))
$localOperatorNativeProfileMatch = $retainedOperatorDiscovery -or (($allBuildEvidence[0].localOperatorCli.normalizedNativeInventory|ConvertTo-Json -Depth 8 -Compress) -ceq ($profile.localOperator.nativeCallerInventory|ConvertTo-Json -Depth 8 -Compress))
$dryRunTechnicalPass = @($allBuildEvidence|Where-Object{-not $_.localOperatorHarness.offlineTestsPass -or -not $_.localOperatorCli.offlineTestsPass}).Count -eq 0 -and $localOperatorDryRunIlStable -and $dryRunGoldenVectorsPass -and $dryRunNegativeSpecimensPass
$retainedLocalOperatorTestsPass = $localOperatorMetadataStable -and $localOperatorNativeStable -and $localOperatorLoopbackStable -and $localOperatorHealthIlStable -and $localOperatorPreflightIlStable -and $localOperatorHealthInstrumentationStable -and $retainedLocalOperatorNegativeSpecimensPass -and $localOperatorNativeProfileMatch
$localOperatorTestsPass = $retainedLocalOperatorTestsPass -and $dryRunTechnicalPass -and $localOperatorNegativeSpecimensPass
$localOperatorProfileBound = (-not $operatorDiscovery) -and $localOperatorInputsBound -and
    [int64]$profile.localOperator.cliMetadataInventory.image.count -eq [int64]$allBuildEvidence[0].localOperatorCli.bytes -and [string]$profile.localOperator.cliMetadataInventory.image.sha256 -ceq [string]$allBuildEvidence[0].localOperatorCli.sha256 -and
    [int64]$profile.localOperator.harnessMetadataInventory.image.count -eq [int64]$allBuildEvidence[0].localOperatorHarness.bytes -and [string]$profile.localOperator.harnessMetadataInventory.image.sha256 -ceq [string]$allBuildEvidence[0].localOperatorHarness.sha256
$localOperatorProfileGatePass = $operatorDiscovery -or $localOperatorProfileBound
$retainedOfflineTestsPass = $roleTestsPass -and $functionalTestsPass -and $projectContextTestsPass -and $taskIntakeTestsPass -and $projectKnowledgeTestsPass -and $projectKnowledgeProfileBound -and $projectQaTestsPass -and $projectQaProfileGatePass -and $retainedLocalOperatorTestsPass -and $localOperatorProfileGatePass
$offlineTestsPass = $retainedOfflineTestsPass -and $dryRunTechnicalPass -and $localOperatorNegativeSpecimensPass
$retainedOverallTechnicalPass = -not $DevelopmentProbe -and $compilerPolicyPass -and $supportsDeterministic -and $supportsPathMap -and $reproducible -and $retainedOfflineTestsPass
$overallTechnicalPass = $retainedOverallTechnicalPass -and $dryRunTechnicalPass
$m4TechnicalChecksPass = $overallTechnicalPass
$noDiscovery = -not $DevelopmentProbe -and -not $ProjectKnowledgeDiscovery -and -not $ProjectQaDiscovery -and -not $LocalOperatorDiscovery -and -not $LocalOperatorPreflightDiscovery -and -not $LocalOperatorDryRunDiscovery
$finalEvidence = $noDiscovery -and -not [String]::IsNullOrEmpty($ExpectedReleaseProfileSha256) -and $overallTechnicalPass -and $localOperatorProfileBound
$releaseOutputs = @()

if ($finalEvidence) {
    $releaseRoot = Join-Path $resolvedOutput 'unsigned-release'
    New-Item -ItemType Directory -Path $releaseRoot | Out-Null
    foreach ($role in @($profile.roles)) {
        $sourceOutput = Join-Path $buildRoots[0] ([string]$role.output)
        $destinationOutput = Join-Path $releaseRoot ([string]$role.output)
        Copy-Item -LiteralPath $sourceOutput -Destination $destinationOutput
        $releaseOutputs += [ordered]@{
            file = [string]$role.output
            bytes = (Get-Item -LiteralPath $destinationOutput).Length
            sha256 = Get-Sha256 -LiteralPath $destinationOutput
            authenticode = (Get-AuthenticodeSignature -LiteralPath $destinationOutput).Status.ToString()
        }
    }
    $taskIntakeReleasePath = Join-Path $releaseRoot ([string]$profile.taskIntake.output)
    Copy-Item -LiteralPath (Join-Path $buildRoots[0] ([string]$profile.taskIntake.output)) -Destination $taskIntakeReleasePath
    $releaseOutputs += [ordered]@{
        file = [string]$profile.taskIntake.output
        bytes = (Get-Item -LiteralPath $taskIntakeReleasePath).Length
        sha256 = Get-Sha256 -LiteralPath $taskIntakeReleasePath
        authenticode = (Get-AuthenticodeSignature -LiteralPath $taskIntakeReleasePath).Status.ToString()
    }
    $projectKnowledgeReleasePath = Join-Path $releaseRoot ([string]$profile.projectKnowledge.output)
    Copy-Item -LiteralPath (Join-Path $buildRoots[0] ([string]$profile.projectKnowledge.output)) -Destination $projectKnowledgeReleasePath
    $releaseOutputs += [ordered]@{
        file = [string]$profile.projectKnowledge.output
        bytes = (Get-Item -LiteralPath $projectKnowledgeReleasePath).Length
        sha256 = Get-Sha256 -LiteralPath $projectKnowledgeReleasePath
        authenticode = (Get-AuthenticodeSignature -LiteralPath $projectKnowledgeReleasePath).Status.ToString()
    }
    $projectQaReleasePath = Join-Path $releaseRoot ([string]$profile.projectQa.output)
    Copy-Item -LiteralPath (Join-Path $buildRoots[0] ([string]$profile.projectQa.output)) -Destination $projectQaReleasePath
    $releaseOutputs += [ordered]@{
        file = [string]$profile.projectQa.output
        bytes = (Get-Item -LiteralPath $projectQaReleasePath).Length
        sha256 = Get-Sha256 -LiteralPath $projectQaReleasePath
        authenticode = (Get-AuthenticodeSignature -LiteralPath $projectQaReleasePath).Status.ToString()
    }
    $localOperatorReleasePath = Join-Path $releaseRoot ([string]$profile.localOperator.output)
    Copy-Item -LiteralPath (Join-Path $buildRoots[0] ([string]$profile.localOperator.output)) -Destination $localOperatorReleasePath
    $releaseOutputs += [ordered]@{ file=[string]$profile.localOperator.output; bytes=(Get-Item -LiteralPath $localOperatorReleasePath).Length; sha256=Get-Sha256 -LiteralPath $localOperatorReleasePath; authenticode=(Get-AuthenticodeSignature -LiteralPath $localOperatorReleasePath).Status.ToString() }
}

$candidateRepositoryEvidence = @()
foreach ($relativePath in $expectedCandidateRepositoryPaths) {
    if ([System.IO.Path]::IsPathRooted($relativePath) -or $relativePath.Contains('..') -or $relativePath.Contains('\')) {
        throw "Invalid candidate repository path: $relativePath"
    }
    $candidatePath = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot $relativePath))
    $repositoryPrefix = $repositoryRoot.TrimEnd('\') + '\'
    if (-not $candidatePath.StartsWith($repositoryPrefix, [StringComparison]::OrdinalIgnoreCase) -or
        -not (Test-Path -LiteralPath $candidatePath -PathType Leaf)) {
        throw "Candidate repository path is absent or outside the repository: $relativePath"
    }
    $candidateItem = Get-Item -LiteralPath $candidatePath
    $candidateRepositoryEvidence += [ordered]@{
        file = $relativePath
        bytes = $candidateItem.Length
        sha256 = Get-Sha256 -LiteralPath $candidatePath
    }
}
if ($candidateRepositoryEvidence.Count -ne 32) { throw 'Candidate repository evidence count mismatch.' }

$compilerItem = Get-Item -LiteralPath $resolvedCompiler
$manifest = [ordered]@{
    schemaVersion = 1
    generatedUtc = [DateTime]::UtcNow.ToString('o')
    classification = if ($DevelopmentProbe) { 'DEVELOPMENT_PROBE_ONLY' } elseif ($LocalOperatorDryRunDiscovery) { 'M5_SLICE4_OPERATOR_DRY_RUN_DISCOVERY' } elseif ($LocalOperatorPreflightDiscovery) { 'M5_SLICE3_OPERATOR_PREFLIGHT_DISCOVERY' } elseif ($LocalOperatorDiscovery) { 'M5_SLICE2_OPERATOR_HEALTH_DISCOVERY' } elseif ($ProjectQaDiscovery) { 'M4_SLICE_5_PROJECT_QA_DISCOVERY' } elseif ($ProjectKnowledgeDiscovery) { 'M4_SLICE_4_PROJECT_KNOWLEDGE_DISCOVERY' } else { 'M5_SLICE4_OPERATOR_DRY_RUN_UNSIGNED_CANDIDATE' }
    status = if ($overallTechnicalPass) { 'M5_SLICE4_UNSIGNED_TECHNICAL_CHECKS_PASS' } elseif ($DevelopmentProbe -and -not $reproducible) { 'BLOCKED_NONDETERMINISTIC_COMPILER' } else { 'FAIL_CLOSED' }
    finalEvidence = [bool]$finalEvidence
    gate25Complete = $false
    externalSigningEligible = $false
    signatureOnlyBlocked = $false
    source = [ordered]@{
        buildScriptFile = 'build/Invoke-Gate25UnsignedRelease.ps1'
        buildScriptSha256 = Get-Sha256 -LiteralPath $buildScriptPath
        functionalContractFile = 'contracts/EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1.md'
        functionalContractSha256 = Get-Sha256 -LiteralPath $functionalContractPath
        taskIntakeContractFile = 'contracts/EAIRA_LOCAL_TASK_INTAKE_V1.md'
        taskIntakeContractSha256 = Get-Sha256 -LiteralPath $taskIntakeContractPath
        localProviderContractFile = 'contracts/EAIRA_LOCAL_MODEL_PROVIDER_V1.md'
        localProviderContractSha256 = Get-Sha256 -LiteralPath $localProviderContractPath
        projectContextContractFile = 'contracts/EAIRA_READ_ONLY_PROJECT_CONTEXT_V1.md'
        projectContextContractSha256 = Get-Sha256 -LiteralPath $projectContextContractPath
        file = 'src/AgentServiceHost.cs'
        sha256 = $sourceHash
        coreFile = 'src/AgentCore.cs'
        coreSha256 = $coreSourceHash
        providerFile = 'src/ModelProviders.cs'
        providerSha256 = $providerSourceHash
        taskIntakeFile = 'src/LocalTaskIntake.cs'
        taskIntakeSha256 = $taskIntakeSourceHash
        taskIntakeHostFile = 'src/AgentTaskIntakeHost.cs'
        taskIntakeHostSha256 = $taskIntakeHostSourceHash
        localProviderFile = 'src/LocalModelProvider.cs'
        localProviderSha256 = $localProviderSourceHash
        loopbackTransportFile = 'src/OllamaLoopbackTransport.cs'
        loopbackTransportSha256 = $loopbackTransportSourceHash
        projectContextFile = 'src/ProjectContext.cs'
        projectContextSha256 = $projectContextSourceHash
        codecFile = 'src/ContractCodec.cs'
        codecSha256 = $codecSourceHash
        projectReadOnlyPlatformFile = 'src/ProjectReadOnlyPlatform.cs'
        projectReadOnlyPlatformSha256 = $projectReadOnlyPlatformSourceHash
        projectKnowledgeFile = 'src/ProjectKnowledge.cs'
        projectKnowledgeSha256 = $projectKnowledgeSourceHash
        projectKnowledgeHostFile = 'src/ProjectKnowledgeHost.cs'
        projectKnowledgeHostSha256 = $projectKnowledgeHostSourceHash
        projectKnowledgeHarnessFile = 'tests/ProjectKnowledgeHarness.cs'
        projectKnowledgeHarnessSha256 = $projectKnowledgeHarnessSourceHash
        projectQaContractFile = 'contracts/EAIRA_BOUNDED_LOCAL_PROJECT_QA_V1.md'
        projectQaContractSha256 = Get-Sha256 -LiteralPath $projectQaContractPath
        projectQaFile = 'src/ProjectQa.cs'
        projectQaSha256 = $projectQaSourceHash
        projectQaHostFile = 'src/ProjectQaHost.cs'
        projectQaHostSha256 = $projectQaHostSourceHash
        projectQaHarnessFile = 'tests/ProjectQaHarness.cs'
        projectQaHarnessSha256 = $projectQaHarnessSourceHash
        localOperatorContractFile = 'contracts/EAIRA_LOCAL_OPERATOR_V1.md'
        localOperatorContractSha256 = Get-Sha256 -LiteralPath $localOperatorContractPath
        localOperatorFile = 'src/LocalOperator.cs'
        localOperatorSha256 = $localOperatorSourceHash
        localOperatorHostFile = 'src/LocalOperatorHost.cs'
        localOperatorHostSha256 = $localOperatorHostSourceHash
        localOperatorHarnessFile = 'tests/LocalOperatorHarness.cs'
        localOperatorHarnessSha256 = $localOperatorHarnessSourceHash
        harnessFile = 'tests/AgentCoreHarness.cs'
        harnessSha256 = $harnessSourceHash
        taskIntakeHarnessFile = 'tests/LocalTaskIntakeHarness.cs'
        taskIntakeHarnessSha256 = $taskIntakeHarnessSourceHash
        localProviderHarnessFile = 'tests/LocalModelProviderHarness.cs'
        localProviderHarnessSha256 = $localProviderHarnessSourceHash
        projectContextHarnessFile = 'tests/ProjectContextHarness.cs'
        projectContextHarnessSha256 = $projectContextHarnessSourceHash
        releaseProfileSha256 = Get-Sha256 -LiteralPath $profilePath
    }
    candidateRepositoryInputs = $candidateRepositoryEvidence
    slice4RepositoryInputs = $slice4RepositoryEvidence
    slice5RepositoryInputs = $slice5RepositoryEvidence
    localOperatorRepositoryInputs = $localOperatorRepositoryEvidence
    compiler = [ordered]@{
        file = $compilerItem.Name
        bytes = $compilerItem.Length
        sha256 = $compilerHash
        productVersion = $compilerItem.VersionInfo.ProductVersion
        authenticode = $compilerSignature.Status.ToString()
        signerSubject = $compilerSignature.SignerCertificate.Subject
        signerThumbprint = $compilerSignature.SignerCertificate.Thumbprint.ToUpperInvariant()
        releaseProfilePolicyMatch = [bool]$compilerPolicyPass
        supportsDeterministic = [bool]$supportsDeterministic
        supportsPathMap = [bool]$supportsPathMap
    }
    references = $referenceEvidence
    cleanBuilds = $allBuildEvidence
    reproducibleByteForByte = [bool]$reproducible
    offlineTestsPass = [bool]$offlineTestsPass
    functionalSlice = [ordered]@{
        contract = 'EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1'
        revision = [int]$profile.functionalSlice.revision
        execution = 'OFFLINE_IN_MEMORY_TEST_ONLY'
        staticForbiddenTokenCheckPass = $true
        runtimeIoAllowlistCheckPass = [bool]$runtimeIoAllowlistCheckPass
        structuredPeIoMemberReferenceCheckPass = $true
        compiledMetadataForbiddenTokenCheckPass = $true
        cleanBuildHarnessReproducible = [bool](
            $allBuildEvidence[0].functionalHarness.sha256 -eq $allBuildEvidence[1].functionalHarness.sha256
        )
        testsPass = [bool]$functionalTestsPass
    }
    taskIntake = [ordered]@{
        contract = 'EAIRA_LOCAL_TASK_INTAKE_V1'
        transport = 'LOCAL_COMMAND_LINE_ONLY'
        mockProvider = 'ENABLED'
        realProvider = 'FAIL_CLOSED_DISABLED'
        localProvider = 'OLLAMA_LOOPBACK_ENABLED'
        network = 'MOCK_REAL_NONE_LOCAL_LOOPBACK_ONLY'
        writes = 'NONE'
        cleanBuildHarnessReproducible = [bool]($allBuildEvidence[0].taskIntakeHarness.sha256 -eq $allBuildEvidence[1].taskIntakeHarness.sha256)
        cleanBuildCliReproducible = [bool]($allBuildEvidence[0].taskIntakeCli.sha256 -eq $allBuildEvidence[1].taskIntakeCli.sha256)
        testsPass = [bool]$taskIntakeTestsPass
    }
    projectContext = [ordered]@{
        contract = 'EAIRA_READ_ONLY_PROJECT_CONTEXT_V1'
        allowlistId = [string]$profile.projectContext.allowlistId
        maximumFileBytes = [int]$profile.projectContext.maximumFileBytes
        maximumAggregateBytes = [int]$profile.projectContext.maximumAggregateBytes
        maximumProjectionBytes = [int]$profile.projectContext.maximumProjectionBytes
        maximumCanonicalRequestBytes = [int]$profile.projectContext.maximumCanonicalRequestBytes
        module = [string]$profile.projectContext.module
        declaringType = [string]$profile.projectContext.declaringType
        rawMasks = [ordered]@{
            methodImportAttributes = [int]$profile.projectContext.methodImportAttributes
            methodAttributes = [int]$profile.projectContext.methodAttributes
            methodImplAttributes = [int]$profile.projectContext.methodImplAttributes
        }
        harnessTestsPassed = [int]$allBuildEvidence[0].projectContextHarness.testsPassed
        cleanBuildHarnessReproducible = [bool]($allBuildEvidence[0].projectContextHarness.sha256 -eq $allBuildEvidence[1].projectContextHarness.sha256)
        nativeCallerGraphPass = $true
        nativeImportSignaturesProfileBound = $true
        nativeCallerIlProfileBound = $true
        nativeCallerIlStableAcrossBuilds = [bool]($projectContextHarnessCallerIlStable -and $projectContextCliCallerIlStable)
        seamPolicyPass = $true
        seamMetadataStableAcrossBuilds = [bool]$projectContextSeamMetadataStable
        seamNegativeSpecimensPass = [bool]$seamNegativeSpecimensPass
        seamNegativeSpecimens = $seamNegativeSpecimenEvidence
        outputIsolationNegativeSpecimensPass = [bool]$outputIsolationNegativeSpecimensPass
        outputIsolationNegativeSpecimens = $outputIsolationNegativeSpecimens
        nativeNegativeSpecimensPass = [bool]$nativeNegativeSpecimensPass
        nativeNegativeSpecimens = $nativeNegativeSpecimenEvidence
        testsPass = [bool]$projectContextTestsPass
        writes = 'NONE'
    }
    projectKnowledge = [ordered]@{
        contract = 'EAIRA_PROJECT_KNOWLEDGE_QUERY_V1'
        discovery = [bool]$ProjectKnowledgeDiscovery
        profileBound = [bool]$projectKnowledgeProfileBound
        expectedReleaseProfileSha256 = if ($ProjectKnowledgeDiscovery -or $DevelopmentProbe) { $null } else { $ExpectedReleaseProfileSha256 }
        actualReleaseProfileSha256 = $releaseProfileSha256
        harnessTestsPassed = [int]$allBuildEvidence[0].projectKnowledgeHarness.testsPassed
        harnessCaseNameSha256 = [string]$allBuildEvidence[0].projectKnowledgeHarness.caseNameSha256
        boundRepositoryInputCount = [int]$profileSlice4Inputs.Count
        boundRepositoryInputsMatch = [bool]$slice4InputsBound
        cleanBuildHarnessReproducible = [bool]($allBuildEvidence[0].projectKnowledgeHarness.sha256 -eq $allBuildEvidence[1].projectKnowledgeHarness.sha256)
        cleanBuildCliReproducible = [bool]($allBuildEvidence[0].projectKnowledgeCli.sha256 -eq $allBuildEvidence[1].projectKnowledgeCli.sha256)
        cliBytes = [int64]$allBuildEvidence[0].projectKnowledgeCli.bytes
        cliSha256 = [string]$allBuildEvidence[0].projectKnowledgeCli.sha256
        harnessBytes = [int64]$allBuildEvidence[0].projectKnowledgeHarness.bytes
        harnessSha256 = [string]$allBuildEvidence[0].projectKnowledgeHarness.sha256
        metadataInventories = [ordered]@{
            Cli = $allBuildEvidence[0].projectKnowledgeCli.metadataInventory
            Harness = $allBuildEvidence[0].projectKnowledgeHarness.metadataInventory
        }
        metadataStableAcrossBuilds = [bool]$projectKnowledgeMetadataStable
        codecRawClosureEqualAcrossOutputs = [bool]$projectKnowledgeCodecRawCrossOutput
        codecSemanticClosureEqualAcrossOutputs = [bool]$projectKnowledgeCodecSemanticCrossOutput
        codecRawClosureProtection = 'EXACT_PER_OUTPUT_PROFILE_BINDING_AND_CLEAN_A_B_STABILITY'
        normalizedNativeInventory = $allBuildEvidence[0].projectKnowledgeCli.normalizedNativeInventory
        normalizedNativeEqualToTaskCli = [bool]$projectKnowledgeNativeCrossOutput
        normalizedNativeProfileMatch = [bool]$projectKnowledgeNormalizedProfileMatch
        negativeSpecimensPass = [bool]$knowledgeNegativeSpecimensPass
        negativeSpecimens = $knowledgeNegativeSpecimenEvidence
        testsPass = [bool]$projectKnowledgeTestsPass
        network = 'NONE'
        writes = 'NONE'
    }
    projectQa = [ordered]@{
        contract = 'EAIRA_BOUNDED_LOCAL_PROJECT_QA_V1'
        discovery = [bool]$ProjectQaDiscovery
        profileBound = [bool]$projectQaProfileBound
        expectedReleaseProfileSha256 = if ($ProjectQaDiscovery -or $ProjectKnowledgeDiscovery -or $DevelopmentProbe) { $null } else { $ExpectedReleaseProfileSha256 }
        actualReleaseProfileSha256 = $releaseProfileSha256
        boundRepositoryInputCount = [int]$profileSlice5Inputs.Count
        boundRepositoryInputsMatch = [bool]$slice5InputsBound
        harnessTestsPassed = [int]$allBuildEvidence[0].projectQaHarness.testsPassed
        harnessCaseNameSha256 = [string]$allBuildEvidence[0].projectQaHarness.caseNameSha256
        cleanBuildHarnessReproducible = [bool]($allBuildEvidence[0].projectQaHarness.sha256 -eq $allBuildEvidence[1].projectQaHarness.sha256)
        cleanBuildCliReproducible = [bool]($allBuildEvidence[0].projectQaCli.sha256 -eq $allBuildEvidence[1].projectQaCli.sha256)
        cliBytes = [int64]$allBuildEvidence[0].projectQaCli.bytes
        cliSha256 = [string]$allBuildEvidence[0].projectQaCli.sha256
        harnessBytes = [int64]$allBuildEvidence[0].projectQaHarness.bytes
        harnessSha256 = [string]$allBuildEvidence[0].projectQaHarness.sha256
        invalidRequestPass = [bool]$allBuildEvidence[0].projectQaCli.invalidRequestPass
        deniedPass = [bool]$allBuildEvidence[0].projectQaCli.deniedPass
        channelMatrixPass = [bool]$allBuildEvidence[0].projectQaCli.channelMatrixPass
        channels = $allBuildEvidence[0].projectQaCli.channels
        cliMetadataInventory = $allBuildEvidence[0].projectQaCli.metadataInventory
        harnessMetadataInventory = $allBuildEvidence[0].projectQaHarness.metadataInventory
        loopbackMetadataAllowlist = $allBuildEvidence[0].projectQaCli.loopbackMetadataAllowlist
        metadataStableAcrossBuilds = [bool]$projectQaMetadataStable
        normalizedNativeInventory = $allBuildEvidence[0].projectQaCli.normalizedNativeInventory
        normalizedNativeStableAcrossBuilds = [bool]$projectQaNativeStable
        normalizedNativeProfileMatch = if ($ProjectQaDiscovery) { $null } else { [bool]$projectQaNativeActualProfileMatch }
        normalizedNativeDiscoveryBypass = [bool]$ProjectQaDiscovery
        negativeSpecimensPass = [bool]$qaNegativeSpecimensPass
        negativeSpecimens = $qaNegativeSpecimenEvidence
        goldenVectorsProfileMatch = if ($ProjectQaDiscovery) { $null } else { [bool]$projectQaGoldenActualProfileMatch }
        goldenVectorsDiscoveryBypass = [bool]$ProjectQaDiscovery
        goldenVectors = $expectedQaGoldenVectors
        requestCountersProfileMatch = if ($ProjectQaDiscovery) { $null } else { [bool]$projectQaCounterActualProfileMatch }
        requestCountersDiscoveryBypass = [bool]$ProjectQaDiscovery
        requestCountersEvidenceMatch = [bool]$projectQaCounterEvidencePass
        requestCounters = $allBuildEvidence[0].projectQaHarness.requestCounters
        testsPass = [bool]$projectQaTestsPass
        network = 'OFFLINE_NONE_LIVE_LOOPBACK_ONLY'
        writes = 'NONE'
    }
    localOperator = [ordered]@{
        contract = 'EAIRA_LOCAL_OPERATOR_V1'
        revision = 4
        discovery = [bool]$operatorDiscovery
        dryRunDiscovery = [bool]$LocalOperatorDryRunDiscovery
        profileBound = [bool]$localOperatorProfileBound
        dryRunProfileBound = [bool]($noDiscovery -and $localOperatorProfileBound -and $dryRunControlFlowProfileMatch)
        expectedReleaseProfileSha256 = if ($DevelopmentProbe -or $ProjectKnowledgeDiscovery -or $ProjectQaDiscovery -or $operatorDiscovery) { $null } else { $ExpectedReleaseProfileSha256 }
        actualReleaseProfileSha256 = $releaseProfileSha256
        boundRepositoryInputCount = [int]$profileOperatorInputs.Count
        boundRepositoryInputsMatch = [bool]$localOperatorInputsBound
        harnessTestsPassed = [int]$allBuildEvidence[0].localOperatorHarness.testsPassed
        harnessCaseNames = $allBuildEvidence[0].localOperatorHarness.caseNames
        harnessCaseNameFramedBytes = [int]$allBuildEvidence[0].localOperatorHarness.caseNameFramedBytes
        harnessCaseNameSha256 = [string]$allBuildEvidence[0].localOperatorHarness.caseNameSha256
        legacyHarness = [ordered]@{ testsPassed=[int]$allBuildEvidence[0].localOperatorHarness.legacyTestsPassed; caseNameFramedBytes=[int]$allBuildEvidence[0].localOperatorHarness.legacyCaseNameFramedBytes; caseNameSha256=[string]$allBuildEvidence[0].localOperatorHarness.legacyCaseNameSha256 }
        fullHarness = [ordered]@{ testsPassed=[int]$allBuildEvidence[0].localOperatorHarness.testsPassed; caseNameFramedBytes=[int]$allBuildEvidence[0].localOperatorHarness.caseNameFramedBytes; caseNameSha256=[string]$allBuildEvidence[0].localOperatorHarness.caseNameSha256 }
        slice2Harness = [ordered]@{ testsPassed=[int]$allBuildEvidence[0].localOperatorHarness.slice2TestsPassed; caseNameFramedBytes=[int]$allBuildEvidence[0].localOperatorHarness.slice2CaseNameFramedBytes; caseNameSha256=[string]$allBuildEvidence[0].localOperatorHarness.slice2CaseNameSha256 }
        slice3NewHarness = [ordered]@{ testsPassed=[int]$allBuildEvidence[0].localOperatorHarness.slice3NewTestsPassed; caseNameFramedBytes=[int]$allBuildEvidence[0].localOperatorHarness.slice3NewCaseNameFramedBytes; caseNameSha256=[string]$allBuildEvidence[0].localOperatorHarness.slice3NewCaseNameSha256 }
        slice4NewHarness = [ordered]@{ testsPassed=[int]$allBuildEvidence[0].localOperatorHarness.slice4NewTestsPassed; caseNameFramedBytes=[int]$allBuildEvidence[0].localOperatorHarness.slice4NewCaseNameFramedBytes; caseNameSha256=[string]$allBuildEvidence[0].localOperatorHarness.slice4NewCaseNameSha256 }
        dryRunChannel = $allBuildEvidence[0].localOperatorCli.channels.dryRun
        dryRunGoldenVectors = $allBuildEvidence[0].localOperatorCli.dryRunGoldenVectors
        dryRunDenialVectors = $allBuildEvidence[0].localOperatorCli.dryRunDenialVectors
        dryRunCounters = $allBuildEvidence[0].localOperatorCli.dryRunCounters
        dryRunControlFlow = [ordered]@{ dispatchMethod=[string]$allBuildEvidence[0].localOperatorCli.dryRunControlFlow.dispatchMethod; allowedRoot=[string]$allBuildEvidence[0].localOperatorCli.dryRunControlFlow.allowedRoot; build8=[string]$allBuildEvidence[0].localOperatorCli.dryRunControlFlow.build8; build9=[string]$allBuildEvidence[0].localOperatorCli.dryRunControlFlow.build9; dispatchRows=@($allBuildEvidence[0].localOperatorCli.dryRunControlFlow.dispatchRows); methodDetails=@($allBuildEvidence[0].localOperatorCli.dryRunControlFlow.methodDetails); methodRows=@($allBuildEvidence[0].localOperatorCli.dryRunControlFlow.methodRows); callRows=@($allBuildEvidence[0].localOperatorCli.dryRunControlFlow.callRows); closureCallRows=@($allBuildEvidence[0].localOperatorCli.dryRunControlFlow.closureCallRows); tokenRows=@($allBuildEvidence[0].localOperatorCli.dryRunControlFlow.tokenRows); methodManifest=$allBuildEvidence[0].localOperatorCli.dryRunControlFlow.methodManifest; callManifest=$allBuildEvidence[0].localOperatorCli.dryRunControlFlow.callManifest; closureCallManifest=$allBuildEvidence[0].localOperatorCli.dryRunControlFlow.closureCallManifest; tokenManifest=$allBuildEvidence[0].localOperatorCli.dryRunControlFlow.tokenManifest; closureManifest=$allBuildEvidence[0].localOperatorCli.dryRunControlFlow.closureManifest; forbiddenMatchCount=[int]$allBuildEvidence[0].localOperatorCli.dryRunControlFlow.forbiddenMatchCount; factoryReferenceCount=[int]$allBuildEvidence[0].localOperatorCli.dryRunControlFlow.factoryReferenceCount; providerReferenceCount=[int]$allBuildEvidence[0].localOperatorCli.dryRunControlFlow.providerReferenceCount; networkReferenceCount=[int]$allBuildEvidence[0].localOperatorCli.dryRunControlFlow.networkReferenceCount; connectAttemptDelta=[int]$allBuildEvidence[0].localOperatorCli.dryRunControlFlow.connectAttemptDelta; stableAcrossBuilds=[bool]$localOperatorDryRunIlStable; profileMatch=$allBuildEvidence[0].localOperatorCli.dryRunControlFlow.profileMatch; discoveryBypass=[bool]$LocalOperatorDryRunDiscovery }
        dryRunSpecimens = [ordered]@{ names=$actualDryRunNegativeNames; count=[int]$dryRunNegativeSpecimenEvidence.Count; framedBytes=[int]$dryRunSpecimenFrameBytes.Length; sha256=[string]$dryRunSpecimenFrameSha256; rows=$dryRunNegativeSpecimenEvidence; pass=[bool]$dryRunNegativeSpecimensPass }
        preflightChannel = [ordered]@{ exitCode=[int]$allBuildEvidence[0].localOperatorCli.channels.preflight.exitCode; stderrBytes=[int]$allBuildEvidence[0].localOperatorCli.channels.preflight.stderrBytes; stdoutBytes=[int]$allBuildEvidence[0].localOperatorCli.channels.preflight.stdoutBytes; stdoutSha256=[string]$allBuildEvidence[0].localOperatorCli.channels.preflight.stdoutSha256; payloadBytes=[int][Text.Encoding]::UTF8.GetByteCount(($operatorPreflightJson.payload | ConvertTo-Json -Compress -Depth 10)); payloadSha256=[string]$operatorPreflightJson.payloadSha256; requestSha256=[string]$operatorPreflightJson.requestSha256; routeSha256=[string]$operatorPreflightJson.routeSha256; auditSha256=[string]$operatorPreflightJson.audit.chainSha256; capability=[string]$operatorPreflightJson.capability; network=[string]$operatorPreflightJson.network; writes=[string]$operatorPreflightJson.writes; authority=[string]$operatorPreflightJson.authority }
        healthChannel = [ordered]@{
            exitCode = [int]$allBuildEvidence[0].localOperatorCli.channels.health.exitCode
            stderrBytes = [int]$allBuildEvidence[0].localOperatorCli.channels.health.stderrBytes
            stdoutBytes = [int]$allBuildEvidence[0].localOperatorCli.channels.health.stdoutBytes
            stdoutSha256 = [string]$allBuildEvidence[0].localOperatorCli.channels.health.stdoutSha256
            payloadBytes = [int][Text.Encoding]::UTF8.GetByteCount(($operatorHealthJson.payload | ConvertTo-Json -Compress -Depth 10))
            payloadSha256 = [string]$operatorHealthJson.payloadSha256
            requestSha256 = [string]$operatorHealthJson.requestSha256
            routeSha256 = [string]$operatorHealthJson.routeSha256
            auditSha256 = [string]$operatorHealthJson.audit.chainSha256
            capability = [string]$operatorHealthJson.capability
            network = [string]$operatorHealthJson.network
            writes = [string]$operatorHealthJson.writes
            authority = [string]$operatorHealthJson.authority
        }
        healthGuardDenial = $allBuildEvidence[0].localOperatorHarness.healthGuardDenial
        healthConnectAttemptMonitor = [ordered]@{ positiveControlBefore=[int]$allBuildEvidence[0].localOperatorCli.healthConnectAttemptMonitor.positiveControlBefore; positiveControlAfter=[int]$allBuildEvidence[0].localOperatorCli.healthConnectAttemptMonitor.positiveControlAfter; positiveControlDelta=[int]$allBuildEvidence[0].localOperatorCli.healthConnectAttemptMonitor.positiveControlDelta; healthBefore=[int]$allBuildEvidence[0].localOperatorCli.healthConnectAttemptMonitor.healthBefore; healthAfter=[int]$allBuildEvidence[0].localOperatorCli.healthConnectAttemptMonitor.healthAfter; healthDelta=[int]$allBuildEvidence[0].localOperatorCli.healthConnectAttemptMonitor.healthDelta; denialBefore=[int]$allBuildEvidence[0].localOperatorCli.healthConnectAttemptMonitor.denialBefore; denialAfter=[int]$allBuildEvidence[0].localOperatorCli.healthConnectAttemptMonitor.denialAfter; denialDelta=[int]$allBuildEvidence[0].localOperatorCli.healthConnectAttemptMonitor.denialDelta; instrumentedEntryPoints=@($allBuildEvidence[0].localOperatorCli.healthConnectAttemptMonitor.instrumentedEntryPoints); instrumentationRows=@($allBuildEvidence[0].localOperatorCli.healthConnectAttemptMonitor.instrumentationRows); instrumentation=$allBuildEvidence[0].localOperatorCli.healthConnectAttemptMonitor.instrumentation; instrumentationIlProfileMatch=$allBuildEvidence[0].localOperatorCli.healthConnectAttemptMonitor.instrumentationIlProfileMatch }
        healthControlFlow = [ordered]@{ dispatchMethod=[string]$allBuildEvidence[0].localOperatorCli.healthControlFlow.dispatchMethod; allowedRoot=[string]$allBuildEvidence[0].localOperatorCli.healthControlFlow.allowedRoot; dispatchRows=@($allBuildEvidence[0].localOperatorCli.healthControlFlow.dispatchRows); methodDetails=@($allBuildEvidence[0].localOperatorCli.healthControlFlow.methodDetails); methodRows=@($allBuildEvidence[0].localOperatorCli.healthControlFlow.methodRows); callRows=@($allBuildEvidence[0].localOperatorCli.healthControlFlow.callRows); dispatchIl=$allBuildEvidence[0].localOperatorCli.healthControlFlow.dispatchIl; allowedClosureMethods=$allBuildEvidence[0].localOperatorCli.healthControlFlow.allowedClosureMethods; allowedClosureCalls=$allBuildEvidence[0].localOperatorCli.healthControlFlow.allowedClosureCalls; forbiddenMatchCount=[int]$allBuildEvidence[0].localOperatorCli.healthControlFlow.forbiddenMatchCount; factoryReferenceCount=[int]$allBuildEvidence[0].localOperatorCli.healthControlFlow.factoryReferenceCount; providerReferenceCount=[int]$allBuildEvidence[0].localOperatorCli.healthControlFlow.providerReferenceCount; networkReferenceCount=[int]$allBuildEvidence[0].localOperatorCli.healthControlFlow.networkReferenceCount; connectAttemptDelta=[int]$allBuildEvidence[0].localOperatorCli.healthControlFlow.connectAttemptDelta; stableAcrossBuilds=[bool]$localOperatorHealthIlStable; profileMatch=$allBuildEvidence[0].localOperatorCli.healthControlFlow.profileMatch; discoveryBypass=[bool]$LocalOperatorDiscovery }
        preflightControlFlow = [ordered]@{ dispatchMethod=[string]$allBuildEvidence[0].localOperatorCli.preflightControlFlow.dispatchMethod; allowedRoot=[string]$allBuildEvidence[0].localOperatorCli.preflightControlFlow.allowedRoot; build8=[string]$allBuildEvidence[0].localOperatorCli.preflightControlFlow.build8; build9=[string]$allBuildEvidence[0].localOperatorCli.preflightControlFlow.build9; dispatchRows=@($allBuildEvidence[0].localOperatorCli.preflightControlFlow.dispatchRows); methodDetails=@($allBuildEvidence[0].localOperatorCli.preflightControlFlow.methodDetails); methodRows=@($allBuildEvidence[0].localOperatorCli.preflightControlFlow.methodRows); callRows=@($allBuildEvidence[0].localOperatorCli.preflightControlFlow.callRows); tokenRows=@($allBuildEvidence[0].localOperatorCli.preflightControlFlow.tokenRows); methodManifest=$allBuildEvidence[0].localOperatorCli.preflightControlFlow.methodManifest; callManifest=$allBuildEvidence[0].localOperatorCli.preflightControlFlow.callManifest; tokenManifest=$allBuildEvidence[0].localOperatorCli.preflightControlFlow.tokenManifest; closureManifest=$allBuildEvidence[0].localOperatorCli.preflightControlFlow.closureManifest; forbiddenMatchCount=[int]$allBuildEvidence[0].localOperatorCli.preflightControlFlow.forbiddenMatchCount; stableAcrossBuilds=[bool]$localOperatorPreflightIlStable; profileMatch=$allBuildEvidence[0].localOperatorCli.preflightControlFlow.profileMatch; discoveryBypass=[bool]$retainedOperatorDiscovery }
        preflightGoldenVectors = $allBuildEvidence[0].localOperatorCli.preflightGoldenVectors
        wrapperMaximumBytes = [int]$allBuildEvidence[0].localOperatorHarness.wrapperMaximumBytes
        cleanBuildHarnessReproducible = [bool]($allBuildEvidence[0].localOperatorHarness.sha256 -ceq $allBuildEvidence[1].localOperatorHarness.sha256)
        cleanBuildCliReproducible = [bool]($allBuildEvidence[0].localOperatorCli.sha256 -ceq $allBuildEvidence[1].localOperatorCli.sha256)
        cliBytes = [int64]$allBuildEvidence[0].localOperatorCli.bytes
        cliSha256 = [string]$allBuildEvidence[0].localOperatorCli.sha256
        harnessBytes = [int64]$allBuildEvidence[0].localOperatorHarness.bytes
        harnessSha256 = [string]$allBuildEvidence[0].localOperatorHarness.sha256
        cliMetadataInventory = $allBuildEvidence[0].localOperatorCli.metadataInventory
        harnessMetadataInventory = $allBuildEvidence[0].localOperatorHarness.metadataInventory
        metadataStableAcrossBuilds = [bool]$localOperatorMetadataStable
        normalizedNativeInventory = $allBuildEvidence[0].localOperatorCli.normalizedNativeInventory
        normalizedNativeStableAcrossBuilds = [bool]$localOperatorNativeStable
        normalizedNativeProfileMatch = if($retainedOperatorDiscovery){$null}else{[bool]$localOperatorNativeProfileMatch}
        loopbackMetadataAllowlist = $allBuildEvidence[0].localOperatorCli.loopbackMetadataAllowlist
        loopbackMetadataStableAcrossBuilds = [bool]$localOperatorLoopbackStable
        channels = $allBuildEvidence[0].localOperatorCli.channels
        channelMatrixPass = [bool]$allBuildEvidence[0].localOperatorCli.channelMatrixPass
        negativeSpecimensPass = [bool]$localOperatorNegativeSpecimensPass
        negativeSpecimens = $localOperatorNegativeSpecimenEvidence
        preflightSpecimens = [ordered]@{ names=$actualPreflightNegativeNames; count=[int]$preflightNegativeSpecimenEvidence.Count; framedBytes=[int]$preflightSpecimenFrameBytes.Length; sha256=[string]$preflightSpecimenFrameSha256; rows=$preflightNegativeSpecimenEvidence; pass=[bool]$preflightNegativeSpecimensPass }
        testsPass = [bool]$localOperatorTestsPass
        retainedOverallTechnicalPass = [bool]$retainedOverallTechnicalPass
        dryRunTechnicalPass = [bool]$dryRunTechnicalPass
        overallTechnicalPass = [bool]$overallTechnicalPass
        network = 'OFFLINE_NONE_LIVE_LOOPBACK_ONLY'
        writes = 'NONE'
    }
    localModelProvider = [ordered]@{
        contract = 'EAIRA_LOCAL_MODEL_PROVIDER_V1'
        providerId = [string]$profile.localModelProvider.providerId
        model = [string]$profile.localModelProvider.model
        digest = [string]$profile.localModelProvider.digest
        baseUri = [string]$profile.localModelProvider.baseUri
        timeoutSeconds = [int]$profile.localModelProvider.timeoutSeconds
        maximumRequestBytes = [int]$profile.localModelProvider.maximumRequestBytes
        maximumResponseBytes = [int]$profile.localModelProvider.maximumResponseBytes
        maximumOutputUtf16CodeUnits = [int]$profile.localModelProvider.maximumOutputUtf16CodeUnits
        writes = [string]$profile.localModelProvider.writes
        fakeHarnessTestsPassed = [int]$allBuildEvidence[0].localProviderHarness.testsPassed
        fakeHarnessReproducible = [bool]($allBuildEvidence[0].localProviderHarness.sha256 -eq $allBuildEvidence[1].localProviderHarness.sha256)
        transportPolicyHarnessTestsPassed = [int]$allBuildEvidence[0].transportPolicyHarness.testsPassed
        transportPolicyHarnessReproducible = [bool]($allBuildEvidence[0].transportPolicyHarness.sha256 -eq $allBuildEvidence[1].transportPolicyHarness.sha256)
        cliMetadataAllowlist = $profile.cliMetadataAllowlist
        liveProbeIncluded = $false
        testsPass = [bool]$taskIntakeTestsPass
    }
    releaseOutputs = $releaseOutputs
    signing = [ordered]@{
        performed = $false
        certificateAccessed = $false
        privateKeyAccessed = $false
        requiredForGate25Completion = $true
    }
    windowsMutation = [ordered]@{
        service = $false
        identity = $false
        membership = $false
        directoryAcl = $false
        tpm = $false
    }
}

$manifestPath = Join-Path $resolvedOutput 'gate25-unsigned-build-manifest.json'
$manifest | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
$manifestHash = Get-Sha256 -LiteralPath $manifestPath

Write-Output ("STATUS=" + $manifest.status)
Write-Output ("REPRODUCIBLE_BYTE_FOR_BYTE=" + $reproducible.ToString().ToUpperInvariant())
Write-Output ("OFFLINE_TESTS_PASS=" + $offlineTestsPass.ToString().ToUpperInvariant())
Write-Output ("FUNCTIONAL_SLICE_TESTS_PASS=" + $functionalTestsPass.ToString().ToUpperInvariant())
Write-Output ("TASK_INTAKE_TESTS_PASS=" + $taskIntakeTestsPass.ToString().ToUpperInvariant())
Write-Output ("LOCAL_PROVIDER_FAKE_TESTS_PASS=" + $taskIntakeTestsPass.ToString().ToUpperInvariant())
Write-Output ("PROJECT_QA_OFFLINE_TESTS_PASS=" + $projectQaTestsPass.ToString().ToUpperInvariant())
Write-Output ("LOCAL_OPERATOR_OFFLINE_TESTS_PASS=" + $localOperatorTestsPass.ToString().ToUpperInvariant())
Write-Output 'EXTERNAL_SIGNING_ELIGIBLE=FALSE'
Write-Output 'SIGNATURE_ONLY_BLOCKED=FALSE'
Write-Output ("MANIFEST_SHA256=" + $manifestHash)

if (-not $m4TechnicalChecksPass) { exit 2 }
