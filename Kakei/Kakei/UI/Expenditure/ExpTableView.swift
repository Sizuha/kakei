//
//  ExpTableView.swift
//  Kakei
//
//  Created by IL KYOUNG HWANG on 2019/04/12.
//  Copyright © 2019 Sizuha. All rights reserved.
//

import UIKit
import SizUtil

class ExpTableView: SizSectionTableView<ExpenseRecord> {


	override init(frame: CGRect, style: UITableView.Style, owner: UIViewController) {
		super.init(frame: frame, style: style, owner: owner)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		register(nibName: "ExpCell", cellResId: "exp_cell")
	}
	
	override func height(rowAt: IndexPath) -> CGFloat {
		return 0
	}
	
	override func getCell(rowAt: IndexPath) -> UITableViewCell {
		guard let cell = dequeueReusableCell(withIdentifier: "exp_cell") else { return UITableViewCell() }
		if let cell = cell as? ExpCell {
			let item = getItem(rowAt)
			cell.update(item: item)
		}
		return cell
	}
	
	override func willDisplay(cell: UITableViewCell, rowAt: IndexPath) {
		(cell as? ExpCell)?.refreshViews()
	}
	
	override func didSelect(rowAt: IndexPath) {
		let item = getItem(rowAt)
		EditExpItemViewController.show(item: item, from: self.parentViewController)
	}
	
}

