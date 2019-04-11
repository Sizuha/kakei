//
//  KakeiConfig.swift
//  Kakei
//
//  Created by IL KYOUNG HWANG on 2019/04/10.
//  Copyright © 2019 Sizuha. All rights reserved.
//

import Foundation

class KakeiConfig {
	
	static let shared = KakeiConfig()
	
	var beginDayOfMonth: Int {
		get {
			let day = UserDefaults.standard.integer(forKey: "begin_day_of_month")
			guard (1...31).contains(day) else { return 1 }
			return day
		}
		set {
			guard (1...31).contains(newValue) else {
				fatalError("out of range (1 ~ 31)")
			}
			UserDefaults.standard.set(newValue, forKey: "begin_day_of_month")
		}
	}

	init() {
	}
	
}
