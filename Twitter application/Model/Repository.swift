//
//  Repository.swift
//  Twitter application
//
//  Created by Denis on 27.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import Foundation
import CoreData

protocol AbstractRepository {
    associatedtype Entity
    
    typealias Completion = (Result<[Entity]>) -> Void
    
    func query(predicate: NSPredicate?, completion: @escaping Completion)
    func save() throws
    func delete(predicate: NSPredicate?) throws
}

final class CoreDataRepository<T: NSManagedObject>: AbstractRepository {
    typealias Entity = T
    
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func query(predicate: NSPredicate?, completion: @escaping Completion) {
        let fetchRequest = NSFetchRequest<T>(entityName: "\(T.self)")
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        do {
        	let result = try context.fetch(fetchRequest)
            completion(.success(result))
        } catch {
            completion(.failure(error))
        }
    }
    
    func save() throws {
        try context.save()
    }
    
    func delete(predicate: NSPredicate?) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(T.self)")
        fetchRequest.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
    }
}

extension AbstractRepository {
    func queryFirst(predicate: NSPredicate? = nil,
                    completion: @escaping (Result<Entity?>) -> Void) {
        query(predicate: predicate) { result in
            let newResult = result.map { $0.first }
            completion(newResult)
        }
    }
    
    func query(predicate: NSPredicate? = nil, completion: @escaping Completion) {
        self.query(predicate: predicate, completion: completion)
    }
}
