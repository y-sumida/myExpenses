//
//  PeriodSelectViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/03.
//
//

import UIKit

class PeriodSelectViewController: UIViewController {

    // TODO 表示する月の設定　過去半年分くらい？
    // TODO UITableViewDelegate実装
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tapButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
