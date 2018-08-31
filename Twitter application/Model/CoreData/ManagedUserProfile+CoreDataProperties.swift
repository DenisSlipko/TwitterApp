//
//  ManagedUserProfile+CoreDataProperties.swift
//  Twitter application
//
//  Created by Denis  on 8/30/18.
//  Copyright © 2018 Denis. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedUserProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedUserProfile> {
        return NSFetchRequest<ManagedUserProfile>(entityName: "ManagedUserProfile")
    }

    @NSManaged public var bio: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var location: String?
    @NSManaged public var name: String?
    @NSManaged public var url: String?
    @NSManaged public var id: Int64

}
