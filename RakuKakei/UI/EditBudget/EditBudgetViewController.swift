//
//  EditBudgetViewController.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2021/12/23.
//  Copyright © 2021 Sizuha. All rights reserved.
//

import UIKit
import SizUI
import SizUtil

class EditBudgetViewController: UIViewController {
    
    static func present(from: UIViewController, edit budget: Budget, onChanged: (()->Void)? = nil) {
        let vc = EditBudgetViewController()
        vc.budget = budget
        vc.mode = .edit
        vc.onChanged = onChanged
        present(vc, from: from)
    }
    
    static func present(from: UIViewController, addNew date: YearMonth, onChanged: (()->Void)? = nil) {
        let dm = DataManager.shared
        
        let newItem = Budget()
        newItem.date = date
        newItem.seq = dm.getLastBudgetSeq(yearMonth: date) + 1
        newItem.displaySeq = dm.getLastBudgetDispSeq(yearMonth: date) + 1
        
        let vc = EditBudgetViewController()
        vc.budget = newItem
        vc.mode = .addNew
        vc.onChanged = onChanged
        present(vc, from: from)
    }
    
    private static func present(_ vc: EditBudgetViewController, from: UIViewController) {
        let navi = UINavigationController()
        navi.pushViewController(vc, animated: false)
        navi.modalTransitionStyle = .coverVertical
        navi.modalPresentationStyle = .fullScreen
        from.present(navi, animated: true, completion: nil)
    }
    
    var tableView: SizPropertyTableView!
    var editLabel: UITextField!
    var editAmount: UITextField!
    
    var onChanged: (()->Void)?
    
    // MARK: - Member Vars
    
    enum Mode { case edit, addNew }
    private var mode: Mode = .edit
    
    private var budget: Budget!
    
    // MARK: - UI Events

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(self.budget != nil)
        
        let titlePrefix = "\(Strings.BUDGET)\(self.mode == .addNew ? Strings.ADD : Strings.EDIT)"
        self.title = "\(titlePrefix)：\(self.budget.date.year)年\(self.budget.date.month)月"

        let bbiCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeWithoutSave))
        let bbiSave = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(closeWithSave))
        self.navigationItem.leftBarButtonItems = [bbiCancel]
        self.navigationItem.rightBarButtonItems = [bbiSave]
        
        self.tableView = SizPropertyTableView(frame: .zero, style: .grouped)
        self.tableView.deselectAfterSelectedRow = true
        setupEditTableView()
        self.view.addSubview(self.tableView)
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
        
        (self.mode == .edit
            ? self.editAmount
            : self.editLabel
        )?.becomeFirstResponder()
    }
    
    // MARK: - Functions
    
    private func setupEditTableView() {
        let sec_base = TableSection(rows: [
            // 予算名
            EditTextCell(label: Strings.BUDGET_TITLE, attrs: [
                .created { cell, _ in
                    let cell = EditTextCell.cellView(cell)
                    cell.maxLength = 10
                    cell.valueViewWidth = FILL_WIDTH
                    cell.textField.textAlignment = .right
                    cell.textField.clearButtonMode = .always
                    cell.textField.returnKeyType = .next
                    cell.delegate = self
                    self.editLabel = cell.textField
                },
                .value {
                    self.budget.label
                },
                .valueChanged { value in
                    let data = value as? String ?? ""
                    self.budget.label = data
                },
                .hint(Strings.Hint.BUDGET_TITLE),
            ]),
            // 予算（金額）
            EditTextCell(label: Strings.LABEL_BUDGET_AMOUNT, attrs: [
                .created { cell, _ in
                    let cell = EditTextCell.cellView(cell)
                    cell.maxLength = 4
                    cell.pattern = "^[0-9]*$"
                    cell.valueViewWidth = FILL_WIDTH
                    cell.textField.keyboardType = .numberPad
                    cell.textField.textAlignment = .right
                    cell.textField.clearButtonMode = .always
                    cell.delegate = self
                    self.editAmount = cell.textField
                },
                .value {
                    self.budget.amount > 0 ? "\(self.budget.amount)" : ""
                },
                .valueChanged { value in
                    let data = value as? String ?? ""
                    self.budget.amount = Int(data) ?? 0
                },
                .hint("0"),
            ]),
        ])
        
        let sec_buttons = TableSection(rows: [
            ButtonCell(label: Strings.REMOVE, attrs: [
                .tintColor(.systemRed),
                .created { cell, _ in
                    let cell = ButtonCell.cellView(cell)
                    var content = cell.contentConfiguration as! UIListContentConfiguration
                    content.textProperties.alignment = .center
                    cell.contentConfiguration = content
                },
                .selected { i in
                    self.tryRemove()
                }
            ])
        ])
        
        /*
        // ラベル色
        let color_list: [(String,UIColor)] = [
            ("● 基本", .label),
            ("● 赤", .systemRed),
            ("● 黄", .systemYellow),
            ("● 緑", .systemGreen),
        ]
        var color_rows: [SizPropertyTableRow] = []
        for i_color in color_list {
            let newCell = TextCell(label: i_color.0, attrs: [
                .created { cell, _ in
                    let cell = TextCell.cellView(cell)
                    cell.textLabel?.textColor = i_color.1
                },
            ])
            color_rows.append(newCell)
        }
        let sec_color = TableSection(title: "ラベル色", rows: color_rows)
         */
        
        self.tableView.setDataSource(self.mode == .addNew ? [sec_base] : [sec_base, sec_buttons])
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
        
        DataManager.shared.writeBudget(self.budget!)
        dismiss(animated: true)
        self.onChanged?()
    }
    
    // MARK: 入力チェック
    func checkInputs() -> Bool {
        [self.editLabel, self.editAmount].forEach {
            $0?.endEditing(true)
        }
        
        guard self.editLabel.text?.isEmpty == false else {
            showError(message: Strings.Error.EMPTY_BUDGET_NAME, focusTo: self.editLabel)
            return false
        }
        
        guard "^[0-9]{1,4}$".asPattern! == self.editAmount.text ?? "" else {
            showError(message: Strings.Error.EMPTY_BUDGET, focusTo: self.editAmount)
            return false
        }
        
        // わざと「0」を許可している
        let amount = Int(self.editAmount.text ?? "0") ?? 0
        guard amount >= 0 else {
            showError(message: Strings.Error.WRONG_BUDGET, focusTo: self.editAmount)
            return false
        }
        
        self.budget.label = self.editLabel.text!
        self.budget.amount = amount
        
        return true
    }

    func tryRemove() {
        SizUI.Alert(message: Strings.Message.CONFIRM_REMOVE, buttons: [
            .cancel(Strings.CANCEL),
            .destrucive(Strings.REMOVE, action: {
                _ = DataManager.shared.removeBudget(self.budget)
                self.closeWithoutSave()
                self.onChanged?()
            })
        ]).show(from: self)
    }
    
}

// MARK: - UITextField Delegate

extension EditBudgetViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.editLabel:
            self.editAmount.becomeFirstResponder()

        default: break
        }
        return true
    }
}
