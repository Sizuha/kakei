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
    
    func refresh(item: Budget, showRemain: Bool = false) {
        lblLabel.text = item.shortLabel
        lblFullName.text = item.label
        
        let remain = item.amount - item.used
        let mutableAttributedString = NSMutableAttributedString()
        
        if showRemain {
            let attr1: [NSAttributedString.Key : Any] = [
                .foregroundColor : UIColor.label,
                .font : UIFont.systemFont(ofSize: 15)
            ]
            let str1 = NSAttributedString(string: "残り", attributes: attr1)

            let attr2: [NSAttributedString.Key : Any] = [
                .foregroundColor : remain >= 0 ? UIColor.label : UIColor.systemRed,
                .font : UIFont.boldSystemFont(ofSize: 20)
            ]
            let str2 = NSAttributedString(string: "\(remain)", attributes: attr2)
            mutableAttributedString.append(str1)
            mutableAttributedString.append(str2)

            //lblAmount.text = "残り\(remain)"
            //lblAmount.textColor = remain >= 0 ? .label : .systemRed
        }
        else {
            let attr1: [NSAttributedString.Key : Any] = [
                .foregroundColor : remain >= 0 ? UIColor.label : UIColor.systemRed,
                .font : UIFont.systemFont(ofSize: 15)
            ]
            let str1 = NSAttributedString(string: "\(remain)", attributes: attr1)

            let attr2: [NSAttributedString.Key : Any] = [
                .foregroundColor : UIColor.label,
                .font : UIFont.systemFont(ofSize: 15)
            ]
            let str2 = NSAttributedString(string: " / ", attributes: attr2)
            
            let attr3: [NSAttributedString.Key : Any] = [
                .foregroundColor : UIColor.label,
                .font : UIFont.boldSystemFont(ofSize: 20)
            ]
            let str3 = NSAttributedString(string: "\(item.amount)", attributes: attr3)

            
            mutableAttributedString.append(str1)
            mutableAttributedString.append(str2)
            mutableAttributedString.append(str3)
            
            //lblAmount.text = "\(item.amount)"
            //lblAmount.textColor = .label
        }
        
        lblAmount.attributedText = mutableAttributedString;
    }
    
}
