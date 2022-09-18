//
//  BaseViewController.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2022/06/07.
//  Copyright © 2022 Sizuha. All rights reserved.
//

import UIKit
import SizUI
import SizUtil

class BaseViewController: UIViewController {
    
    var indicator: UIActivityIndicatorView?
    var fadeView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func onFadeViewTap() {}
        
    private func addIndicator() {
        if self.indicator == nil {
            self.indicator = UIActivityIndicatorView()
            self.indicator!.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            self.indicator!.center = view.center
            self.indicator!.style = UIActivityIndicatorView.Style.large
            self.indicator!.hidesWhenStopped = true
        }
        
        self.indicator?.removeFromSuperview()
        getKeyWindow()?.addSubview(self.indicator!)
    }
    
    func startNowLoading() {
        self.addIndicator()
        self.indicator?.bringToFront()
        self.indicator?.startAnimating()
    }
    
    func stopNowLoading() {
        self.indicator?.stopAnimating()
        self.indicator?.removeFromSuperview()
    }

}
