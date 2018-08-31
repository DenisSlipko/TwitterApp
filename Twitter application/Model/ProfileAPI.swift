//
//  ProfileAPI.swift
//  Twitter application
//
//  Created by Denis on 27.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import UIKit

enum ProfileAPI: DataRequestConvertible {
    case getProfile
    case update(profile: ManagedUserProfile)
    case upload(image: UIImage)
    
    var path: String {
        switch self {
        case .getProfile:
            return "account/verify_credentials.json"
        case .update:
            return "account/update_profile.json"
        case .upload:
            return "account/update_profile_image.json"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getProfile:
            return .get
        case .update:
            return .post
        case .upload:
            return .post
        }
    }
    
    var parameters: Parameters {
        switch self {
        case .getProfile:
            return [:]
        case .update(let profile):
            guard let data = try? JSONEncoder().encode(profile) else { return [:] }
            let parametersObject = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            let parameters = parametersObject as? [String: Any] ?? [:]
            return parameters
        case .upload(let image):
            let resizedImage = image.resized(toWidth: 300)!
            let data = UIImagePNGRepresentation(resizedImage)!
            let imageBase64String = data
                .base64EncodedString()
            return [
                "include_entities": true,
                "image": imageBase64String
            ]
        }
    }
}
