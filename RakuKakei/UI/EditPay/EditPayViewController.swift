//
//  EditPayViewController.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2022/02/07.
//  Copyright © 2022 Sizuha. All rights reserved.
//

import UIKit
import SizUI
import SizUtil

class EditPayViewController: UIViewController {
    
    static func present(from: UIViewController, item: Household) {
        let vc = EditPayViewController()
        vc.item = item
        vc.mode = .edit
        
        present(vc, from: from)
    }
    
    static func present(from: UIViewController, addNew date: SizYearMonthDay) {
        let vc = EditPayViewController()
        vc.item = Household()
        vc.item.date = date
        vc.mode = .addNew
        
        present(vc, from: from)
    }
    
    private static func present(_ vc: EditPayViewController, from: UIViewController) {
        let navi = UINavigationController()
        navi.pushViewController(vc, animated: false)
        navi.modalTransitionStyle = .coverVertical
        navi.modalPresentationStyle = .fullScreen
        from.present(navi, animated: true, completion: nil)
    }
    
    var tableView: SizPropertyTableView!
    var editPrice: UITextField!
    var editMemo: UITextField!
    
    // MARK: - Member Vars
    
    /// 支出情報
    var item: Household!
    /// 予算情報
    var budget: Budget?
    
    enum Mode { case addNew, edit }
    var mode: Mode = .addNew
    
    let DATE_FMT = DateFormatter()
    
    // MARK: - UI Events

    override func viewDidLoad() {
        assert(self.item.date != nil)
        
        super.viewDidLoad()
        title = "支出\(self.mode == .addNew ? "登録" : "編集")"
        
        self.budget = DataManager.shared.getBudget(by: item)
        self.DATE_FMT.calendar = .standard
        self.DATE_FMT.dateFormat = DATE_FMT_FOR_DISPLAY
        
        self.tableView = SizPropertyTableView(frame: .zero, style: .grouped)
        setupEditTableView()
        self.view.addSubview(self.tableView)
        
        let bbiCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeWithoutSave))
        let bbiSave = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(closeWithSave))
        self.navigationItem.leftBarButtonItems = [bbiCancel]
        self.navigationItem.rightBarButtonItems = [bbiSave]
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.setMatchTo(parent: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.editPrice?.becomeFirstResponder()
    }
    
    // MARK: - Functions

    private func setupEditTableView() {
        let sec_base = TableSection(rows: [
            EditTextCell(label: "金額（単位：千円）", attrs: [
                .created { cell, _ in
                    let cell = EditTextCell.cellView(cell)
                    cell.maxLength = 4
                    cell.pattern = "^[0-9]*$"
                    cell.valueViewWidth = HALF_WIDTH
                    cell.textField.keyboardType = .numberPad
                    cell.textField.textAlignment = .right
                    cell.textField.clearButtonMode = .always
                    cell.textField.returnKeyType = .done
                    cell.delegate = self
                    self.editPrice = cell.textField
                },
                .read {
                    self.item.price <= 0 ? "" : "\(self.item.price)"
                },
                .valueChanged { value in
                    let data = value as? String ?? "0"
                    self.item.price = Int(data) ?? 0
                },
                .hint("0"),
            ]),
            TextCell(label: "予算", attrs: [
                .created { cell, _ in
                    let cell = TextCell.cellView(cell)
                    cell.valueViewWidth = HALF_WIDTH
                },
                .read {
                    self.budget?.label ?? "無し"
                },
                .selected { i in
                    self.tableView.deselectRow(at: i, animated: true)
                    self.showBudgets()
                },
            ]),
            TextCell(label: "日付", attrs: [
                .created { cell, _ in
                    let cell = TextCell.cellView(cell)
                    cell.valueViewWidth = FILL_WIDTH
                },
                .read {
                    guard let date = self.item.date?.toDate() else {
                        return "無し"
                    }
                    return self.DATE_FMT.string(from: date)
                },
                .selected { i in
                    self.tableView.deselectRow(at: i, animated: true)
                    self.showDateSelector()
                },
            ]),
        ])
        
        let sec_memo = TableSection(rows: [
            EditTextCell(attrs: [
                .created { cell, _ in
                    let cell = EditTextCell.cellView(cell)
                    cell.maxLength = 100
                    cell.textField.clearButtonMode = .whileEditing
                    cell.textField.returnKeyType = .done
                    cell.delegate = self
                    self.editMemo = cell.textField
                },
                .read {
                    self.item.memo
                },
                .valueChanged { value in
                    self.item.memo = value as? String ?? ""
                },
                .hint("メモ"),
            ]),
        ])
        
        let sec_buttons = TableSection(rows: [
            ButtonCell(label: "削除", attrs: [
                .tintColor(.systemRed),
                .created { cell, _ in
                    let cell = ButtonCell.cellView(cell)
                    cell.textLabel?.textAlignment = .center
                },
                .selected { i in
                    self.tableView.deselectRow(at: i, animated: true)
                    self.tryRemove()
                }
            ])
        ])
        
        self.tableView.setDataSource(
            self.mode == .addNew ? [sec_base, sec_memo] : [sec_base, sec_memo, sec_buttons]
        )
    }
    
    func showBudgets() {
        let date = YearMonth(year: self.item.date.year, month: self.item.date.month)
        SelectBudgetViewController.push(
            to: self.navigationController!,
            date: date,
            preSelected: self.item.budget_seq
        ) { budget in
            self.item.budget_seq = budget.seq
            self.budget = budget
            self.tableView.reloadData()
        }
    }
    
    func showDateSelector() {
        SelectDayViewController.push(to: self.navigationController!, date: self.item.date) { day in
            self.item.date = SizYearMonthDay(self.item.date.year, self.item.date.month, day)
            self.tableView.reloadData()
        }
    }
    
    func tryRemove() {
        Alert(message: "削除しますか？", buttons: [
            .destrucive("削除", action: {
                DataManager.shared.removeHousehold(self.item)
                self.closeWithoutSave()
            }),
            .cancel("キャンセル", action: nil),
        ]).show(from: self)
    }
    
    @objc
    func closeWithoutSave() {
        dismiss(animated: true)
    }
    
    @objc
    func closeWithSave() {
        guard checkInputs() else {
            return
        }
        
        DataManager.shared.writeHousehold(self.item)
        dismiss(animated: true)
    }
    
    func checkInputs() -> Bool {
        self.editPrice.endEditing(true)
        self.editMemo.endEditing(true)
        
        guard self.item.price > 0 else {
            showError(message: "金額を入力してください", focusTo: self.editPrice)
            return false
        }
        
        guard self.item.budget_seq > 0 else {
            Alert(message: "予算を選択してください", buttons: [
                .default("OK", action: {
                    self.showBudgets()
                })
            ]).show(from: self)
            return false
        }
        
        guard self.item.date != nil else {
            Alert(message: "日付を選択してください", buttons: [
                .default("OK", action: {
                    self.showDateSelector()
                })
            ]).show(from: self)
            return false
        }
        
        return true
    }
    
}


// MARK: - UITextField Delegate

extension EditPayViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.editPrice:
            self.editPrice.endEditing(true)
            
        case self.editMemo:
            self.editMemo.endEditing(true)

        default: break
        }
        return true
    }
}
