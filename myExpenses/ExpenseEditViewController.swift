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

    var rows: Int {
        switch self {
        case Date, .Destination, .Fare, .Memo:
            return 1
        case Transport:
            return 6
        case Interval:
            return 2
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

        let nib = UINib(nibName: "TransportSelectCell", bundle: nil)
        table.registerNib(nib, forCellReuseIdentifier: "transportCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 6
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ExpenseEditSections(rawValue: section)?.title
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (ExpenseEditSections(rawValue: section)?.rows)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case ExpenseEditSections.Transport.rawValue:
            // TODO 交通機関ごとのラベル
            let cell: TransportSelectCell = tableView.dequeueReusableCellWithIdentifier("transportCell") as! TransportSelectCell
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO 各セルごとの処理実装
        switch indexPath.section {
        case ExpenseEditSections.Destination.rawValue:
            showTextEditView(ExpenseEditSections.Destination.title)
        default:
            break
        }
    }

    private func showTextEditView(title: String) {
        let vc:TextEditViewController = UIStoryboard(name: "ExpenseEdit", bundle: nil).instantiateViewControllerWithIdentifier("TextEditViewController") as! TextEditViewController
        vc.inputItem = title
        vc.modalPresentationStyle = .OverCurrentContext
        vc.modalTransitionStyle = .CoverVertical
        presentViewController(vc, animated: true, completion: nil)
    }
}
