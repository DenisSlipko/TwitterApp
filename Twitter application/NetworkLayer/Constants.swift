//
//  Constants.swift
//  Algorithms
//
//  Created by Denis  on 8/28/18.
//  Copyright © 2018 Denis . All rights reserved.
//

import Foundation

enum Constants {
    enum Key {
        static let consumerKey = "oauth_consumer_key"
        static let nonce = "oauth_nonce"
        static let signatureMethod = "oauth_signature_method"
        static let timestamp = "oauth_timestamp"
        static let oauthToken = "oauth_token"
        static let oauthVersion = "oauth_version"
    }
    
    struct Value {
        static let consumerKey = "nIhm3OLyKE02a5w95MKEnL7Sz"
        static let consumerSecret = "lrlMGKMb64l4gFZBvXOAT4f2twySBgeDtn4qIcf2ntvyUmBiMW"
        static let oauthToken = Session.fetch()!.accessToken.token//"1295068026-1u1Jn66gpk82RDhMZ3o5TnLrbaLzj1yWs2iuVKY"
        static let tokenSecret = Session.fetch()!.accessToken.tokenSecret//"sapv0EpQTIzx0PunzcO9cxIhVAjUGzfjxe8hXQu6EMkUK"
        static let oauthVersion = "1.0"
        static let signatureMethod = "HMAC-SHA1"
        
        static var nonce: String {
            let data = NSMutableData(length: 32)!
            _ = SecRandomCopyBytes(kSecRandomDefault, data.length, UnsafeMutableRawPointer(data.mutableBytes))
            let base64Encoded = data.base64EncodedString(options: [])
            let nonce = base64Encoded.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
            return nonce
        }
        
        static var timestamp: String {
            let timestamp = Date().timeIntervalSince1970
            return "\(Int(timestamp))"
        }
    }
    
    static var headers: [String: String] {
        return [
            Key.consumerKey: Value.consumerKey,
            Key.nonce: Value.nonce,
            Key.signatureMethod: Value.signatureMethod,
            Key.timestamp: Value.timestamp,
            Key.oauthToken: Value.oauthToken,
            Key.oauthVersion: Value.oauthVersion
        ]
    }
}
