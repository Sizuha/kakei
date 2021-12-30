//
//  YearMonth.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2020/08/08.
//  Copyright © 2020 Sizuha. All rights reserved.
//

import Foundation

struct YearMonth: Equatable {
    
    var year: Int
    var month: Int
    
    init() {
        year = 0
        month = 0
    }
    
    init(from yyyyMM: Int) {
        year = yyyyMM / 100
        month = yyyyMM - year*100
    }
    
    init(from yyyyMM: String) {
        let value = Int(yyyyMM) ?? 0
        self.init(from: value)
    }
    
    init(year: Int, month: Int) {
        self.init(from: year*100 + month)
    }

    init(from date: Date) {
        let cal = Calendar(identifier: .gregorian)
        year = cal.component(.year, from: date)
        month = cal.component(.month, from: date)
    }
    
    init(from other: YearMonth) {
        self.year = other.year
        self.month = other.month
    }
    
    func toInt() -> Int {
        year*100 + month
    }
    
    mutating func moveNextMonth() {
        self.month += 1
        if self.month > 12 {
            self.year += 1
            self.month = 1
        }
    }
    
    mutating func movePrevMonth() {
        self.month -= 1
        if self.month <= 0 {
            self.year -= 1
            self.month = 12
        }
    }
    
    func nextMonth() -> YearMonth {
        var result = YearMonth(from: self)
        result.moveNextMonth()
        return result
    }
    
    func prevMonth() -> YearMonth {
        var result = YearMonth(from: self)
        result.movePrevMonth()
        return result
    }

    
    static var now: YearMonth { YearMonth(from: Date()) }

    static func == (lhs: YearMonth, rhs: YearMonth) -> Bool {
        lhs.toInt() == rhs.toInt()
    }

}
