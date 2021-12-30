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
    
    private var db: SQuery!
    
    private init() {}
    
    func open() {
        let docUrl = AppDocUrl
        try? FileManager.default.createDirectory(at: docUrl, withIntermediateDirectories: true)
        
        let dbUrl = docUrl.appendingPathComponent("user.db", isDirectory: false)
        db = SQuery(url: dbUrl, mode: .readWriteCreate)
        
        db.create(tables: [ Budget.self, Household.self ])
    }
    
    // MARK: - 予算
    
    func loadBudgetList(date: YearMonth) -> [Budget] {
        guard let tbl = db.from(Budget.self) else { assert(false); return [] }
        defer { tbl.close() }
        
        let (rows, error) = tbl
            .setWhere("\(Budget.F.YEAR_MONTH)=?", date.toInt())
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
    
    func getLastBudgetSeq(date: YearMonth) -> Int {
        guard let tbl = db.from(Budget.self) else { fatalError() }
        defer { tbl.close() }

        let (row, error) = tbl.setWhere("\(Budget.F.YEAR_MONTH)=?", date.toInt())
            .orderBy(Budget.F.SEQ, desc: true)
            .selectOne { Budget() }
        
        if let error = error {
            print(error.localizedDescription)
            assert(false)
            return 0
        }
        return row?.seq ?? 0
    }
    
    func writeBudget(_ budget: Budget) {
        guard let tbl = db.from(Budget.self) else { assert(false); return }
        defer { tbl.close() }

        let result = tbl
            .keys(columns: Budget.tableScheme.getKeys())
            .values(budget)
            .insertOrUpdate()
        assert(result)
    }
    
    func updateBudgetDisplaySeq(_ items: [Budget]) {
        guard let tbl = db.from(Budget.self) else { assert(false); return }
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
        guard let tbl = db.from(Budget.self) else { assert(false); return false }
        defer { tbl.close() }

        let r = tbl.setWhere("\(Budget.F.YEAR_MONTH)=?", budget.date.toInt())
            .andWhere("\(Budget.F.SEQ)=?", budget.seq)
            .delete()
        
        return r.isSuccess
    }
    
    func copyBudgets(from: YearMonth, to: YearMonth) {
        guard let tbl = db.from(Budget.self) else { assert(false); return }
        defer { tbl.close() }

        let (fromItems, error) = tbl
            .setWhere("\(Budget.F.YEAR_MONTH)=?", from.toInt())
            .select { Budget() }
        
        if let error = error {
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

    // MARK: - 支出
    
    func loadPayList(date: SizYearMonthDay) -> [Household] {
        guard let tbl = db.from(Household.self) else { assert(false); return [] }
        defer { tbl.close() }
        
        let (rows, error) = tbl
            .setWhere("\(Household.F.DATE)=?", date.toInt)
            .select { Household() }
        
        guard error == nil else {
            print(error.debugDescription)
            assert(false)
            return []
        }
        
        return rows
    }

    
}
