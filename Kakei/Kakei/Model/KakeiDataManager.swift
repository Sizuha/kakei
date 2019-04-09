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
				.addPrimaryKey(KakeiLog.F_IDX, type: .integer)
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
	
}
