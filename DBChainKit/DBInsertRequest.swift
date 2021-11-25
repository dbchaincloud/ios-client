//
//  File.swift
//  
//  BASEURL + "auth/accounts/"
//  Created by iOS on 2021/6/19.
//

import Foundation
import Alamofire

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
