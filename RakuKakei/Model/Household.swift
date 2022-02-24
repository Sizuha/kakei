//
//  Household.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2020/08/08.
//  Copyright © 2020 Sizuha. All rights reserved.
//

import Foundation
import SQuery
import SizUtil

/// 家計クラス
class Household: SQueryRowEx {
    static var tableScheme = TableScheme(name: "household", columns: [
        .def(F.DATE, type: .integer, [.primaryKey()]),
        .def(F.SEQ, type: .integer, [.primaryKey()]),
        .def(F.TIME, type: .integer, []),
        .def(F.BUDGET, type: .integer, [.notNull]),
        .def(F.PRICE, type: .integer, [.notNull, .default(.integer(0))]),
        .def(F.MEMO, type: .text, []),
    ])
    
    struct F {
        /// 日付（PK）
        static let DATE = "date"
        /// 連番（PK）
        static let SEQ = "seq"
        /// 時間
        static let TIME = "time"
        /// 使用した予算
        static let BUDGET = "budget_seq"
        /// 金額（単位：円）
        static let PRICE = "price"
        /// メモ
        static let MEMO = "memo"
    }
    
    /// 日付：年月日
    var date: SizYearMonthDay! = nil
    
    /// 連番：0からスタート
    var seq: Int = 0
    
    /// 今は使わない
    var time: SizHourMinSec? = nil
    
    /// 予算ID
    var budget_seq: Int = -1
    
    /// 金額
    var price: Int = 0
    var priceForDisplay: Int {
        price / AMOUNT_MULTIPLIER
    }
    
    /// メモ
    var memo = ""
    
    func load(from cursor: SQLiteCursor) {
        cursor.forEachColumn { c, i in
            let colName = c.getColumnName(i)
            switch colName {
            case F.DATE: date = SizYearMonthDay(from: c.getInt(i))!
            case F.SEQ: seq = c.getInt(i)!
            case F.TIME: time = SizHourMinSec(from: c.getInt(i))
            case F.BUDGET: budget_seq = c.getInt(i)!
            case F.PRICE: price = c.getInt(i) ?? 0
            case F.MEMO: memo = c.getString(i) ?? ""
            default: break
            }
        }
        
        assert( self.date != nil )
    }
    
    func toValues() -> [String : Any?] {
        [
            F.DATE: date.toInt(),
            F.SEQ: seq,
            F.TIME: time?.toInt() ?? sqlNil,
            F.BUDGET: budget_seq,
            F.PRICE: price,
            F.MEMO: memo
        ]
    }
    
}
