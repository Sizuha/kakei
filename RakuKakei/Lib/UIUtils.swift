//
//  UIUtils.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2021/12/23.
//  Copyright © 2021 Sizuha. All rights reserved.
//

import Foundation
import UIKit
import SizUI

extension UIViewController {
    
    func showError(title: String? = nil, message: String, focusTo: UIView? = nil) {
        SizUI.Alert(title: title, message: message, buttons: [
            .default("OK", action: {
                focusTo?.becomeFirstResponder()
            })
        ]).show(from: self)
    }
    
}
