//
//  Resources.swift
//  Kakei
//
//  Created by IL KYOUNG HWANG on 2019/04/11.
//  Copyright © 2019 Sizuha. All rights reserved.
//

import UIKit

class Strings {
	
	static let `default` = Strings()
	
	lazy var expenditure = "expenditure".localized()
	lazy var budget = "budget".localized()
	lazy var setting = "setting".localized()
	
}

class Icons {
	
	static let `default` = Icons()
	
	lazy var settings = UIImage(named: "ic_setting")
	lazy var budget = UIImage(named: "ic_budget")
	lazy var expenditure = UIImage(named: "ic_expend")
	
}
