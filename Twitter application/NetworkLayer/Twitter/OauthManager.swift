//
//  OauthManager.swift
//  Twitter application
//
//  Created by Denis on 27.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import Foundation

public final class OauthManager {
    
    public typealias Credentials = (key: String, secret: String)
    
    static func calculateSignature(url: URL,
                                   method: String,
                                   parameter: [String: String],
                                   consumerCredentials cc: Credentials,
                                   userCredentials uc: Credentials?) -> String {
        typealias Tup = (key: String, value: String)
        
        let tuplify: (String, String) -> Tup = {
            return (key: rfc3986encode($0), value: rfc3986encode($1))
        }
        let cmp: (Tup, Tup) -> Bool = {
            return $0.key < $1.key
        }
        let toPairString: (Tup) -> String = {
            return $0.key + "=" + $0.value
        }
        let toBrackyPairString: (Tup) -> String = {
            return $0.key + "=\"" + $0.value + "\""
        }
        
        var oAuthParameters = oAuthDefaultParameters(consumerKey: cc.key, userKey: uc?.key)
        
        let signString: String = [oAuthParameters, parameter, url.queryParameters()]
            .flatMap { $0.map(tuplify) }
            .sorted(by: cmp)
            .map(toPairString)
            .joined(separator: "&")
        
        let signatureBase: String = [method, url.oAuthBaseURL(), signString]
            .map(rfc3986encode)
            .joined(separator: "&")
        
        let signingKey: String = [cc.secret, uc?.secret ?? ""]
            .map(rfc3986encode)
            .joined(separator: "&")
        
        let binarySignature = HMAC.calculate(withHash: .sha1, key: signingKey, message: signatureBase)
        oAuthParameters["oauth_signature"] = binarySignature.base64EncodedString()
    
        return "OAuth " + oAuthParameters
            .map(tuplify)
            .sorted(by: cmp)
            .map(toBrackyPairString)
            .joined(separator: ",")
    }

    open static func httpBody(forFormParameters paras: [String: String],
                              encoding: String.Encoding = .utf8) -> Data? {
        let trans: (String, String) -> String = { k, v in
            return rfc3986encode(k) + "=" + rfc3986encode(v)
        }
        return paras.map(trans).joined(separator: "&").data(using: encoding)
    }

    private static func rfc3986encode(_ str: String) -> String {
        struct Static {
            static let allowed = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._~"
            static let allowedSet = CharacterSet(charactersIn: allowed)
        }
        return str.addingPercentEncoding(withAllowedCharacters: Static.allowedSet) ?? str
    }
    
    private static func oAuthDefaultParameters(consumerKey: String,
                                               userKey: String?)
        -> [String: String] {
            var defaults: [String: String] = [
                "oauth_consumer_key":     consumerKey,
                "oauth_signature_method": "HMAC-SHA1",
                "oauth_version":          "1.0",
                "oauth_timestamp":        String(Int(Date().timeIntervalSince1970)),
                "oauth_nonce":            UUID().uuidString,
                ]
            if let userKey = userKey {
                defaults["oauth_token"] = userKey
            }
            return defaults
    }
}


public extension URLRequest {
    
    public mutating func oAuthSign(method: String,
                                   urlFormParameters paras: [String: String],
                                   consumerCredentials cc: OauthManager.Credentials,
                                   userCredentials uc: OauthManager.Credentials? = nil) {
        self.httpMethod = method.uppercased()
        
        if method == "GET" {
            var urlComponents = URLComponents.init(string: self.url!.absoluteString)!
            urlComponents.queryItems = paras.map {
                let stringValue = "\($0.value)"
                return URLQueryItem(name: $0.key, value: stringValue)
            }
            urlComponents.percentEncodedQuery = urlComponents
                .percentEncodedQuery?
                .replacingOccurrences(of: "+", with: "%2B")
            self = URLRequest(url: urlComponents.url!)
        } else {
            let body = OauthManager.httpBody(forFormParameters: paras)
            self.addValue(String(body?.count ?? 0), forHTTPHeaderField: "Content-Length")
            self.httpBody = body
        }
        
        self.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let sig = OauthManager.calculateSignature(url: self.url!,
                                                  method: self.httpMethod!,
                                                  parameter: paras,
                                                  consumerCredentials: cc, userCredentials: uc)
        
        self.addValue(sig, forHTTPHeaderField: "Authorization")
    }

    public mutating func oAuthSign(
        method: String,
        body: Data? = nil,
        contentType: String? = nil,
        consumerCredentials cc: OauthManager.Credentials,
        userCredentials uc: OauthManager.Credentials? = nil) {
        self.httpMethod = method.uppercased()
        
        if let body = body {
            self.httpBody = body
            self.addValue(String(body.count), forHTTPHeaderField: "Content-Length")
        }
        
        if let ct = contentType {
            self.addValue(ct, forHTTPHeaderField: "Content-Type")
        }
        
        let sig = OauthManager.calculateSignature(url: self.url!,
                                                  method: self.httpMethod!,
                                                  parameter: [:],
                                                  consumerCredentials: cc, userCredentials: uc)
        
        self.addValue(sig, forHTTPHeaderField: "Authorization")
    }
}

fileprivate class HMAC {
    enum HashMethod: UInt32 {
        case sha1, md5, sha256, sha384, sha512, sha224
        
        var length: Int {
            switch self {
            case .md5:     return 16
            case .sha1:    return 20
            case .sha224:  return 28
            case .sha256:  return 32
            case .sha384:  return 48
            case .sha512:  return 64
            }
        }
    }
    
    static func calculate(withHash hash: HashMethod, key: String, message msg: String) -> Data {
        let mac = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: hash.length)
        let keyLen = CUnsignedLong(key.lengthOfBytes(using: .utf8))
        let msgLen = CUnsignedLong(msg.lengthOfBytes(using: .utf8))
        hmac(hash.rawValue, key, keyLen, msg, msgLen, mac)
        return Data(bytesNoCopy: mac, count: hash.length, deallocator: .free)
    }
    
    
    private static let hmac: CCHmacFuncPtr = loadHMACfromCommonCrypto()
    
    private typealias CCHmacFuncPtr = @convention(c) (
        _ algorithm:  CUnsignedInt,
        _ key:        UnsafePointer<CUnsignedChar>,
        _ keyLength:  CUnsignedLong,
        _ data:       UnsafePointer<CUnsignedChar>,
        _ dataLength: CUnsignedLong,
        _ macOut:     UnsafeMutablePointer<CUnsignedChar>
        ) -> Void
    
    private static func loadHMACfromCommonCrypto() -> CCHmacFuncPtr {
        let libcc = dlopen("/usr/lib/system/libcommonCrypto.dylib", RTLD_NOW)
        return unsafeBitCast(dlsym(libcc, "CCHmac"), to: CCHmacFuncPtr.self)
    }
}


fileprivate extension URL {
    
    func queryParameters() -> [String: String] {
        var res: [String: String] = [:]
        for qi in URLComponents(url: self, resolvingAgainstBaseURL: true)?.queryItems ?? [] {
            res[qi.name] = qi.value ?? ""
        }
        return res
    }
    
    func oAuthBaseURL() -> String {
        let scheme = self.scheme?.lowercased() ?? ""
        let host = self.host?.lowercased() ?? ""
        
        var authority = ""
        if let user = self.user, let pw = self.password {
            authority = user + ":" + pw + "@"
        }
        else if let user = self.user {
            authority = user + "@"
        }
        
        var port = ""
        if let iport = self.port, iport != 80, scheme == "http" {
            port = ":\(iport)"
        }
        else if let iport = self.port, iport != 443, scheme == "https" {
            port = ":\(iport)"
        }
        
        return scheme + "://" + authority + host + port + self.path
    }
}
