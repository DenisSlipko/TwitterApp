//
//  NetworkProvider.swift
//  Twitter application
//
//  Created by Denis on 27.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import Foundation

protocol NetworkProvider {
	typealias Completion<T> = (Result<T>) -> Void
    
    var decodingContext: Any? { get }
    
    @discardableResult
    func requestData(_ request: DataRequestConvertible,
                     completion: @escaping Completion<Data>) -> Cancellable?
}
