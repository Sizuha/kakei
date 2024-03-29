//
//  HouseholdTable.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2021/12/30.
//  Copyright © 2021 Sizuha. All rights reserved.
//

import UIKit
import SizUtil
import SizUI

class HouseholdTable: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    /// [日: 支出リスト]
    var items: [Int:[Household]] = [:]
    
    private var yearMonth: SizYearMonth!
    private var days: [Int] = []
    
    var ownerViewController: UIViewController!
    var onItemRemoved: (()->Void)?
    var onItemChanged: ((_ item: Household)->Void)?

    func setDataSource(items from: [Household]) {
        self.items.removeAll()
        self.days.removeAll()
        
        for h_item in from {
            let day = h_item.date.day
            if let _ = self.items[day] {
                self.items[day]!.append(h_item)
            }
            else {
                self.items[day] = [h_item]
            }
        }
        
        self.days.append(contentsOf: self.items.keys.sorted(by: { $0 > $1 }))
        
        if let first: Household = from.first {
            self.yearMonth = YearMonth(year: first.date.year, month: first.date.month)
        }
        else {
            self.yearMonth = nil
        }
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        HouseholdTableCell.register(to: self)
        self.dataSource = self
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func reloadData() {
        super.reloadData()
    }
    
    func getDayBy(section: Int) -> Int? {
        self.days[at: section]
    }
    
    func getHouseholdsBy(section index: Int) -> [Household] {
        guard let day = getDayBy(section: index) else { return [] }
        return self.items[day] ?? []
    }
    
    func scrollTo(_ item: Household, animated: Bool = true) {
        guard
            let i_sec = self.days.firstIndex(where: { $0 == item.date.day }),
            let dayItems = self.items[item.date.day],
            let i_row = dayItems.firstIndex(where: { $0.seq == item.seq })
        else { return }
        
        let ip = IndexPath(row: i_row, section: i_sec)
        self.scrollToRow(at: ip, at: .middle, animated: animated)
    }
    
    func scrollToBottom(animated: Bool = true) {
        guard let last = self.days.last else { return }
        
        let i_sec = self.days.count-1
        let i_row = (self.items[last]?.count ?? 1) - 1
        let ip = IndexPath(row: i_row, section: i_sec)
        self.scrollToRow(at: ip, at: .bottom, animated: animated)
    }
    
    func edit(item: Household) {
        EditPayViewController.present(from: self.ownerViewController, item: item) { item in
            if let item = item {
                self.onItemChanged?(item)
            }
            else {
                self.onItemRemoved?()
            }
        }
    }
    
    private func tryRemove(indexPath: IndexPath, handler: ((Bool)->Void)? = nil) {
        let households = getHouseholdsBy(section: indexPath.section)
        guard let item = households[at: indexPath.row] else { return }
        
        Alert(message: Strings.Message.CONFIRM_REMOVE, buttons: [
            .cancel(Strings.CANCEL, action: { handler?(false) }),
            .destrucive(Strings.REMOVE, action: {
                handler?(false)
                self.remove(item: item)
                self.onItemRemoved?()
            })
        ]).show(from: self.ownerViewController)
    }
    
    private func remove(item: Household) {
        DataManager.shared.removeHousehold(item)
    }
    
    // MARK: - Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.days.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let day = self.days[at: section] else { return nil }
        return "\(day)"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard
            let header = view as? UITableViewHeaderFooterView,
            let day = self.days[at: section]
        else { return }
        
        let ymd = SizYearMonthDay(self.yearMonth.year, self.yearMonth.month, day)
        let weekday = Calendar.standard.component(.weekday, from: ymd.toDate()!)
        
        var content = (header.contentConfiguration ?? header.defaultContentConfiguration()) as! UIListContentConfiguration
        content.text = "\(day)日（\(WEEKDAY_TEXT[weekday-1])）"
        content.textProperties.color = getWeekdayColor(weekday, defaultColor: .systemBrown)
        header.contentConfiguration = content
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        getHouseholdsBy(section: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        dequeueReusableCell(withIdentifier: HouseholdTableCell.resId, for: indexPath) as! HouseholdTableCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? HouseholdTableCell else { return }
        
        let households = getHouseholdsBy(section: indexPath.section)
        guard
            households.isEmpty == false,
            let item = households[at: indexPath.row]
        else { return }
        
        cell.refresh(item: item)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let households = getHouseholdsBy(section: indexPath.section)
        guard let item = households[at: indexPath.row] else { return }
        edit(item: item)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        Swipe(actions: [
            .destructive(image: UIImage(systemName: "trash"), action: { action, view, handler in
                self.tryRemove(indexPath: indexPath, handler: handler)
            })
        ])
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard
            !self.items.isEmpty
        else { assert(false); return }
        
        func updateDisplaySeqIn(day section: Int) {
            guard let targets = self.items[section] else { return }
            
            var dispSeq = 0
            for item in targets {
                item.displaySeq = dispSeq
                dispSeq += 1
            }
            
            DataManager.shared.updateHouseholdDisplaySeq(targets)
        }
        
        let households = getHouseholdsBy(section: sourceIndexPath.section)
        guard
            !households.isEmpty,
            let backup = households[at: sourceIndexPath.row],
            let from_day = getDayBy(section: sourceIndexPath.section),
            let to_day = getDayBy(section: destinationIndexPath.section)
        else { assert(false); return }
        
        if sourceIndexPath.section == destinationIndexPath.section {
            // 同じSection内の移動
            
            let from_i = sourceIndexPath.row
            let to_i = destinationIndexPath.row
            
            self.items[from_day]!.remove(at: from_i)
            self.items[from_day]!.insert(backup, at: to_i)
            updateDisplaySeqIn(day: from_day)
            return
        }
        
        // 違うSection間の移動
        let orgKey = (date: SizYearMonthDay(from: backup.date.toInt())!, seq: backup.seq)
        
        backup.date = SizYearMonthDay(backup.date.year, backup.date.month, to_day)
        backup.seq = DataManager.shared.getLastHouseholdSeq(date: backup.date) + 1
        
        self.items[from_day]!.remove(at: sourceIndexPath.row)
        if self.items[from_day]!.isEmpty {
            // 注意！
            // Section内が空になるが、意図的にSectionを削除しない。
            // 削除してしまうと、Section処理が面倒になることと、
            // 後で空になったSection(日)に行を移動できるメリットもある。
        }
        self.items[to_day]!.insert(backup, at: destinationIndexPath.row)
        
        DataManager.shared.removeHousehold(date: orgKey.date, seq: orgKey.seq)
        DataManager.shared.writeHousehold(backup)
        
        updateDisplaySeqIn(day: to_day)
    }
    
}
