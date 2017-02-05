//
//  PeriodsViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/03.
//
//

import UIKit

class PeriodsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var table: UITableView!
    private var periods: [Period]!

    // TODO 表示する月の設定　過去半年分くらい？
    // TODO UITableViewDelegate実装
    override func viewDidLoad() {
        super.viewDidLoad()

        table.delegate = self
        table.dataSource = self

        // TODO カスタムセル必要？
        table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

        periods = Period.pastHalfYear()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return periods.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // TODO 表示書式調整
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel!.text = periods[indexPath.row].description

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO 選択した月をExpensesViewControllerに連携
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func tapButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
