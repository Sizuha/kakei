//
//  DataManager.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2020/08/08.
//  Copyright © 2020 Sizuha. All rights reserved.
//

import Foundation
import SQuery
import SizUtil

class DataManager {
    
    static let shared = DataManager()
    
    private var db_w: SQuery!
    private var db_r: SQuery!
    
    private init() {}
    
    func open() {
        let docUrl = AppDocUrl
        try? FileManager.default.createDirectory(at: docUrl, withIntermediateDirectories: true)
        let dbUrl = docUrl.appendingPathComponent(DB_FILE, isDirectory: false)
        
        self.db_w = SQuery(url: dbUrl, mode: .readWriteCreate)
        self.db_w.create(tables: [ Budget.self, Household.self ])
        
        self.db_r = SQuery(url: dbUrl, mode: .readonly)
    }
    
    // MARK: - 予算
    
    func getBudget(by household: Household) -> Budget? {
        let ym = YearMonth(year: household.date.year, month: household.date.month)
        return getBudget(date: ym, budgeSeq: household.budget_seq)
    }
    
    func getBudget(date: YearMonth, budgeSeq: Int) -> Budget? {
        guard budgeSeq >= 0 else { return nil }
        
        guard let tbl = db_r.from(Budget.self) else { fatalError() }
        defer { tbl.close() }
        
        let (budget, error) = tbl.setWhere("\(Budget.F.YEAR_MONTH)=?", date.toInt())
            .andWhere("\(Budget.F.SEQ)=?", budgeSeq)
            .selectOne { Budget() }
        
        if DEBUG_MODE, let error = error {
            print(error.localizedDescription)
        }
        return budget
    }
    
    func loadBudgetList(yearMonth: YearMonth) -> [Budget] {
        guard let tbl = db_r.from(Budget.self) else { assert(false); return [] }
        defer { tbl.close() }
        
        let (rows, error) = tbl
            .setWhere("\(Budget.F.YEAR_MONTH)=?", yearMonth.toInt())
            .andWhere("\(Budget.F.SEQ) > 0")
            .orderBy(Budget.F.DISP_SEQ, desc: false)
            .orderBy(Budget.F.SEQ, desc: false)
            .select { Budget() }
        
        if let error = error {
            print(error.localizedDescription)
            assert(false)
            return []
        }
        return rows
    }
    
    func countBudgetList(yearMonth: YearMonth) -> Int {
        guard let tbl = db_r.from(Budget.self) else { assert(false); return 0 }
        defer { tbl.close() }
        
        let count = tbl
            .setWhere("\(Budget.F.YEAR_MONTH)=?", yearMonth.toInt())
            .andWhere("\(Budget.F.SEQ) > 0")
            .count() ?? 0
        
        return count
    }
    
    func getLastBudgetSeq(yearMonth: YearMonth) -> Int {
        guard let tbl = db_r.from(Budget.self) else { fatalError() }
        defer { tbl.close() }

        let (row, error) = tbl.setWhere("\(Budget.F.YEAR_MONTH)=?", yearMonth.toInt())
            .orderBy(Budget.F.SEQ, desc: true)
            .selectOne { Budget() }
        
        if let error = error {
            print(error.localizedDescription)
            assert(false)
            return 0
        }
        return row?.seq ?? 0
    }
    
    func getLastBudgetDispSeq(yearMonth: YearMonth) -> Int {
        guard let tbl = db_r.from(Budget.self) else { fatalError() }
        defer { tbl.close() }

        let (row, error) = tbl.setWhere("\(Budget.F.YEAR_MONTH)=?", yearMonth.toInt())
            .orderBy(Budget.F.DISP_SEQ, desc: true)
            .selectOne { Budget() }
        
        if let error = error {
            print(error.localizedDescription)
            assert(false)
            return 0
        }
        return row?.displaySeq ?? 0
    }
    
    func writeBudget(_ budget: Budget) {
        guard let tbl = db_w.from(Budget.self) else { assert(false); return }
        defer { tbl.close() }

        let result = tbl
            .keys(columns: Budget.tableScheme.getKeys())
            .values(budget)
            .insertOrUpdate()
        assert(result)
    }
    
    func updateBudgetDisplaySeq(_ items: [Budget]) {
        guard let tbl = db_w.from(Budget.self) else { assert(false); return }
        defer { tbl.close() }

        for budget in items {
            let result = tbl
                .setWhere("\(Budget.F.YEAR_MONTH)=?", budget.date.toInt())
                .andWhere("\(Budget.F.SEQ)=?", budget.seq)
                .values([
                    Budget.F.DISP_SEQ: budget.displaySeq
                ])
                .update()
            assert(result.isSuccess)
        }
    }
    
    func removeBudget(_ budget: Budget) -> Bool {
        guard let tblBudget = db_w.from(Budget.self) else { assert(false); return false }
        defer { tblBudget.close() }
        
        guard let tblHousehold = db_w.from(Household.self) else { assert(false); return false }
        defer { tblHousehold.close() }
        
        // 支出記録から、予算情報を消す
        var r = tblHousehold.setWhere("\(Household.F.BUDGET)=?", budget.seq)
            .values([Household.F.BUDGET : -1])
            .update()

        r = tblBudget.setWhere("\(Budget.F.YEAR_MONTH)=?", budget.date.toInt())
            .andWhere("\(Budget.F.SEQ)=?", budget.seq)
            .delete()
        
        return r.isSuccess
    }
    
    func removeBudgets(yearMonth: YearMonth) {
        guard let tblBudget = db_w.from(Budget.self) else { assert(false); return }
        defer { tblBudget.close() }
        
        guard let tblHousehold = db_w.from(Household.self) else { assert(false); return }
        defer { tblHousehold.close() }
        
        // 支出記録から、予算情報を消す
        let date_begin = yearMonth.toInt()*100
        let date_end = date_begin + 99
        _ = tblHousehold.setWhere("\(Household.F.DATE) BETWEEN ? AND ?", date_begin, date_end)
            .values([Household.F.BUDGET : -1])
            .update()

        // 予算削除
        _ = tblBudget.setWhere("\(Budget.F.YEAR_MONTH)=?", yearMonth.toInt())
            .delete()
    }
    
    func copyBudgets(from: YearMonth, to: YearMonth) {
        guard let tbl = db_w.from(Budget.self) else { assert(false); return }
        defer { tbl.close() }

        let (fromItems, error) = tbl
            .setWhere("\(Budget.F.YEAR_MONTH)=?", from.toInt())
            .select { Budget() }
        
        if DEBUG_MODE, let error = error {
            print(error.localizedDescription)
            assert(false)
        }

        _ = tbl.reset()
            .setWhere("\(Budget.F.YEAR_MONTH)=?", to.toInt())
            .delete()
        
        _ = tbl.reset()
        for item in fromItems {
            item.date = to
            let result = tbl.insert(values: item)
            assert(result.isSuccess)
        }
    }

    // MARK: - 支出（ししゅつ）
    
    func loadHouseholdList(yearMonth: YearMonth) -> [Household] {
        guard let tbl = db_r.from(Household.self) else { assert(false); return [] }
        defer { tbl.close() }
        
        let date_val = yearMonth.toInt()*100
        let (rows, error) = tbl
            .setWhere("\(Household.F.DATE) BETWEEN ? AND ?", date_val, date_val + 99)
            .select { Household() }
        
        guard error == nil else {
            print(error.debugDescription)
            assert(false)
            return []
        }
        
        return rows
    }

    func getTotalAmount(yearMonth: YearMonth, budget: Budget) -> Int {
        guard let tbl = db_r.from(Household.self) else { assert(false); return 0 }
        defer { tbl.close() }

        let date_begin = yearMonth.toInt()*100 + 1
        let date_end = date_begin + 30
        let (rows, error) = tbl.setWhere("\(Household.F.DATE) BETWEEN ? AND ?", date_begin, date_end)
            .andWhere("\(Household.F.BUDGET) = ?", budget.seq)
            .select { Household() }
        
        guard error == nil else {
            print(error.debugDescription)
            assert(false)
            return 0
        }
        
        var sum = 0
        for row in rows {
            sum += row.price
        }
        return sum
    }
    
    func removeHousehold(_ item: Household) {
        removeHousehold(date: item.date, seq: item.seq)
    }
    
    func removeHousehold(date: SizYearMonthDay, seq: Int) {
        guard let tbl = db_w.from(Household.self) else { assert(false); return }
        defer { tbl.close() }
        
        let r = tbl.setWhere("\(Household.F.DATE)=?", date.toInt())
            .andWhere("\(Household.F.SEQ)=?", seq)
            .delete()
        
        if DEBUG_MODE, let err = r.error {
            print(err)
            assert(false)
        }
    }
    
    func writeHousehold(_ item: Household) {
        guard let tbl = db_w.from(Household.self) else { assert(false); return }
        defer { tbl.close() }

        let result = tbl
            .keys(columns: Household.tableScheme.getKeys())
            .values(item)
            .insertOrUpdate()
        assert(result)
    }
    
}
