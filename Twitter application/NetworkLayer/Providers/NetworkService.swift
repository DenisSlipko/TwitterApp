//
//  NetworkService.swift
//  Twitter application
//
//  Created by Denis on 27.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import Foundation

final class NetworkService: NetworkProvider {
    
    // MARK: - Public
    
    let baseURL: URL
    let decodingContext: Any?
    
    init(baseURL: URL, decodingContext: Any? = nil) {
        self.baseURL = baseURL
        self.decodingContext = decodingContext
    }
    
    func requestData(_ request: DataRequestConvertible,
                     completion: @escaping Completion<Data>) -> Cancellable? {
        let cKeys = (key: Constants.Value.consumerKey, secret: Constants.Value.consumerSecret)
        let uKeys = (key: Constants.Value.oauthToken, secret: Constants.Value.tokenSecret)
        let requestURL = baseURL.appendingPathComponent(request.path)
        var urlRequest = URLRequest(url: requestURL)
        let parameters = request.parameters.mapValues { "\($0)" }
        urlRequest.oAuthSign(method: request.method.rawValue, urlFormParameters: parameters, consumerCredentials: cKeys, userCredentials: uKeys)
        let task = URLSession(configuration: .ephemeral).dataTask(with: urlRequest) { (data, response, error) in
            self.handleTaskResponse(data: data, error: error, completion: completion)
        }
        task.resume()
        let cancellable = BlockCancellable()
        cancellable.onCancelled { task.cancel() }
        return cancellable
    }
}

// MARK: - Private
private extension NetworkService {    
    func decodeError(with data: Data) throws {
        let apiError = try? JSONDecoder().decode(ApiError.self, from: data)
        if let apiError = apiError {
            throw apiError
        }
    }
    
    func handleTaskResponse(data: Data?, error: Error?, completion: @escaping Completion<Data>) {
        if let error = error {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        } else if let data = data {
            do {
                try self.decodeError(with: data)
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }
    }
}
