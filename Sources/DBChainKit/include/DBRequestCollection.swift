//
//  File.swift
//  
//
//  Created by iOS on 2021/6/18.
//

import Foundation

public struct DBRequestCollection {

    public init(){ }

    /// 获取用户信息
    /// - Parameters:
    ///   - urlStr: Get请求 .库的地址链接 +  公开的地址字符串   例如: https://chain-ytbox.dbchain.cloud/relay/auth/accounts/cosmos1557ygk9vkplf82a34nyrgnyt9negrd2k6e9zek
    ///   - DBUserModelCloure: 用户模型
    ///   - failure: 错误返回code和message
    public func getUserAccountNum(urlStr:String,DBUserModelCloure:@escaping (DBUserModel) -> Void,failure : ((Int?, String) ->Void)?){

        DBRequest.GET(url: urlStr, params: nil) { (jsonData) in
            let str = String(data: jsonData, encoding: .utf8)!
            do {
                let model = try JSONDecoder().decode(DBUserModel.self, from: jsonData)
                DispatchQueue.main.async {
                    DBUserModelCloure(model)
                }
            } catch {
                failure?(201,"获取用户信息转换失败: \(error)")
            }

        } failure: { (code, message) in
            DispatchQueue.main.async {
                failure?(code,message)
            }
        }
    }
}
