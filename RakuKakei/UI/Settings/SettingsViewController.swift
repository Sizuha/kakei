//
//  SettingsViewController.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2022/03/02.
//  Copyright © 2022 Sizuha. All rights reserved.
//

import UIKit
import SizUI
import SizUtil

class SettingsViewController: UIViewController {
    
    static func present(from: UIViewController, onNeedReload: (()->Void)? = nil) {
        let vc = SettingsViewController()
        vc.onNeedReload = onNeedReload
        
        let navi = UINavigationController()
        navi.pushViewController(vc, animated: false)
        navi.modalTransitionStyle = .coverVertical
        navi.modalPresentationStyle = .fullScreen
        
        from.present(navi, animated: true, completion: nil)
    }
    
    private var settingsView: SizPropertyTableView!
    private var lastBackupText = "無し"
    private var onNeedReload: (()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "設定"
        
        let bbiClose = UIBarButtonItem(title: "閉じる", style: .plain, target: self, action: #selector(closeThis))
        self.navigationItem.leftBarButtonItems = [bbiClose]

        self.settingsView = SizPropertyTableView(frame: .zero, style: .grouped)
        self.settingsView.deselectAfterSelectedRow = true
        
        let secInfo = SizPropertyTableSection(title: "情報", rows: [
            TextCell(label: "バージョン", attrs: [
                .value {
                    "\(SizApplication.shortVersion).\(SizApplication.buildVersion)"
                },
            ]),
            TextCell(label: "使い方", attrs: [
                .selected { i in
                    ManualViewController.push(to: self.navigationController!)
                },
            ]),
        ])
        
        let secBackup = SizPropertyTableSection(title: "バックアップ", rows: [
            TextCell(label: "バックアップ", attrs: [
                .created { cell, i in
                    let cell = TextCell.cellView(cell)
                    cell.accessoryType = .none
                },
                .labelColor(.tintColor),
                .value {
                    self.lastBackupText
                },
                .selected { i in
                    self.confirmBackupNow()
                },
            ]),
            ButtonCell(label: "復元", attrs: [
                .created { cell, i in
                    let cell = ButtonCell.cellView(cell)
                    var content = cell.contentConfiguration as! UIListContentConfiguration
                    content.textProperties.color = .systemRed
                    content.textProperties.alignment = .center
                    cell.contentConfiguration = content
                },
                .selected { i in
                    self.tryRestore()
                },
            ]),
        ])
        self.settingsView.setDataSource([secInfo, secBackup])
        
        self.view.addSubview(self.settingsView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.settingsView.setMatchTo(parent: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataManager.shared.backupIfNeed()
        refreshLastBackupDate()
    }
    
    func confirmBackupNow() {
        Alert(title: "今すぐバックアップ", message: "バックアップを行いますか？", buttons: [
            .cancel("キャンセル"),
            .default("アップアップ", action: {
                if DataManager.shared.backup() {
                    self.refreshLastBackupDate()
                }
            })
        ]).show(from: self)
    }
    
    @objc
    func closeThis() {
        self.dismiss(animated: true, completion: nil)
        self.onNeedReload?()
    }
    
    func refreshLastBackupDate() {
        let fmt = DateFormatter()
        fmt.calendar = .standard
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        DispatchQueue.main.async {
            var result = DataManager.shared.syncBackupData()
            
            if result {
                if let url = iCloudBackupUrl,
                    let modiDate = try? FileManager.default.attributesOfItem(atPath: url.path)[.modificationDate] as? Date
                {
                    self.lastBackupText = fmt.string(from: modiDate)
                }
                else {
                    result = false
                }
            }
            
            if !result {
                self.lastBackupText = "無し"
            }
            
            self.settingsView.reloadData()
        }
    }
    
    func tryRestore() {
        ActionSheet(title: "復元", message: "最後のバックアップ内容で復元します。\n現在の全てのデータは消えます。", buttons: [
            .destrucive("復元") {
                if DataManager.shared.restore() {
                    Alert(message: "復元しました", buttons: [ .default("OK") ]).show(from: self)
                }
                else {
                    self.showError(title: "復元失敗", message: "バックアップが無いか\n途中でエラーが発生しました。", focusTo: nil)
                }
            },
            .cancel("キャンセル")
        ]).show(from: self)
    }
    
}
