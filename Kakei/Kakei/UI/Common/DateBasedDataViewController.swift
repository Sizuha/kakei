//
//  DateBasedDataViewController.swift
//  Kakei
//
//  Created by IL KYOUNG HWANG on 2019/08/22.
//  Copyright © 2019 Sizuha. All rights reserved.
//

import UIKit
import SizUtil


class DateBasedDataViewController: UIViewController {
	
	var currentDate: SizYearMonthDay!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = Colors.default.WIN_BG
		
		initNavigationBar()
		onInit()
		
		moveToToday()
	}
	
	func initNavigationBar() {
		let btnPrev = UIBarButtonItem(title: Strings.default.prevMonth, style: .plain, target: self, action: #selector(moveToPrevMonth))
		let btnNext = UIBarButtonItem(title: Strings.default.nextMonth, style: .plain, target: self, action: #selector(moveToNextMonth))
		let btnToday = UIBarButtonItem(title: Strings.default.currMonth, style: .plain, target: self, action: #selector(moveToToday))
		let btnAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewItem))
		
		let naviItem = navigationItem
		naviItem.leftItemsSupplementBackButton = false
		naviItem.leftBarButtonItems = [btnToday, btnPrev]
		naviItem.rightBarButtonItems = [btnAdd, btnNext]
	}
	
	func onInit() {}
	
	func refreshCurrent() {
		guard let date = self.currentDate.toDate() else {
			return
		}
		
		navigationItem.title = toYearMonthText(date: date)
	}
	
	@objc func moveToToday() {
		let now = SizYearMonthDay.now
		moveTo(now)
	}
	
	func moveTo(_ yearMonth: SizYearMonthDay) {
		self.currentDate = yearMonth
		refreshCurrent()
	}
	
	@objc func moveToPrevMonth() {
		self.currentDate = currentDate.add(month: -1)
		refreshCurrent()
	}
	@objc func moveToNextMonth() {
		self.currentDate = currentDate.add(month: 1)
		refreshCurrent()
	}
	
	@objc func addNewItem() {}
}
