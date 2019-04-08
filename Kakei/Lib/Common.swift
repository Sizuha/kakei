//
//  Common.swift
//  Kakei
//
//  Created by IL KYOUNG HWANG on 2019/04/08.
//  Copyright © 2019 Sizuha. All rights reserved.
//

import Foundation
import SizUtil

protocol CsvExportable {
	func toCsv() -> [String]
	func loadFrom(csvColumn: SizCsvParser.ColumnData)
}
