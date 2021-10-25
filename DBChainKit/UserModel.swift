//
//  File.swift
//
//
//  Created by iOS on 2021/6/18.
//

import Foundation

public class DBUserModel:NSObject, Codable {

//    public init () {
//    }
//    public var height: String
//    public var result: resultModel
//
//    public struct resultModel: Codable {
//        var type: String
//        var value: valueData
//    }
//
//    public struct valueData: Codable {
//        var address: String
//        var coins: [coinData]?
//        var public_key: [publickey]?
//        var account_number: String
//        var sequence: String
//    }
//
//    public struct publickey: Codable {
//        var type: String
//        var value: String
//    }
//
//    public struct coinData: Codable {
//        var denom: String
//        var amount: String
//    }

    var height: String
    var result: resultModel

    struct resultModel: Codable {
        var type: String
        var value: valueData
    }

    struct valueData: Codable {
        var address: String
        var coins: [coinData]?
        var public_key: publicData?
        var account_number: String
        var sequence: String
    }

    struct publicData: Codable {
        var type: String
        var value: String
    }

    struct coinData: Codable {
        var denom: String
        var amount: String
    }
}
