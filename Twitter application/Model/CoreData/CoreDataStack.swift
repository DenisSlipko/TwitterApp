//
//  CoreDataStack.swift
//  Twitter application
//
//  Created by Denis on 27.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataStack {
    
    private let modelName: String
    
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle(for: CoreDataStack.self).url(forResource: modelName, withExtension: "momd") else {
            fatalError("Unable to locate DataModel")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to create ManagedObjectModel from \(modelURL)")
        }
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let storeURL = documentsDirectoryURL.appendingPathComponent(storeName)
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: storeURL,
                                               options: nil)
        } catch {
            fatalError("Unable to load PersistentStore")
        }
        return coordinator
    }()
    
    private var storeName: String {
        return "\(modelName).sqlite"
    }
    
    private var documentsDirectoryURL: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    init(modelName: String) {
        self.modelName = modelName
    }
}
