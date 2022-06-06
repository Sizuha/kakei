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
    
    var indicator: UIActivityIndicatorView? = nil
    var fadeView: UIView? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getKeyWindow() -> UIWindow? {
        UIApplication.shared.getKeyWindow()
    }

    func addFadeView() {
        guard self.fadeView == nil else { return }
        
        if let window = getKeyWindow() {
            self.fadeView = UIView(frame: window.frame)
            window.addSubview(self.fadeView!)
        }
        else {
            self.fadeView = UIView(frame: self.view.frame)
            self.view.addSubview(self.fadeView!)
        }
        self.fadeView!.backgroundColor = .black
        self.fadeView!.isHidden = true
        
        let onFadeViewTap = UITapGestureRecognizer(target: self, action: #selector(self.onFadeViewTap))
        self.fadeView?.addGestureRecognizer(onFadeViewTap)
    }
    
    @objc func onFadeViewTap() {}
    
    private func addIndicator() {
        guard self.indicator == nil else { return }
        
        self.indicator = UIActivityIndicatorView()
        self.indicator!.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.indicator!.center = view.center
        self.indicator!.style = UIActivityIndicatorView.Style.large
        self.indicator!.hidesWhenStopped = true
        
        if let window = getKeyWindow() {
            window.addSubview(self.indicator!)
        }
        else {
            view.addSubview(self.indicator!)
        }
    }
    
    func startNowLoading() {
        self.addIndicator()
        self.indicator?.startAnimating()
    }
    
    func stopNowLoading() {
        self.indicator?.stopAnimating()
    }
    
    func fadeOut(
        start: CGFloat = 0.0,
        end: CGFloat = 0.5,
        duration: TimeInterval = 0.3,
        completion: ((Bool)->Void)? = nil)
    {
        if self.fadeView == nil { addFadeView() }
        if let fadeView = self.fadeView {
            fadeView.alpha = start
            fadeView.isHidden = false
            UIView.animate(
                withDuration: duration,
                delay: 0,
                animations: { fadeView.alpha = end },
                completion: completion
            )
        }
    }
    
    func fadeIn(completion: ((Bool)->Void)? = nil) {
        guard let fadeView = self.fadeView else { return }
        
        UIView.animate(withDuration: 0.15, delay: 0, animations: { fadeView.alpha = 0.0 }) { finished in
            if finished {
                fadeView.isHidden = true
            }
            
            completion?(finished)
        }
    }
    
}
