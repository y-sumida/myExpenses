//
//  ExpensesViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2016/12/31.
//
//

import UIKit

class ExpensesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // ナビゲーションバー表示
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "交通費"
            navigationItem.hidesBackButton = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
