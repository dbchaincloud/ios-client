//
//  DBChainSm2.swift
//  DBChainKit
//
//  Created by iOS on 2021/11/26.
//

import Foundation
import DBChainSm2
import HDWalletSDK

public class Sm2 : Compatible {

    public init(){}

    /// 获取token
    /// - Parameters:
    ///   - privateKeyStr: 私钥
    ///   - publicKeyStr: 公钥
    /// - Returns: token
    private func token(privateKeyStr: String,publicKeyStr: String) -> String {
        /// 时间戳
        let timeInterval: TimeInterval = Date().timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        let millisecondStr = "\(millisecond)"
        // sm2 签名
        let plainHex = DBChainGMUtils.string(toHex: millisecondStr)
        let userHex = DBChainGMUtils.string(toHex: "1234567812345678")
        /// 对当前时间戳签名
        let signMilliSecond = DBChainGMSm2Utils.signHex(plainHex!, privateKey: privateKeyStr, userHex: userHex)
        let timeBase58 = Base58.encode(signMilliSecond!.hexaData)
        let publicKeyBase58 = Base58.encode(publicKeyStr.hexaData)
        return "\(publicKeyBase58):" + "\(millisecond):" + "\(timeBase58)"
    }

    public func generatePublicKeyBy(privateKey: String) -> String {
        let publickey = DBChainGMSm2Utils.adoptPrivatekeyGetPublicKey(privateKey, isCompress: true)
        return publickey
    }

    public func generateAddressBy(publicKey: String) -> String {
        return getPubToDpAddress(publicKey.hexaData, ChainType.DBCHAIN_MAIN)
    }

    public func generateTokenBy(publicKey: String, privateKey: String) -> String {
        return self.token(privateKeyStr: privateKey, publicKeyStr: publicKey)
    }
    
    public func signData(signHex: String, privateKeyStr: String) -> String {
        /// sm2 签名
        let userid = "1234567812345678"
        let plainHex = DBChainGMUtils.string(toHex: signHex)
        let userHex = DBChainGMUtils.string(toHex: userid)
        let signStr = DBChainGMSm2Utils.signHex(plainHex!, privateKey: privateKeyStr, userHex: userHex)
        let signBaseStr = signStr!.hexaData.base64EncodedString()
        return signBaseStr
    }

    public func signDictionaryType(publicKeyStr: String) -> [String : Any] {
        let publickBaseStr = publicKeyStr.hexaData.base64EncodedString()
        let signDivSorted = ["key":["type":"tendermint/PubKeySm2",
                                    "value":publickBaseStr]]
        return signDivSorted
    }
}
