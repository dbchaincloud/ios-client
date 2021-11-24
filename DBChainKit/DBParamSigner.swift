//
//  File.swift
//  
//
//  Created by iOS on 2021/6/18.
//

import Foundation
import HDWalletSDK

public class DBParamSigner: NSObject {
    public static let shared = DBParamSigner()
    private override init() {}

    var signMsgArr = [Dictionary<String, Any>]()
    let fee: [String: Any] = ["amount":[],"gas":"99999999"]

    /// 单条插入数据
    /// - Parameters:
    ///   - appinfo: 基本信息
    ///   - userModel: 用户模型
    ///   - address: 地址
    ///   - privateKeyStr: 私钥
    ///   - publicKeyStr: 公钥
    ///   - fields: 待插入信息体
    ///   - tableName: 表名
    /// - Returns: 返回签名后按字母顺序排序的字典
    func insertRowSign(appinfo: AppInfo,
                       userModel: DBUserModel,
                       privateKeyStr: String,
                       publicKeyStr: String,
                       address: String,
                       tableName: String,
                       fields: [String: Any]) -> [String: Any]? {

        let fieldStr = fields.dicValueString()
        let fieldData = Data(fieldStr!.utf8)
        let fieldBase = fieldData.base64EncodedString()
        let valueDic:[String:Any] = ["app_code":appinfo.appcode!,
                                     "owner":address,
                                     "fields":fieldBase,
                                     "table_name":tableName]
        let msgDic: [String:Any] = ["type":"dbchain/InsertRow",
                                    "value":valueDic]
        signMsgArr.append(msgDic)
        return singerBasic(appinfo: appinfo, userModel: userModel, privateKeyStr: privateKeyStr, publicKeyStr: publicKeyStr)
    }

    /// 冻结单条数据
    /// - Parameters:
    ///   - appinfo: 基本信息
    ///   - userModel: 用户模型
    ///   - privateKeyStr: 私钥
    ///   - publicKeyStr: 公钥
    ///   - address: 地址
    ///   - tableName: 待冻结数据的表名
    ///   - trashcanID: 待冻结数据的id
    /// - Returns: 返回签名后按字母顺序排序的字典
    func trashcanRowSign(appinfo: AppInfo,
                         userModel: DBUserModel,
                         privateKeyStr: String,
                         publicKeyStr: String,
                         address: String,
                         tableName: String,
                         trashcanID: String) -> [String: Any]? {

        let valueDic:[String:Any] = ["app_code": appinfo.appcode!,
                                     "owner": address,
                                     "id": trashcanID,
                                     "table_name": tableName]

        let msgDic:[String:Any] = ["type": "dbchain/FreezeRow",
                                   "value": valueDic]

        signMsgArr.append(msgDic)
        return singerBasic(appinfo: appinfo, userModel: userModel, privateKeyStr: privateKeyStr, publicKeyStr: publicKeyStr)
    }

    /// 单次函数请求
    /// - Parameters:
    ///   - appinfo: 基本信息
    ///   - userModel: 用户模型
    ///   - privateKeyStr: 私钥
    ///   - publicKeyStr: 公钥
    ///   - address: 地址
    ///   - signArgument: 多条数据请求的字符串 格式:
    ///      ["tableName__表名"," 第一条数据的字符串数组排列",  " 第二条数据的字符串数组排列 ",.......]
    ///   - function_name: 函数名称  使用前提是该函数名已在控制台注册过
    /// - Returns: 返回签名后按字母顺序排序的字典
    func functionRowSign(appinfo: AppInfo,
                         userModel: DBUserModel,
                         privateKeyStr: String,
                         publicKeyStr: String,
                         address: String,
                         signArgument:String,
                         function_name:String) -> [String: Any]? {

        let signvalueDic:[String:Any] = ["app_code":appinfo.appcode!,
                                         "owner":address,
                                         "argument":signArgument,
                                         "function_name":function_name]

        let signmsgDic:[String:Any] = ["type":"dbchain/CallFunction",
                                       "value":signvalueDic]
        signMsgArr.append(signmsgDic)
        return singerBasic(appinfo: appinfo, userModel: userModel, privateKeyStr: privateKeyStr, publicKeyStr: publicKeyStr)
    }

    /// 多条函数请求组合
    /// - Parameters:
    ///   - appinfo: 基本信息
    ///   - userModel: 用户模型
    ///   - privateKeyStr: 私钥
    ///   - publicKeyStr: 公钥
    ///   - address: 地址
    ///   - signStrAndFunctionNames: key: 数据组合的字符串 value:  函数的名称 一一对应
    /// - Returns: 返回签名后按字母顺序排序的字典
    func functionSignMore(appinfo: AppInfo,
                          userModel: DBUserModel,
                          privateKeyStr: String,
                          publicKeyStr: String,
                          address: String,
                          signStrAndFunctionNames: [String: String]) -> [String: Any]? {
        for (signStr,funtionName) in signStrAndFunctionNames {
            let signvalueDic:[String:Any] = ["app_code": appinfo.appcode!,
                                             "owner": address,
                                             "argument": signStr,
                                             "function_name": funtionName]

            let signmsgDic:[String:Any] = ["type": "dbchain/CallFunction",
                                           "value": signvalueDic]
            signMsgArr.append(signmsgDic)
        }

        return singerBasic(appinfo: appinfo, userModel: userModel, privateKeyStr: privateKeyStr, publicKeyStr: publicKeyStr)
    }

    /// 多条数据打包请求, 在外处理数据形式
    /// - Parameters:
    ///   - appinfo: 基本信息
    ///   - userModel: 用户模型
    ///   - privateKeyStr: 私钥
    ///   - publicKeyStr: 公钥
    ///   - msgObjectArr: 打包的数据, 类型为 字典数组
    /// - Returns: 返回签名后按字母顺序排序的字典
    func functionSignObjectArr(appinfo: AppInfo,
                               userModel: DBUserModel,
                               privateKeyStr: String,
                               publicKeyStr: String,
                               msgObjectArr:[Dictionary<String, Any>]) -> [String: Any]? {
        signMsgArr = msgObjectArr

        return singerBasic(appinfo: appinfo, userModel: userModel, privateKeyStr: privateKeyStr, publicKeyStr: publicKeyStr)
    }
}

extension DBParamSigner {

    /// 排序最后提交服务器的数据
    /// - Parameters:
    ///   - appinfo: 基本信息
    ///   - userModel: 用户模型
    ///   - privateKeyStr: 私钥
    ///   - publicKeyStr: 公钥
    /// - Returns: 返回签名并排序的数据
    fileprivate func singerBasic(appinfo: AppInfo,
                                 userModel: DBUserModel,
                                 privateKeyStr: String,
                                 publicKeyStr: String) -> [String:Any]? {

        let signDiv : [String:Any] = ["account_number":userModel.result.value.account_number,
                                      "chain_id":appinfo.chainid!,
                                      "fee":fee,
                                      "memo":"",
                                      "msgs":signMsgArr,
                                      "sequence":userModel.result.value.sequence]

        let str = signDiv.dicValueString()
        let replacStr = str!.replacingOccurrences(of: "\\/", with: "/")
        let strArr = [UInt8](replacStr.utf8)
        /// secp256k1 签名
        do {
            let signData = try signSawtoothSigning(data: strArr, privateKey: privateKeyStr.hexaBytes)

            let signStr = signData.base64EncodedString()
            let publickeyBase = publicKeyStr.hexaData.base64EncodedString()

            let signDivSorted = ["key":["type":"tendermint/PubKeySecp256k1",
                                        "value":publickeyBase]]
            let typeSignDiv = sortedDictionarybyLowercaseString(dic: signDivSorted)

            let signDic = ["key":["pub_key":typeSignDiv[0],
                                  "signature":signStr]]

            let signDiv = sortedDictionarybyLowercaseString(dic: signDic)

            let tx = ["key":["memo":"",
                             "fee":fee,
                             "msg":signMsgArr,
                             "signatures":[signDiv[0]]]]

            let sortTX = sortedDictionarybyLowercaseString(dic: tx)

            let dataSort = sortedDictionarybyLowercaseString(dic: ["key": ["mode":"async","tx":sortTX[0]]])

            return dataSort[0]

        } catch {
            return nil
        }
    }

    /// 字典排序
    fileprivate func sortedDictionarybyLowercaseString(dic:Dictionary<String, Any>) -> [[String:Any]] {
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











//public struct DBQuery {
//
//    public init() { }
//
//    /// 查询指定id数据
//    /// - Parameters: URL 格式应如下  tableName: 需要查询表的名称,
//    //      let token = Token().createAccessToken()
//    //      let url = BASEURL + "dbchain/find/" + "\(token)/" + "\(appcode)/" + "\(tableName)/" + "\(id)"
//    ///   - appcode: appcode
//    ///   - tableName: 表名
//    ///   - id: 需要查询的 id
//    ///   - Returns:成功返回JsonStr,  失败返回字符串 Query Failed: \(error message)
//    public func queryUserData(url:String,closeBlock:@escaping(_ queryStatus:String) -> Void) -> Void {
//      DBRequest.GET(url: url, params: nil) { (data) in
//          let jsonStr : String = String(data: data, encoding: .utf8) ?? ""
//          closeBlock(jsonStr)
//      } failure: { (code, message) in
//          closeBlock("Query Failed:\(message)")
//      }
//    }
//
//    /// 查询整张表数据
//    /// - Parameters:
//    ///   - urlStr:
//    ///    let token = Token().createAccessToken() ,
//    ///    let url = BASEURL + "dbchain/querier/" + "\(token)/"    注意: 以 " / "  结尾传入
//    ///   - tableName: 待查询的表名称
//    ///   - appcode: 对应数据库 的 appcode
//    ///   - closeBlock: 闭包回调,. 成功返回 JsonStr.  失败返回 字符串 Query Failed: \(error message)
//    /// - Returns:  成功返回 JsonStr.  失败返回 字符串 Query Failed: \(error message)
//    public func queryTableData(urlStr:String,tableName: String,appcode:String,closeBlock:@escaping(_ queryStatus:String) -> Void) -> Void {
//      let name : [[String:Any]] = [["method":"table","table":tableName]]
//      guard let nameData : Data = ObjectToData(object: name) else { return }
//      let nameBase = Base58.encode(nameData)
//      let url = urlStr + "\(appcode)/" + nameBase
//        print("查询请求的 URL:\(url)")
//        DBRequest.GET(url: url, params: nil) { (data) in
//        let jsonStr : String = String(data: data, encoding: .utf8)!
//          closeBlock(jsonStr)
//      } failure: { (code, message) in
//        closeBlock("Query Failed:\(message)")
//      }
//    }
//
//
//    /// 查询与value匹配的数据  多条件查询
//    /// - Parameters:
//    ///   - urlStr:
//    ///   let token = Token().createAccessToken()
//    ///   let urlStr = BASEURL + "dbchain/querier/" + "\(token)/"  注意: 以 " / "  结尾传入
//    ///   - tableName: 表名
//    ///   - appcode: 对应数据库的 appcode
//    ///   - fieldToValueDic: 查询字段名和数据组成的字典:  ["字段名" : "数据"]
//    ///   - closeBlock: 闭包回调,. 成功返回 data 类型.  失败返回 error message 的 data 形式
//    /// - Returns:. 成功返回 JsonStr.  失败返回 字符串 Query Failed: \(error message)
//    public func queryOneData(urlStr:String,tableName: String,appcode:String,fieldToValueDic:[String:Any],closeBlock:@escaping(_ queryData : Data) -> Void) -> Void {
//        var nameArr : [[String:Any]] = [["method":"table","table":tableName]]
//        for (key,value) in fieldToValueDic {
//            let arr = ["field":key,"method":"where","operator":"=","value":value]
//            nameArr.append(arr)
//        }
//        guard let nameData : Data = ObjectToData(object: nameArr) else { return }
//        let nameBase = Base58.encode(nameData)
//        let url = urlStr + "\(appcode)/" + nameBase
//        DBRequest.GET(url: url, params: nil) { (data) in
//            let jsonStr : String = String(data: data, encoding: .utf8) ?? "查询表为空"
//            closeBlock(data)
//        } failure: { (code, message) in
//            closeBlock(message.data(using: .utf8)!)
//        }
//    }
//
//    /// 传承查询  - 查询传承需使用特定的方法.
//    /// - Parameters:
//    ///   - urlStr: let url = BASEURL + "dbchain/call-custom-querier/" + "\(token)/" + "\(appcode)/" + "\(querierName)/"
//    ///   Token:  传递 Token
//    ///   Appcode: 库信息
//    ///   QuerierName: 自定义函数名称  需先调用注册函数方法在库中注册后才能正常使用
//    ///   严格按照以上格式传递 urlStr 参数
//    ///   - fieldToValueDic: 查询条件
//    ///   - closeBlock: 回调查询结果
//    /// - Returns: 成功返回 jsonString  失败 返回字符串 " 0 "
//    public func queryInheritListData(urlStr : String,tableName:String,fieldToValueDic:[String:Any]?,closeBlock:@escaping(_ queryStatus:String) -> Void) -> Void {
//        var nameArr : [[String:Any]] = [["method":"table","table":tableName]]
//        if fieldToValueDic?.count ?? 0 > 0 {
//            for (key,value) in fieldToValueDic! {
//                let arr = ["field":key,"method":"where","operator":"=","value":value]
//                nameArr.append(arr)
//            }
//        }
//        guard let nameData : Data = ObjectToData(object: nameArr) else { return }
//        let nameBase = Base58.encode(nameData)
//        guard let againData : Data = nameBase.data(using: .utf8) else {return}
//        let againBaseStr = Base58.encode(againData)
//        let url = urlStr + "\(againBaseStr)"
//
//        DBRequest.GET(url: url, params: nil) { (data) in
//            let jsonString : String = String(data: data, encoding: .utf8) ?? "查询为空"
//            closeBlock(jsonString)
//        } failure: { (code, message) in
//            closeBlock("0")
//        }
//     }
//}

// 字典|数组 转Data
//public func ObjectToData(object: Any) -> Data? {
//
//    do {
//        return try JSONSerialization.data(withJSONObject: object, options: []);
//    } catch {
//        return nil;
//    }
//    return nil;
//}
