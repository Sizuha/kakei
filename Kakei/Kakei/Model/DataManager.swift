//
//  KakeiDataManager.swift
//  Kakei
//
//  Created by IL KYOUNG HWANG on 2019/04/08.
//  Copyright © 2019 Sizuha. All rights reserved.
//

import Foundation
import SQuery
import SizUtil

class DataManager {
	
	private let db: SQuery
	
	private init(source: String) {
		self.db = SQuery(at: source)
	}
	
	private static var sharedInstance: DataManager? = nil
	static var shared: DataManager {
		if sharedInstance == nil {
			let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
			sharedInstance = DataManager(source: "\(path)/user.db")
		}
		return sharedInstance!
	}
	
	func createTables() {
		if let tbl = self.db.tableCreator(name: ExpenseRecord.tableName) {
			defer { tbl.close() }
			_ = tbl
				.addPrimaryKey(ExpenseRecord.F_DATE, type: .integer)
				.addPrimaryKey(ExpenseRecord.F_TIME, type: .integer)
				.addPrimaryKey(ExpenseRecord.F_IDX, type: .integer, notNull: true, unique: true)
				.addColumn(ExpenseRecord.F_TITLE, type: .text)
				.addColumn(ExpenseRecord.F_BUDGET_IDX, type: .integer, notNull: true)
				.addColumn(ExpenseRecord.F_PRICE, type: .integer, notNull: true)
				.create(ifNotExists: true)
		}
		
		if let tbl = self.db.tableCreator(name: Budget.tableName) {
			defer { tbl.close() }
			_ = tbl
				.addPrimaryKey(Budget.F_YEAR_MONTH, type: .integer)
				.addPrimaryKey(Budget.F_IDX, type: .integer)
				.addColumn(Budget.F_ORDER, type: .integer)
				.addColumn(Budget.F_TITLE, type: .text, notNull: true)
				.create(ifNotExists: true)
		}
	}
	
	//--- 家計 ---
	
	func loadExpenseRecords(year: Int, month: Int) -> [ExpenseRecord] {
		guard let tbl = self.db.from(ExpenseRecord.tableName) else { return [] }
		defer { tbl.close() }
		
		let beginDate = SizYearMonthDay(year, month, 1).toInt()
		let endDate = SizYearMonthDay(year, month, 31).toInt()
		
		let (items, _) = tbl
			.whereAnd("\(ExpenseRecord.F_DATE) BETWEEN ? AND ?", beginDate, endDate)
			.select { ExpenseRecord() }
		return items
	}
	
	func write(_ exp: ExpenseRecord) {
		guard let tbl = self.db.from(ExpenseRecord.tableName) else { return }
		defer { tbl.close() }

		_ = tbl.keys(columns: ExpenseRecord.keyFields).values(exp).updateOrInsert()
	}
	
	func delete(expId: Int) {
		guard let tbl = self.db.from(ExpenseRecord.tableName) else { return }
		defer { tbl.close() }

		_ = tbl.whereAnd("\(ExpenseRecord.F_IDX)=?", expId).delete()
	}
	
	//--- 予算 ---
	
	func write(budget: Budget) {
		guard let tbl = self.db.from(Budget.tableName) else { return }
		defer { tbl.close() }
		
		_ = tbl.keys(columns: Budget.keyFields).values(budget).updateOrInsert()
	}
	
	func loadBudget(year: Int, month: Int) -> [Budget] {
		guard let tbl = self.db.from(Budget.tableName) else { return [] }
		defer { tbl.close() }

		let (items, _) = tbl
			.whereAnd("\(Budget.F_YEAR_MONTH)=?", year*100 + month)
			.select { Budget() }
		
		return items
	}
	
	func delete(year: Int, month: Int, dudgeIdx: Int) {
		guard let tbl = self.db.from(Budget.tableName) else { return }
		defer { tbl.close() }
		
		_ = tbl
			.whereAnd("\(Budget.F_YEAR_MONTH)=?", year*100 + month)
			.whereAnd("\(Budget.F_IDX)=?", dudgeIdx)
			.delete()
	}
	
}
