//
//  BudgetTableViewCell.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2021/12/29.
//  Copyright © 2021 Sizuha. All rights reserved.
//

import UIKit

class BudgetTableViewCell: UITableViewCell {
    
    static let resId = "BudgetCell"
    
    @IBOutlet weak var lblLabel: UILabel!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    
    public class func register(to tableView: UITableView) {
        tableView.register(UINib(nibName: "BudgetTableViewCell", bundle: nil), forCellReuseIdentifier: Self.resId)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func refresh(item: Budget) {
        lblLabel.text = item.shortLabel
        lblFullName.text = item.label
        lblAmount.text = "\(item.amountSimple)千円"
    }
    
}
