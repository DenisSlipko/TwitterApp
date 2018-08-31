//
//  ManagedUserProfile+CoreDataClass.swift
//  Twitter application
//
//  Created by Denis on 27.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedUserProfile)
final class ManagedUserProfile: NSManagedObject, Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case location
        case bio = "description"
        case url
        case expandedURL = "expanded_url"
        case imageURL = "profile_image_url"
        case entities
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard
            let context = decoder
                .userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext,
            let entity = NSEntityDescription
                .entity(forEntityName: "\(ManagedUserProfile.self)", in: context) else {
                    fatalError()
        }
        self.init(entity: entity, insertInto: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        location = try container.decode(String.self, forKey: .location)
        bio = try container.decode(String.self, forKey: .bio)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        
        let url = try? container.decode(Entities.self, forKey: .entities)
        self.url = url?.url.innerURL.first?.expandedURL
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(bio, forKey: .bio)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
    }
    
    convenience init(userProfile: UserProfile, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "\(ManagedUserProfile.self)", in: context)!
        self.init(entity: entity, insertInto: context)
        name = userProfile.name
        location = userProfile.location
        bio = userProfile.bio
        url = userProfile.url
        imageURL = userProfile.imageURL
    }
    
    var asUserProfile: UserProfile {
        return UserProfile(
            name: name ?? "",
            location: location ?? "",
            bio: bio ?? "",
            url: url ?? "",
            imageURL: imageURL)
    }
    
    struct Entities: Decodable {
        struct URL: Decodable {
            let innerURL: [InnerURL]
            enum CodingKeys: String, CodingKey {
                case innerURL = "urls"
            }
            struct InnerURL: Decodable {
                let expandedURL: String
                enum CodingKeys: String, CodingKey {
                    case expandedURL = "expanded_url"
                }
            }
        }
        let url: URL
    }
}

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")!
}
