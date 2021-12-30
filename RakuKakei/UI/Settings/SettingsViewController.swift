//
//  SettingsViewController.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2020/08/09.
//  Copyright © 2020 Sizuha. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    static func presentSheet(from: UIViewController, onDismiss: (()->Void)? = nil) {
        let vc = SettingsViewController()
        vc.onDismiss = onDismiss
        
        let navi = UINavigationController()
        navi.pushViewController(vc, animated: false)
        
        from.present(navi, animated: true, completion: nil)
    }
    
    private var onDismiss: (()->Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onDismiss?()
    }

}
