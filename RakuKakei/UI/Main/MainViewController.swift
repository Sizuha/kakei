//
//  MainViewController.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2020/08/08.
//  Copyright © 2020 Sizuha. All rights reserved.
//

import UIKit
import SizUI
import SizUtil

class MainViewController: BaseViewController {
    
    /// Actionボタン
    @IBOutlet weak var btnMoreActions: UIButton!
    
    /// 編集（並び変更）ボタン
    @IBOutlet weak var btnMoveUpDown: UIButton!
    @IBAction func btnMoveUpDownTap(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        
        switch self.currentTab {
        case .budget: setEditMode(budgetTable: !self.editMode)
        case .pay: setEditMode(householdTable: !self.editMode)
        default: break
        }
        
        sender.isUserInteractionEnabled = true
    }
    
    /// 選択マーカー
    @IBOutlet weak var selectionBar: UIView!
    
    /// 上部のライン
    @IBOutlet weak var borderTop: UIView!
    
    // MARK: 予算タブ
    ///「予算」タブ
    @IBOutlet weak var btnBudget: UIButton!
    @IBAction func btnBudgetTap(_ sender: UIButton) {
        guard self.currentTab != .budget else { return }
        change(tab: .budget)
    }
    
    /// 予算タブの画面
    @IBOutlet weak var groupBudget: UIView!
    
    /// 予算タップのタイトル
    @IBOutlet weak var lblBudgetTitle: UILabel!
    
    @IBOutlet weak var btnEmptyBudgetTap: UIButton!
    
    /// 予算一覧
    var tblBudgetList: BudgetTableView!
    
    // MARK: 支出タブ
    ///「支出」タブ
    @IBOutlet weak var btnPay: UIButton!
    @IBAction func btnPayTap(_ sender: UIButton) {
        guard self.currentTab != .pay else { return }
        change(tab: .pay)
    }
    /// 支出画面
    @IBOutlet weak var groupPay: UIView!
    
    /// 支出画面内の予算一覧
    @IBOutlet weak var budgetList: UICollectionView!
    
    /// 支出一覧
    var tblHousehold: HouseholdTable!
    
    @IBOutlet weak var lblEmptyPayMsg: UILabel!
    
        
    // MARK: 下部ツルバー
    /// 下部のツルバー
    @IBOutlet weak var groupBottom: UIView!

    /// 年表示
    @IBOutlet weak var lblYear: UILabel!
    
    /// 前の月へボタン
    @IBOutlet weak var btnPrevMonth: UIButton!
    @IBAction func btnPrevMonthTap(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        movePrevMonth()
        sender.isUserInteractionEnabled = true
    }
    
    /// 次の月へボタン
    @IBOutlet weak var btnNextMonth: UIButton!
    @IBAction func btnNextMonthTap(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        moveNextMonth()
        sender.isUserInteractionEnabled = true
    }
    
    /// 月ボタン
    @IBOutlet weak var btnMonth: UILabel!
    
    /// 今月ボタン
    @IBOutlet weak var btnToday: UIButton!
    @IBAction func btnTodayTap(_ sender: UIView) {
        sender.isUserInteractionEnabled = false
        moveToday()
        sender.isUserInteractionEnabled = true
    }

    /// 追加ボタン
    @IBOutlet weak var btnAdd: UIButton!
    @IBAction func btnAddTap(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        switch self.currentTab! {
        case .budget:
            addNewBudget()
            
        case .pay:
            addNewPay()
            break
        }
        sender.isUserInteractionEnabled = true
    }
    
    /// 年月選択UI
    var yearMonthPicker: YearMonthPicker!
    
    // MARK: - Member Vars
    
    enum Tab {
        case budget, pay
    }
    
    /// 現在のタブ
    private var currentTab: Tab! = nil
    /// 現在の年月
    var currentDate: YearMonth = .now
    
    var editMode = false
    var budgets: [Budget] = []
    
    private let IMG_EDIT_SEQ = UIImage(systemName: "arrow.up.arrow.down")
    private let IMG_NULL = UIImage()
    
    // MARK: - UI Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for btn in [self.btnBudget!, self.btnPay!] {
            btn.setTitleColor(.secondaryLabel, for: .normal)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        }
        
        let onMonthTap = UITapGestureRecognizer(target: self, action: #selector(showSelectYearMonth))
        self.btnMonth.addGestureRecognizer(onMonthTap)
        
        let onEmptyPayTap = UITapGestureRecognizer(target: self, action: #selector(showBudgetTab))
        self.lblEmptyPayMsg.addGestureRecognizer(onEmptyPayTap)
        
        addFadeView()
        
        self.yearMonthPicker = YearMonthPicker()
        self.yearMonthPicker.onHidden = {
            self.fadeIn()
        }
        self.yearMonthPicker.onSelected = { date in
            self.refresh_byDate(date)
        }
        self.yearMonthPicker.addTo(self)
    
        self.tblBudgetList = BudgetTableView(frame: .zero, style: .plain)
        self.tblBudgetList.tableFooterView = UIView(frame: .zero)
        self.tblBudgetList.ownerViewController = self
        self.tblBudgetList.onItemRemoved = {
            self.budgets = self.tblBudgetList.items
            if self.tblBudgetList.items.isEmpty {
                self.refresh_budgetTab()
            }
        }
        self.tblBudgetList.onItemChanged = {
            self.refresh_byDate()
        }
        self.groupBudget.addSubview(self.tblBudgetList)
        
        self.tblHousehold = HouseholdTable(frame: .zero, style: .plain)
        self.tblHousehold.tableFooterView = UIView(frame: .zero)
        self.tblHousehold.ownerViewController = self
        self.tblHousehold.onItemRemoved = {
            self.refresh_payTab()
        }
        self.tblHousehold.onItemChanged = { item in
            self.refresh_payTab()
            self.tblHousehold.scrollTo(item)
        }
        self.groupPay.addSubview(self.tblHousehold)
        
        BudgetCell.register(to: self.budgetList)
        self.budgetList.dataSource = self
        self.budgetList.delegate = self
        
        self.budgets.reserveCapacity(MAX_BUDGET_COUNT)
        change(tab: .pay, animation: false)
    }
    
    // MARK: Layout
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    
        self.groupBudget.translatesAutoresizingMaskIntoConstraints = false
        self.groupBudget.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.groupBudget.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.groupBudget.topAnchor.constraint(equalTo: self.borderTop.bottomAnchor, constant: 20).isActive = true
        self.groupBudget.bottomAnchor.constraint(equalTo: self.groupBottom.topAnchor, constant: 0).isActive = true
        
        self.groupPay.translatesAutoresizingMaskIntoConstraints = false
        self.groupPay.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.groupPay.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.groupPay.topAnchor.constraint(equalTo: self.borderTop.bottomAnchor, constant: 10).isActive = true
        self.groupPay.bottomAnchor.constraint(equalTo: self.groupBottom.topAnchor, constant: 0).isActive = true
        
        self.tblBudgetList.translatesAutoresizingMaskIntoConstraints = false
        self.tblBudgetList.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.tblBudgetList.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.tblBudgetList.topAnchor.constraint(equalTo: self.lblBudgetTitle.bottomAnchor, constant: 10).isActive = true
        self.tblBudgetList.bottomAnchor.constraint(equalTo: self.groupBottom.topAnchor, constant: -8).isActive = true
        
        self.tblHousehold.translatesAutoresizingMaskIntoConstraints = false
        self.tblHousehold.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.tblHousehold.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.tblHousehold.topAnchor.constraint(equalTo: self.budgetList.bottomAnchor, constant: 10).isActive = true
        self.tblHousehold.bottomAnchor.constraint(equalTo: self.groupPay.bottomAnchor, constant: 0).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        DispatchQueue.global().async {
//            DataManager.shared.backupIfNeed()
//        }
    }
    
    
    func setupMenuItems() -> UIMenu {
        var menuItems = [UIMenuElement]()
        
        if self.currentTab == .budget {
            makeActionButtons_forBudget(to: &menuItems)
        }
        else if self.currentTab == .pay {
            if !self.budgets.isEmpty {
                // Add: 支出登録
                menuItems.append(UIAction(title: Strings.ADD_PAY, image: Images.IC_ADD_NEW) { action in
                    self.addNewPay()
                })
            }
            
            if !self.tblHousehold.items.isEmpty {
                // Add: 全て削除
                let actRemoveAll = UIAction(
                    title: Strings.REMOVE_ALL,
                    image: Images.IC_REMOVE,
                    attributes: .destructive
                ) { action in
                    self.confrimRemoveAllHouseholds()
                }
                menuItems.append(actRemoveAll)
            }
        }
        
        // Add: 設定
        let menuSettings = UIMenu(options: .displayInline, children: [
            UIAction(title: Strings.SETTINGS, image: Images.IC_SETTINGS) { action in
                self.showSettings()
            }
        ])
        
        menuItems.append(menuSettings)
        /*menuItems.append(UIAction(title: Strings.SETTINGS, image: Images.IC_SETTINGS) { action in
            self.showSettings()
        })*/
        
        let menu = UIMenu(options: .displayInline, children: menuItems)
        return menu
    }
    
    // MARK: - Functions
    
    /// タップ変更
    /// - Parameters:
    ///   - tab: 表示するタプ
    ///   - animation: アニメーション効果の有無
    func change(tab: Tab, animation: Bool = true) {
        self.currentTab = tab
        self.groupBudget.isHidden = tab != .budget
        self.groupPay.isHidden = tab != .pay
        
        let selBtn: UIButton
        switch tab {
        case .pay:
            selBtn = self.btnPay
            setEditMode(budgetTable: false, animated: false)
            
        case .budget:
            selBtn = self.btnBudget
            setEditMode(householdTable: false, animated: false)
        }
        
        let fromSelFrame = self.selectionBar.frame
        let toSelFrame = CGRect(
            x: selBtn.frame.minX,
            y: fromSelFrame.minY,
            width: fromSelFrame.width,
            height: fromSelFrame.height
        )

        if animation {
            UIView.animate(withDuration: 0.2) {
                self.selectionBar.frame = toSelFrame
            }
        }
        else {
            self.selectionBar.frame = toSelFrame
        }

        for btn in [self.btnBudget!, self.btnPay!] {
            if btn == selBtn {
                btn.tintColor = .label
                continue
            }
            
            btn.tintColor = .secondaryLabel
        }
        
        refresh_byDate()
    }
    
    func moveNextMonth() {
        self.currentDate.moveNextMonth()
        self.setEditMode(budgetTable: false, animated: false)
        self.setEditMode(householdTable: false, animated: false)
        refresh_byDate()
    }
    
    func movePrevMonth() {
        self.currentDate.movePrevMonth()
        self.setEditMode(budgetTable: false, animated: false)
        self.setEditMode(householdTable: false, animated: false)
        refresh_byDate()
    }
    
    func moveToday() {
        self.setEditMode(budgetTable: false, animated: false)
        self.setEditMode(householdTable: false, animated: false)
        refresh_byDate(.now)
    }
    
    @objc
    func showSelectYearMonth() {
        self.btnMonth.isUserInteractionEnabled = false

        let now = YearMonth.now
        let selYear = now.year - MIN_YEAR
        let selMonth = now.month - 1
        
        fadeOut()
        
        self.yearMonthPicker.selectedRows = [selYear, selMonth]
        self.yearMonthPicker.show()
        
        self.btnMonth.isUserInteractionEnabled = true
    }
    
    override func onFadeViewTap() {
        self.yearMonthPicker?.cancel()
    }
    
    func refresh_byDate(_ toDate: YearMonth? = nil) {
        if let date = toDate {
            self.currentDate = date
        }
        
        let now = YearMonth.now
        let min_year = MIN_YEAR
        let max_year = MAX_YEAR
        
        self.btnToday.isEnabled = self.currentDate != now
        self.btnPrevMonth.isEnabled = self.currentDate.year > min_year || self.currentDate.year == min_year && self.currentDate.month > 1
        self.btnNextMonth.isEnabled = self.currentDate.year < max_year || self.currentDate.year == max_year && self.currentDate.month < 12
        
        self.lblYear.text = Strings.YEAR(self.currentDate.year)
        self.btnMonth.text = Strings.MONTH(self.currentDate.month)
        
        loadBudgets(date: self.currentDate)
        switch self.currentTab! {
        case .budget:
            refresh_budgetTab()
            
        case .pay:
            refresh_payTab()
        }
    }
    
    /// 「予算」タブの更新
    private func refresh_budgetTab() {
        self.lblBudgetTitle.text =
            Strings.TITLE_BUDGET_OF(year: self.currentDate.year, month: self.currentDate.month)
        
        self.tblBudgetList.items.removeAll()
        self.tblBudgetList.items = self.budgets
        for item in self.budgets {
            item.used = DataManager.shared.getTotalAmount(yearMonth: self.currentDate, budget: item)
        }
        
        self.tblBudgetList.isHidden = self.tblBudgetList.items.isEmpty
        self.btnMoveUpDown.isHidden = self.tblBudgetList.isHidden
        
        if self.tblBudgetList.isHidden {
            setEditMode(budgetTable: false, animated: false)
            
            // 予算登録の案内メッセージをタップした時のアクション
            var menuItems_forBudget = [UIMenuElement]()
            makeActionButtons_forBudget(to: &menuItems_forBudget)
            self.btnEmptyBudgetTap.menu = UIMenu(title: Strings.ADD_BUDGET, children: menuItems_forBudget)
            self.btnEmptyBudgetTap.showsMenuAsPrimaryAction = true
        }
        else {
            self.tblBudgetList.reloadData()
        }
        
        let enableAdd = self.budgets.count < MAX_BUDGET_COUNT
        self.btnAdd.isEnabled = enableAdd
        
        self.btnMoreActions.menu = setupMenuItems()
        self.btnMoreActions.showsMenuAsPrimaryAction = true
    }
    
    /// 「支出」タブの更新
    private func refresh_payTab() {
        self.btnAdd.isEnabled = !self.budgets.isEmpty
        
        let payItems = DataManager.shared.loadHouseholdList(yearMonth: self.currentDate)
        self.btnMoveUpDown.isHidden = payItems.isEmpty

        self.tblHousehold.setDataSource(items: payItems)
        self.tblHousehold.reloadData()
        self.tblHousehold.isHidden = payItems.isEmpty
        
        if payItems.isEmpty {
            if self.budgets.isEmpty {
                self.lblEmptyPayMsg.text = Strings.Message.EMPTY_BUDGET
                self.lblEmptyPayMsg.textColor = .link
                self.lblEmptyPayMsg.isUserInteractionEnabled = true
            }
            else {
                self.lblEmptyPayMsg.text = Strings.Message.EMPTY_PAY_LIST
                self.lblEmptyPayMsg.textColor = .secondaryLabel
                self.lblEmptyPayMsg.isUserInteractionEnabled = false
            }
        }

        for budget in self.budgets {
            budget.used = DataManager.shared.getTotalAmount(yearMonth: self.currentDate, budget: budget)
        }
        self.budgetList.reloadData()
        
        self.btnMoreActions.menu = setupMenuItems()
        self.btnMoreActions.showsMenuAsPrimaryAction = true
    }
    
    private func makeActionButtons_forBudget(to menuItems: inout [UIMenuElement]) {
        if self.budgets.count < MAX_BUDGET_COUNT {
            menuItems.append(UIAction(title: Strings.ADD_BUDGET, image: Images.IC_ADD_NEW) { _ in
                self.addNewBudget()
            })
        }
        
        let prevMonth = self.currentDate.prevMonth()
        if DataManager.shared.countBudgetList(yearMonth: prevMonth) > 0 {
            menuItems.append(
                UIAction(
                    title: Strings.IMPORT_FROM_PREV_MONTH,
                    image: Images.IC_IMPORT,
                    attributes: self.budgets.isEmpty ? [] : .destructive
                ) { _ in
                    self.confirmImportBudget()
                }
            )
        }
        
        if !self.budgets.isEmpty {
            menuItems.append(
                UIAction(
                    title: Strings.REMOVE_ALL,
                    image: Images.IC_REMOVE,
                    attributes: .destructive
                ) { _ in
                    self.confrimRemoveAllBugdets()
                }
            )
        }
    }
        
    func showSettings() {
        SettingsViewController.present(from: self) {
            self.refresh_byDate()
        }
    }
    
    @objc
    func showBudgetTab() {
        change(tab: .budget)
    }
    
    // MARK: 予算処理
    
    func loadBudgets(date: YearMonth) {
        let items = DataManager.shared.loadBudgetList(yearMonth: date)
        self.budgets.removeAll()
        self.budgets.append(contentsOf: items)
    }

    func addNewBudget() {
        EditBudgetViewController.present(from: self, addNew: self.currentDate) {
            self.refresh_byDate()
        }
    }
    
    /// 前月から引き継ぎ（予算）
    func confirmImportBudget() {
        func importBudget() {
            DataManager.shared.copyBudgets(from: self.currentDate.prevMonth(), to: self.currentDate)
            loadBudgets(date: self.currentDate)
            
            setEditMode(budgetTable: false, animated: false)
            refresh_budgetTab()
        }
        
        if self.budgets.isEmpty {
            importBudget()
            return
        }
        
        Alert(title: Strings.WARNING, message: Strings.Message.ALERT_CELAR, buttons: [
            .cancel(Strings.CANCEL),
            .destrucive(Strings.OK) { importBudget() }
        ]).show(from: self)
    }
    
    /// 現在の月の予算を全て削除
    func confrimRemoveAllBugdets() {
        Alert(
            title: Strings.WARNING,
            message: Strings.Message.CONFIRM_REMOVE_BUDGETS_IN(year: self.currentDate.year, month: self.currentDate.month),
            buttons: [
                .cancel(Strings.CANCEL),
                .destrucive(Strings.REMOVE) {
                    DataManager.shared.removeBudgets(yearMonth: self.currentDate)
                    self.budgets.removeAll()
                
                    self.setEditMode(budgetTable: false, animated: false)
                    self.refresh_budgetTab()
                }
            ]
        ).show(from: self)
    }
    
    func setEditMode(budgetTable flag: Bool, animated: Bool = true) {
        setEditMode(tableView: self.tblBudgetList, flag: flag, animated: animated)
    }
    
    func setEditMode(householdTable flag: Bool, animated: Bool = true) {
        setEditMode(tableView: self.tblHousehold, flag: flag, animated: animated)
    }
    
    private func setEditMode(tableView: UITableView, flag: Bool, animated: Bool) {
        self.editMode = flag
        if flag {
            if tableView.isEditing {
                // Swipeメニューが表示されている場合、これも編集モードとして認識されるので
                // 先に編集モードを終了する
                tableView.setEditing(false, animated: false)
            }
            tableView.setEditing(true, animated: animated)
        }
        else {
            tableView.setEditing(false, animated: animated)
        }
    }

    // MARK: 支出処理
    
    func addNewPay() {
        let today = SizYearMonthDay.now
        let date = self.currentDate.year == today.year && self.currentDate.month == today.month
            ? today
            : SizYearMonthDay(self.currentDate.year, self.currentDate.month, 0)
        
        EditPayViewController.present(from: self, addNew: date) { item in
            self.refresh_payTab()
            if let item = item {
                self.tblHousehold.scrollTo(item)
            }
        }
    }
    
    /// 現在の月の支出を全て削除
    func confrimRemoveAllHouseholds() {
        Alert(
            title: Strings.WARNING,
            message: Strings.Message.CONFIRM_REMOVE_HOUSEHOLDS_IN(year: self.currentDate.year, month: self.currentDate.month),
            buttons: [
                .cancel(Strings.CANCEL),
                .destrucive(Strings.REMOVE) {
                    DataManager.shared.removeHouseholds(yearMonth: self.currentDate)
                    self.refresh_payTab()
                }
            ]
        ).show(from: self)
    }

    
}

// MARK: - CollectionView関連

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.budgets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: BudgetCell.resId, for: indexPath)
        cell.makeRoundCornor(13)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? BudgetCell else { return }
        
        //print("collectionView cell at \(indexPath)")
        let budget = self.budgets[indexPath.row]
        cell.refresh(budget: budget)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let cnt = collectionView.numberOfItems(inSection: 0)
        return centerItemsInCollectionView(cellWidth: 50, numberOfItems: Double(cnt), spaceBetweenCell: 10, collectionView: collectionView)
    }
    
    private func centerItemsInCollectionView(cellWidth: Double, numberOfItems: Double, spaceBetweenCell: Double, collectionView: UICollectionView) -> UIEdgeInsets {
        let totalWidth = cellWidth * numberOfItems
        let totalSpacingWidth = spaceBetweenCell * (numberOfItems - 1)
        let leftInset = (collectionView.frame.width - CGFloat(totalWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
}
