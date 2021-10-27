//
//  File.swift
//  
//
//  Created by iOS on 2021/6/18.
//

import Foundation
import Alamofire


enum MethodType {
    case get
    case post
}

//一次封装
public class DBRequest {

    public init() {}

    /// 请求方法 返回值JSON
     class func request(_ type : MethodType = .post, url : String, params : [String : Any]?,headers : HTTPHeaders,encoding:ParameterEncoding,success : @escaping (_ data : Data)->(), failure : ((Int?, String) ->Void)?) {

        let method = type == .get ? HTTPMethod.get : HTTPMethod.post

        AF.request(url, method: method, parameters: params,encoding: encoding, headers: headers,requestModifier: { $0.timeoutInterval = 60 }).responseData { (response) in

            guard response.data != nil else {
                failure?(-1001,"请求超时")
                return
            }

            switch response.result {
                case let .success(responseData):
                    success(responseData)
                case let .failure(error):
                    if error.responseCode == NSURLErrorTimedOut {

                    }
                    failure?(201,"请求超时")
                    failureHandle(failure: failure, stateCode: nil, message: error.localizedDescription)
                }
            }

        //错误处理 - 弹出错误信息
        func failureHandle(failure: ((Int?, String) ->Void)? , stateCode: Int?, message: String) {
            failure?(stateCode ,message)
        }
    }

}

//二次封装
extension DBRequest {

    /// GET 请求 返回JSON
    ///
    /// - Parameters:
    ///   - URLString: 请求链接
    ///   - params: 参数
    ///   - success: 成功的回调
    ///   - failture: 失败的回调
    public class func GET(url : String, params : [String : Any]?,headers: HTTPHeaders = ["Content-Type":"application/json"],encoding:ParameterEncoding = JSONEncoding.default,success : @escaping (_ data : Data)->(), failure : ((Int?, String) ->Void)?) {
        DBRequest.request(.get, url: url, params: params,headers: headers,encoding:encoding, success: success, failure: failure)
    }


    /// POST 求情
    ///
    /// - Parameters:
    ///   - URLString: 请求链接
    ///   - params: 参数
    ///   - success: 成功的回调
    ///   - failture: 失败的回调
    public class func POST(url : String, params : [String : Any]?,headers: HTTPHeaders = ["Content-Type":"application/json"],encoding:ParameterEncoding = JSONEncoding.default,success : @escaping (_ data : Data) ->(), failure : ((Int?, String) ->Void)?) {
        DBRequest.request(.post, url: url, params: params, headers:headers,encoding:encoding, success: success, failure: failure)
    }
}
