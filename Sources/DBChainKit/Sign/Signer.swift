//
//  Signer.swift
//  DBChain
//
//  Created by iOS on 2020/10/22.
//

import Foundation
import SawtoothSigning
import CommonCrypto
import secp256k1
import CryptoSwift

public func signSawtoothSigning(data: [UInt8], privateKey: [UInt8]) throws -> Data {
    let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))
    var sig = secp256k1_ecdsa_signature()

    var msgDigest = signerHash(data: data)
    let resultSign = msgDigest.withUnsafeMutableBytes { (msgDigestBytes) in
        secp256k1_ecdsa_sign(ctx!, &sig, msgDigestBytes, privateKey, nil, nil)
    }
    if resultSign == 0 {
        throw SigningError.invalidPrivateKey
    }

    var input: [UInt8] {
        var tmp = sig.data
        return [UInt8](UnsafeBufferPointer(start: &tmp.0, count: MemoryLayout.size(ofValue: tmp)))
    }
    var compactSig = secp256k1_ecdsa_signature()

    if secp256k1_ecdsa_signature_parse_compact(ctx!, &compactSig, input) == 0 {
        secp256k1_context_destroy(ctx)
        throw SigningError.invalidSignature
    }

    var csigArray: [UInt8] {
        var tmp = compactSig.data
        return [UInt8](UnsafeBufferPointer(start: &tmp.0, count: MemoryLayout.size(ofValue: tmp)))
    }

    secp256k1_context_destroy(ctx)
    return Data(csigArray)
}


public func verifySawtoothSigning(signature: String, data: [UInt8], publicKey: [UInt8]) throws-> Bool {
    let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_VERIFY))

    var sig = secp256k1_ecdsa_signature()
    if secp256k1_ecdsa_signature_parse_compact(ctx!, &sig, signature.signertoBytes) == 0 {
        secp256k1_context_destroy(ctx)
        throw SigningError.invalidSignature
    }

    var pubKey = secp256k1_pubkey()
    let resultParsePublicKey = secp256k1_ec_pubkey_parse(ctx!, &pubKey, publicKey,
                                                         publicKey.count)
    if resultParsePublicKey == 0 {
        throw SigningError.invalidPublicKey
    }

    let msgDigest = signerHash(data: data)
    let result = msgDigest.withUnsafeBytes { (msgDigestBytes) -> Int32 in
        return secp256k1_ecdsa_verify(ctx!, &sig, msgDigestBytes, &pubKey)
    }

    secp256k1_context_destroy(ctx)

    if result == 1 {
        return true
    } else {
        return false
    }
}


extension UInt8 {
    static func signerfromHex(hexString: String) -> UInt8 {
        return UInt8(strtoul(hexString, nil, 16))
    }
}

extension StringProtocol {
    var signertoBytes: [UInt8] {
        let hexa = Array(self)
        return stride(from: 0, to: count, by: 2).compactMap {
            UInt8.signerfromHex(hexString: String(hexa[$0..<$0.advanced(by: 2)]))
        }
    }
}


public enum ChainType: String {
    case COSMOS_MAIN
    case IRIS_MAIN
    case BINANCE_MAIN
    case KAVA_MAIN
    case IOV_MAIN
    case BAND_MAIN
    case SECRET_MAIN

    case BINANCE_TEST
    case KAVA_TEST
    case IOV_TEST
    case OKEX_TEST
    case CERTIK_TEST

    static func SUPPRT_CHAIN() -> Array<ChainType> {
        var result = [ChainType]()
        result.append(COSMOS_MAIN)
        result.append(IRIS_MAIN)
        result.append(BINANCE_MAIN)
        result.append(IOV_MAIN)
        result.append(KAVA_MAIN)
        result.append(BAND_MAIN)
        result.append(SECRET_MAIN)

//        result.append(BINANCE_TEST)
//        result.append(KAVA_TEST)
//        result.append(IOV_TEST)
        result.append(OKEX_TEST)
        result.append(CERTIK_TEST)
        return result
    }
}

/// 获取地址
/// - Parameters:
///   - pubHex: 公钥哈希
///   - chain: chain 类型
/// - Returns: 返回地址
public func DBGetPubToDpAddress(_ pubHex:Data, _ chain:ChainType) -> String {
   let pub = [UInt8](pubHex)
   var result = ""
   let sha256 = Digest.sha256(pub)
   let ripemd160 = RIPEMD160.hash(Data(sha256))

   if (chain == ChainType.COSMOS_MAIN) {
       result = try! SegwitAddrCoder.shared.encode2(hrp: "cosmos", program: ripemd160)
   } else if (chain == ChainType.IRIS_MAIN) {
       result = try! SegwitAddrCoder.shared.encode2(hrp: "iaa", program: ripemd160)
   } else if (chain == ChainType.BINANCE_MAIN) {
       result = try! SegwitAddrCoder.shared.encode2(hrp: "bnb", program: ripemd160)
   } else if (chain == ChainType.KAVA_MAIN || chain == ChainType.KAVA_TEST) {
       result = try! SegwitAddrCoder.shared.encode2(hrp: "kava", program: ripemd160)
   } else if (chain == ChainType.BAND_MAIN) {
       result = try! SegwitAddrCoder.shared.encode2(hrp: "band", program: ripemd160)
   } else if (chain == ChainType.SECRET_MAIN) {
       result = try! SegwitAddrCoder.shared.encode2(hrp: "secret", program: ripemd160)
   } else if (chain == ChainType.BINANCE_TEST) {
       result = try! SegwitAddrCoder.shared.encode2(hrp: "tbnb", program: ripemd160)
   } else if (chain == ChainType.IOV_MAIN || chain == ChainType.IOV_TEST) {
       result = try! SegwitAddrCoder.shared.encode2(hrp: "star", program: ripemd160)
   } else if (chain == ChainType.OKEX_TEST) {
       result = try! SegwitAddrCoder.shared.encode2(hrp: "okexchain", program: ripemd160)
   } else if (chain == ChainType.CERTIK_TEST) {
       result = try! SegwitAddrCoder.shared.encode2(hrp: "certik", program: ripemd160)
   }
   return result
}

public func signerHash(data: [UInt8]) -> Data {
    var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
    _ = digest.withUnsafeMutableBytes { (digestBytes) in
        CC_SHA256(data, CC_LONG(data.count), digestBytes)
    }
    return digest
}
