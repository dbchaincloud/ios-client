import Foundation
import CryptoKit
import SawtoothSigning
import secp256k1
import CryptoSwift
import Alamofire
import HDWalletSDK

public let DBChain = DBChainKit.shared

public struct AppInfo {
    public var appcode: String?
    public var chainid: String?
    public var baseurl: String?
    public init(_ appcode: String, _ chainid: String,_ baseurl: String) {
        self.chainid = chainid
        self.appcode = appcode
        self.baseurl = baseurl
    }
}


open class DBChainKit :NSObject {
    //单例
    public static let shared = DBChainKit()
    private override init() {}

    var newPrivateKey : String?
    var newMnemonicString : String?
    var newPublicKey : String?
    var newAppinfo: AppInfo?

    var msgArr = [Dictionary<String, Any>]()
    // 准备签名数据
    let fee : [String:Any] = ["amount":[],"gas":"99999999"]
    
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

    /// Token
    /// get:  对当前时间戳 私钥与公钥进行 Base58编码
    public var token: String {
        set {}
        get {
            assert(!self.privatekey.isBlank, "Private key cannot be empty")
            assert(!self.publickey.isBlank, "Public key cannot be empty")
            return self.token(privateKeyStr: privatekey, publicKeyStr: publickey)
        }
    }

    /// AppInfo:  应用基本信息
    public var appinfo: AppInfo {
        set {
            self.newAppinfo = newValue
        }
        get {
            return self.newAppinfo ?? AppInfo("", "", "")
        }
    }
}


extension DBChainKit {

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
        /// secp256k1 签名
        let publikey = HDWalletSDK.PublicKey(privateKey: privateString.hexaData, coin: .bitcoin)
        self.newPublicKey = publikey.data.dataToHexString()
        return publikey.data.dataToHexString()
    }

    /// COSMOS_MAIN 地址
    /// - Parameter publickeyStr: 公钥字符串
    /// - Returns: COSMOS_MAIN 类型地址
    public func address(publickeyStr: String) -> String {
        /// secp256k1
        let address = getPubToDpAddress(publickeyStr.hexaData, ChainType.COSMOS_MAIN)
        return address
    }

    /// 获取token
    /// - Parameters:
    ///   - privateKeyStr: 私钥
    ///   - publicKeyStr: 公钥
    /// - Returns: token
    public func token(privateKeyStr: String,publicKeyStr: String) -> String {
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
            self.token = token
            return token
        } catch {
            return ""
        }
    }
}


extension DBChainKit {

    
    /// 根据 表名 和 id 查询
    /// - Parameters:
    ///   - appinfo: 基本信息
    ///   - tableName: 表名
    ///   - id: 待查询数据的id
    ///   - closeBlock: 返回  String
    public func queryDataByID(_ appinfo: AppInfo ,
                              _ tableName: String,
                              _ id: String,
                              closeBlock:@escaping(_ resultJsonStr:String) -> Void) {

        var tempurl = appinfo.baseurl!
        if tempurl.last != "/" { tempurl = tempurl + "/" }

        let url = "\(tempurl)dbchain/find/\(self.token)/\(appinfo.appcode!)/\(tableName)/\(id)"
        DBRequest.GET(url: url, params: nil) { (data) in
            let jsonStr : String = String(data: data, encoding: .utf8) ?? ""
            closeBlock(jsonStr)
        } failure: { (code, message) in
            closeBlock("Query Failed:\(message)")
        }
    }


    /// 根据表名查询整张表的数据
    /// - Parameters:
    ///   - appinfo: 基本信息
    ///   - tableName: 表名
    ///   - closeBlock: 返回 String
    public func queryDataByTablaName(_ appinfo: AppInfo,
                                     _ tableName: String,
                                     closeBlock:@escaping(_ resultString :String) -> Void) {
        var tempurl = appinfo.baseurl!
        if tempurl.last != "/" { tempurl = tempurl + "/" }

        let dic : [[String:Any]] = [["method":"table","table":tableName]]
        let dicData = try! JSONSerialization.data(withJSONObject: dic, options: [])
        let dicBase = Base58.encode(dicData)

        let url = tempurl + "dbchain/querier/" + self.token + "/\(appinfo.appcode!)/" + dicBase
        DBRequest.GET(url: url, params: nil) { (data) in
        let jsonStr : String = String(data: data, encoding: .utf8)!
          closeBlock(jsonStr)
        } failure: { (code, message) in
          closeBlock("Query Failed:\(message)")
        }
    }

    /// 多条件查询
    /// - Parameters:
    ///   - appinfo: 基本信息
    ///   - tableName: 表名
    ///   - fieldDic: 查询条件的字典
    ///   - closeBlock: 返回 String
    public func queryDataByCondition(_ appinfo: AppInfo,
                                     _ tableName: String,
                                     _ fieldDic: [String: Any],
                                     closeBlock:@escaping(_ resultString : String) -> Void) {
        var tempurl = appinfo.baseurl!
        if tempurl.last != "/" { tempurl = tempurl + "/" }

        var dicArr : [[String:Any]] = [["method":"table","table":tableName]]
        for (key,value) in fieldDic {
            let arr = ["field":key,"method":"where","operator":"=","value":value]
            dicArr.append(arr)
        }
        let dicData = try! JSONSerialization.data(withJSONObject: dicArr, options: [])
        let dicBase = Base58.encode(dicData)

        let url = tempurl + "dbchain/querier/" + self.token + "/\(appinfo.appcode!)/" + dicBase
        DBRequest.GET(url: url, params: nil) { (data) in
            let jsonStr : String = String(data: data, encoding: .utf8) ?? ""
            closeBlock(jsonStr)
        } failure: { (code, message) in
            closeBlock(message)
        }
    }


    /// 传承查询 专用
    /// - Parameters:
    ///   - appinfo: app 基本信息
    ///   - tableName: 表名
    ///   - querierFuncName: 函数名称, 必须保证已在控制台进行过注册
    ///   - fieldDic: 查询条件, 可为空
    ///   - closeBlock: 返回 String
    public func queryInheritListData(_ appinfo: AppInfo,
                                     _ tableName: String,
                                     _ querierFuncName: String,
                                     fieldDic:[String:Any]?,
                                     closeBlock: @escaping( _ resultString :String) -> Void) {
        var tempurl = appinfo.baseurl!
        if tempurl.last != "/" { tempurl = tempurl + "/" }

        var dicArr : [[String:Any]] = [["method":"table","table":tableName]]
        if fieldDic?.count ?? 0 > 0 {
            for (key,value) in fieldDic! {
                let arr = ["field":key,"method":"where","operator":"=","value":value]
                dicArr.append(arr)
            }
        }

        let dicData = try! JSONSerialization.data(withJSONObject: dicArr, options: [])
        let dicBase = Base58.encode(dicData)

        let dicAgainData = dicBase.data(using: .utf8)
        let againBase = Base58.encode(dicAgainData!)

        let url = tempurl + "dbchain/call-custom-querier/" + self.token + "/\(appinfo.appcode!)/" + "\(querierFuncName)/" + againBase

        DBRequest.GET(url: url, params: nil) { (data) in
            let jsonString : String = String(data: data, encoding: .utf8) ?? ""
            closeBlock(jsonString)
        } failure: { (code, message) in
            closeBlock(message)
        }
    }

}
