//
//  Strings.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2020/08/08.
//  Copyright © 2020 Sizuha. All rights reserved.
//

import Foundation
import SizUtil

struct Strings {
    static let APP_TITLE = "楽家計"
    static let BUDGET = "予算"
    static let HOUSEHOLD = "家計"
    static let SETTINGS = "設定"
    static let REMOVE = "削除"
    static let ADD = "登録"
    static let EDIT = "編集"
    static let OK = "OK"
    static let CANCEL = "キャンセル"
    static let CLOSE = "閉じる"
    static let WITHOUT_BUDGET = "予算外"
    static let ADD_BUDGET = "予算登録"
    static let IMPORT_FROM_PREV_MONTH =  "前月から引き継ぎ"
    static let REMOVE_ALL = "すべて削除"
    static let ADD_PAY = "支出登録"
    static let WARNING = "警告"
    static let DONE = "完了"
    static let HOW_TO_USE = "使い方"
    static let NONE = "無し"
    static let INFO = "情報"
    static let VERSION = "バージョン"
    static let BACKUP = "バックアップ"
    static let AUTO_BACKUP = "自動バックアップ"
    static let RESTORE = "復元"
    
    struct Message {
        static let CONFIRM_REMOVE = "削除しますか？"
        static let EMPTY_BUDGET = "先に予算を登録してください"
        static let EMPTY_PAY_LIST = "支出履歴がありません"
        static let ALERT_CELAR = "現在編集中の内容は削除されます"
        static let CONFIRM_BACKUP = "バックアップを行いますか？"
        static let CONFIRM_RESTORE = "最後のバックアップ内容で復元します。\n現在の全てのデータは消えます。"
    }
    
    struct Error {
        static let EMPTY_BUDGET_NAME = "予算名を入力してください"
        static let EMPTY_BUDGET = "予算を入力してください"
        static let WRONG_BUDGET = "予算は半角数字で\n入力してください"
        static let FAIL_RESTORE = "復元失敗"
        static let FAIL_RESTORE_MSG = "バックアップが無いか\n途中でエラーが発生しました。"
    }
}
