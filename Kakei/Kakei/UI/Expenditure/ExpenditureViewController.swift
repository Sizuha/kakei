//
//  ExpendViewController.swift
//  Kakei
//
//  Created by IL KYOUNG HWANG on 2019/04/11.
//  Copyright © 2019 Sizuha. All rights reserved.
//

import UIKit
import SizUtil

/**
 出費一覧の画面
 */
class ExpenditureViewController: UIViewController {
	
	private var navigationBar: UINavigationBar! {
		return navigationController?.navigationBar
	}
	private var expTableView: ExpTableView!
	
	private var currentDate: SizYearMonthDay!
	
	override func viewDidLoad() {
		view.backgroundColor = Colors.default.WIN_BG
		
		initStatusBar()
		initNavigationBar()
		initTableView()

		moveToToday()
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
	}
	
	private func initNavigationBar() {
		guard let _ = navigationBar else { return }
		
		//self.navigationController?.delegate = self
		initNavigationBarStyle(navigationBar)
		
		let btnPrev = UIBarButtonItem(title: "先月", style: .plain, target: self, action: #selector(moveToPrevMonth))
		let btnNext = UIBarButtonItem(title: "次月", style: .plain, target: self, action: #selector(moveToNextMonth))
		let btnToday = UIBarButtonItem(title: "今月", style: .plain, target: self, action: #selector(moveToToday))
		
		let naviItem = navigationItem
		naviItem.leftItemsSupplementBackButton = false
		naviItem.leftBarButtonItems = [btnPrev]
		naviItem.rightBarButtonItems = [btnNext, btnToday]
	}
	
	private func initTableView() {
		expTableView = ExpTableView(frame: CGRect(), style: .plain, owner: self)
	}
	
	func refreshCurrent() {
		guard let date = currentDate.toDate() else {
			return
		}
		
		navigationItem.title = toYearMonthText(date: date)
	}
	
	@objc func moveToToday() {
		let now = SizYearMonthDay.now
		moveTo(now)
	}
	
	func moveTo(_ yearMonth: SizYearMonthDay) {
		currentDate = yearMonth
		refreshCurrent()
	}
	
	@objc func moveToPrevMonth() {
		currentDate = currentDate.add(month: -1)
		refreshCurrent()
	}
	@objc func moveToNextMonth() {
		currentDate = currentDate.add(month: 1)
		refreshCurrent()
	}

}
