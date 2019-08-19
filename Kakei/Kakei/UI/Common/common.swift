//
//  Common.swift
//  Kakei
//
//  Created by IL KYOUNG HWANG on 2019/04/08.
//  Copyright © 2019 Sizuha. All rights reserved.
//

import Foundation
import SizUtil

func createEmptyView(text: String) -> UILabel {
	let emptyView = UILabel()
	emptyView.text = text
	emptyView.textAlignment = .center
	emptyView.textColor = .placeholderGray
	emptyView.font = UIFont.systemFont(ofSize: 24.0)
	emptyView.isHidden = true
	//emptyView.backgroundColor = .blue
	emptyView.translatesAutoresizingMaskIntoConstraints = false
	
	return emptyView
}

extension UIViewController {
	
	var navigationBar: UINavigationBar! {
		return navigationController?.navigationBar
	}
		
	func initNavigationBarStyle(_ naviBar: UINavigationBar) {
		naviBar.barStyle = .default
		naviBar.isTranslucent = true
	}
	
}

func toYearMonthText(date: Date) -> String {
	let fmt = DateFormatter()
	fmt.calendar = Calendar.standard
	fmt.dateFormat = Strings.default.fmtYearMonth
	return fmt.string(from: date)
}
