//
//  Utils.swift
//  Twitter application
//
//  Created by Denis on 27.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}

typealias Parameters = [String: Any]
typealias HTTPHeaders = [String: String]


extension URLRequest {
    mutating func addPostRequestHeaders() {
        addValue("application/json",
                 forHTTPHeaderField: "Content-Type")
        addValue("application/json",
                 forHTTPHeaderField: "Accept")
    }
}
