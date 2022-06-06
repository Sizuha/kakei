//
//  ManualViewController.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2022/03/05.
//  Copyright © 2022 Sizuha. All rights reserved.
//

import UIKit
import WebKit

class ManualViewController: UIViewController {
    
    var webView: WKWebView!
    
    static func push(to navi: UINavigationController) {
        let vc = ManualViewController()
        navi.pushViewController(vc, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.HOW_TO_USE
        
        guard
            let pdfURL = Bundle.main.url(forResource: "README", withExtension: "pdf", subdirectory: nil, localization: nil),
            let pdfData = try? Data(contentsOf: pdfURL)
        else {
            assert(false)
            return
        }
        
        self.webView = WKWebView(
            frame: CGRect(x:20,y:20,width:view.frame.size.width-40, height:view.frame.size.height-40)
        )
        self.webView.load(pdfData, mimeType: "application/pdf", characterEncodingName:"", baseURL:pdfURL.deletingLastPathComponent())
        view.addSubview(self.webView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.webView.setMatchTo(parent: self.view)
    }

}
