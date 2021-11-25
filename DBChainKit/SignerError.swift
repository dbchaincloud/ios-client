//
//  SignerError.swift
//  DBChainKit
//
//  Created by iOS on 2021/11/25.
//

import Foundation

/// Thrown when an error occurs during the signing process.
public enum SigningError: Error {
    /// An invalid private key
    case invalidPrivateKey

    /// An invalid public key
    case invalidPublicKey

    /// An invalid signature
    case invalidSignature
}
