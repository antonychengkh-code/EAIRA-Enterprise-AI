using System;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading;

namespace EAIRA.AgentServices.Functional
{
    internal sealed class OllamaLoopbackTransport : ILocalByteTransport
    {
        private const string BaseAddress = "http://127.0.0.1:11434/";
        private const int MaximumResponseBytes = 65536;
        private readonly HttpClient client;
        private bool disposed;

        internal OllamaLoopbackTransport()
        {
            HttpClientHandler handler = new HttpClientHandler();
            try
            {
                handler.UseProxy = false;
                handler.Proxy = null;
                handler.AllowAutoRedirect = false;
                handler.UseCookies = false;
                handler.UseDefaultCredentials = false;
                handler.Credentials = null;
                handler.PreAuthenticate = false;
                handler.AutomaticDecompression = DecompressionMethods.None;
                client = new HttpClient(handler, true);
                client.Timeout = Timeout.InfiniteTimeSpan;
            }
            catch
            {
                handler.Dispose();
                throw new LocalProviderException();
            }
        }

        public byte[] GetTags(CancellationToken cancellationToken)
        {
            return Send(HttpMethod.Get, "api/tags", null, cancellationToken);
        }

        public byte[] SendChat(byte[] canonicalRequest, CancellationToken cancellationToken)
        {
            if (canonicalRequest == null || canonicalRequest.Length == 0 || canonicalRequest.Length > 16384)
            {
                throw new LocalProviderException();
            }
            return Send(HttpMethod.Post, "api/chat", canonicalRequest, cancellationToken);
        }

        public void Dispose()
        {
            if (disposed) { return; }
            disposed = true;
            client.Dispose();
        }

        private byte[] Send(HttpMethod method, string relativePath, byte[] body, CancellationToken cancellationToken)
        {
            if (disposed ||
                (method != HttpMethod.Get && method != HttpMethod.Post) ||
                (!String.Equals(relativePath, "api/tags", StringComparison.Ordinal) &&
                 !String.Equals(relativePath, "api/chat", StringComparison.Ordinal)))
            {
                throw new LocalProviderException();
            }

            try
            {
                using (HttpRequestMessage request = new HttpRequestMessage(method, new Uri(new Uri(BaseAddress), relativePath)))
                {
                    if (body != null)
                    {
                        ByteArrayContent content = new ByteArrayContent(body);
                        content.Headers.ContentType = new MediaTypeHeaderValue("application/json");
                        request.Content = content;
                    }
                    using (HttpResponseMessage response = client.SendAsync(
                        request,
                        HttpCompletionOption.ResponseHeadersRead,
                        cancellationToken).GetAwaiter().GetResult())
                    {
                        if (response.Content == null)
                        {
                            throw new LocalProviderException();
                        }
                        ValidateResponsePolicy(response.StatusCode, response.Content.Headers);
                        using (Stream stream = response.Content.ReadAsStreamAsync().GetAwaiter().GetResult())
                        {
                            return ReadBounded(stream, cancellationToken);
                        }
                    }
                }
            }
            catch (LocalProviderException) { throw; }
            catch (Exception) { throw new LocalProviderException(); }
        }

        internal static void ValidateResponsePolicy(HttpStatusCode statusCode, HttpContentHeaders headers)
        {
            if (statusCode != HttpStatusCode.OK ||
                headers == null || headers.ContentType == null ||
                !String.Equals(headers.ContentType.MediaType, "application/json", StringComparison.OrdinalIgnoreCase))
            {
                throw new LocalProviderException();
            }

            int parameterCount = 0;
            foreach (NameValueHeaderValue parameter in headers.ContentType.Parameters)
            {
                parameterCount++;
                if (parameterCount > 1 ||
                    parameter == null ||
                    !String.Equals(parameter.Name, "charset", StringComparison.OrdinalIgnoreCase) ||
                    String.IsNullOrEmpty(parameter.Value) ||
                    !String.Equals(parameter.Value.Trim('"'), "utf-8", StringComparison.OrdinalIgnoreCase))
                {
                    throw new LocalProviderException();
                }
            }
            if (headers.ContentEncoding.Count != 0) { throw new LocalProviderException(); }
            long? length = headers.ContentLength;
            if (length.HasValue && (length.Value < 0 || length.Value > MaximumResponseBytes))
            {
                throw new LocalProviderException();
            }
        }

        internal static byte[] ReadBounded(Stream stream, CancellationToken cancellationToken)
        {
            if (stream == null || !stream.CanRead) { throw new LocalProviderException(); }
            byte[] buffer = new byte[MaximumResponseBytes + 1];
            int total = 0;
            while (true)
            {
                int read = stream.ReadAsync(
                    buffer,
                    total,
                    buffer.Length - total,
                    cancellationToken).GetAwaiter().GetResult();
                if (read == 0) { break; }
                total += read;
                if (total > MaximumResponseBytes || total == buffer.Length) { throw new LocalProviderException(); }
            }
            byte[] result = new byte[total];
            Buffer.BlockCopy(buffer, 0, result, 0, total);
            return result;
        }
    }
}

#if TRANSPORT_POLICY_TESTS
namespace EAIRA.AgentServices.Tests
{
    using EAIRA.AgentServices.Functional;

    internal static class LoopbackTransportPolicyHarness
    {
        private static int passed;

        private static void Require(bool condition)
        {
            if (!condition) { throw new ContractException("Transport policy test failed."); }
            passed++;
        }

        private static void RequireLocalFailure(Action action)
        {
            bool failed = false;
            try { action(); }
            catch (LocalProviderException) { failed = true; }
            Require(failed);
        }

        private static HttpContentHeaders Headers(string mediaType, string charset, long? contentLength)
        {
            ByteArrayContent content = new ByteArrayContent(new byte[0]);
            content.Headers.ContentType = new MediaTypeHeaderValue(mediaType);
            if (charset != null) { content.Headers.ContentType.CharSet = charset; }
            content.Headers.ContentLength = contentLength;
            return content.Headers;
        }

        private static void RunAll()
        {
            HttpContentHeaders noCharset = Headers("application/json", null, 0);
            OllamaLoopbackTransport.ValidateResponsePolicy(HttpStatusCode.OK, noCharset);
            Require(true);

            HttpContentHeaders utf8 = Headers("application/json", "UTF-8", 65536);
            OllamaLoopbackTransport.ValidateResponsePolicy(HttpStatusCode.OK, utf8);
            Require(true);

            RequireLocalFailure(
                delegate { OllamaLoopbackTransport.ValidateResponsePolicy(HttpStatusCode.Found, noCharset); });
            RequireLocalFailure(
                delegate { OllamaLoopbackTransport.ValidateResponsePolicy(HttpStatusCode.OK, Headers("text/plain", null, 0)); });
            RequireLocalFailure(
                delegate { OllamaLoopbackTransport.ValidateResponsePolicy(HttpStatusCode.OK, Headers("application/json", "utf-16", 0)); });

            HttpContentHeaders extraParameter = Headers("application/json", null, 0);
            extraParameter.ContentType.Parameters.Add(new NameValueHeaderValue("profile", "x"));
            RequireLocalFailure(
                delegate { OllamaLoopbackTransport.ValidateResponsePolicy(HttpStatusCode.OK, extraParameter); });

            HttpContentHeaders encoded = Headers("application/json", null, 0);
            encoded.ContentEncoding.Add("gzip");
            RequireLocalFailure(
                delegate { OllamaLoopbackTransport.ValidateResponsePolicy(HttpStatusCode.OK, encoded); });
            RequireLocalFailure(
                delegate { OllamaLoopbackTransport.ValidateResponsePolicy(HttpStatusCode.OK, Headers("application/json", null, 65537)); });

            using (MemoryStream exact = new MemoryStream(new byte[65536], false))
            {
                Require(OllamaLoopbackTransport.ReadBounded(exact, CancellationToken.None).Length == 65536);
            }
            RequireLocalFailure(delegate
            {
                using (MemoryStream over = new MemoryStream(new byte[65537], false))
                {
                    OllamaLoopbackTransport.ReadBounded(over, CancellationToken.None);
                }
            });
        }

        internal static int Main(string[] args)
        {
            if (args == null || args.Length != 1 || !String.Equals(args[0], "--self-test", StringComparison.Ordinal)) { return 64; }
            try
            {
                RunAll();
                Console.WriteLine("{\"status\":\"PASS\",\"contract\":\"EAIRA_LOCAL_MODEL_PROVIDER_V1\",\"testsPassed\":" +
                    passed + ",\"network\":\"NONE\",\"writes\":\"NONE\",\"transport\":\"POLICY_ONLY_FAKE_STREAM\"}");
                return 0;
            }
            catch (Exception exception)
            {
                Console.WriteLine("{\"status\":\"FAIL\",\"errorType\":" + ContractCodec.Json(exception.GetType().Name) + "}");
                return 70;
            }
        }
    }
}
#endif
