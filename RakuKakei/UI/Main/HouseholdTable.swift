//
//  HouseholdTable.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2021/12/30.
//  Copyright © 2021 Sizuha. All rights reserved.
//

import UIKit

class HouseholdTable: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
    
}
