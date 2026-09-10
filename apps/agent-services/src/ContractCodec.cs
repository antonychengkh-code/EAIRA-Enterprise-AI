using System;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;

namespace EAIRA.AgentServices.Functional
{
    internal sealed class ContractException : Exception
    {
        internal ContractException(string message) : base(message) { }
    }

    internal static class ContractCodec
    {
        internal const string ZeroHash = "0000000000000000000000000000000000000000000000000000000000000000";

        internal static void RequireWellFormedUtf16(string value, string fieldName)
        {
            if (value == null) { throw new ContractException(fieldName + " cannot be null."); }
            for (int index = 0; index < value.Length; index++)
            {
                char character = value[index];
                if (Char.IsHighSurrogate(character))
                {
                    if (index + 1 >= value.Length || !Char.IsLowSurrogate(value[index + 1])) { throw new ContractException(fieldName + " contains malformed UTF-16."); }
                    index++;
                }
                else if (Char.IsLowSurrogate(character)) { throw new ContractException(fieldName + " contains malformed UTF-16."); }
            }
        }

        internal static UTF8Encoding Utf8Strict(string fieldName)
        {
            if (String.IsNullOrEmpty(fieldName)) { throw new ContractException("UTF-8 field name is required."); }
            return new UTF8Encoding(false, true);
        }

        internal static byte[] Sha256(byte[] input)
        {
            if (input == null) { throw new ContractException("Digest input cannot be null."); }
            using (SHA256 algorithm = SHA256.Create()) { return algorithm.ComputeHash(input); }
        }

        internal static string Sha256Hex(byte[] input)
        {
            byte[] digest = Sha256(input);
            StringBuilder builder = new StringBuilder(64);
            for (int index = 0; index < digest.Length; index++) { builder.Append(digest[index].ToString("X2", CultureInfo.InvariantCulture)); }
            return builder.ToString();
        }

        internal static string Sha256Hex(string value)
        {
            RequireWellFormedUtf16(value, "Digest input");
            return Sha256Hex(Utf8Strict("Digest input").GetBytes(value));
        }

        internal static byte[] U32BE(uint value)
        {
            return new byte[] { (byte)(value >> 24), (byte)(value >> 16), (byte)(value >> 8), (byte)value };
        }

        internal static byte[] Concat(params byte[][] values)
        {
            if (values == null) { throw new ContractException("Byte frames cannot be null."); }
            int total = 0;
            for (int index = 0; index < values.Length; index++)
            {
                if (values[index] == null) { throw new ContractException("Byte frame cannot be null."); }
                total = checked(total + values[index].Length);
            }
            byte[] result = new byte[total];
            int offset = 0;
            for (int index = 0; index < values.Length; index++)
            {
                Buffer.BlockCopy(values[index], 0, result, offset, values[index].Length);
                offset += values[index].Length;
            }
            return result;
        }

        internal static string Field(string value)
        {
            RequireWellFormedUtf16(value, "Canonical field");
            return value.Length.ToString(CultureInfo.InvariantCulture) + ":" + value;
        }

        internal static string Json(string value)
        {
            if (value == null) { return "null"; }
            RequireWellFormedUtf16(value, "JSON value");
            StringBuilder builder = new StringBuilder(value.Length + 2);
            builder.Append('"');
            for (int index = 0; index < value.Length; index++)
            {
                char character = value[index];
                switch (character)
                {
                    case '"': builder.Append("\\\""); break;
                    case '\\': builder.Append("\\\\"); break;
                    case '\b': builder.Append("\\b"); break;
                    case '\f': builder.Append("\\f"); break;
                    case '\n': builder.Append("\\n"); break;
                    case '\r': builder.Append("\\r"); break;
                    case '\t': builder.Append("\\t"); break;
                    default:
                        if (character < 0x20)
                        {
                            builder.Append("\\u");
                            builder.Append(((int)character).ToString("X4", CultureInfo.InvariantCulture));
                        }
                        else { builder.Append(character); }
                        break;
                }
            }
            builder.Append('"');
            return builder.ToString();
        }

        internal static void RequireHash(string value, string fieldName)
        {
            if (value == null || value.Length != 64) { throw new ContractException(fieldName + " must be SHA-256 hex."); }
            for (int index = 0; index < value.Length; index++)
            {
                char character = value[index];
                if (!((character >= '0' && character <= '9') || (character >= 'A' && character <= 'F'))) { throw new ContractException(fieldName + " must use uppercase SHA-256 hex."); }
            }
        }
    }
}
