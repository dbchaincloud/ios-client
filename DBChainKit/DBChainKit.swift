import Foundation
import CryptoKit
import SawtoothSigning
import secp256k1
import CryptoSwift
import Alamofire
import HDWalletSDK

public let DBChain = DBChainKit.shared

open class DBChainKit :NSObject {
    //单例
    public static let shared = DBChainKit()
    private override init() {}

    var newPrivateKey : String?
    var newMnemonicString : String?
    var newPublicKey : String?

    /// 助记词
    /// - set: 自定义助记词  由 12 个英文单词由空格隔开
    /// - get: 随机生成助记词
    public var mnemonicStr : String {
        set {
            /// 判断自定义助记词合法性
            let tempArr = newValue.split(separator: " ")
            assert(tempArr.count == 12, "Please enter a string of 12 English words separated by spaces")
            self.newMnemonicString = newValue
        }
        get {
            if self.newMnemonicString != nil {
                return self.newMnemonicString!
            }
            return self.createMnemonic()
        }
    }

    /// 私钥:
    /// - set: 自定义私钥
    /// - get: 已自定义助记词时, 返回自定义助记词生成的私钥, 未自定义助记词时,返回通过随机生成助记词生成的私钥
    public var privatekey: String {
        set {
            self.newPrivateKey = newValue
        }
        get {
            if self.newPrivateKey != nil {
                return newPrivateKey!
            } else if self.newMnemonicString != nil {
                return self.privateKey(mnemonicStr: self.newMnemonicString!)
            } else {
                let mnemonic = self.createMnemonic()
                let priStr = self.privateKey(mnemonicStr: mnemonic)
                return priStr
            }
        }
    }

    /// 公钥
    /// get: 先获取私钥才能得到相对应的公钥,否则返回空
    public var publickey: String {
        get {
            if self.newPrivateKey != nil {
                let publikey = HDWalletSDK.PublicKey(privateKey: self.newPrivateKey!.hexaData, coin: .bitcoin)
                return publikey.data.dataToHexString()
            }
            return ""
        }
    }

    /// 地址
    /// get: 先获取公钥才能得出地址, 否则返回为空, 类型指定为 COSMOS_MAIN
    public var address: String {
        get {
            if !self.publickey.isBlank {
                return getPubToDpAddress(self.publickey.hexaData, ChainType.COSMOS_MAIN)
            }
            return ""
        }
    }

    /// 生成随机助记词
    public func createMnemonic() -> String {
        let mnemonic = Mnemonic.create()
        self.newMnemonicString = mnemonic
        return mnemonic
    }

    /// 通过助记词生成私钥
    /// - Parameter mnemonicStr: 助记词 12 个英文单词由空格隔开
    /// - Returns: 私钥字符串
    public func privateKey(mnemonicStr: String) -> String {
        /// 判断助记词合法性
        let tempArr = mnemonicStr.split(separator: " ")
        assert(tempArr.count == 12, "Please enter a string of 12 English words separated by spaces")
        let seedBip39 = Mnemonic.createSeed(mnemonic: mnemonicStr)
        let privatekey = HDWalletSDK.PrivateKey(seed: seedBip39, coin: .bitcoin)
        // 派生
        let purpose = privatekey.derived(at: .hardened(44))
        let coinType = purpose.derived(at: .hardened(118))
        let account = coinType.derived(at: .hardened(0))
        let change = account.derived(at: .notHardened(0))
        let firstPrivateKey = change.derived(at: .notHardened(0))
        self.privatekey = firstPrivateKey.raw.dataToHexString()
        return firstPrivateKey.raw.dataToHexString()
    }


    /// 通过私钥生成公钥
    /// - Parameter privateString: 私钥字符串
    /// - Returns: 公钥字符串
    public func publicKey(privateString: String) -> String {
        let publikey = HDWalletSDK.PublicKey(privateKey: privateString.hexaData, coin: .bitcoin)
        self.newPublicKey = publikey.data.dataToHexString()
        return publikey.data.dataToHexString()
    }

    /// COSMOS_MAIN 地址
    /// - Parameter publickeyStr: 公钥字符串
    /// - Returns: COSMOS_MAIN 类型地址
    public func address(publickeyStr: String) -> String {
        let address = getPubToDpAddress(publickeyStr.hexaData, ChainType.COSMOS_MAIN)
        return address
    }

}


extension DBChainKit {

}
