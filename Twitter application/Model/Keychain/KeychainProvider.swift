//
//  KeychainProvider.swift
//  Twitter application
//
//  Created by Denis  on 8/30/18.
//  Copyright © 2018 Denis. All rights reserved.
//

import Foundation

final class KeychainProvider {
    
    var lastQueryParameters: [String: Any]?
    
     var lastResultCode: OSStatus = noErr
    
    var keyPrefix = "" // Can be useful in test.

     var accessGroup: String?
    
     var synchronizable: Bool = false
    
    private let readLock = NSLock()
    
    public init(keyPrefix: String = "") {
        self.keyPrefix = keyPrefix
    }
 
     func set(_ value: String, forKey key: String,
                  withAccess access: KeychainSwiftAccessOptions? = nil) {
        if let value = value.data(using: String.Encoding.utf8) {
            set(value, forKey: key, withAccess: access)
        }
    }
    
     func set(_ value: Data, forKey key: String,
                  withAccess access: KeychainSwiftAccessOptions? = nil) {
        
        delete(key)
        let accessible = access?.value ?? KeychainSwiftAccessOptions.defaultOption.value
        
        let prefixedKey = keyWithPrefix(key)
        
        var query: [String : Any] = [
            KeychainConstants.klass       : kSecClassGenericPassword,
            KeychainConstants.attrAccount : prefixedKey,
            KeychainConstants.valueData   : value,
            KeychainConstants.accessible  : accessible
        ]
        
        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: true)
        lastQueryParameters = query
        
        lastResultCode = SecItemAdd(query as CFDictionary, nil)
    }
    
     func set(_ value: Bool, forKey key: String,
                  withAccess access: KeychainSwiftAccessOptions? = nil) {
        let bytes: [UInt8] = value ? [1] : [0]
        let data = Data(bytes: bytes)
        set(data, forKey: key, withAccess: access)
    }
    
     func get(_ key: String) -> String? {
        if let data = getData(key) {
            if let currentString = String(data: data, encoding: .utf8) {
                return currentString
            }
            lastResultCode = -67853 // errSecInvalidEncoding
        }
        return nil
    }

     func getData(_ key: String) -> Data? {
        readLock.lock()
        defer { readLock.unlock() }
        
        let prefixedKey = keyWithPrefix(key)
        var query: [String: Any] = [
            KeychainConstants.klass       : kSecClassGenericPassword,
            KeychainConstants.attrAccount : prefixedKey,
            KeychainConstants.returnData  : kCFBooleanTrue,
            KeychainConstants.matchLimit  : kSecMatchLimitOne
        ]
        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: false)
        lastQueryParameters = query
        
        var result: AnyObject?
        lastResultCode = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        if lastResultCode == noErr { return result as? Data }
        return nil
    }
    
     func getBool(_ key: String) -> Bool? {
        guard let data = getData(key) else { return nil }
        guard let firstBit = data.first else { return nil }
        return firstBit == 1
    }

     func delete(_ key: String) {
        let prefixedKey = keyWithPrefix(key)
        
        var query: [String: Any] = [
            KeychainConstants.klass       : kSecClassGenericPassword,
            KeychainConstants.attrAccount : prefixedKey
        ]
        
        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: false)
        lastQueryParameters = query
        
        lastResultCode = SecItemDelete(query as CFDictionary)
    }

     func clear() {
        var query: [String: Any] = [ kSecClass as String : kSecClassGenericPassword ]
        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: false)
        lastQueryParameters = query
        
        lastResultCode = SecItemDelete(query as CFDictionary)
    }
    
    func keyWithPrefix(_ key: String) -> String {
        return "\(keyPrefix)\(key)"
    }
    
    func addAccessGroupWhenPresent(_ items: [String: Any]) -> [String: Any] {
        guard let accessGroup = accessGroup else { return items }
        
        var result: [String: Any] = items
        result[KeychainConstants.accessGroup] = accessGroup
        return result
    }
    
    func addSynchronizableIfRequired(_ items: [String: Any], addingItems: Bool) -> [String: Any] {
        if !synchronizable { return items }
        var result: [String: Any] = items
        result[KeychainConstants.attrSynchronizable] = addingItems == true ? true : kSecAttrSynchronizableAny
        return result
    }
}
