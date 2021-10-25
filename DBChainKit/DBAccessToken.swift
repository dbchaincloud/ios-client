//
//  File.swift
//  
//
//  Created by iOS on 2021/6/18.
//

import Foundation
import HDWalletSDK
public struct DBToken {

    public init(){}
    
    /// 获取当前 毫秒级 时间戳 - 13位
    public  var milliStamp : String {
          let timeInterval: TimeInterval = Date().timeIntervalSince1970
          let millisecond = CLongLong(round(timeInterval*1000))
          return "\(millisecond)"
      }


    /// 获取Token
    /// - Parameters:
    ///   - privateKey: 秘钥  Uint8 数组形式
    ///   - PublikeyData: 公钥  Data 形式
    /// - Returns: 成功则 返回Token. 错误返回空
    public func createAccessToken(privateKey:[UInt8],PublikeyData:Data) -> String {
        let millisecond = self.milliStamp
        let secondUint = [UInt8](millisecond.utf8)
        do{
            let signMilliSecond = try signSawtoothSigning(data: secondUint, privateKey: privateKey)

            let timeBase58 = Base58.encode(signMilliSecond)

            let publicKeyBase58 = Base58.encode(PublikeyData)

            return "\(publicKeyBase58):" + "\(millisecond):" + "\(timeBase58)"

        } catch {
            return ""
        }
    }
}
