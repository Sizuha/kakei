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
	
	private var expTableView: ExpTableView!
	private var emptyView: UIView!
	
	private var currentDate: SizYearMonthDay!
	
	override func viewDidLoad() {
		view.backgroundColor = Colors.default.WIN_BG
		
		initNavigationBar()
		initTableView()

		moveToToday()
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		setMatchToParent(parent: view, child: expTableView)
		
		emptyView.centerXAnchor.constraint(equalTo: expTableView.centerXAnchor).isActive = true
		emptyView.centerYAnchor.constraint(equalTo: expTableView.centerYAnchor).isActive = true
	}
	
	private func initNavigationBar() {
		//navigationController?.delegate = self
		
		let btnPrev = UIBarButtonItem(title: "先月", style: .plain, target: self, action: #selector(moveToPrevMonth))
		let btnNext = UIBarButtonItem(title: "次月", style: .plain, target: self, action: #selector(moveToNextMonth))
		let btnToday = UIBarButtonItem(title: "今月", style: .plain, target: self, action: #selector(moveToToday))
		let btnAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewItem))
		
		let naviItem = navigationItem
		naviItem.leftItemsSupplementBackButton = false
		naviItem.leftBarButtonItems = [btnToday, btnPrev]
		naviItem.rightBarButtonItems = [btnAdd, btnNext]
	}
	
	private func initTableView() {
		expTableView = ExpTableView(frame: CGRect(), style: .plain, owner: self)
		expTableView.tableFooterView = UIView()
		expTableView.translatesAutoresizingMaskIntoConstraints = false
		expTableView.allowsMultipleSelection = false
		view.addSubview(expTableView)
		
		emptyView = createEmptyView(text: "Empty")
		emptyView.center = expTableView.center
		view.addSubview(emptyView)
		
		expTableView.emptyView = emptyView
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
	
	@objc func addNewItem() {
		
	}

}
