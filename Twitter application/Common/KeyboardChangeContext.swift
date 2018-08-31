//
//  KeyboardChangeContext.swift
//  Twitter application
//
//  Created by Denis on 28.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import UIKit

struct KeyboardChangeContext {
    private let base: [AnyHashable: Any]
    
    var beginFrame: CGRect {
        return base[UIKeyboardFrameBeginUserInfoKey] as! CGRect
    }
    
    var endFrame: CGRect {
        return base[UIKeyboardFrameEndUserInfoKey] as! CGRect
    }

    var animationCurve: UIViewAnimationCurve {
        let value = base[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
        return UIViewAnimationCurve(rawValue: value.intValue)!
    }

    var animationDuration: Double {
        return base[UIKeyboardAnimationDurationUserInfoKey] as! Double
    }

    @available(iOS 9.0, *)
    var isLocal: Bool {
        return base[UIKeyboardIsLocalUserInfoKey] as! Bool
    }
    
    init(_ userInfo: [AnyHashable: Any]) {
        base = userInfo
    }
}
