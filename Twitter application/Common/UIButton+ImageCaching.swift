//
//  UIButton+ImageCaching.swift
//  Twitter application
//
//  Created by Denis on 27.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func setImage(withURL url: URL, placeholder: UIImage? = nil, cache: URLCache? = nil) {
        let cache = cache ?? URLCache.shared
        let request = URLRequest(url: url)
        if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
            setBackgroundImage(image, for: .normal)
        } else {
            setBackgroundImage(placeholder, for: .normal)
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                print()
                if
                    let data = data,
                    let response = response,
                    let image = UIImage(data: data) {
                    
                    DispatchQueue.main.async {
                        let cachedData = CachedURLResponse(response: response, data: data)
                        cache.storeCachedResponse(cachedData, for: request)
                        self.setBackgroundImage(image, for: .normal)
                    }
                }
            }).resume()
        }
    }
}
