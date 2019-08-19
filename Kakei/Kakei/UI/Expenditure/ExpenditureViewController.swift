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
		super.viewDidLoad()
		view.backgroundColor = Colors.default.WIN_BG
		
		initNavigationBar()
		initTableView()

		moveToToday()
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		self.expTableView.setMatchTo(parent: self.view)
		
		self.emptyView.centerXAnchor.constraint(equalTo: self.expTableView.centerXAnchor).isActive = true
		self.emptyView.centerYAnchor.constraint(equalTo: self.expTableView.centerYAnchor).isActive = true
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
		self.expTableView = ExpTableView(frame: CGRect(), style: .plain, owner: self)
		self.expTableView.tableFooterView = UIView()
		self.expTableView.translatesAutoresizingMaskIntoConstraints = false
		self.expTableView.allowsMultipleSelection = false
		view.addSubview(self.expTableView)
		
		self.emptyView = createEmptyView(text: "Empty")
		self.emptyView.center = self.expTableView.center
		view.addSubview(self.emptyView)
		
		self.expTableView.emptyView = self.emptyView
	}
	
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
	
	@objc func addNewItem() {
		EditExpItemViewController.show(item: nil, from: self)
	}

}
