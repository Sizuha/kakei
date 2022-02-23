//
//  SelectBudgetViewController.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2022/02/24.
//  Copyright © 2022 Sizuha. All rights reserved.
//

import UIKit

class SelectBudgetViewController: UIViewController {

    static func push(
        to: UINavigationController,
        date: YearMonth,
        preSelected: Int = -1,
        onSelected: @escaping (_ budget: Budget)->Void
    ) {
        let vc = SelectBudgetViewController()
        vc.date = date
        vc.preSelected = preSelected
        vc.onSelected = onSelected
        
        to.pushViewController(vc, animated: true)
    }
    
    var date: YearMonth!
    var preSelected: Int = -1
    var onSelected: ((_ budget: Budget)->Void)?
    var tableView: BudgetTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "予算"
        
        let items = DataManager.shared.loadBudgetList(yearMonth: date)
        
        self.tableView = BudgetTableView(frame: .zero, style: .plain)
        self.tableView.items = items
        self.tableView.editalbe = false
        self.tableView.selectedRow = items.firstIndex { $0.seq == self.preSelected } ?? -1
        self.tableView.onItemSelected = { item in
            self.onSelected?(item)
            self.popSelf()
        }

        self.view.addSubview(self.tableView)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.setMatchTo(parent: self.view)
    }

}
