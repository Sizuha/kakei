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
        
        let result = tbl.where("\(Budget.F.YEAR_MONTH)=?", date.toInt())
            .andWhere("\(Budget.F.SEQ)=?", budgeSeq)
            .selectOne { Budget() }
        
        if DEBUG_MODE, let error = result.error {
            print(error.localizedDescription)
        }
        return result.row
    }
    
    func loadBudgetList(yearMonth: YearMonth) -> [Budget] {
        guard let tbl = db_r.from(Budget.self) else { assert(false); return [] }
        defer { tbl.close() }
        
        let result = tbl
            .where("\(Budget.F.YEAR_MONTH)=?", yearMonth.toInt())
            .andWhere("\(Budget.F.SEQ) > 0")
            .orderBy(Budget.F.DISP_SEQ, desc: false)
            .orderBy(Budget.F.SEQ, desc: false)
            .select { Budget() }
        
        if let error = result.error {
            print(error.localizedDescription)
            assert(false)
            return []
        }
        return result.rows
    }
    
    func countBudgetList(yearMonth: YearMonth) -> Int {
        guard let tbl = db_r.from(Budget.self) else { assert(false); return 0 }
        defer { tbl.close() }
        
        let count = tbl
            .where("\(Budget.F.YEAR_MONTH)=?", yearMonth.toInt())
            .andWhere("\(Budget.F.SEQ) > 0")
            .count() ?? 0
        
        return count
    }
    
    func getLastBudgetSeq(yearMonth: YearMonth) -> Int {
        guard let tbl = db_r.from(Budget.self) else { fatalError() }
        defer { tbl.close() }

        let result = tbl.where("\(Budget.F.YEAR_MONTH)=?", yearMonth.toInt())
            .orderBy(Budget.F.SEQ, desc: true)
            .selectOne { Budget() }
        
        if let error = result.error {
            print(error.localizedDescription)
            assert(false)
            return 0
        }
        return result.row?.seq ?? 0
    }
    
    func getLastBudgetDispSeq(yearMonth: YearMonth) -> Int {
        guard let tbl = db_r.from(Budget.self) else { fatalError() }
        defer { tbl.close() }

        let result = tbl.where("\(Budget.F.YEAR_MONTH)=?", yearMonth.toInt())
            .orderBy(Budget.F.DISP_SEQ, desc: true)
            .selectOne { Budget() }
        
        if let error = result.error {
            print(error.localizedDescription)
            assert(false)
            return 0
        }
        return result.row?.displaySeq ?? 0
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
                .where("\(Budget.F.YEAR_MONTH)=?", budget.date.toInt())
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
        let date_begin = budget.date.toInt()*100
        let date_end = date_begin + 99
        var r = tblHousehold.where("\(Household.F.DATE) BETWEEN ? AND ?", date_begin, date_end)
            .andWhere("\(Household.F.BUDGET)=?", budget.seq)
            .values([Household.F.BUDGET : -1])
            .update()

        r = tblBudget.where("\(Budget.F.YEAR_MONTH)=?", budget.date.toInt())
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
        _ = tblHousehold.where("\(Household.F.DATE) BETWEEN ? AND ?", date_begin, date_end)
            .values([Household.F.BUDGET : -1])
            .update()

        // 予算削除
        _ = tblBudget.where("\(Budget.F.YEAR_MONTH)=?", yearMonth.toInt())
            .delete()
    }
    
    func copyBudgets(from: YearMonth, to: YearMonth) {
        guard let tbl = db_w.from(Budget.self) else { assert(false); return }
        defer { tbl.close() }

        let result = tbl
            .where("\(Budget.F.YEAR_MONTH)=?", from.toInt())
            .select { Budget() }
        
        if DEBUG_MODE, let error = result.error {
            print(error.localizedDescription)
            assert(false)
        }

        _ = tbl.reset()
            .where("\(Budget.F.YEAR_MONTH)=?", to.toInt())
            .delete()
        
        _ = tbl.reset()
        for item in result.rows {
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
        let result = tbl
            .where("\(Household.F.DATE) BETWEEN ? AND ?", date_val, date_val + 99)
            .orderBy(Household.F.DATE, desc: true)
            .orderBy(Household.F.DISP_SEQ, desc: false)
            .orderBy(Household.F.SEQ, desc: false)
            .select { Household() }
        
        guard result.isSuccess else {
            print(result.error!.localizedDescription)
            assert(false)
            return []
        }
        
        return result.rows
    }
    
    func loadHouseholdList(date: SizYearMonthDay) -> [Household] {
        guard let tbl = db_r.from(Household.self) else { assert(false); return [] }
        defer { tbl.close() }
        
        let date_val = date.toInt()
        let result = tbl
            .where("\(Household.F.DATE)=?", date_val)
            .orderBy(Household.F.DISP_SEQ, desc: false)
            .orderBy(Household.F.SEQ, desc: false)
            .select { Household() }
        
        guard result.isSuccess else {
            print(result.error!.localizedDescription)
            assert(false)
            return []
        }
        
        return result.rows
    }
    
    func getLastHouseholdSeq(date: SizYearMonthDay) -> Int {
        guard let tbl = db_r.from(Household.self) else { assert(false); return -1 }
        defer { tbl.close() }

        let result = tbl.where("\(Household.F.DATE)=?", date.toInt())
            .orderBy(Household.F.SEQ, desc: true)
            .selectOne { Household() }

        guard result.isSuccess else {
            print(result.error!.localizedDescription)
            assert(false)
            return -1
        }

        return result.row?.seq ?? -1
    }

    func getTotalAmount(yearMonth: YearMonth, budget: Budget) -> Int {
        guard let tbl = db_r.from(Household.self) else { assert(false); return 0 }
        defer { tbl.close() }

        let date_begin = yearMonth.toInt()*100 + 1
        let date_end = date_begin + 30
        let result = tbl.where("\(Household.F.DATE) BETWEEN ? AND ?", date_begin, date_end)
            .andWhere("\(Household.F.BUDGET) = ?", budget.seq)
            .select { Household() }
        
        guard result.isSuccess else {
            print(result.error!.localizedDescription)
            assert(false)
            return 0
        }
        
        var sum = 0
        for row in result.rows {
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
        
        let r = tbl.where("\(Household.F.DATE)=?", date.toInt())
            .andWhere("\(Household.F.SEQ)=?", seq)
            .delete()
        
        if DEBUG_MODE, let err = r.error {
            print(err)
            assert(false)
        }
    }
    
    func removeHouseholds(yearMonth date: YearMonth) {
        guard let tbl = db_w.from(Household.self) else { assert(false); return }
        defer { tbl.close() }
        
        let date_begin = date.toInt()*100
        let date_end = date_begin + 99
        let r = tbl.where("\(Household.F.DATE) BETWEEN ? AND ?", date_begin, date_end)
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
    
    func updateHouseholdDisplaySeq(_ items: [Household]) {
        guard let tbl = db_w.from(Household.self) else { assert(false); return }
        defer { tbl.close() }

        for item in items {
            let result = tbl
                .where("\(Household.F.DATE)=?", item.date.toInt())
                .andWhere("\(Household.F.SEQ)=?", item.seq)
                .values([
                    Household.F.DISP_SEQ: item.displaySeq
                ])
                .update()
            assert(result.isSuccess)
        }
    }
    
    
    // MARK: - Backup/Restore
    
    func syncBackupData() -> Bool {
        guard
            let url = iCloudBackupUrl?.appendingPathComponent(BACKUP_DB_FILE)
        else { return false }
        
        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: url)
            return true
        }
        catch let error {
            print("error: \(error.localizedDescription)")
            return false
        }
    }
    
    private func copyFile(from fromUrl: URL, to toUrl: URL) -> Bool {
        let fileMng = FileManager.default
        do { try fileMng.removeItem(at: toUrl) } catch {
            print("fail: remove a target file")
        }
        do { try fileMng.copyItem(at: fromUrl, to: toUrl) } catch {
            print("fail: copy file")
            return false
        }
        
        return true
    }
    
    func backup() -> Bool {
        guard let iCloudUrl = iCloudBackupUrl else { assert(false); return false }
        let fromUrl = AppDocUrl.appendingPathComponent(DB_FILE)
        let toUrl = iCloudUrl.appendingPathComponent(BACKUP_DB_FILE)
        
        if copyFile(from: fromUrl, to: toUrl) {
            AppSettings.shared.lastBackup = Date()
            return true
        }
        return false
    }
    
    func restore(fromOldDB: Bool = false) -> Bool {
        guard let iCloudUrl = iCloudBackupUrl else { return false }
        let fromUrl = iCloudUrl.appendingPathComponent(BACKUP_DB_FILE)
        let toUrl = AppDocUrl.appendingPathComponent(DB_FILE)
        
        _ = syncBackupData()
        
        guard FileManager.default.fileExists(atPath: fromUrl.path) else {
            return false
        }
        
        return copyFile(from: fromUrl, to: toUrl)
    }
    
    /// 自動バックアップ機能
    func backupIfNeed() {
        guard AppSettings.shared.enableAutoBackup else { return }
        
        guard let last = AppSettings.shared.lastBackup else {
            _ = backup()
            return
        }
        
        let cal = Calendar.standard
        let next: Date? = cal.date(byAdding: .day, value: 1, to: last)
        
        let now = Date()
        if let date = next, now >= date {
            _ = backup()
        }
    }
    
}
