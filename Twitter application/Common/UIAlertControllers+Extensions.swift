//
//  UIAlertControllers+Extensions.swift
//  Twitter application
//
//  Created by Denis on 27.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func with(_ error: Error) -> UIAlertController {
        let alert = UIAlertController(title: "Oops!", message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: nil))
        return alert
    }
    
    static func photos(selection: ((UIImagePickerControllerSourceType) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: "Get Photo", message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: "From Gallery", style: .default, handler: { _ in
            selection?(.photoLibrary)
        }))
        alert.addAction(.init(title: "Using Camera", style: .default, handler: { _ in
            selection?(.camera)
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        return alert
    }
}
