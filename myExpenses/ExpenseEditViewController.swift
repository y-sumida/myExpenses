//
//  ExpenseEditViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/18.
//
//

import UIKit

enum ExpenseEditSections: Int {
    case Date = 0
    case Destination
    case Transport
    case Interval
    case Fare
    case Memo

    var title: String {
        switch self {
        case Date:
            return "日付"
        case Destination:
            return "外出先"
        case Transport:
            return "交通機関"
        case Interval:
            return "区間"
        case Fare:
            return "料金"
        case Memo:
            return "備考"
        }
    }
}

class ExpenseEditViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak private var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // ナビゲーションバー表示
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "外出先編集"
            navigationItem.hidesBackButton = false
        }

        table.delegate = self
        table.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // TODO　セクションごとのタイトル
        return 6
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ExpenseEditSections(rawValue: section)?.title
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODO セクションごとの行数
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
