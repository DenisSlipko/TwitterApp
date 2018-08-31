//
//  Session.swift
//  Twitter application
//
//  Created by Denis  on 8/30/18.
//  Copyright © 2018 Denis. All rights reserved.
//

import Foundation
import Security

final class Session: Codable {
    
    let user: User
    let accessToken: AccessToken
    
    static private var keychain: KeychainProvider {
        return KeychainProvider(keyPrefix: KeychainKey.service)
    }
    
    init(user: User, accessToken: AccessToken) {
        self.user = user
        self.accessToken = accessToken
    }
    
    func save() throws {
        let userData = try JSONEncoder().encode(user)
        let tokenData = try JSONEncoder().encode(accessToken)
        Session.keychain.set(userData, forKey: KeychainKey.user)
        Session.keychain.set(tokenData, forKey: KeychainKey.accessToken)
    }
    
    func invalidate() {
        Session.keychain.delete(KeychainKey.user)
        Session.keychain.delete(KeychainKey.accessToken)
    }
    
    static func fetch() -> Session? {
        guard
            let userData = Session.keychain.getData(KeychainKey.user),
            let tokenData = Session.keychain.getData(KeychainKey.accessToken) else {
                return nil
        }
        do {
            let user = try JSONDecoder().decode(User.self, from: userData)
            let accessToken = try JSONDecoder().decode(AccessToken.self, from: tokenData)
            return Session(user: user, accessToken: accessToken)
        } catch {
            return nil
        }
    }
}

private enum KeychainKey {
    static let user: String = "keychain.user"
    static let accessToken: String = "keychain.access.token"
    static let service: String = "com.twitter.app"
}
