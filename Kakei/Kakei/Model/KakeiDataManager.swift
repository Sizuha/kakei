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

class KakeiDataManager {
	
	private let db: SQuery
	
	private init(source: String) {
		db = SQuery(at: source)
	}
	
	private static var sharedInstance: KakeiDataManager? = nil
	static var shared: KakeiDataManager {
		if sharedInstance == nil {
			let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
			sharedInstance = KakeiDataManager(source: "\(path)/user.db")
		}
		return sharedInstance!
	}
	
	func createTables() {
		if let tbl = db.tableCreator(name: KakeiLog.tableName) {
			defer { tbl.close() }
			let _ = tbl
				.addPrimaryKey(KakeiLog.F_DATE, type: .integer)
				.addPrimaryKey(KakeiLog.F_TIME, type: .integer)
				.addPrimaryKey(KakeiLog.F_IDX, type: .integer, notNull: true, unique: true)
				.addColumn(KakeiLog.F_TITLE, type: .text)
				.addColumn(KakeiLog.F_BUDGET_IDX, type: .integer, notNull: true)
				.addColumn(KakeiLog.F_PRICE, type: .integer, notNull: true)
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
	
	func loadKakeiItems(year: Int, month: Int) -> [KakeiLog] {
		guard let tbl = db.from(KakeiLog.tableName) else { return [] }
		defer { tbl.close() }
		
		let beginDate = YearMonthDay(year, month, 1).toInt()
		let endDate = YearMonthDay(year, month, 31).toInt()
		
		let (items, _) = tbl
			.whereAnd("\(KakeiLog.F_DATE) BETWEEN ? AND ?", beginDate, endDate)
			.select { KakeiLog() }
		return items
	}
	
	func write(_ kakei: KakeiLog) {
		guard let tbl = db.from(KakeiLog.tableName) else { return }
		defer { tbl.close() }

		let _ = tbl.keys(columns: KakeiLog.keyFields).values(kakei).updateOrInsert()
	}
	
	func delete(kakeiId: Int) {
		guard let tbl = db.from(KakeiLog.tableName) else { return }
		defer { tbl.close() }

		let _ = tbl.whereAnd("\(KakeiLog.F_IDX)=?", kakeiId).delete()
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
