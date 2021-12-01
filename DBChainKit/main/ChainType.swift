//
//  ChainType.swift
//  DBChainKit
//
//  Created by iOS on 2021/12/1.
//

import Foundation
import HDWalletSDK
import CryptoSwift
import CommonCrypto

@objc public enum ChainType: Int {
    case COSMOS_MAIN
    case IRIS_MAIN
    case BINANCE_MAIN
    case KAVA_MAIN
    case IOV_MAIN
    case BAND_MAIN
    case SECRET_MAIN

    case DBCHAIN_MAIN

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

        result.append(DBCHAIN_MAIN)

        result.append(BINANCE_TEST)
        result.append(KAVA_TEST)
        result.append(IOV_TEST)
        result.append(OKEX_TEST)
        result.append(CERTIK_TEST)
        return result
    }
}


public func getPubToDpAddress(_ pubHex:Data, _ chain:ChainType) -> String {

   let pub = [UInt8](pubHex)
   var result = ""
   let sha256 = Digest.sha256(pub)
   let ripemd160 = RIPEMD160.hash(Data(sha256))

   if (chain == ChainType.COSMOS_MAIN) {
       result = try! SegwitAddrCoder.shared.encode2(hrp: "cosmos", program: ripemd160)
   } else if (chain == ChainType.DBCHAIN_MAIN) {

    /// 算法不同
    let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
    var hash = [UInt8](repeating: 0, count: digestLength)
    let pubHexData = pubHex as NSData
    CC_SHA256(pubHexData.bytes, UInt32(pubHexData.length), &hash)
    let dbsha256 = NSData(bytes: hash, length: digestLength)

    let shaArr = dbsha256[0...19]
    let chain160 = Data(shaArr)

    result = try! SegwitAddrCoder.shared.encode2(hrp: "dbchain", program: chain160)

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
