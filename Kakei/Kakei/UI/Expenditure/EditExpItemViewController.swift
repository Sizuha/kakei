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
	
	static func show(item: ExpLog?, from viewController: UIViewController, completion: (()->Void)? = nil) {
		let editNaviController = UINavigationController()
		let editView = EditExpItemViewController()
		editView.item = item
		editNaviController.pushViewController(editView, animated: false)
		
		viewController.present(editNaviController, animated: true, completion: completion)
	}
	
	var item: ExpLog? = nil
	private var sections = [SizPropertyTableSection]()
	
	private var tableView: SizPropertyTableView!
	
	override func viewDidLoad() {
		title = item == nil ? Strings.default.add : Strings.default.edit
		
		initNavigationBar()
		
		tableView = SizPropertyTableView()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(tableView)
	}
	
	override func viewWillLayoutSubviews() {
		setMatchToParent(parent: view, child: tableView)
	}
	
	private func initNavigationBar() {
		guard let _ = navigationBar else { return }
		
		initNavigationBarStyle(navigationBar)
		
		let btnSave = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(trySave))
		
		let naviItem = navigationItem
		naviItem.leftItemsSupplementBackButton = true
		naviItem.rightBarButtonItems = [btnSave]
	}
	
	@objc func trySave() {
		
	}
	
}
