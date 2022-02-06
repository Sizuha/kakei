//
//  MainViewController.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2020/08/08.
//  Copyright © 2020 Sizuha. All rights reserved.
//

import UIKit
import SizUI

class MainViewController: UIViewController {
    
    /// 設定ボタン
    @IBOutlet weak var btnSettings: UIButton!
    
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
    
    ///（予算）編集ボタン
    @IBOutlet weak var btnEditBudget: UIButton!
    @IBAction func btnEditBudgetTap(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        setEditMode(budgetTable: !self.editMode)
        sender.isUserInteractionEnabled = true
    }
    
    /// 予算一覧
    var tblBudgetList: BudgetTableView!
    
    /// 予算追加ボタン
    @IBOutlet weak var btnAddBudget: UIButton!
    @IBAction func btnAddBudgetTap(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        addNewBudget()
        sender.isUserInteractionEnabled = true
    }
    
    ///「前月から引き継ぎ」ボタン
    @IBOutlet weak var btnImportBudget: UIButton!
    @IBAction func btnImportBudgetTap(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        Alert(title: "警告", message: "現在編集中の内容は削除されます", buttons: [
            .cancel("キャンセル"),
            .destrucive("OK") {
                DataManager.shared.copyBudgets(from: self.currentDate.prevMonth(), to: self.currentDate)
                self.loadBudgets(date: self.currentDate)
                
                self.setEditMode(budgetTable: false, animated: false)
                self.refresh_budgetTab()
            }
        ]).show(from: self)
        sender.isUserInteractionEnabled = true
    }
    
    /// 「すべて削除」ボタン
    @IBOutlet weak var btnClearBudgets: UIButton!
    @IBAction func btnRemoveAllTap(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        Alert(title: "警告", message: "\(self.currentDate.year)年\(self.currentDate.month)月の予算を\nすべて削除します", buttons: [
            .cancel("キャンセル"),
            .destrucive("OK") {
                DataManager.shared.removeBudgets(yearMonth: self.currentDate)
                self.budges.removeAll()
                
                self.setEditMode(budgetTable: false, animated: false)
                self.refresh_budgetTab()
            }
        ]).show(from: self)
        sender.isUserInteractionEnabled = true
    }
    
    // MARK: 支出タブ
    ///「支出」タブ
    @IBOutlet weak var btnPay: UIButton!
    @IBAction func btnPayTap(_ sender: UIButton) {
        guard self.currentTab != .pay else { return }
        change(tab: .pay)
    }
    /// 支出画面
    @IBOutlet weak var groupPay: UIView!
    
    @IBOutlet weak var budgetList: UICollectionView!
    
    /// 支出一覧
    var tblHoousehold: HouseholdTable!
        
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
    /// 画面を準備してから、初めてのデータ読み取りか？
    var firstLoad = true
    
    var editMode = false
    var budges: [Budget] = []
    
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
        
        self.yearMonthPicker = YearMonthPicker()
        self.yearMonthPicker.onSelected = { date in
            self.refresh_byDate(date)
        }
        self.yearMonthPicker.addTo(self)
    
        self.tblBudgetList = BudgetTableView(frame: .zero, style: .plain)
        self.tblBudgetList.tableFooterView = UIView(frame: .zero)
        self.tblBudgetList.ownerViewController = self
        self.tblBudgetList.onItemRemoved = {
            self.budges = self.tblBudgetList.items
            if self.tblBudgetList.items.isEmpty {
                self.refresh_budgetTab()
            }
        }
        self.groupBudget.addSubview(self.tblBudgetList)
        
        self.tblHoousehold = HouseholdTable(frame: .zero, style: .plain)
        self.tblHoousehold.tableFooterView = UIView(frame: .zero)
        self.tblHoousehold.ownerViewController = self
        self.groupPay.addSubview(self.tblHoousehold)
        
        BudgetCell.register(to: self.budgetList)
        self.budgetList.dataSource = self
        self.budgetList.delegate = self
        
        self.budges.reserveCapacity(MAX_BUDGET_COUNT)
        change(tab: .pay, animation: false)
        self.firstLoad = true
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

        
        // IBで、自動レイアウトが設定されているが、
        // iPhoneをバックグラウンドで横の状態 --> 縦にするとレイアウトが崩れる為
        // ここで再び設定する
        
        self.btnClearBudgets.translatesAutoresizingMaskIntoConstraints = false
        self.btnClearBudgets.leftAnchor.constraint(equalTo: self.groupBottom.leftAnchor, constant: 8).isActive = true
        self.btnClearBudgets.rightAnchor.constraint(equalTo: self.groupBottom.rightAnchor, constant: -8).isActive = true
        self.btnClearBudgets.bottomAnchor.constraint(equalTo: self.groupBottom.topAnchor, constant: -12).isActive = true
        self.btnClearBudgets.heightAnchor.constraint(equalToConstant: self.btnClearBudgets.frame.height) .isActive = true
        
        self.btnImportBudget.translatesAutoresizingMaskIntoConstraints = false
        self.btnImportBudget.leftAnchor.constraint(equalTo: self.groupBottom.leftAnchor, constant: 8).isActive = true
        self.btnImportBudget.rightAnchor.constraint(equalTo: self.groupBottom.rightAnchor, constant: -8).isActive = true
        self.btnImportBudget.bottomAnchor.constraint(equalTo: self.btnClearBudgets.topAnchor, constant: -8*3).isActive = true
        self.btnImportBudget.heightAnchor.constraint(equalToConstant: self.btnImportBudget.frame.height) .isActive = true

        self.btnAddBudget.translatesAutoresizingMaskIntoConstraints = false
        self.btnAddBudget.leftAnchor.constraint(equalTo: self.groupBottom.leftAnchor, constant: 8).isActive = true
        self.btnAddBudget.rightAnchor.constraint(equalTo: self.groupBottom.rightAnchor, constant: -8).isActive = true
        self.btnAddBudget.bottomAnchor.constraint(equalTo: self.btnImportBudget.topAnchor, constant: -8).isActive = true
        self.btnAddBudget.heightAnchor.constraint(equalToConstant: self.btnAddBudget.frame.height) .isActive = true


        self.tblBudgetList.translatesAutoresizingMaskIntoConstraints = false
        self.tblBudgetList.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.tblBudgetList.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.tblBudgetList.topAnchor.constraint(equalTo: self.lblBudgetTitle.bottomAnchor, constant: 10).isActive = true
        self.tblBudgetList.bottomAnchor.constraint(equalTo: self.btnAddBudget.topAnchor, constant: -8).isActive = true
        
        self.tblHoousehold.translatesAutoresizingMaskIntoConstraints = false
        self.tblHoousehold.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.tblHoousehold.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.tblHoousehold.topAnchor.constraint(equalTo: self.budgetList.bottomAnchor, constant: 10).isActive = true
        self.tblHoousehold.bottomAnchor.constraint(equalTo: self.groupPay.bottomAnchor, constant: 0).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.firstLoad {
            self.firstLoad = false
        }
        else {
            refresh_byDate()
        }
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
        refresh_byDate()
    }
    
    func movePrevMonth() {
        self.currentDate.movePrevMonth()
        self.setEditMode(budgetTable: false, animated: false)
        refresh_byDate()
    }
    
    func moveToday() {
        self.setEditMode(budgetTable: false, animated: false)
        refresh_byDate(.now)
    }
    
    @objc
    func showSelectYearMonth() {
        self.btnMonth.isUserInteractionEnabled = false

        let now = YearMonth.now
        let selYear = now.year - MIN_YEAR
        let selMonth = now.month - 1
        self.yearMonthPicker.selectedRows = [selYear, selMonth]
        self.yearMonthPicker.show()
        
        self.btnMonth.isUserInteractionEnabled = true
    }
    
    func refresh_byDate(_ toDate: YearMonth? = nil) {
        if let date = toDate {
            self.currentDate = date
        }
        
        let now = YearMonth.now
        let min_year = MIN_YEAR
        let max_year = MAX_YEAR
        
        self.btnToday.isEnabled = self.currentDate != now
        self.btnPrevMonth.isEnabled = self.currentDate.year >= min_year || self.currentDate.month > 1
        self.btnNextMonth.isEnabled = self.currentDate.year < max_year || self.currentDate.year == max_year && self.currentDate.month < 12
        
        self.lblYear.text = String(format: "%d年", self.currentDate.year)
        self.btnMonth.text = String(format: "%d月", self.currentDate.month)
        
        loadBudgets(date: self.currentDate)
        switch self.currentTab! {
        case .budget:
            refresh_budgetTab()
            
        case .pay:
            refresh_payTab()
        }
        
        self.firstLoad = false
    }
    
    /// 「予算」タブの更新
    private func refresh_budgetTab() {
        self.lblBudgetTitle.text = String(format:"%d年%d月の予算", self.currentDate.year, self.currentDate.month)
        
        self.tblBudgetList.items.removeAll()
        self.tblBudgetList.items = self.budges
        
        self.tblBudgetList.isHidden = self.tblBudgetList.items.isEmpty
        self.btnEditBudget.isHidden = self.tblBudgetList.items.isEmpty
        
        if self.tblBudgetList.isHidden {
            setEditMode(budgetTable: false, animated: false)
        }
        else {
            self.tblBudgetList.reloadData()
        }
        
        let enableAdd = self.tblBudgetList.items.count < MAX_BUDGET_COUNT
        self.btnAdd.isEnabled = enableAdd
        self.btnAddBudget.isEnabled = enableAdd
        
        self.btnClearBudgets.isEnabled = !self.tblBudgetList.items.isEmpty
        
        let prevMonth = self.currentDate.prevMonth()
        let prevMonthItems = DataManager.shared.loadBudgetList(yearMonth: prevMonth)
        self.btnImportBudget.isEnabled = !prevMonthItems.isEmpty
    }
    
    /// 「支出」タブの更新
    private func refresh_payTab() {
        self.btnAdd.isEnabled = !self.budges.isEmpty
        
        let payItems = DataManager.shared.loadPayList(yearMonth: self.currentDate)
        self.tblHoousehold.setDataSource(items: payItems)
        self.tblHoousehold.reloadData()
        self.tblHoousehold.isHidden = payItems.isEmpty
        
        for budget in self.budges {
            budget.used = DataManager.shared.getTotalAmount(yearMonth: self.currentDate, budget: budget)
        }
        self.budgetList.reloadData()
    }
    
    func addNewBudget() {
        EditBudgetViewController.present(from: self, addNew: self.currentDate)
    }
    
    func setEditMode(budgetTable flag: Bool, animated: Bool = true) {
        self.editMode = flag
        if flag {
            if self.tblBudgetList.isEditing {
                // Swipeメニューが表示されている場合、これも編集モードとして認識されるので
                // 先に編集モードを終了する
                self.tblBudgetList.setEditing(false, animated: false)
            }
            self.tblBudgetList.setEditing(true, animated: animated)
            btnEditBudget.setTitle("完了", for: .normal)
            btnEditBudget.setImage(IMG_NULL, for: .normal)
        }
        else {
            self.tblBudgetList.setEditing(false, animated: animated)
            btnEditBudget.setTitle("", for: .normal)
            btnEditBudget.setImage(IMG_EDIT_SEQ, for: .normal)
        }
    }
    
    // MARK: - データ読み取り
    
    func loadBudgets(date: YearMonth) {
        let items = DataManager.shared.loadBudgetList(yearMonth: date)
        self.budges.removeAll()
        self.budges.append(contentsOf: items)
    }
    
}

// MARK: - CollectionView関連

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.budges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: BudgetCell.resId, for: indexPath)
        cell.makeRoundCornor(13)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? BudgetCell else { return }
        
        //print("collectionView cell at \(indexPath)")
        let budget = self.budges[indexPath.row]
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
