//
//  KakeiLog.swift
//  Kakei
//
//  Created by IL KYOUNG HWANG on 2019/04/08.
//  Copyright © 2019 Sizuha. All rights reserved.
//

import Foundation
import SQuery
import SizUtil

/**
 家計Table
 */
class ExpenseRecord: SQueryRow, CsvSerializable {
	
	static let tableName = "kakei"
	
	static let F_DATE = "date" // yyyyMMdd (*PK)
	static let F_TIME = "time" // HHmmss (*PK)
	static let F_IDX = "idx" // idx in all (*PK)
	
	static let F_TITLE = "title"
	static let F_BUDGET_IDX = "bugdget_idx" // 予算IDX
	static let F_PRICE = "price"
	
	static let keyFields = [F_DATE, F_TIME, F_IDX]

	private var dateRaw: Int = 0
	private var time: Int = 0
	
	var date: Date? {
		get {
			return getDate()
		}
		set {
			if let value = newValue {
				setDate(value)
			}
			else {
				dateRaw = 0
			}
		}
	}
	
	private func getDate() -> Date? {
		guard self.dateRaw > 0 else { return nil }
		
		// yyyyMMdd HHmmss
		let srouce = String(format: "%08d %06d", self.dateRaw, self.time)
		return self.dateTimeFormat.date(from: srouce)
	}
	private func setDate(_ date: Date) {
		let cal = Calendar(identifier: .gregorian)
		
		let year = cal.component(.year, from: date)
		let month = cal.component(.month, from: date)
		let day = cal.component(.day, from: date)
		self.dateRaw = year*100_00 + month*100 * day
		
		let hour = cal.component(.hour, from: date)
		let minute = cal.component(.minute, from: date)
		let second = cal.component(.second, from: date)
		self.time = hour*100_00 + minute*100 + second
	}
	
	private var idx: Int = 0
	
	var title: String = ""
	var budgetIdx: Int = 0
	var price: Int = 0
	
	
	private let dateTimeFormat: DateFormatter
	
	init() {
		self.dateTimeFormat = SQuery.newDateTimeFormat()
		self.dateTimeFormat.dateFormat = "yyyyMMdd HHmmss"
		self.dateTimeFormat.timeZone = TimeZone.current
	}
	
	func load(from cursor: SQLiteCursor) {
		cursor.forEachColumn { cur, i in
			let colName = cur.getColumnName(i)
			switch colName {
			case ExpenseRecord.F_DATE: self.dateRaw = cur.getInt(i) ?? 0
			case ExpenseRecord.F_TIME: self.time = cur.getInt(i) ?? 0
			case ExpenseRecord.F_IDX: self.idx = cur.getInt(i) ?? 0
			case ExpenseRecord.F_TITLE: self.title = cur.getString(i) ?? ""
			case ExpenseRecord.F_BUDGET_IDX: self.budgetIdx = cur.getInt(i) ?? 0
			case ExpenseRecord.F_PRICE: self.price = cur.getInt(i) ?? 0
			default: break
			}
		}
	}
	
	func toValues() -> [String:Any?] {
		return [
			ExpenseRecord.F_DATE: self.dateRaw,
			ExpenseRecord.F_TIME: self.time,
			ExpenseRecord.F_IDX: self.idx,
			ExpenseRecord.F_TITLE: self.title,
			ExpenseRecord.F_BUDGET_IDX: self.budgetIdx,
			ExpenseRecord.F_PRICE: self.price
		]
	}
	
	func toCsv() -> [String] {
		return ["\(self.dateRaw)", "\(self.time)", "\(self.idx)", self.title, "\(self.budgetIdx)", "\(self.price)"]
	}
	
	func load(from csvColumn: SizCsvParser.ColumnData) {
		switch csvColumn.colIdx {
		case 0: self.dateRaw = csvColumn.asInt ?? 0
		case 1: self.time = csvColumn.asInt ?? 0
		case 2: self.idx = csvColumn.asInt ?? 0
		case 3: self.title = csvColumn.data
		case 4: self.budgetIdx = csvColumn.asInt ?? 0
		case 5: self.price = csvColumn.asInt ?? 0
		default: break
		}
	}

}

