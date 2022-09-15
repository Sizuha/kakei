//
//  SelectDayViewController.swift
//  RakuKakei
//
//  Created by ILKYOUNG HWANG on 2022/02/24.
//  Copyright © 2022 Sizuha. All rights reserved.
//

import UIKit
import SizUtil

class SelectDayViewController: UIViewController {
    
    static func push(to: UINavigationController, date: SizYearMonthDay, onSelected: @escaping (_ day: Int)->Void) {
        let vc = SelectDayViewController()
        vc.date = date
        vc.onSelected = onSelected
        to.pushViewController(vc, animated: true)
    }
    
    var tableView: UITableView!

    private var date: SizYearMonthDay!
    private var yearMonth: YearMonth!
    private var days: [Int] = []
    private var onSelected: ((_ day: Int)->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.TITLE_DATE(year: self.date.year, month: self.date.month)
        
        self.yearMonth = YearMonth(year: self.date.year, month: self.date.month)
        self.days = (1...self.yearMonth.lastDayInMonth).map { $0 }
        
        self.tableView = UITableView(frame: .zero, style: .plain)
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "day_cell")

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
        
        guard self.date.day > 0 else { return }
        let ip = IndexPath(row: self.date.day-1, section: 0)
        self.tableView.scrollToRow(at: ip, at: .middle, animated: true)
    }

}

extension SelectDayViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.yearMonth.lastDayInMonth
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "day_cell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isSelected = indexPath.row == self.date.day-1
        cell.backgroundColor = isSelected ? .secondarySystemFill : nil
        cell.accessoryType = isSelected ? .checkmark : .none

        var content = cell.defaultContentConfiguration()
        let day = self.days[indexPath.row]
        let date = SizYearMonthDay(self.yearMonth.year, self.yearMonth.month, day)
        let weekday = Calendar.standard.component(.weekday, from: date.toDate()!)
        
        content.text = Strings.DAY_AND_WEEK(day: day, weekday: weekday)
        content.textProperties.color = getWeekdayColor(weekday)
        cell.contentConfiguration = content
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.onSelected?(indexPath.row+1)
        popSelf()
    }
    
}
