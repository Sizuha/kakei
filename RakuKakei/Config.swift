//
//  Config.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2020/08/08.
//  Copyright © 2020 Sizuha. All rights reserved.
//

import Foundation
import SizUtil

typealias YearMonth = SizYearMonth

let USER_DB_VER = 0
let DB_FILE = "user.db"
let BACKUP_DB_FILE = "backup.db"

var DEBUG_MODE: Bool {
    #if DEBUG
    true
    #else
    false
    #endif
}

var AppDocUrl: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}

let MIN_YEAR = 2022
var MAX_YEAR: Int {
    YearMonth.now.year + 1
}

let MAX_BUDGET_COUNT = 6

/// 単位：千円
//let AMOUNT_MULTIPLIER = 1000

let DATE_FMT_FOR_DISPLAY = "yyyy年M月d日"
let WEEKDAY_TEXT = ["日","月","火","水","木","金","土"]

fileprivate let ICLOUD_CONTAINER_ID = "iCloud.com.kishe.sizuha.rakukakei"

var iCloudBackupUrl: URL? {
    guard let url = FileManager.default.url(forUbiquityContainerIdentifier: ICLOUD_CONTAINER_ID)?.appendingPathComponent("Backup")
    else { return nil }
    
    do {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }
    catch {
        return nil
    }
}

