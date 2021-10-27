import Foundation
import CryptoKit
import SawtoothSigning
import secp256k1
import CryptoSwift
import Alamofire
import HDWalletSDK

public struct DBChainKit{
    public init(){}

    public func createMnemonic() -> String {
        let mnemonic = Mnemonic.create()
        return mnemonic
    }
}
