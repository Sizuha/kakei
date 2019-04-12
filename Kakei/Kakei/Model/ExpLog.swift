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
class ExpLog: SQueryRow, CsvSerializable {
	
	static let tableName = "kakei"
	
	static let F_DATE = "date" // yyyyMMdd (*PK)
	static let F_TIME = "time" // HHmmss (*PK)
	static let F_IDX = "idx" // idx in all (*PK)
	
	static let F_TITLE = "title"
	static let F_BUDGET_IDX = "bugdget_idx" // 予算IDX
	static let F_PRICE = "price"
	
	static let keyFields = [F_DATE, F_TIME, F_IDX]

	private var date: Int = 0
	private var time: Int = 0
	
	func getDate() -> Date? {
		guard self.date > 0 else { return nil }
		
		// yyyyMMdd HHmmss
		let srouce = String(format: "%08d %06d", self.date, self.time)
		return self.dateTimeFormat.date(from: srouce)
	}
	func setDate(_ date: Date) {
		let cal = Calendar(identifier: .gregorian)
		
		let year = cal.component(.year, from: date)
		let month = cal.component(.month, from: date)
		let day = cal.component(.day, from: date)
		self.date = year*100_00 + month*100 * day
		
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
			case ExpLog.F_DATE: date = cur.getInt(i) ?? 0
			case ExpLog.F_TIME: time = cur.getInt(i) ?? 0
			case ExpLog.F_IDX: idx = cur.getInt(i) ?? 0
			case ExpLog.F_TITLE: title = cur.getString(i) ?? ""
			case ExpLog.F_BUDGET_IDX: budgetIdx = cur.getInt(i) ?? 0
			case ExpLog.F_PRICE: price = cur.getInt(i) ?? 0
			default: break
			}
		}
	}
	
	func toValues() -> [String:Any?] {
		return [
			ExpLog.F_DATE: date,
			ExpLog.F_TIME: time,
			ExpLog.F_IDX: idx,
			ExpLog.F_TITLE: title,
			ExpLog.F_BUDGET_IDX: budgetIdx,
			ExpLog.F_PRICE: price
		]
	}
	
	func toCsv() -> [String] {
		return ["\(date)", "\(time)", "\(idx)", title, "\(budgetIdx)", "\(price)"]
	}
	
	func load(from csvColumn: SizCsvParser.ColumnData) {
		switch csvColumn.colIdx {
		case 0: date = csvColumn.asInt ?? 0
		case 1: time = csvColumn.asInt ?? 0
		case 2: idx = csvColumn.asInt ?? 0
		case 3: title = csvColumn.data
		case 4: budgetIdx = csvColumn.asInt ?? 0
		case 5: price = csvColumn.asInt ?? 0
		default: break
		}
	}

}

