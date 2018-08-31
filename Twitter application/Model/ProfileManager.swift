//
//  ProfileManager.swift
//  Twitter application
//
//  Created by Denis on 27.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import UIKit

final class ProfileManager {
    
    // MARK: - Types
    
    typealias GetProfileCompletion = (Result<UserProfile>) -> Void
    typealias UpdateProfileCompletion = (Result<UserProfile>) -> Void
    typealias Repository = CoreDataRepository<ManagedUserProfile>
    
    // MARK: - Dependencies
    
    let networkProvider: NetworkProvider
    let repository: CoreDataRepository<ManagedUserProfile>
    
    // MARK: - Lifecycle
    
    init(networkProvider: NetworkProvider, repository: Repository) {
        self.networkProvider = networkProvider
        self.repository = repository
    }
    
    // MARK: - API
    
    @discardableResult
    func getProfile(completion: @escaping GetProfileCompletion) -> Cancellable? {
        repository.queryFirst { result in
            switch result {
            case .success(let managedProfile):
                guard let managedProfile = managedProfile else { return }
                let profile = managedProfile.asUserProfile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        let request = ProfileAPI.getProfile
        return networkProvider.requestDecodable(request, completion: { (result: Result<ManagedUserProfile>) in
            if case .success(let profile) = result {
                try? self.repository.delete(predicate: self.predicate(profile))
            }
            try? self.repository.save()
            let newResult = result.map { $0.asUserProfile }
            completion(newResult)
        })
    }
    
    @discardableResult
    func update(profile: UserProfile, completion: @escaping UpdateProfileCompletion) -> Cancellable? {
        let managedProfile = ManagedUserProfile(userProfile: profile, context: repository.context)
        let request = ProfileAPI.update(profile: managedProfile)
        return networkProvider.requestDecodable(request, completion: { (result: Result<ManagedUserProfile>) in
            if case .success(let profile) = result {
                try? self.repository.delete(predicate: self.predicate(profile))
            }
            try? self.repository.save()
            let newResult = result.map { $0.asUserProfile }
            completion(newResult)
        })
    }
    
    @discardableResult
    func upload(image: UIImage, completion: @escaping GetProfileCompletion) -> Cancellable? {
        let request = ProfileAPI.upload(image: image)
        return networkProvider.requestDecodable(request, completion: { (result: Result<ManagedUserProfile>) in
            if case .success(let profile) = result {
                try? self.repository.delete(predicate: self.predicate(profile))
            }
            try? self.repository.save()
            let newResult = result.map { $0.asUserProfile }
            completion(newResult)
        })
    }
    
    private func predicate(_ exceptProfile: ManagedUserProfile) -> NSPredicate {
        let keyPath = #keyPath(ManagedUserProfile.id)
        return NSPredicate(format: "\(keyPath) != \(exceptProfile.id)")
    }
}
