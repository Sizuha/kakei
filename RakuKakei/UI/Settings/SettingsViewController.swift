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
    private var lastBackupText = Strings.NONE
    private var onNeedReload: (()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.SETTINGS
        
        let bbiClose = UIBarButtonItem(title: Strings.CLOSE, style: .plain, target: self, action: #selector(closeThis))
        self.navigationItem.leftBarButtonItems = [bbiClose]

        self.settingsView = SizPropertyTableView(frame: .zero, style: .grouped)
        self.settingsView.deselectAfterSelectedRow = true
        
        let secInfo = SizPropertyTableSection(title: Strings.INFO, rows: [
            TextCell(label: Strings.VERSION, attrs: [
                .value {
                    "\(SizApplication.shortVersion).\(SizApplication.buildVersion)"
                },
            ]),
            TextCell(label: Strings.HOW_TO_USE, attrs: [
                .selected { i in
                    ManualViewController.push(to: self.navigationController!)
                },
            ]),
        ])
        
        let secBackup = SizPropertyTableSection(title: Strings.BACKUP, rows: [
            TextCell(label: Strings.BACKUP, attrs: [
                .created { cell, i in
                    let cell = TextCell.cellView(cell)
                    cell.valueViewWidth = FILL_WIDTH
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
            ButtonCell(label: Strings.RESTORE, attrs: [
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
        Alert(title: "今すぐバックアップ", message: Strings.Message.CONFIRM_BACKUP, buttons: [
            .cancel(Strings.CANCEL),
            .default(Strings.BACKUP, action: {
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
                self.lastBackupText = Strings.NONE
            }
            
            self.settingsView.reloadData()
        }
    }
    
    func tryRestore() {
        ActionSheet(title: Strings.RESTORE, message: Strings.Message.CONFIRM_RESTORE, buttons: [
            .destrucive(Strings.RESTORE) {
                if DataManager.shared.restore() {
                    Alert(message: "復元しました", buttons: [ .default(Strings.OK) ]).show(from: self)
                }
                else {
                    self.showError(title: Strings.Error.FAIL_RESTORE, message: Strings.Error.FAIL_RESTORE_MSG, focusTo: nil)
                }
            },
            .cancel(Strings.CANCEL)
        ]).show(from: self)
    }
    
}
