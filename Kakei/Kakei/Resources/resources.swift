//
//  Resources.swift
//  Kakei
//
//  Created by IL KYOUNG HWANG on 2019/04/11.
//  Copyright © 2019 Sizuha. All rights reserved.
//

import UIKit

public class Colors {
	static let `default` = Colors()
	
	let WIN_BG: UIColor = .white
	let ACTION: UIColor = .red
	let NAVI_ACTION: UIColor = .blue
	let NAVI_BG: UIColor = .blue
}

class Strings {
	static let `default` = Strings()
	
	lazy var expenditure = "expenditure".localized()
	lazy var budget = "budget".localized()
	lazy var setting = "setting".localized()

	lazy var fmtYearMonth = "fmt_year_month".localized()
}

class Icons {
	static let `default` = Icons()
	
	lazy var settings = UIImage(named: "ic_setting")
	lazy var budget = UIImage(named: "ic_budget")
	lazy var expenditure = UIImage(named: "ic_expend")
	
}
