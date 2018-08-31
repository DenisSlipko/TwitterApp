//
//  ApiError.swift
//  Twitter application
//
//  Created by Denis on 28.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import Foundation

struct ApiError: LocalizedError, Decodable {
    let errors: [ResponseError]
    
    var errorDescription: String? {
        return errors
            .map { $0.message }
            .joined(separator: ", ")
    }
}

struct ResponseError: Decodable {
    let code: Int
    let message: String    
}
