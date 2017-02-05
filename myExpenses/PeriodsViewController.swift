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

    // TODO 表示する月の設定　過去半年分くらい？
    // TODO UITableViewDelegate実装
    override func viewDidLoad() {
        super.viewDidLoad()

        table.delegate = self
        table.dataSource = self

        // TODO カスタムセル必要？
        table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

        Period.pastHalfYear()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6 // TODO とりあえず半年分
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //TODO 年月表示
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel!.text = "\(indexPath.row)"

        return cell
    }
    
    @IBAction func tapButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
