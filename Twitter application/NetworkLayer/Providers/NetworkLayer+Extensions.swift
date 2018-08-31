//
//  NetworkLayer+Extensions.swift
//  Twitter application
//
//  Created by Denis on 27.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import Foundation

extension NetworkProvider {
    @discardableResult
    func requestDecodable<T>(_ request: DataRequestConvertible,
                             completion: @escaping Completion<T>)
        -> Cancellable? where T: Decodable {
            return requestData(request, completion: { (result) in
                do {
                    let decodedResult = try result.map { (data) -> T in
                        let decoder = JSONDecoder()
                        decoder.userInfo[.context] = self.decodingContext
                        return try decoder.decode(T.self, from: data)
                    }
                    completion(decodedResult)
                } catch {
                    completion(.failure(error))
                }
            })
    }
}
