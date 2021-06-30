//
//  File.swift
//  
//
//  Created by iOS on 2021/6/18.
//

import Foundation

public struct Query {

    public init() { }
    
    /// 查询指定id数据
    /// - Parameters: URL 格式应如下  tableName: 需要查询表的名称,
    //      let token = Token().createAccessToken()
    //      let url = BASEURL + "dbchain/find/" + "\(token)/" + "\(appcode)/" + "\(tableName)/" + "\(id)"
    ///   - appcode: appcode
    ///   - tableName: 表名
    ///   - id: 需要查询的 id
    ///   - Returns:成功返回JsonStr,  失败返回字符串 Query Failed: \(error message)
    public func queryUserData(url:String,closeBlock:@escaping(_ queryStatus:String) -> Void) -> Void {
      DBRequest.GET(url: url, params: nil) { (data) in
          let jsonStr : String = String(data: data, encoding: .utf8) ?? ""
          closeBlock(jsonStr)
      } failure: { (code, message) in
          closeBlock("Query Failed:\(message)")
      }
    }

    /// 查询整张表数据
    /// - Parameters:
    ///   - urlStr:
    ///    let token = Token().createAccessToken() ,
    ///    let url = BASEURL + "dbchain/querier/" + "\(token)/"    注意: 以 " / "  结尾传入
    ///   - tableName: 待查询的表名称
    ///   - appcode: 对应数据库 的 appcode
    ///   - closeBlock: 闭包回调,. 成功返回 JsonStr.  失败返回 字符串 Query Failed: \(error message)
    /// - Returns:  成功返回 JsonStr.  失败返回 字符串 Query Failed: \(error message)
    public func queryTableData(urlStr:String,tableName: String,appcode:String,closeBlock:@escaping(_ queryStatus:String) -> Void) -> Void {
      let name : [[String:Any]] = [["method":"table","table":tableName]]
      guard let nameData : Data = ObjectToData(object: name) else { return }
      let nameBase = Base58.encode(nameData)
      let url = urlStr + "\(appcode)/" + nameBase
        print("查询请求的 URL:\(url)")
        DBRequest.GET(url: url, params: nil) { (data) in
        let jsonStr : String = String(data: data, encoding: .utf8)!
          closeBlock(jsonStr)
      } failure: { (code, message) in
        closeBlock("Query Failed:\(message)")
      }
    }


    /// 查询与value匹配的数据  多条件查询
    /// - Parameters:
    ///   - urlStr:
    ///   let token = Token().createAccessToken()
    ///   let urlStr = BASEURL + "dbchain/querier/" + "\(token)/"  注意: 以 " / "  结尾传入
    ///   - tableName: 表名
    ///   - appcode: 对应数据库的 appcode
    ///   - fieldToValueDic: 查询字段名和数据组成的字典:  ["字段名" : "数据"]
    ///   - closeBlock: 闭包回调,. 成功返回 data 类型.  失败返回 error message 的 data 形式
    /// - Returns:. 成功返回 JsonStr.  失败返回 字符串 Query Failed: \(error message)
    public func queryOneData(urlStr:String,tableName: String,appcode:String,fieldToValueDic:[String:Any],closeBlock:@escaping(_ queryData : Data) -> Void) -> Void {
        var nameArr : [[String:Any]] = [["method":"table","table":tableName]]
        for (key,value) in fieldToValueDic {
            let arr = ["field":key,"method":"where","operator":"=","value":value]
            nameArr.append(arr)
        }
        guard let nameData : Data = ObjectToData(object: nameArr) else { return }
        let nameBase = Base58.encode(nameData)
        let url = urlStr + "\(appcode)/" + nameBase
        DBRequest.GET(url: url, params: nil) { (data) in
            let jsonStr : String = String(data: data, encoding: .utf8) ?? "查询表为空"
            closeBlock(data)
        } failure: { (code, message) in
            closeBlock(message.data(using: .utf8)!)
        }
    }

    /// 传承查询  - 查询传承需使用特定的方法.
    /// - Parameters:
    ///   - urlStr: let url = BASEURL + "dbchain/call-custom-querier/" + "\(token)/" + "\(appcode)/" + "\(querierName)/"
    ///   Token:  传递 Token
    ///   Appcode: 库信息
    ///   QuerierName: 自定义函数名称  需先调用注册函数方法在库中注册后才能正常使用
    ///   严格按照以上格式传递 urlStr 参数
    ///   - fieldToValueDic: 查询条件
    ///   - closeBlock: 回调查询结果
    /// - Returns: 成功返回 jsonString  失败 返回字符串 " 0 "
    public func queryInheritListData(urlStr : String,tableName:String,fieldToValueDic:[String:Any]?,closeBlock:@escaping(_ queryStatus:String) -> Void) -> Void {
        var nameArr : [[String:Any]] = [["method":"table","table":tableName]]
        if fieldToValueDic?.count ?? 0 > 0 {
            for (key,value) in fieldToValueDic! {
                let arr = ["field":key,"method":"where","operator":"=","value":value]
                nameArr.append(arr)
            }
        }
        guard let nameData : Data = ObjectToData(object: nameArr) else { return }
        let nameBase = Base58.encode(nameData)
        guard let againData : Data = nameBase.data(using: .utf8) else {return}
        let againBaseStr = Base58.encode(againData)
        let url = urlStr + "\(againBaseStr)"

        DBRequest.GET(url: url, params: nil) { (data) in
            let jsonString : String = String(data: data, encoding: .utf8) ?? "查询为空"
            closeBlock(jsonString)
        } failure: { (code, message) in
            closeBlock("0")
        }
     }
}

// 字典|数组 转Data
public func ObjectToData(object: Any) -> Data? {

    do {
        return try JSONSerialization.data(withJSONObject: object, options: []);
    } catch {
        return nil;
    }
    return nil;
}
