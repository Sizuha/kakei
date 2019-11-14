//
//  EditExpItemViewController.swift
//  Kakei
//
//  Created by IL KYOUNG HWANG on 2019/04/19.
//  Copyright © 2019 Sizuha. All rights reserved.
//

import UIKit
import SizUtil

class EditExpItemViewController: UIViewController {
	
	static func show(item: ExpenseRecord?, from viewController: UIViewController, completion: (()->Void)? = nil) {
		let editNaviController = UINavigationController()
		let editView = EditExpItemViewController()
		editView.item = item
		editNaviController.pushViewController(editView, animated: false)
		
		viewController.present(editNaviController, animated: true, completion: completion)
	}
	
	var item: ExpenseRecord? = nil
	var budgetItems: [Budget] = []
	private var sections = [SizPropertyTableSection]()
	
	private var tableView: SizPropertyTableView!
	
	override func viewDidLoad() {
		self.title = self.item == nil ? Strings.default.add : Strings.default.edit
		
		initNavigationBar()
		initNavigationItems()
		
		let now = SizYearMonthDay.now
		self.budgetItems = DataManager.shared.loadBudget(year: now.year, month: now.month)
		
		// 予算（カテゴリー）
		let rowBudget = SizPropertyTableRow(type: .select, label: Strings.default.budget)
			.selection(items: [])
			.hint("未定")
			.bindData {
				return self.item?.budgetIdx
			}
			.onChanged { value in
				if let v = value as? Int {
					self.item?.budgetIdx = v
				}
			}
		// 費用
		let rowCost = SizPropertyTableRow(type: .editText, label: Strings.default.cost)
			.bindData {
				guard let price = self.item?.price else { return "" }
				guard price > 0 else { return "" }
				return "\(price)"
			}
			.onCreate { cell, i in
				guard let cell = cell as? SizCellForEditText else { return }
				cell.textField.keyboardType = .numberPad
				cell.textField.becomeFirstResponder()
			}
		// 日付
		let rowDate = SizPropertyTableRow(type: .datetime, label: Strings.default.date)
			.bindData {
				return self.item?.date ?? Date()
			}
			.onCreate { cell, i in
				guard let cell = cell as? SizCellForEditText else { return }
				cell.valueViewWidth = cell.contentView.frame.width * 0.8
				
				guard let dateField = cell.textField as? SizDatePickerField else { return }
				dateField.pickerView.backgroundColor = .white
				dateField.pickerView.datePickerMode = .dateAndTime
				dateField.changeLocale(Locale.current, todayText: Strings.default.today)
			}

		self.sections = [
			SizPropertyTableSection(rows: [
				rowCost,
				rowBudget,
				rowDate,
			])
		]
		
		self.tableView = SizPropertyTableView(frame: .zero, style: .grouped)
		self.tableView.translatesAutoresizingMaskIntoConstraints = false
		self.tableView.setDataSource(self.sections)
		
		self.view.addSubview(self.tableView)
	}
	
	override func viewWillLayoutSubviews() {
		self.tableView.setMatchTo(parent: self.view)
	}
	
	private func initNavigationBar() {
		guard let naviBar = self.navigationController?.navigationBar else { return }
		initNavigationBarStyle(naviBar)
	}
	
	private func initNavigationItems() {
		let btnSave = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(trySave))
		
		let naviItem = navigationItem
		naviItem.leftItemsSupplementBackButton = true
		naviItem.rightBarButtonItems = [btnSave]
		
		if self.navigationController?.viewControllers.first == self {
			let backBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(returnBack))
			naviItem.leftBarButtonItems = [backBtn]
		}
	}
	
	@objc func trySave() {
		returnBack()
	}
	
	@objc func returnBack() {
		popSelf()
	}
	
}
