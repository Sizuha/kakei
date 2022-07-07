//
//  AppSettings.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2022/03/03.
//  Copyright © 2022 Sizuha. All rights reserved.
//

import Foundation
import SizUtil

class AppSettings {
    
    static let shared = AppSettings()
    
    private var pref: UserDefaults {
        return UserDefaults.standard
    }
    
    private let FMT_DATETIME = DateFormatter()
    
    init() {
        FMT_DATETIME.calendar = .standard
        FMT_DATETIME.dateFormat = "yyyyMMdd HHmmss"
    }
    
    var lastBackup: Date? {
        get {
            guard let dateStr = pref.string(forKey: "last_backup") else { return nil }
            return FMT_DATETIME.date(from: dateStr)
        }
        set {
            if let date = newValue {
                pref.setValue(FMT_DATETIME.string(from: date), forKey: "last_backup")
            }
            else {
                pref.setNilValueForKey("last_backup")
            }
        }
    }
    
    var enableAutoBackup: Bool {
        get {
            !pref.bool(forKey: "disable_auto_backup")
        }
        set {
            pref.setValue(!newValue, forKey: "disable_auto_backup")
        }
    }
    
}
