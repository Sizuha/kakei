//
//  Budget.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2020/08/08.
//  Copyright © 2020 Sizuha. All rights reserved.
//

import Foundation
import UIKit
import SQuery
import SizUtil
import SizUI

/// 予算クラス
class Budget: SQueryRowEx {
    static var tableScheme = TableScheme(name: "budget", columns: [
        .def(F.YEAR_MONTH, type: .integer, [.primaryKey()]),
        .def(F.SEQ, type: .integer, [.primaryKey()]),
        .def(F.DISP_SEQ, type: .integer, []),
        .def(F.AMOUNT, type: .integer, [.notNull]),
        .def(F.LABEL, type: .text, [.notNull]),
        .def(F.COLOR, type: .integer, []),
    ])
    
    struct F {
        /// 年月（PK）：YYYYMM
        static let YEAR_MONTH = "year_month"
        /// 連番（PK）
        static let SEQ = "seq"
        /// 表示順番
        static let DISP_SEQ = "disp_seq"
        /// 予算
        static let AMOUNT = "amount"
        /// ラベル
        static let LABEL = "label"
        /// 色
        static let COLOR = "color"
    }
    
    /// 年月
    var date: YearMonth! = nil
    /// 連番：0より大きいこと！ 
    var seq: Int = 0
    /// 表示順番
    var displaySeq: Int = 0
    
    /// 予算
    var amount: Int = 0
    
    /// ラベル
    var label = ""
    /// ラベル（画面に表示）
    var shortLabel: String {
        label.count >= 2 ? label.subStr(from: 0, length: 2) : label
    }
    
    private static let DEFAULT_COLOR: UIColor = .label
    
    /// 色
    var color: UIColor = DEFAULT_COLOR
    
    /// 使用した金額（画面表示用）単位：千円
    var used = 0
    
    /// 予算の残り（画面表示用）単位：千円
    var remains: Int {
        self.amount - self.used
    }
    
    init() {}
    
    init(_ copy: Budget) {
        self.date = copy.date
        self.seq = copy.seq
        self.displaySeq = copy.displaySeq
        self.amount = copy.amount
        self.label = "\(copy.label)"
        self.color = copy.color
        self.used = copy.used
    }
    
    func load(from cursor: SQLiteCursor) {
        cursor.forEachColumn { c, i in
            let colName = c.getColumnName(i)
            switch colName {
            case F.YEAR_MONTH: self.date = YearMonth(from: c.getInt(i) ?? 0)
            case F.SEQ: self.seq = c.getInt(i) ?? 0
            case F.DISP_SEQ: self.displaySeq = c.getInt(i) ?? 0
            case F.AMOUNT: self.amount = c.getInt(i) ?? 0
            case F.LABEL: self.label = c.getString(i) ?? ""
            case F.COLOR:
                if let code = c.getInt(i) {
                    self.color = UIColor(argb: code)
                }
                else {
                    self.color = Budget.DEFAULT_COLOR
                }
                
            default: break
            }
        }
        
        assert( self.date != nil )
        assert( self.date.year >= 2000 )
        assert( (1...12).contains(self.date.month) )
        assert( self.label.isEmpty == false )
    }
    
    func toValues() -> [String : Any?] {
        [
            F.YEAR_MONTH: self.date.toInt(),
            F.SEQ: self.seq,
            F.DISP_SEQ: self.displaySeq,
            F.AMOUNT: self.amount,
            F.LABEL: self.label,
            F.COLOR: self.color == Budget.DEFAULT_COLOR ? sqlNil : self.color.toInt()!
        ]
    }
    
}
