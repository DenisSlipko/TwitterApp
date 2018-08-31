//
//  AuthMananger.swift
//  Twitter application
//
//  Created by Denis  on 8/30/18.
//  Copyright © 2018 Denis. All rights reserved.
//

import Foundation
import TwitterKit

final class AuthManager {
    
    typealias Completion = (Result<Void>) -> Void
    
    func logIn(completion: @escaping Completion) {
        if Session.fetch() != nil {
            completion(.success(()))
            return
        }

        TWTRTwitter.sharedInstance().logIn { session, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            } else if let session = session {
                let user = User(id: session.userID, name: session.userName)
                let token = AccessToken(token: session.authToken,
                                        tokenSecret: session.authTokenSecret)
                let session = Session(user: user, accessToken: token)
                do {
                    try session.save()
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
