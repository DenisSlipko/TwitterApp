//
//  Cancellable.swift
//  Twitter application
//
//  Created by Denis on 27.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import Foundation

protocol Cancellable {
    func cancel()
}

class SimpleCancellable: Cancellable {
    private(set) var isCancelled: Bool = false
    
    func cancel() {
        isCancelled = true
    }
}

final class BlockCancellable: SimpleCancellable {
    
    typealias Action = () -> Void
    
    private var onCancelledAction: Action?
    
    override func cancel() {
        super.cancel()
        onCancelledAction?()
    }
    
    func onCancelled(_ action: @escaping Action) {
        onCancelledAction = action
    }
}
