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
class ExpenditureViewController: DateBasedDataViewController {
	
	private var expTableView: ExpTableView!
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
		
		self.expTableView.setMatchTo(parent: self.view)
		
		self.emptyView.centerXAnchor.constraint(equalTo: self.expTableView.centerXAnchor).isActive = true
		self.emptyView.centerYAnchor.constraint(equalTo: self.expTableView.centerYAnchor).isActive = true
	}
	
	private func initTableView() {
		self.expTableView = ExpTableView(frame: CGRect(), style: .plain, owner: self)
		self.expTableView.tableFooterView = UIView()
		self.expTableView.translatesAutoresizingMaskIntoConstraints = false
		self.expTableView.allowsMultipleSelection = false
		view.addSubview(self.expTableView)
		
		self.emptyView = createEmptyView(text: Strings.default.emptyItems)
		self.emptyView.center = self.expTableView.center
		view.addSubview(self.emptyView)
		
		self.expTableView.emptyView = self.emptyView
	}
	
	override func refreshCurrent() {
		super.refreshCurrent()
		// TODO
	}
	
	@objc override func addNewItem() {
		EditExpItemViewController.show(item: nil, from: self)
	}

}
