//
//  Config.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2020/08/08.
//  Copyright © 2020 Sizuha. All rights reserved.
//

import Foundation

let USER_DB_VER = 0
let DB_FILE = "user.db"

var AppDocUrl: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}

let MIN_YEAR = 2020
var MAX_YEAR: Int {
    YearMonth.now.year + 1
}

let MAX_BUDGET_COUNT = 6

/// 単位：千円
let AMOUNT_MULTIPLIER = 1000
