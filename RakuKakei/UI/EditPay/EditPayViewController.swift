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
    
    static func present(from: UIViewController, item: Household, onChanged: ((_ item: Household?)->Void)? = nil) {
        let vc = EditPayViewController()
        vc.item = item.clone()
        vc.mode = .edit
        vc.oriDate = item.date
        vc.onChanged = onChanged
        
        present(vc, from: from)
    }
    
    static func present(from: UIViewController, addNew date: SizYearMonthDay, onChanged: ((_ item: Household?)->Void)? = nil) {
        let vc = EditPayViewController()
        vc.item = Household()
        vc.item.date = date
        vc.mode = .addNew
        vc.onChanged = onChanged
        
        present(vc, from: from)
    }
    
    private static func present(_ vc: EditPayViewController, from: UIViewController) {
        let navi = UINavigationController()
        navi.pushViewController(vc, animated: false)
        navi.modalTransitionStyle = .coverVertical
        navi.modalPresentationStyle = .fullScreen
        from.present(navi, animated: true, completion: nil)
    }
    
    @IBOutlet weak var btnSave: UIButton!
    @IBAction func btnSaveTap(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        closeWithSave()
        sender.isUserInteractionEnabled = true
    }
    
    var tableView: SizPropertyTableView!
    var editPrice: UITextField!
    var editMemo: UITextField!
    
    var onChanged: ((_ item: Household?)->Void)? = nil
    
    // MARK: - Member Vars
    
    /// 支出情報
    var item: Household!
    /// 予算情報
    var budget: Budget?
    
    private var oriDate: SizYearMonthDay?
    private var fisrtLoad = true
    
    enum Mode { case addNew, edit }
    var mode: Mode = .addNew
    
    let DATE_FMT = DateFormatter()
    
    // MARK: - UI Events

    override func viewDidLoad() {
        assert(self.item.date != nil)
        
        super.viewDidLoad()
        title = "\(Strings.SPENDING)\(self.mode == .addNew ? Strings.ADD : Strings.EDIT)"
        
        self.budget = DataManager.shared.getBudget(by: item)
        self.DATE_FMT.calendar = .standard
        self.DATE_FMT.dateFormat = DATE_FMT_FOR_DISPLAY
        
        self.tableView = SizPropertyTableView(frame: .zero, style: .grouped)
        self.tableView.deselectAfterSelectedRow = true
        setupEditTableView()
        self.view.addSubview(self.tableView)
        
        let bbiCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeWithoutSave))
        let bbiSave = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(closeWithSave))
        self.navigationItem.leftBarButtonItems = [bbiCancel]
        self.navigationItem.rightBarButtonItems = [bbiSave]
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        [
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.btnSave.topAnchor),
        ].forEach { $0.isActive = true }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.fisrtLoad {
            self.editPrice?.becomeFirstResponder()
            self.fisrtLoad = false
        }
    }
    
    // MARK: - Functions

    private func setupEditTableView() {
        let sec_base = TableSection(rows: [
            // 金額
            EditTextCell(label: Strings.LABEL_AMOUNT, attrs: [
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
                .value {
                    self.item.price <= 0 ? "" : "\(self.item.price)"
                },
                .valueChanged { value in
                    let data = value as? String ?? "0"
                    self.item.price = Int(data) ?? 0
                },
                .hint("0"),
            ]),
            // 予算
            TextCell(label: Strings.BUDGET, attrs: [
                .created { cell, _ in
                    let cell = TextCell.cellView(cell)
                    cell.valueViewWidth = HALF_WIDTH
                },
                .value {
                    self.budget?.shortLabel ?? Strings.NONE
                },
                .selected { i in
                    self.showBudgets()
                },
            ]),
            // 日付
            TextCell(label: Strings.DATE, attrs: [
                .created { cell, _ in
                    let cell = TextCell.cellView(cell)
                    cell.valueViewWidth = FILL_WIDTH
                },
                .value {
                    guard self.item.date.day > 0, let date = self.item.date?.toDate() else {
                        return Strings.NONE
                    }
                    return self.DATE_FMT.string(from: date)
                },
                .selected { i in
                    self.showDateSelector()
                },
            ]),
        ])
        
        let sec_memo_title: String? = self.mode == .edit ? Strings.MEMO : nil
        let sec_memo = TableSection(title: sec_memo_title, rows: [
            EditTextCell(attrs: [
                .created { cell, _ in
                    let cell = EditTextCell.cellView(cell)
                    cell.maxLength = 100
                    cell.valueViewWidth = FILL_WIDTH
                    cell.textField.clearButtonMode = .whileEditing
                    cell.textField.returnKeyType = .done
                    cell.delegate = self
                    self.editMemo = cell.textField
                },
                .value {
                    self.item.memo
                },
                .valueChanged { value in
                    self.item.memo = (value as? String ?? "").trimmingCharacters(in: .whitespaces)
                },
                .hint(Strings.MEMO),
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
            
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .right)
            self.tableView.endUpdates()
            
            if self.mode == .addNew {
                let currPrice = Int(self.editPrice.text ?? "0") ?? 0
                if currPrice > 0 {
                    self.editMemo.becomeFirstResponder()
                }
                else {
                    self.editPrice.becomeFirstResponder()
                }
            }
        }
    }
    
    func showDateSelector() {
        SelectDayViewController.push(to: self.navigationController!, date: self.item.date) { day in
            self.item.date = SizYearMonthDay(self.item.date.year, self.item.date.month, day)
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .right)
            self.tableView.endUpdates()
        }
    }
    
    func tryRemove() {
        Alert(message: Strings.Message.CONFIRM_REMOVE, buttons: [
            .destrucive(Strings.REMOVE, action: {
                DataManager.shared.removeHousehold(self.item)
                self.closeWithoutSave()
                self.onChanged?(nil)
            }),
            .cancel(Strings.CANCEL, action: nil),
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
        
        if self.mode == .addNew {
            self.item.seq = DataManager.shared.getLastHouseholdSeq(date: self.item.date) + 1
            assert(self.item.seq >= 0)
        }
        else {
            // DATEもPKなので、DATEが変わった場合に対処する
            if self.mode == .edit && self.oriDate != self.item.date {
                assert(self.oriDate != nil)
                let oriSeq = self.item.seq
                DataManager.shared.removeHousehold(date: self.oriDate!, seq: oriSeq)
                
                self.item.seq = DataManager.shared.getLastHouseholdSeq(date: self.item.date) + 1
            }
        }
        
        DataManager.shared.writeHousehold(self.item)
        self.onChanged?(self.item)
        dismiss(animated: true)
    }
    
    func checkInputs() -> Bool {
        self.editPrice.endEditing(true)
        self.editMemo.endEditing(true)
        
        guard self.item.price > 0 else {
            showError(message: Strings.Error.EMPTY_AMOUNT, focusTo: self.editPrice)
            return false
        }
        
        guard self.item.budget_seq > 0 else {
            Alert(message: Strings.Error.NO_SELECT_BUDGET, buttons: [
                .default(Strings.OK, action: {
                    self.showBudgets()
                })
            ]).show(from: self)
            return false
        }
        
        guard self.item.date != nil, self.item.date.day > 0 else {
            Alert(message: Strings.Error.NO_SELECT_DATE, buttons: [
                .default(Strings.OK, action: {
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
