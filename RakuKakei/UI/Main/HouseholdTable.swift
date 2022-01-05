//
//  HouseholdTable.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2021/12/30.
//  Copyright © 2021 Sizuha. All rights reserved.
//

import UIKit

class HouseholdTable: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var items: [[Household]] = []
    
    func setDataSource(items: [Household]) {
        self.items.removeAll()
        self.items = [[Household]](repeating: [Household](), count: 31)
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func getSection(_ index: Int) -> [Household] {
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
        let section = getSection(section)
        guard let day = section.first?.date.day else {
            assert(false)
            return nil
        }
        
        return "\(day)日"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        getSection(section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
    
}
