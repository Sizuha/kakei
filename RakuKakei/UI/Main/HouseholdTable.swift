//
//  HouseholdTable.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2021/12/30.
//  Copyright © 2021 Sizuha. All rights reserved.
//

import UIKit
import SizUtil

class HouseholdTable: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var ownerViewController: UIViewController!
    var items: [[Household]] = []
    
    func setDataSource(items: [Household]) {
        self.items.removeAll()
        self.items = [[Household]](repeating: [Household](), count: 31)
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        HouseholdTableCell.register(to: self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func getHouseholds(bySection index: Int) -> [Household] {
        var i = 0
        for section in self.items {
            guard section.isEmpty == false else { continue }
            if i == index {
                return section
            }
            i += 1
        }
        return []
    }
    
    override var numberOfSections: Int {
        var cnt = 0
        for d in items {
            if d.count > 0 { cnt += 1 }
        }
        return cnt
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let households = getHouseholds(bySection: section)
        guard let day = households.first?.date.day else {
            assert(false)
            return nil
        }
        
        return "\(day)日"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        getHouseholds(bySection: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        dequeueReusableCell(withIdentifier: HouseholdTableCell.resId, for: indexPath) as! HouseholdTableCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? HouseholdTableCell else { return }
        
        let households = getHouseholds(bySection: indexPath.section)
        guard
            households.isEmpty == false,
            let item = households[at: indexPath.row]
        else { return }
        
        cell.refresh(item: item)
    }
    
}
