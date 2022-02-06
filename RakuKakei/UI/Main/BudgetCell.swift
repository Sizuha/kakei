//
//  BudgetCell.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2022/01/05.
//  Copyright © 2022 Sizuha. All rights reserved.
//

import UIKit

class BudgetCell: UICollectionViewCell {
    
    static let resId = "budget_cell"
    
    static func register(to: UICollectionView) {
        to.register(UINib(nibName: "BudgetCell", bundle: nil), forCellWithReuseIdentifier: resId)
    }
    
    @IBOutlet weak var lblLabel: UILabel!
    @IBOutlet weak var lblAmount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func refresh(budget: Budget) {
        self.lblLabel.text = budget.shortLabel
        
        let remains: Int = budget.remains/AMOUNT_MULTIPLIER
        self.lblAmount.text = "\(remains)"
        self.lblAmount.textColor = remains < 0 ? .systemRed : .label
    }

}
