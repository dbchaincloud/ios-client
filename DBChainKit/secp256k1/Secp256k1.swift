//
//  DBChainSecp256k1.swift
//  DBChainKit
//
//  Created by iOS on 2021/11/26.
//

import Foundation
import CryptoKit
import secp256k1
import CryptoSwift
import Alamofire
import HDWalletSDK

public class Secp256k1 : Compatible {

    public init() {}


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
        let secondUint = [UInt8](millisecondStr.utf8)
        let privateBytes = privateKeyStr.hexaBytes
        let publicData = publicKeyStr.hexaData
        /// secp256k1 签名
        do {
            let signMilliSecond = try signSawtoothSigning(data: secondUint, privateKey: privateBytes)
            let timeBase58 = Base58.encode(signMilliSecond)
            let publicKeyBase58 = Base58.encode(publicData)
            let token = "\(publicKeyBase58):" + "\(millisecond):" + "\(timeBase58)"
            return token
        } catch {
            return ""
        }
    }


    public func generatePublicKeyBy(privateKey: String) -> String {
        let publikey = HDWalletSDK.PublicKey(privateKey: privateKey.hexaData, coin: .bitcoin)
        return publikey.data.dataToHexString()
    }

    public func generateAddressBy(publicKey: String) -> String {
        return getPubToDpAddress(publicKey.hexaData, ChainType.COSMOS_MAIN)
    }

    public func generateTokenBy(publicKey: String, privateKey: String) -> String {
        return self.token(privateKeyStr: privateKey, publicKeyStr: publicKey)
    }


    public func signData(signHex: String, privateKeyStr: String) -> String {
        let strArr = [UInt8](signHex.utf8)
        do {
            let signData = try signSawtoothSigning(data: strArr, privateKey: privateKeyStr.hexaBytes)

            let signStr = signData.base64EncodedString()
            return signStr
            
        } catch {
            return ""
        }
    }

    public func signDictionaryType(publicKeyStr: String) -> [String : Any] {
        let publicBase = publicKeyStr.hexaData.base64EncodedString()
        return ["key":["type":"tendermint/PubKeySecp256k1",
                       "value":publicBase]]
    }

}
