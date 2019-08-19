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
	private var sections = [SizPropertyTableSection]()
	
	private var tableView: SizPropertyTableView!
	
	override func viewDidLoad() {
		self.title = self.item == nil ? Strings.default.add : Strings.default.edit
		
		initNavigationBar()
		
		let rowBudget = SizPropertyTableRow(type: .select, label: Strings.default.budget)
			.bindData {
				return self.item?.budgetIdx
			}
			.onChanged{ value in
				if let v = value as? Int {
					self.item?.budgetIdx = v
				}
		}
		rowBudget.selection(items: [])
		let rowCost = SizPropertyTableRow(type: .text, label: Strings.default.cost)
		let rowDate = SizPropertyTableRow(type: .date, label: Strings.default.date)
		let rowTime = SizPropertyTableRow(type: .time, label: Strings.default.time)
		
		self.sections = [
			SizPropertyTableSection(rows: [rowBudget,rowCost,rowDate,rowTime])
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
		guard let _ = self.navigationBar else { return }
		
		initNavigationBarStyle(self.navigationBar)
		
		let btnSave = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(trySave))
		
		let naviItem = navigationItem
		naviItem.leftItemsSupplementBackButton = true
		naviItem.rightBarButtonItems = [btnSave]
	}
	
	@objc func trySave() {
		
	}
	
}
