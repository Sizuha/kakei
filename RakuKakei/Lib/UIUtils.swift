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

func getWeekdayColor(_ weekday: Int, defaultColor: UIColor = .defaultText) -> UIColor {
    weekday == 1
        ? .systemRed
        : weekday == 7
            ? .systemBlue
            : defaultColor
}

func blur(
    view: UIView,
    style: UIBlurEffect.Style = .regular,
    alpha: CGFloat = 1,
    completion: ((Bool)->Void)? = nil
) -> UIVisualEffectView {
    let blurEffect = UIBlurEffect(style: style)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.frame = view.frame
    
    view.addSubview(blurEffectView)
    
    blurEffectView.alpha = 0
    blurEffectView.isHidden = false
    
    UIView.animate(withDuration: 0.2, animations: {
        blurEffectView.alpha = alpha
    }, completion: completion)
    
    return blurEffectView
}
