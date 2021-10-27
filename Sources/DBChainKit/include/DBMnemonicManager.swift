//
//  File.swift
//  
//
//  Created by iOS on 2021/6/18.
//

import Foundation

public struct DBMnemonicManager {

    public init(){ }
    
    /// 获取公钥私钥地址. 传入由12个英文单词以逗号分隔的数组, 返回格式为 字符串
    /// - Parameter mnemonicArr: 由12个英文单词以逗号分隔的数组,
    /// - Returns: 返回公钥私钥地址字符串
    public func MnemonicGetPrivateKeyStrAndPublickStrWithMnemonicArr(_ mnemonicArr: [String]) -> (publicKeyString:String,privateKeyString:String,privateKeyUint:[UInt8],address:String) {
        guard mnemonicArr.count == 12 else {
            assert(mnemonicArr.count != 12, "PLEASE INPUT IN A STRING ARRAY OF 12 English words,English Comma Separated")
            return ("","",[],"")
        }
        /// 生成助记词
        let tempStr = mnemonicArr.joined(separator: ",")
        let tempMnemoicStr = tempStr.replacingOccurrences(of: ",", with: " ")
        let lowMnemoicStr = tempMnemoicStr.lowercased()

        let seedBip39 = Mnemonic.createSeed(mnemonic: lowMnemoicStr)
        let privateKey = PrivateKey(seed: seedBip39, coin: .bitcoin)

        //私钥和密钥派生（BIP39）
        let purpose = privateKey.derived(at: .hardened(44))
        let coinType = purpose.derived(at: .hardened(118))
        let account = coinType.derived(at: .hardened(0))
        let change = account.derived(at: .notHardened(0))
        let dbPrivateKey = change.derived(at: .notHardened(0))
        // ************  公钥  *************
        let publikey = PublicKey(privateKey: dbPrivateKey.raw, coin: .bitcoin)
        let address = DBGetPubToDpAddress(publikey.data, ChainType.COSMOS_MAIN)

        return (publikey.data.toHexString(),dbPrivateKey.raw.toHexString(),[UInt8](dbPrivateKey.raw),address)
    }

}
