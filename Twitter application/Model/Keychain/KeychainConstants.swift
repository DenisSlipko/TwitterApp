//
//  KeychainConstants.swift
//  Twitter application
//
//  Created by Denis  on 8/30/18.
//  Copyright © 2018 Denis. All rights reserved.
//

import Foundation
import Security

public struct KeychainConstants {
    
    public static var accessGroup: String { return toString(kSecAttrAccessGroup) }
    
    public static var accessible: String { return toString(kSecAttrAccessible) }
    
    public static var attrAccount: String { return toString(kSecAttrAccount) }
    
    public static var attrSynchronizable: String { return toString(kSecAttrSynchronizable) }
    
    public static var klass: String { return toString(kSecClass) }
    
    public static var matchLimit: String { return toString(kSecMatchLimit) }
    
    public static var returnData: String { return toString(kSecReturnData) }
    
    public static var valueData: String { return toString(kSecValueData) }
    
    static func toString(_ value: CFString) -> String {
        return value as String
    }
}

public enum KeychainSwiftAccessOptions {
    case accessibleWhenUnlocked
    case accessibleWhenUnlockedThisDeviceOnly
    case accessibleAfterFirstUnlock
    case accessibleAfterFirstUnlockThisDeviceOnly
    case accessibleAlways
    case accessibleWhenPasscodeSetThisDeviceOnly
    case accessibleAlwaysThisDeviceOnly
    
    static var defaultOption: KeychainSwiftAccessOptions {
        return .accessibleWhenUnlocked
    }
    
    var value: String {
        switch self {
        case .accessibleWhenUnlocked:
            return toString(kSecAttrAccessibleWhenUnlocked)
            
        case .accessibleWhenUnlockedThisDeviceOnly:
            return toString(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
            
        case .accessibleAfterFirstUnlock:
            return toString(kSecAttrAccessibleAfterFirstUnlock)
            
        case .accessibleAfterFirstUnlockThisDeviceOnly:
            return toString(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
            
        case .accessibleAlways:
            return toString(kSecAttrAccessibleAlways)
            
        case .accessibleWhenPasscodeSetThisDeviceOnly:
            return toString(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
            
        case .accessibleAlwaysThisDeviceOnly:
            return toString(kSecAttrAccessibleAlwaysThisDeviceOnly)
        }
    }
    
    func toString(_ value: CFString) -> String {
        return KeychainConstants.toString(value)
    }
}
