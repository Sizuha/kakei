//
//  HouseholdTableCell.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2021/12/30.
//  Copyright © 2021 Sizuha. All rights reserved.
//

import UIKit

class HouseholdTableCell: UITableViewCell {

    static let resId = "HouseholdCell"

    static func register(to: UITableView) {
        to.register(UINib(nibName: "HouseholdTableCell", bundle: nil), forCellReuseIdentifier: resId)
    }
    
    /// 予算名
    @IBOutlet weak var lblBudget: UILabel!
    /// メモ
    @IBOutlet weak var lblMemo: UILabel!
    /// 金額
    @IBOutlet weak var lblAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func refresh(item: Household) {
        let budget = DataManager.shared.getBudget(by: item)
        
        self.lblBudget.text = budget?.shortLabel ?? "予算外"
        self.lblBudget.textColor = budget == nil ? .systemRed : .label
        
        self.lblMemo.text = item.memo
        self.lblAmount.text = "\(item.priceForDisplay)"
    }
    
}
