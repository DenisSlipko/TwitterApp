//
//  PhotosProvider.swift
//  Twitter application
//
//  Created by Denis on 28.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import Foundation
import UIKit

final class PhotosProvider: NSObject {
    
    typealias Completion = (UIImage?) -> Void
    
    private var completion: Completion?
    
    private weak var viewController: UIViewController?
    
    private var picker: UIImagePickerController?
    
    init(presentPhotosFrom viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func getPhoto(sourceType: UIImagePickerControllerSourceType, completion: @escaping Completion) {
        let picker = UIImagePickerController()
        self.picker = picker
        if sourceType == .camera, !UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .photoLibrary
        } else {
            picker.sourceType = sourceType
        }
        picker.isEditing = false
        self.completion = completion
        picker.delegate = self
        viewController?.present(picker, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension PhotosProvider: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            completion?(nil)
            return
        }
        completion?(originalImage)
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        completion?(nil)
        picker.dismiss(animated: true, completion: nil)
    }
}
