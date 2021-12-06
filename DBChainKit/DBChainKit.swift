import Foundation
import CryptoKit
import secp256k1
import CryptoSwift
import Alamofire
import HDWalletSDK

public class DBChainKit {

    var signMsgArr: [[String : Any]] = [[String : Any]]()
    var fee: [String : Any] = ["amount":[],"gas":"99999999"]

    public var appcode: String? { get { return self.tempAppcode } }
    public var chainid: String? { get { return self.tempChainid } }
    public var baseurl: String? { get { return self.tempBaseurl } }

    public var privateKey: String? { get { return tempPrivateKey } }
    public var publicKey: String? { get { return tempPublickey } }
    public var address: String? { get { return tempAddress } }

    /// 每次获取时都重新生成 Token
    public var token: String? {
        get {
            if self.privateKey != nil, self.publicKey != nil {
                return self.generateToken(self.privateKey!, self.publicKey!)
            }
            return nil
        }
    }

    /// 协议类型
    var encryptType: Compatible

    private var tempAppcode: String?
    private var tempChainid: String?
    private var tempBaseurl: String?

    private var tempPrivateKey: String?
    private var tempPublickey: String?
    private var tempAddress: String?


    public init( appcode code: String, chainid id: String,baseurl url : String, encryptType type: Compatible) {
        self.tempChainid = id
        self.tempAppcode = code
        self.tempBaseurl = url
        self.encryptType = type
    }

    /// 创建助记词
    public func createMnemonic() -> String {
        return Mnemonic.create()
    }

    /// 通过助记词 生成 私钥
    /// - Parameter mnemonicStr: 助记词
    /// - Returns: 返回 私钥
    public func generatePrivateByMenemonci(_ mnemonicStr: String) -> String {
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
        self.tempPrivateKey = firstPrivateKey.raw.dataToHexString()
        return firstPrivateKey.raw.dataToHexString()
    }

    /// 通过私钥 生成 公钥
    /// - Parameter privateKey: 私钥
    /// - Returns: 返回公钥
    public func generatePublickey(_ privateKey: String) -> String {
        self.tempPublickey = encryptType.generatePublicKeyBy(privateKey: privateKey);
        return self.tempPublickey!
    }

    /// 通过公钥生成地址
    /// - Parameter publickey: 分钥
    /// - Returns: 地址
    public func generateAddress(_ publickey: String) -> String {
        self.tempAddress = encryptType.generateAddressBy(publicKey: publickey)
        return self.tempAddress!
    }

    /// 生成Token
    /// - Parameters:
    ///   - privatekey: 私钥
    ///   - publickey: 公钥
    /// - Returns: Token
    public func generateToken(_ privatekey: String, _ publickey: String) -> String {
        return encryptType.generateTokenBy(publicKey: publickey, privateKey: privatekey)
    }

}


/// 公共方法
extension DBChainKit {

    /// 新注册用户获取积分
    /// - Parameters:
    ///   - baseurl: 初始化时的baseurl
    ///   - token: token
    ///   - resultCloure: 成功或失败
    public func registerNewAccountNumber( resultCloure: @escaping (Bool, String?) -> Void) {
        guard self.baseurl != nil, self.token != nil else {
            resultCloure(false , "BASEURL / Token  is empty")
            return
        }
        var tempUrl = baseurl!
        if tempUrl.last != "/" { tempUrl = tempUrl + "/"}
        let url = tempUrl + "dbchain/oracle/new_app_user/" + self.token!
        DBRequest.GET(url: url, params: nil) { (result) in
            let resultStr = String(data: result, encoding: .utf8)
            guard resultStr!.isjsonStyle else { resultCloure(false, resultStr); return }
            let dic = resultStr!.toDictionary()
            if dic.keys.contains("error") {
                resultCloure(false, (dic["error"] as! String))
            } else if dic.keys.contains("result") {
                let stateStr = dic["result"] as! String
                if stateStr == "success" {
                    sleep(5)
                    resultCloure(true,stateStr)
                } else {
                    resultCloure(false,stateStr)
                }
            }
        } failure: { (code, message ) in
            resultCloure(false, message)
        }
    }


    /// 获取用户信息
    /// - Parameters:
    ///   - userModelCloure: 闭包传递用户信息模型
    ///   - failure: 错误.
    public func getUserModel(userModelCloure: @escaping (DBUserModel) -> Void,failure: ((_ code: Int?, _ errorMessage: String) -> Void)?) {
        guard self.address != nil else {
            failure?( 0 ,  "Address is empty")
            return
        }
        guard self.baseurl != nil else {
            failure?( 0 ,  "BASEURL is empty")
            return
        }

        var tempUrl = self.baseurl!
        if tempUrl.last != "/" {
            tempUrl = tempUrl + "/"
        }

        let url = tempUrl + "auth/accounts/" + self.address!
        DBRequest.GET(url: url, params: nil) { (data) in
            do {
                let userModel = try JSONDecoder().decode(DBUserModel.self, from: data)
                userModelCloure(userModel)
            } catch {
                failure?(201,"获取用户信息转换失败: \(error)")
            }
        } failure: { (code, errorMsg) in
            failure?(code,errorMsg)
        }
    }

}


/// 插入数据相关操作
extension DBChainKit {

    /// 单表单数据插入
    /// - Parameters:
    ///   - tableName: 表名
    ///   - fields: 待插入信息
    ///   - insertStatusBlock: 成功或失败以数字 0 代表失败,1 代表成功的形式返回
    public func insertRow(tableName: String,
                          fields: [String:Any],
                          insertStateBlock:@escaping(_ state:String) -> Void) {
        guard self.baseurl != nil, self.token != nil,self.appcode != nil  else {
            insertStateBlock( "BASEURL / Token  is empty")
            return
        }
        self.signMsgArr.removeAll()
        /// 先获取用户信息
        getUserModel { (model) in
            let fieldStr = fields.dicValueString()
            let fieldData = Data(fieldStr!.utf8)
            let fieldBase = fieldData.base64EncodedString()
            let valueDic:[String:Any] = ["app_code":self.appcode!,
                                         "owner":self.address!,
                                         "fields":fieldBase,
                                         "table_name":tableName]
            let msgDic: [String:Any] = ["type":"dbchain/InsertRow",
                                        "value":valueDic]
            self.signMsgArr.append(msgDic)

            let paramsDic = self.singerBasic(userModel: model, privateKeyStr: self.privateKey!, publicKeyStr: self.publicKey!)

            self.startInsertRowRequest(params: paramsDic!, insertStateBlock: insertStateBlock)
        } failure: { (code, error) in
            insertStateBlock("error:\(error)")
            print("获取用户信息失败: \(error)")
        }
    }

    /// 冻结一条数据
    /// - Parameters:
    ///   - appinfo: 基本信息
    ///   - tableName: 表名
    ///   - trashcanID: 冻结的id
    ///   - trashcanStateBlock: 返回成功或失败 0 代表失败, 1 代表成功的形式返回
    public func trashcanRowData (tableName: String,
                                 trashcanID: String,
                                 trashcanStateBlock:@escaping(_ state:String) -> Void) {
        guard self.baseurl != nil, self.token != nil, self.appcode != nil else {
            trashcanStateBlock( "BASEURL / Token  is empty")
            return
        }
        self.signMsgArr.removeAll()
        getUserModel { (model) in
            let valueDic:[String:Any] = ["app_code": self.appcode!,
                                         "owner": self.address!,
                                         "id": trashcanID,
                                         "table_name": tableName]

            let msgDic:[String:Any] = ["type": "dbchain/FreezeRow",
                                       "value": valueDic]

            self.signMsgArr.append(msgDic)

            let paramsDic = self.singerBasic(userModel: model, privateKeyStr: self.privateKey!, publicKeyStr: self.publicKey!)

            self.startInsertRowRequest(params: paramsDic!, insertStateBlock: trashcanStateBlock)

        } failure: { (code, message) in
            trashcanStateBlock("error:\(message)")
        }
    }

    /// 函数单表多数据插入请求
    /// - Parameters:
    ///   - appinfo: 基本信息
    ///   - signArgument: 多数据请求的字符串数组形式
    ///   - functionName: 函数名称  需在控制台进行过注册,
    ///   - insertStateBlock: 数据插入的结果
    public func functionInsertRow (signArgument: String,
                                   functionName: String,
                                   insertStateBlock:@escaping(_ state:String) -> Void) {
        guard self.baseurl != nil, self.appcode != nil else {
            insertStateBlock( "BASEURL / Appcode  is empty")
            return
        }
        self.signMsgArr.removeAll()
        getUserModel { (model) in
            let signvalueDic:[String:Any] = ["app_code":self.appcode!,
                                             "owner":self.address!,
                                             "argument":signArgument,
                                             "function_name":functionName]

            let signmsgDic:[String:Any] = ["type":"dbchain/CallFunction",
                                           "value":signvalueDic]
            self.signMsgArr.append(signmsgDic)
            let params = self.singerBasic(userModel: model, privateKeyStr: self.privateKey!, publicKeyStr: self.publicKey!)
            self.startInsertRowRequest(params: params!, insertStateBlock: insertStateBlock)

        } failure: { (code, message) in
            insertStateBlock("error:\(message)")
        }
    }

    /// 函数请求  多条数据打包格式
    /// - Parameters:
    ///   - appinfo: 基本信息
    ///   - argumentsAndFunctionNames: key:  多条数据请求的字符串数组格式  value:  函数名称
    ///   - insertStateBlock: 数据插入的结果  成功返回 1, 失败返回 0, 错误 返回error
    public func functionInsertDic(argumentsAndFunctionNames: [String: String],
                                  insertStateBlock:@escaping(_ state:String) -> Void) {
        guard self.baseurl != nil, self.appcode != nil else {
            insertStateBlock( "BASEURL / Appcode  is empty")
            return
        }
        self.signMsgArr.removeAll()
        getUserModel { (model) in
            for (signStr,funtionName) in argumentsAndFunctionNames {
                let signvalueDic:[String:Any] = ["app_code": self.appcode!,
                                                 "owner": self.address!,
                                                 "argument": signStr,
                                                 "function_name": funtionName]

                let signmsgDic:[String:Any] = ["type": "dbchain/CallFunction",
                                               "value": signvalueDic]
                self.signMsgArr.append(signmsgDic)
            }

            let params = self.singerBasic(userModel: model, privateKeyStr: self.privateKey!, publicKeyStr: self.publicKey!)
            self.startInsertRowRequest(params: params!, insertStateBlock: insertStateBlock)

        } failure: { (code, message) in
            insertStateBlock("error:\(message)")
        }
    }

    /// 多条数据打包上传, 自由组合签名消息体
    /// - Parameters:
    ///   - appinfo: 基本信息
    ///   - messageArr: 消息体数组
    ///   - insertStateBlock:  数据请求的结果  成功返回 1, 失败返回 0, 错误 返回error
    public func functionInsertMessageArr (messageArr: [[String: Any]],
                                          insertStateBlock:@escaping(_ state:String) -> Void) {

        guard self.privateKey != nil, self.publicKey != nil else {
            insertStateBlock( "privateKey / publicKey  is empty")
            return
        }
        getUserModel { (model) in
            self.signMsgArr = messageArr
            let params = self.singerBasic(userModel: model, privateKeyStr: self.privateKey!, publicKeyStr: self.publicKey!)
            self.startInsertRowRequest(params: params!, insertStateBlock: insertStateBlock)
        } failure: { (code, message) in
            insertStateBlock("error:\(message)")
        }
    }

    /// 上传文件类型数据
    /// - Parameters:
    ///   - filename: 文件名称
    ///   - fileData: 文件内容
    ///   - uploadStateBlock: 成功返回该文件的 cid,  失败返回 faile
    public func uploadfile( filename: String,
                            fileData: Data,
                            uploadStateBlock:@escaping(_ fileCid: String) -> Void ) {

        guard self.privateKey != nil, self.publicKey != nil, self.appcode != nil else {
            uploadStateBlock( "privateKey / publicKey / appcode is empty")
            return
        }
        let headers : HTTPHeaders = ["Content-type": "multipart/form-data",
                                     "Content-Disposition" : "form-data",
                                     "Content-Type": "application/json;charset=utf-8"]
        let url = self.baseurl! + "dbchain/upload/\(self.token!)/\(self.appcode!)"
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append(fileData, withName: "file", fileName: filename, mimeType: "application/octet-stream")
        }, to: url,headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                let value = response.value as? Dictionary<String, Any>
                if ((value?.keys.contains("result")) != nil) {
                    uploadStateBlock(value!["result"] as! String)
                } else {
                    uploadStateBlock("File upload failed")
                }
            } else {
                uploadStateBlock("File upload failed")
            }
        }
    }
}


///  最终提交给服务器的数据排序组装
extension DBChainKit {

    /// 排序最后提交服务器的数据
    /// - Parameters:
    ///   - userModel: 用户模型
    ///   - privateKeyStr: 私钥
    ///   - publicKeyStr: 公钥
    /// - Returns: 返回签名并排序的数据
    private func singerBasic(userModel: DBUserModel,
                                 privateKeyStr: String,
                                 publicKeyStr: String) -> [String:Any]? {

        let signDiv : [String:Any] = ["account_number":userModel.result.value.account_number,
                                      "chain_id":self.chainid!,
                                      "fee":fee,
                                      "memo":"",
                                      "msgs":self.signMsgArr,
                                      "sequence":userModel.result.value.sequence]

        let str = signDiv.dicValueString()
        let replacStr = str!.replacingOccurrences(of: "\\/", with: "/")

        /// 不同类型签名,  Secp256k1  或 Sm2
        let signStr = encryptType.signData(signHex: replacStr, privateKeyStr: privateKeyStr)

        let signDivSorted = encryptType.signDictionaryType(publicKeyStr: publicKeyStr)

        let typeSignDiv = sortedDictionarybyLowercaseString(dic: signDivSorted)

        let signDic = ["key":["pub_key":typeSignDiv[0],
                              "signature":signStr]]

        let signSortDiv = sortedDictionarybyLowercaseString(dic: signDic)

        let tx = ["key":["memo":"",
                         "fee":fee,
                         "msg":signMsgArr,
                         "signatures":[signSortDiv[0]]]]

        let sortTX = sortedDictionarybyLowercaseString(dic: tx)

        let dataSort = sortedDictionarybyLowercaseString(dic: ["key": ["mode":"async","tx":sortTX[0]]])

        return dataSort[0]
    }

    /// 字典排序
    private func sortedDictionarybyLowercaseString(dic:Dictionary<String, Any>) -> [[String:Any]] {
        let allkeyArray  = dic.keys
        let afterSortKeyArray = allkeyArray.sorted(by: {$0 < $1})
        var valueArray = [[String:Any]]()
        afterSortKeyArray.forEach { (sortString) in
            let valuestring = dic[sortString]
            valueArray.append(valuestring as! [String:Any])
        }
        return valueArray
    }
}



/**
    开始发送插入数据的网络请求
 */
extension DBChainKit {

    private func startInsertRowRequest(params: [String: Any] , insertStateBlock:@escaping(_ state:String) -> Void) {
        var tempUrl = self.baseurl!
        if tempUrl.last != "/" { tempUrl = tempUrl + "/" }
        let url = tempUrl + "txs"

        DBRequest.POST(url: url, params: params) { (result) in
            let str = String(data: result, encoding: .utf8)
            if str!.isjsonStyle {
                let dic = str!.toDictionary()
                guard dic.keys.contains("txhash") else {
                    insertStateBlock("0")
                    return
                }
                let txhash = dic["txhash"]
                let timerName = "verificationName"
                if DBGCDTimer.shared.isExistTimer(WithTimerName: timerName) {
                    DBGCDTimer.shared.cancleTimer(WithTimerName: timerName)
                }
                var waitTimer = 15
                DBGCDTimer.shared.scheduledDispatchTimer(WithTimerName: timerName, timeInterval: 1, queue: .main, repeats: true) {
                    waitTimer -= 1
                    if waitTimer >= 0 {
                        let requestUrl = tempUrl + "dbchain/tx-simple-result/" + "\(self.token!)/" + "\(txhash!)"
                        self.verificationHash(url: requestUrl) { (state) in
                            if state != "2" {
                                insertStateBlock(state)
                                DBGCDTimer.shared.cancleTimer(WithTimerName: timerName)
                            }
                        }
                    } else {
                        insertStateBlock("0")
                        DBGCDTimer.shared.cancleTimer(WithTimerName: timerName)
                    }
                }
            } else {
                insertStateBlock("0")
            }
        } failure: { (code, message) in
            insertStateBlock("0")
        }
    }


    /// 验证 txhash  是否已成功上链
    /// - Parameters:
    ///   - url: 检查地址
    ///   - verifiSuccessBlock: 返回结果. 0: 失败, 1: 成功, 2: 继续等待
    private func verificationHash(url: String,
                                      verifiSuccessBlock:@escaping(_ state: String) -> Void) {

        DBRequest.GET(url: url, params: nil) { (data) in
            let json = data.dataToDictionary()
//            print("查询结果: \(json!)")
            guard json != nil else {verifiSuccessBlock("0"); return }
            guard !json!.keys.contains("error") else { verifiSuccessBlock("0"); return }

            /// 状态:  0: 错误 已经失败  1:  成功  2: 等待
            guard json!.keys.contains("result") else { verifiSuccessBlock("0");
                return
            }
            let result = json!["result"] as? [String:Any]
            let status = result?["state"]
            if status as! String == "pending" {
               verifiSuccessBlock("2")
            } else if status as! String == "success" {
               verifiSuccessBlock("1")
            } else {
               verifiSuccessBlock("0")
            }
       } failure: { (code, message) in
            verifiSuccessBlock("0")
       }
    }
}


/// 查询相关公共方法
extension DBChainKit {
    /// 根据 ID 查询一条数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - id: 查询的id
    ///   - closeBlock: 回调
    public func queryDataByID(tableName: String,
                              id: String,
                              closeBlock: @escaping (String) -> Void) {
        guard self.baseurl != nil, self.token != nil, self.appcode != nil else {
            closeBlock("BASEURL / Token / Appcode  is empty")
            return
        }
        var tempurl = self.baseurl!
        if tempurl.last != "/" { tempurl = tempurl + "/" }

        let url = "\(tempurl)dbchain/find/\(token!)/\(appcode!)/\(tableName)/\(id)"
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
    public func queryDataByTablaName(_ tableName: String,
                                     closeBlock:@escaping(_ resultString :String) -> Void) {

        guard self.baseurl != nil, self.token != nil, self.appcode != nil else {
            closeBlock("BASEURL / Token / Appcode  is empty")
            return
        }
        var tempurl = baseurl!
        if tempurl.last != "/" { tempurl = tempurl + "/" }

        let dic : [[String:Any]] = [["method":"table","table":tableName]]
        let dicData = try! JSONSerialization.data(withJSONObject: dic, options: [])
        let dicBase = Base58.encode(dicData)

        let url = tempurl + "dbchain/querier/" + self.token! + "/\(self.appcode!)/" + dicBase
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
    public func queryDataByCondition(_ tableName: String,
                                     _ fieldDic: [String: Any],
                                     closeBlock:@escaping(_ resultString : String) -> Void) {

        guard self.baseurl != nil, self.token != nil, self.appcode != nil else {
            closeBlock("BASEURL / Token / Appcode  is empty")
            return
        }
        var tempurl = baseurl!
        if tempurl.last != "/" { tempurl = tempurl + "/" }

        var dicArr : [[String:Any]] = [["method":"table","table":tableName]]
        for (key,value) in fieldDic {
            let arr = ["field":key,"method":"where","operator":"=","value":value]
            dicArr.append(arr)
        }
        let dicData = try! JSONSerialization.data(withJSONObject: dicArr, options: [])
        let dicBase = Base58.encode(dicData)

        let url = tempurl + "dbchain/querier/" + self.token! + "/\(appcode!)/" + dicBase
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
    public func queryInheritListData(_ tableName: String,
                                     _ querierFuncName: String,
                                     fieldDic:[String:Any]?,
                                     closeBlock: @escaping( _ resultString :String) -> Void) {
        guard self.baseurl != nil, self.token != nil, self.appcode != nil else {
            closeBlock("BASEURL / Token / Appcode  is empty")
            return
        }
        var tempurl = baseurl!
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

        let url = tempurl + "dbchain/call-custom-querier/" + self.token! + "/\(self.appcode!)/" + "\(querierFuncName)/" + againBase

        DBRequest.GET(url: url, params: nil) { (data) in
            let jsonString : String = String(data: data, encoding: .utf8) ?? ""
            closeBlock(jsonString)
        } failure: { (code, message) in
            closeBlock(message)
        }
    }
}



extension Dictionary {

    func jsonPrintDic() {
        let ff =  try! JSONSerialization.data(withJSONObject:self, options: [])
        let str = String(data:ff, encoding: .utf8)
        print(str!)
    }
}

extension Array {

    func jsonPrint() {
        let ff = try! JSONSerialization.data(withJSONObject:self, options: [])
        let str = String(data:ff, encoding: .utf8)
        print(str!)
    }

}

