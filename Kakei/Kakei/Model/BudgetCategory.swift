//
//  BudgetCategory.swift
//  Kakei
//
//  Created by IL KYOUNG HWANG on 2019/08/22.
//  Copyright © 2019 Sizuha. All rights reserved.
//

import Foundation
import SQuery

class BudgetCategory: SQueryRow {

	static let tableName = "budget_category"
	
	static let F_IDX = "idx" // idx in year_month (*PK,AI)
	static let F_SIG = "sig"
	static let F_DESC = "descript"
	
	static let keyFields = [F_IDX]
	
	private var idx: Int = 0	
	var signiture: String = ""
	var description: String = ""
	
	func load(from cursor: SQLiteCursor) {
		
	}
	
	func toValues() -> [String:Any?] {
		//var result = [String:Any?]()
		
		return [:]
	}
	
}
