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
		db = SQuery(at: source)
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
		if let tbl = db.tableCreator(name: ExpLog.tableName) {
			defer { tbl.close() }
			let _ = tbl
				.addPrimaryKey(ExpLog.F_DATE, type: .integer)
				.addPrimaryKey(ExpLog.F_TIME, type: .integer)
				.addPrimaryKey(ExpLog.F_IDX, type: .integer, notNull: true, unique: true)
				.addColumn(ExpLog.F_TITLE, type: .text)
				.addColumn(ExpLog.F_BUDGET_IDX, type: .integer, notNull: true)
				.addColumn(ExpLog.F_PRICE, type: .integer, notNull: true)
				.create(ifNotExists: true)
		}
		
		if let tbl = db.tableCreator(name: Budget.tableName) {
			defer { tbl.close() }
			let _ = tbl
				.addPrimaryKey(Budget.F_YEAR_MONTH, type: .integer)
				.addPrimaryKey(Budget.F_IDX, type: .integer)
				.addColumn(Budget.F_ORDER, type: .integer)
				.addColumn(Budget.F_TITLE, type: .text, notNull: true)
				.create(ifNotExists: true)
		}
	}
	
	//--- 家計 ---
	
	func loadExpItems(year: Int, month: Int) -> [ExpLog] {
		guard let tbl = db.from(ExpLog.tableName) else { return [] }
		defer { tbl.close() }
		
		let beginDate = SizYearMonthDay(year, month, 1).toInt()
		let endDate = SizYearMonthDay(year, month, 31).toInt()
		
		let (items, _) = tbl
			.whereAnd("\(ExpLog.F_DATE) BETWEEN ? AND ?", beginDate, endDate)
			.select { ExpLog() }
		return items
	}
	
	func write(_ exp: ExpLog) {
		guard let tbl = db.from(ExpLog.tableName) else { return }
		defer { tbl.close() }

		let _ = tbl.keys(columns: ExpLog.keyFields).values(exp).updateOrInsert()
	}
	
	func delete(expId: Int) {
		guard let tbl = db.from(ExpLog.tableName) else { return }
		defer { tbl.close() }

		let _ = tbl.whereAnd("\(ExpLog.F_IDX)=?", expId).delete()
	}
	
	//--- 予算 ---
	
	func write(budget: Budget) {
		guard let tbl = db.from(Budget.tableName) else { return }
		defer { tbl.close() }
		
		let _ = tbl.keys(columns: Budget.keyFields).values(budget).updateOrInsert()
	}
	
	func loadBudget(year: Int, month: Int) -> [Budget] {
		guard let tbl = db.from(Budget.tableName) else { return [] }
		defer { tbl.close() }

		let (items, _) = tbl
			.whereAnd("\(Budget.F_YEAR_MONTH)=?", year*100 + month)
			.select { Budget() }
		
		return items
	}
	
	func delete(year: Int, month: Int, dudgeIdx: Int) {
		guard let tbl = db.from(Budget.tableName) else { return }
		defer { tbl.close() }
		
		let _ = tbl
			.whereAnd("\(Budget.F_YEAR_MONTH)=?", year*100 + month)
			.whereAnd("\(Budget.F_IDX)=?", dudgeIdx)
			.delete()
	}
	
}
