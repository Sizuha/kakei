//
//  YearMonthPicker.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2021/12/22.
//  Copyright © 2021 Sizuha. All rights reserved.
//

import Foundation
import UIKit
import SizUI

class YearMonthPicker: SizPopupPickerView, UIPickerViewDataSource, SizPopupPickerViewDelegate {
    
    override init() {
        super.init()
        self.dataSource = self
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addTo(_ vc: UIViewController) {
        if let window = UIApplication.shared.getKeyWindow() {
            window.addSubview(self)
        }
        else {
            vc.view.addSubview(self)
        }
    }
    
    var onSelected: ((_ date: YearMonth)->Void)? = nil
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return MAX_YEAR - MIN_YEAR + 1 // 年
        case 1: return 12 // 月
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: // 年
            return "\(MIN_YEAR + row)年"
        case 1: // 月
            return "\(row + 1)月"
            
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelect rows: [Int]) {
        let year = MIN_YEAR + rows[0]
        let month = rows[1] + 1
        let toDate = YearMonth(year: year, month: month)
        self.onSelected?(toDate)
    }
}
