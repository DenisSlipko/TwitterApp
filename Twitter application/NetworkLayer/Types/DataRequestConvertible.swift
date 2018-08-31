//
//  DataRequestConvertible.swift
//  Twitter application
//
//  Created by Denis on 27.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import Foundation

protocol DataRequestConvertible: RequestConvertible {
    var parameters: Parameters { get }
}

extension DataRequestConvertible {
    var parameters: Parameters {
        return [:]
    }
    
    func asURLRequest(baseURL: URL) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        switch method {
        case .get, .delete:
            var urlComponents = URLComponents.init(string: url.absoluteString)!
            urlComponents.queryItems = parameters.map {
                let stringValue = "\($0.value)"
                return URLQueryItem(name: $0.key, value: stringValue)
            }
            urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?
                .replacingOccurrences(of: "+", with: "%2B")
            return URLRequest(url: urlComponents.url!)
        case .post:
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.addPostRequestHeaders()
            request.httpBody = try JSONSerialization.data(
                withJSONObject: parameters,
                options: [])
            return request
        }
    }
}
