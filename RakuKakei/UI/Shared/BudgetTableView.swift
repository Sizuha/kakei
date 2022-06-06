//
//  BudgetTableView.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2021/12/23.
//  Copyright © 2021 Sizuha. All rights reserved.
//

import Foundation
import UIKit
import SizUI

class BudgetTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var items: [Budget] = []
    var ownerViewController: UIViewController!
    
    var onItemRemoved: (()->Void)?
    var onItemChanged: (()->Void)?
    
    /// 予算を編集可能
    var editable = true
    /// 予算の残りを表示
    var showRemain = false
    
    var onItemSelected: ((_ item: Budget)->Void)? = nil
    var selectedRow = -1
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        self.dataSource = self
        self.delegate = self
        
        BudgetTableViewCell.register(to: self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func edit(item: Budget) {
        // 編集画面で修正された内容に影響を受けない為。
        // 編集画面で明確に「保存」を行った時のみ、反映する必要がある。
        let copy = Budget(item)
        EditBudgetViewController.present(from: self.ownerViewController, edit: copy) {
            self.onItemChanged?()
        }
    }
    
    private func tryRemove(indexPath: IndexPath, handler: ((Bool)->Void)? = nil) {
        let item = self.items[indexPath.row]
        
        Alert(message: Strings.Message.CONFIRM_REMOVE, buttons: [
            .cancel(Strings.CANCEL, action: { handler?(false) }),
            .destrucive(Strings.REMOVE, action: {
                handler?(false)
                if self.remove(item: item) {
                    self.beginUpdates()
                    self.items.remove(at: indexPath.row)
                    self.deleteRows(at: [indexPath], with: .automatic)
                    self.endUpdates()
                    self.onItemRemoved?()
                }
            })
        ]).show(from: self.ownerViewController)
    }
    
    private func remove(item: Budget) -> Bool {
        DataManager.shared.removeBudget(item)
    }
    
    // MARK: UI Events
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        dequeueReusableCell(withIdentifier: BudgetTableViewCell.resId) as! BudgetTableViewCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? BudgetTableViewCell else { assert(false); return }
        let item = items[indexPath.row]
        cell.refresh(item: item, showRemain: self.showRemain)
        
        //cell.accessoryType = self.selectedRow == indexPath.row ? .checkmark : .none
        cell.backgroundColor = self.selectedRow == indexPath.row ? .secondarySystemFill : nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        
        if self.editable {
            edit(item: item)
        }
        else {
            onItemSelected?(item)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard self.editable else { return nil }
        
        return Swipe(actions: [
            .destructive(image: UIImage(systemName: "trash"), action: { action, view, handler in
                self.tryRemove(indexPath: indexPath, handler: handler)
            })
        ])
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard self.editable else { return }
        
        let from_i = sourceIndexPath.row
        let to_i = destinationIndexPath.row
        
        let backup = self.items[from_i]
        self.items.remove(at: from_i)
        self.items.insert(backup, at: to_i)
        
        var dispSeq = 0
        for item in self.items {
            item.displaySeq = dispSeq
            dispSeq += 1
        }
        
        DataManager.shared.updateBudgetDisplaySeq(self.items)
    }
    
}
