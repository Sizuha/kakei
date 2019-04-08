//
//  Budget.swift
//  Kakei
//
//  Created by IL KYOUNG HWANG on 2019/04/08.
//  Copyright © 2019 Sizuha. All rights reserved.
//

import Foundation
import SQuery
import SizUtil

class Budget: SQueryRow, CsvExportable {
	
	static let tableName = "budget"
	
	static let F_YEAR_MONTH = "year_month" // yyyyMM (*PK)
	static let F_IDX = "idx" // idx in year_month (*PK)
	static let F_ORDER = "order" // order in year_month
	static let F_TITLE = "title"
	static let F_PRICE = "price"
	
	private var yearMonth: Int =  0
	private var idx: Int = 0
	private var order: Int = 0
	
	var title: String = ""
	var price: Int = 0
	
	
	func loadFrom(cursor: SQLiteCursor) {
		
	}
	
	func toValues() -> [String:Any?] {
		//var result = [String:Any?]()
		
		return [:]
	}
	
	func toCsv() -> [String] {
		return []
	}
	
	func loadFrom(csvColumn: SizCsvParser.ColumnData) {
		
	}

}
