//
//  RequestConvertible.swift
//  Twitter application
//
//  Created by Denis on 27.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import Foundation

protocol RequestConvertible {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders { get }
    
    func asURLRequest(baseURL: URL) throws -> URLRequest
}

extension RequestConvertible {
    var headers: HTTPHeaders {
        return [:]
    }
}
