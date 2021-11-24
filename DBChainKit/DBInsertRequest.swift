//
//  File.swift
//  
//  BASEURL + "auth/accounts/"
//  Created by iOS on 2021/6/19.
//

import Foundation
import UIKit
import Alamofire

//open class DBInsertData :NSObject {
//
//    public var appcode :String
//    public var publikeyBase64Str :String
//    public var address :String
//    public var tableName :String
//    public var chainid :String
//    public var privateKeyDataUint :[UInt8]
//    public var baseUrl :String
//    public var insertDataUrl: String
//    public var publicKey :String
//    var msgArr = [Dictionary<String, Any>]()
//    // 准备签名数据
//    let fee : [String:Any] = ["amount":[],"gas":"99999999"]
//
//    required public init(baseUrl: String,
//                appcode: String,
//                address: String,
//                chainid: String,
//                tableName: String,
//                privateKeyDataUint: [UInt8],
//                publicKey: String,
//                insertDataUrl: String) {
//
//        self.appcode = appcode
//        self.address = address
//        self.tableName = tableName
//        self.chainid = chainid
//        self.privateKeyDataUint = privateKeyDataUint
//        self.baseUrl = baseUrl
//        self.publicKey = publicKey
//        self.insertDataUrl = insertDataUrl
//        /// 公钥 的 Base64
//        publikeyBase64Str = publicKey.hexaData.base64EncodedString()
//    }
//
//    /// 插入数据
//    public func insertRowSortedSignDic(model:DBUserModel,fields : [String:Any],insertStatusBlock:@escaping(_ status:String) -> Void){
//
//        let fieldsStr = fields.dicValueString(fields)
//        let fieldsData = Data(fieldsStr!.utf8)
//        let fieldBase = fieldsData.base64EncodedString()
//
//         let valueDic:[String:Any] = ["app_code":appcode,
//                                      "owner":address,
//                                      "fields":fieldBase,
//                                      "table_name":tableName]
//
//         let msgDic:[String:Any] = ["type":"dbchain/InsertRow",
//                                    "value":valueDic]
//         msgArr.append(msgDic)
//
//         let signDiv : [String:Any] = ["account_number":model.result.value.account_number,
//                                       "chain_id":chainid,
//                                       "fee":fee,
//                                       "memo":"",
//                                       "msgs":msgArr,
//                                       "sequence":model.result.value.sequence]
//
//        let str = signDiv.dicValueString(signDiv)
//        var replacStr = str!.replacingOccurrences(of: "dbchain\\/InsertRow", with: "dbchain/InsertRow")
//        replacStr = replacStr.replacingOccurrences(of: "\\/", with: "/")
//
//         let str8 = [UInt8](replacStr.utf8)
//         do {
//
//            let signData = try signSawtoothSigning(data: str8, privateKey: privateKeyDataUint)
//            insertRowData(insertUrlStr: insertDataUrl, publikeyBase: publikeyBase64Str, signature: signData) { (status) in
//                insertStatusBlock(status)
//            }
//        } catch {
//            insertStatusBlock("0")
//        }
//     }
//
//    ///  冻结数据
//    public func trashcanRowSortedSignDic(model: DBUserModel,deleteID: String,insertStatusBlock: @escaping(_ status:String) -> Void){
//
//         let valueDic:[String:Any] = ["app_code": appcode,
//                                      "owner": address,
//                                      "id": deleteID,
//                                      "table_name": tableName]
//
//         let msgDic:[String:Any] = ["type": "dbchain/FreezeRow",
//                                    "value": valueDic]
//
//         msgArr.append(msgDic)
//
//         let signDiv : [String:Any] = ["account_number": model.result.value.account_number,
//                                       "chain_id": chainid,
//                                       "fee": fee,
//                                       "memo": "",
//                                       "msgs": msgArr,
//                                       "sequence": model.result.value.sequence]
//
//         // 排序方法只对value进行,所以在外层包裹一层
//         let signDivSorted = ["key":signDiv]
//
//         let sortSignDiv = sortedDictionarybyLowercaseString(dic: signDivSorted)
//
//         if (sortSignDiv.count > 0 ) {
//            let sorted = sortSignDiv.sorted {($0 as AnyObject).key! < ($1 as AnyObject).key!}
//             for element in sorted {
//                let elementDic : Dictionary = element
//                let str = elementDic.creatJsonString(dict: elementDic)
//                let str8 = [UInt8](str.utf8)
//                do {
//                    let signData = try signSawtoothSigning(data: str8, privateKey: privateKeyDataUint)
//                    insertRowData(insertUrlStr: insertDataUrl, publikeyBase: publikeyBase64Str, signature: signData) { (status) in
//                        insertStatusBlock(status)
//                    }
//                } catch {
//                    insertStatusBlock("0")
//                }
//             }
//
//         } else {
//            insertStatusBlock("0")
//         }
//     }
//
//
//    ///  函数请求
//    /// - Parameters:
//    ///   - model: DBUserModel
//    ///   - signArgument: 多条数据请求的字符串 格式:
//    ///      ["tableName__表名"," 第一条数据的字符串数组排列",  " 第二条数据的字符串数组排列 ",.......]
//    ///   - address: 地址
//    ///   - function_name: 函数名称
//    ///   - appcode: appcode
//    ///   - chainid: chainid
//    ///   - insertStatusBlock: 结果
//    public func functionSignDic(model:DBUserModel,
//                                signArgument:String,
//                                function_name:String,
//                                insertStatusBlock:@escaping(_ status:String) -> Void){
//
//         let signvalueDic:[String:Any] = ["app_code":appcode,
//                                          "owner":address,
//                                          "argument":signArgument,
//                                          "function_name":function_name]
//
//         let signmsgDic:[String:Any] = ["type":"dbchain/CallFunction",
//                                        "value":signvalueDic]
//         msgArr.append(signmsgDic)
//
//         let signDiv : [String:Any] = ["account_number":model.result.value.account_number,
//                                      "chain_id":chainid,
//                                      "fee":fee,
//                                      "memo":"",
//                                      "msgs":msgArr,
//                                      "sequence":model.result.value.sequence]
//
//         let str = signDiv.dicValueString(signDiv)
//
//         var replacStr = str!.replacingOccurrences(of: "dbchain\\/CallFunction", with: "dbchain/CallFunction")
//         replacStr = replacStr.replacingOccurrences(of: "\\/", with: "/")
//
//         let str8 = [UInt8](replacStr.utf8)
//         do {
//            let signData = try signSawtoothSigning(data: str8, privateKey: privateKeyDataUint)
////            let verifyStr = try verifySawtoothSigning(signature: signData.hex, data: str8, publicKey:PublikeyData.bytes)
//            insertRowData(insertUrlStr: insertDataUrl, publikeyBase: publikeyBase64Str, signature: signData) { (status) in
//                insertStatusBlock(status)
//            }
//        } catch {
//            insertStatusBlock("0")
//        }
//
//     }
//
//    ///  函数请求  多条数据打包格式
//    /// - Parameters:
//    ///   - model: DBUserModel
//    ///   - argument: 多条数据请求的字符串 格式:
//    ///      ["tableName__表名"," 第一条数据的字符串数组排列",  " 第二条数据的字符串数组排列 ",.......]
//    ///   - address: 地址
//    ///   - function_nameArr: 函数名称   和 signArguments  必须数量一致. 否则将会cash
//    ///   - appcode: appcode
//    ///   - chainid: chainid
//    ///   - insertStatusBlock: 结果
//    public func functionSignDicArr(model: DBUserModel,
//                                   signArgumentsAndFunctionNames: [String:String],
//                                   insertStatusBlock: @escaping(_ status:String) -> Void){
//
//        for (signStr,funtionName) in signArgumentsAndFunctionNames {
//            let signvalueDic:[String:Any] = ["app_code": appcode,
//                                             "owner": address,
//                                             "argument": signStr,
//                                             "function_name": funtionName]
//
//            let signmsgDic:[String:Any] = ["type": "dbchain/CallFunction",
//                                           "value": signvalueDic]
//            self.msgArr.append(signmsgDic)
//        }
//        let signDiv : [String:Any] = ["account_number": model.result.value.account_number,
//                                      "chain_id": chainid,
//                                      "fee": self.fee,
//                                      "memo": "",
//                                      "msgs": self.msgArr,
//                                      "sequence": model.result.value.sequence]
//
//        let str = signDiv.dicValueString(signDiv)
//
//        var replacStr = str!.replacingOccurrences(of: "dbchain\\/CallFunction", with: "dbchain/CallFunction")
//        replacStr = replacStr.replacingOccurrences(of: "\\/", with: "/")
//
//        let str8 = [UInt8](replacStr.utf8)
//        do {
//            let signData = try signSawtoothSigning(data: str8, privateKey: privateKeyDataUint)
//            insertRowData(insertUrlStr: insertDataUrl, publikeyBase: publikeyBase64Str, signature: signData) { (status) in
//                insertStatusBlock(status)
//            }
//
//        } catch {
//            insertStatusBlock("0")
//        }
//     }
//
//
//    /// 多条数据打包上传, 在外处理数据形式  灵活处理
//    /// - Parameters:
//    ///   - model: 用户模型
//    ///   - msgObjectArr: 打包的数据, 字典数组类型
//    ///   - insertStatusBlock: 回调
//    public func functionSignMsgObjectArr(model:DBUserModel,
//                                         msgObjectArr:[Dictionary<String, Any>],
//                                         insertStatusBlock:@escaping(_ status:String) -> Void){
//            self.msgArr = msgObjectArr
//            let signDiv : [String:Any] = ["account_number":model.result.value.account_number,
//                                          "chain_id":chainid,
//                                          "fee":self.fee,
//                                          "memo":"",
//                                          "msgs":msgObjectArr,
//                                          "sequence":model.result.value.sequence]
//
//            let str = signDiv.dicValueString(signDiv)
//
//            var replacStr = str!.replacingOccurrences(of: "dbchain\\/CallFunction", with: "dbchain/CallFunction")
//            replacStr = replacStr.replacingOccurrences(of: "\\/", with: "/")
//
//            let str8 = [UInt8](replacStr.utf8)
//            do {
//                let signData = try signSawtoothSigning(data: str8, privateKey: privateKeyDataUint)
//                insertRowData(insertUrlStr: insertDataUrl, publikeyBase: publikeyBase64Str, signature: signData) { (status) in
//                    insertStatusBlock(status)
//                }
//            } catch {
//                insertStatusBlock("0")
//            }
//     }
//
//
//
//    /// 最终提交数据
//    /// - Parameters:
//    ///   - urlStr: 插入数据的url地址.
//    ///   - publikeyBase: 公钥的 base64 字符串
//    ///   - signature: 签名数据
//    ///   - insertDataStatusBlock: 返回结果. 类型为 int ,
//    ///   返回结果的参数说明 :
//    ///   返回 0  表示查询结果的倒计时结束, 数据插入不成功.
//    ///   返回 1  表示数据已成功插入数据库
//    ///   返回 2  表示该条数据插入的结果还处于等待状态.
//    func insertRowData(insertUrlStr:String,
//                       publikeyBase:String,
//                        signature: Data,
//                        insertDataStatusBlock:@escaping(_ Status:String) -> Void) {
//
//        let sign = signature.base64EncodedString()
//
//        let signDivSorted = ["key":["type":"tendermint/PubKeySecp256k1",
//                                    "value":publikeyBase]]
//
//        let typeSignDiv = sortedDictionarybyLowercaseString(dic: signDivSorted)
//
//        let signDic = ["key":["pub_key":typeSignDiv[0],
//                              "signature":sign]]
//
//        let signDiv = sortedDictionarybyLowercaseString(dic: signDic)
//
//        let tx = ["key":["memo":"",
//                         "fee":fee,
//                         "msg":msgArr,
//                         "signatures":[signDiv[0]]]]
//
//        let sortTX = sortedDictionarybyLowercaseString(dic: tx)
//
//        let dataSort = sortedDictionarybyLowercaseString(dic: ["key": ["mode":"async","tx":sortTX[0]]])
//
//        let isTimerExistence = DBGCDTimer.shared.isExistTimer(WithTimerName: "VerificationHash")
//
//        DBRequest.POST(url: insertUrlStr, params:( dataSort[0] )) { [self] (json) in
//
//             let decoder = JSONDecoder()
//             let insertModel = try? decoder.decode(DBInsertModel.self, from: json)
//             guard let model = insertModel else {
//                insertDataStatusBlock("0")
//                 return
//             }
//
//            if !(model.txhash?.isBlank ?? true) {
//                /// 开启定时器 循环查询结果
//                if isTimerExistence == true{
//                    DBGCDTimer.shared.cancleTimer(WithTimerName: "DBVerificationHash")
//                }
//
//                /// 查询请求最长等待时长
//                var waitTime = 15
//                let token = DBToken().createAccessToken(privateKey: privateKeyDataUint, PublikeyData:self.publicKey.hexaData)
//                DBGCDTimer.shared.scheduledDispatchTimer(WithTimerName: "DBVerificationHash", timeInterval: 1, queue: .main, repeats: true) {
//                    waitTime -= 1
//                    if waitTime > 0 {
//                        let requestUrl = baseUrl + "dbchain/tx-simple-result/" + "\(token)/" + "\(model.txhash!)"
//                        verificationHash(url: requestUrl) { (status) in
//                            NSLog("verificationHash:\(status),时间和次数:\(waitTime)")
//                            if status != "2"{
//                                //  成功或失败都直接返回 停止计时器
//                                insertDataStatusBlock(status)
//                                DBGCDTimer.shared.cancleTimer(WithTimerName: "DBVerificationHash")
//                            }
//                        }
//                    } else {
//                        /// 最长循环等待时间已过. 取消定时器
//                        insertDataStatusBlock("0")
//                        DBGCDTimer.shared.cancleTimer(WithTimerName: "DBVerificationHash")
//                    }
//                }
//            } else {
//                insertDataStatusBlock("0")
//            }
//
//         } failure: { (code, message) in
//
//            if isTimerExistence == true{
//                DBGCDTimer.shared.cancleTimer(WithTimerName: "DBVerificationHash")
//            }
//            insertDataStatusBlock("0")
//        }
//     }
//
//    /// 字典排序
//    public func sortedDictionarybyLowercaseString(dic:Dictionary<String, Any>) -> [[String:Any]] {
//        let allkeyArray  = dic.keys
//        let afterSortKeyArray = allkeyArray.sorted(by: {$0 < $1})
//        var valueArray = [[String:Any]]()
//        afterSortKeyArray.forEach { (sortString) in
//            let valuestring = dic[sortString]
//            valueArray.append(valuestring as! [String:Any])
//        }
//        return valueArray
//    }
//
//
//    /// 检查数据是否已经插入成功
//    /// - Parameters:
//    //       let token = Token().createAccessToken()
//    //       let requestUrl = BASEURL + "dbchain/tx-simple-result/" + "\(token)/" + "/\(hash)"
//    ///   - url: 地址
//    ///   - hash: 插入数据时返回的hash值
//    /// - Returns: 不为空则是成功
//    public func verificationHash(url:String,verifiSuccessBlock:@escaping(_ status: String) -> Void){
//
//       DBRequest.GET(url: url, params: nil) { [weak self] (data) in
//         guard let mySelf = self else {return}
//        let json = mySelf.dataToJSON(data: data as NSData)
//        if json.keys.count > 0 {
//           /// 状态:  0: 错误 已经失败  1:  成功  2: 等待
//           if json["error"] != nil {
//               verifiSuccessBlock("0")
//           } else {
//            let result = json["result"] as? [String:Any]
//               let status = result?["state"]
//               if status as! String == "pending" {
//                   verifiSuccessBlock("2")
//               } else if status as! String == "success" {
//                   verifiSuccessBlock("1")
//               } else {
//                   verifiSuccessBlock("0")
//               }
//           }
//        } else {
//            verifiSuccessBlock("0")
//        }
//
//      } failure: { (code, message) in
//           verifiSuccessBlock("0")
//      }
//    }
//
//    public func dataToJSON(data:NSData) ->[String : Any] {
//        var result = [String : Any]()
//
//        if let dic = try? JSONSerialization.jsonObject(with: data as Data,
//                                                       options: .mutableContainers) as? [String : Any] {
//            result = dic
//        }
//
//        return result
//    }
//}




extension DBChainKit {
    /// 获取积分
    public func registerNewAccountNumber(appinfo: AppInfo,
                                         resultCloure: @escaping (_ state: Bool,
                                                                  _ errorMsg: String?) -> Void) {
        var tempUrl = appinfo.baseurl!
        if tempUrl.last != "/" { tempUrl = tempUrl + "/"}
        let url = tempUrl + "dbchain/oracle/new_app_user/" + self.token

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
                    resultCloure(true,nil)
                } else {
                    resultCloure(false,stateStr)
                }
            }
        } failure: { (code, message ) in
            resultCloure(false, message)
        }
    }

    /// 获取用户信息
    public func getUserModel(userModelCloure: @escaping (DBUserModel) -> Void,failure: ((_ code: Int?, _ errorMessage: String) -> Void)?) {
        guard !self.address.isBlank else {
            return
        }
        guard self.appinfo.baseurl != nil else {
            return
        }

        var tempUrl = self.appinfo.baseurl!
        if tempUrl.last != "/" {
            tempUrl = tempUrl + "/"
        }

        let url = tempUrl + "auth/accounts/" + self.address
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



extension DBChainKit {


    /// 单表单数据插入
    /// - Parameters:
    ///   - appinfo: 基本信息
    ///   - tableName: 表名
    ///   - fields: 待插入信息
    ///   - insertStatusBlock: 成功或失败以数字 0 代表失败,1 代表成功的形式返回
    public func insertRow (appinfo: AppInfo,
                          tableName: String,
                          fields: [String:Any],
                          insertStateBlock:@escaping(_ state:String) -> Void) {
        /// 先获取用户信息
        getUserModel { (model) in
            /// 参数签名及排序
            let paramsDic = DBParamSigner.shared.insertRowSign(appinfo: appinfo,
                                                               userModel: model,
                                                               privateKeyStr: self.privatekey,
                                                               publicKeyStr: self.publickey,
                                                               address: self.address,
                                                               tableName: tableName,
                                                               fields: fields)

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
    public func trashcanRowData (appinfo: AppInfo,
                                tableName: String,
                                trashcanID: String,
                                trashcanStateBlock:@escaping(_ state:String) -> Void) {

        getUserModel { (model) in
            let params = DBParamSigner.shared.trashcanRowSign(appinfo: appinfo,
                                                              userModel: model,
                                                              privateKeyStr: self.privatekey,
                                                              publicKeyStr: self.publickey,
                                                              address: self.address,
                                                              tableName: tableName,
                                                              trashcanID: trashcanID)
            self.startInsertRowRequest(params: params!, insertStateBlock: trashcanStateBlock)

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
    public func functionInsertRow (appinfo: AppInfo,
                                   signArgument: String,
                                   functionName: String,
                                   insertStateBlock:@escaping(_ state:String) -> Void) {
        getUserModel { (model) in
            let params = DBParamSigner.shared.functionRowSign(appinfo: appinfo,
                                                              userModel: model,
                                                              privateKeyStr: self.privatekey,
                                                              publicKeyStr: self.publickey,
                                                              address: self.address,
                                                              signArgument: signArgument,
                                                              function_name: functionName)
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
    public func functionInsertDic(appinfo: AppInfo,
                                  argumentsAndFunctionNames: [String: String],
                                  insertStateBlock:@escaping(_ state:String) -> Void) {
        getUserModel { (model) in
            let params = DBParamSigner.shared.functionSignMore(appinfo: appinfo,
                                                               userModel: model,
                                                               privateKeyStr: self.privatekey,
                                                               publicKeyStr: self.publickey,
                                                               address: self.address,
                                                               signStrAndFunctionNames: argumentsAndFunctionNames)
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
    public func functionInsertMessageArr (appinfo: AppInfo,
                                          messageArr: [[String: Any]],
                                          insertStateBlock:@escaping(_ state:String) -> Void) {
        getUserModel { (model) in
            let params = DBParamSigner.shared.functionSignObjectArr(appinfo: appinfo,
                                                                    userModel: model,
                                                                    privateKeyStr: self.privatekey,
                                                                    publicKeyStr: self.publickey,
                                                                    msgObjectArr: messageArr)
            self.startInsertRowRequest(params: params!, insertStateBlock: insertStateBlock)
        } failure: { (code, message) in
            insertStateBlock("error:\(message)")
        }
    }


}


extension DBChainKit {
    /**
        开始发送插入数据的网络请求
     */
    fileprivate func startInsertRowRequest(params: [String: Any] , insertStateBlock:@escaping(_ state:String) -> Void) {
        var tempUrl = appinfo.baseurl!
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
                        let requestUrl = tempUrl + "dbchain/tx-simple-result/" + "\(self.token)/" + "\(txhash!)"
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
    fileprivate func verificationHash(url: String,
                                      verifiSuccessBlock:@escaping(_ state: String) -> Void) {

        DBRequest.GET(url: url, params: nil) { (data) in
            let json = data.dataToDictionary()
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
