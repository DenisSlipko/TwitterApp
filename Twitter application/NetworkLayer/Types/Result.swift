//
//  Result.swift
//  Twitter application
//
//  Created by Denis on 27.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import Foundation

enum Result<Value> {
    case success(Value)
    case failure(Error)
    
    init(_ value: Value) {
        self = .success(value)
    }
    
    init (_ error: Error) {
        self = .failure(error)
    }
}

extension Result {
    func map<T>(_ transformation: (Value) throws -> T) rethrows -> Result<T> {
        switch self {
        case .success(let value):
            do {
            	let newValue = try transformation(value)
                return Result<T>(newValue)
            } catch {
            	return .init(error)
            }
        case .failure(let error):
            return .init(error)
        }
    }
}
