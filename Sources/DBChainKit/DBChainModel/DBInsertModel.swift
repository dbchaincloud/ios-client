//
//  File.swift
//  
//
//  Created by iOS on 2021/6/18.
//

import Foundation
public struct DBInsertModel: Codable {
    public var height: String?
    public var txhash: String?

    public enum CodingKeys: String, CodingKey {
        case height
        case txhash
    }
}
