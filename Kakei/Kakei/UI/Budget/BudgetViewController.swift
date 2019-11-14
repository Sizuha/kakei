//
//  BudgetViewController.swift
//  Kakei
//
//  Created by IL KYOUNG HWANG on 2019/04/11.
//  Copyright © 2019 Sizuha. All rights reserved.
//

import UIKit
import SizUtil


class BudgetViewController: DateBasedDataViewController {
	
	private var budgetTableView: BudgetTableView!
	private var emptyView: UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func onInit() {
		super.onInit()
		initTableView()
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		self.budgetTableView.setMatchTo(parent: self.view)
		
		self.emptyView.centerXAnchor.constraint(equalTo: self.budgetTableView.centerXAnchor).isActive = true
		self.emptyView.centerYAnchor.constraint(equalTo: self.budgetTableView.centerYAnchor).isActive = true
	}
	
	private func initTableView() {
		let tableView = BudgetTableView(frame: CGRect(), style: .plain, owner: self)
		tableView.tableFooterView = UIView()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.allowsMultipleSelection = false
		view.addSubview(tableView)
		self.budgetTableView = tableView
		
		self.emptyView = createEmptyView(text: Strings.default.emptyItems)
		self.emptyView.center = self.budgetTableView.center
		view.addSubview(self.emptyView)
		
		self.budgetTableView.emptyView = self.emptyView
	}
	
	override func refreshCurrent() {
		super.refreshCurrent()
		// TODO
	}
	
	@objc override func addNewItem() {
		
	}
	
}
