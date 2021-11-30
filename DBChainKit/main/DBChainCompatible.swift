//
//  DBChainCompatible.swift
//  DBChainKit
//
//  Created by iOS on 2021/11/29.
//

import Foundation

/// 公共方法
public protocol Compatible {
    /// 通过私钥获取公钥
    /// - Parameter privateKey: 私钥
    func generatePublicKeyBy(privateKey : String) -> String

    /// 通过公钥获取地址
    /// - Parameter publicKey: 公钥
    func generateAddressBy(publicKey:  String) -> String

    /// 获取Token
    /// - Parameters:
    ///   - publicKey: 公钥
    ///   - privateKey: 私钥
    func generateTokenBy(publicKey: String,privateKey: String) -> String

    /// 数据签名
    /// - Parameters:
    ///   - signHex: 待签名数据
    ///   - privateKeyStr: 私钥
    func signData(signHex: String, privateKeyStr: String) -> String

    /// 不同加密方法的签名请求
    /// - Parameter publicKeyStr: 公钥
    func signDictionaryType(publicKeyStr: String) -> [String: Any]

}
