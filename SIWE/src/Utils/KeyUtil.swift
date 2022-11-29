import Foundation
import secp256k1
import Logging

enum KeyUtilError: Error {
    case invalidContext
    case privateKeyInvalid
    case unknownError
    case signatureFailure
    case signatureParseFailure
    case badArguments
}

class KeyUtil {
    private static var logger: Logger {
        Logger(label: "web3.swift.key-util")
    }

    static func recoverPublicKey(message: Data, signature: Data) throws -> String {
        if signature.count != 65 || message.count != 32 {
            throw KeyUtilError.badArguments
        }

        guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY)) else {
            logger.warning("Failed to sign message: invalid context.")
            throw KeyUtilError.invalidContext
        }
        defer { secp256k1_context_destroy(ctx) }

        // get recoverable signature
        let signaturePtr = UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>.allocate(capacity: 1)
        defer { signaturePtr.deallocate() }

        let serializedSignature = Data(signature[0..<64])
        var v = Int32(signature[64])
        if v >= 27 && v <= 30 {
            v -= 27
        } else if v >= 31 && v <= 34 {
            v -= 31
        } else if v >= 35 && v <= 38 {
            v -= 35
        }

        try serializedSignature.withUnsafeBytes {
            guard secp256k1_ecdsa_recoverable_signature_parse_compact(ctx, signaturePtr, $0.bindMemory(to: UInt8.self).baseAddress!, v) == 1 else {
                logger.warning("Failed to parse signature: recoverable ECDSA signature parse failed.")
                throw KeyUtilError.signatureParseFailure
            }
        }
        let pubkey = UnsafeMutablePointer<secp256k1_pubkey>.allocate(capacity: 1)
        defer { pubkey.deallocate() }

        try message.withUnsafeBytes {
            guard secp256k1_ecdsa_recover(ctx, pubkey, signaturePtr, $0.bindMemory(to: UInt8.self).baseAddress!) == 1 else {
                throw KeyUtilError.signatureFailure
            }
        }
        var size: Int = 65
        var rv = Data(count: size)
        rv.withUnsafeMutableBytes {
            secp256k1_ec_pubkey_serialize(ctx, $0.bindMemory(to: UInt8.self).baseAddress!, &size, pubkey, UInt32(SECP256K1_EC_UNCOMPRESSED))
            return
        }
        return "0x\(rv[1...].web3.keccak256.web3.hexString.suffix(40))"
    }
}
