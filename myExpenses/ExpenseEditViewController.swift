//
//  ExpenseEditViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/18.
//
//

import UIKit

class ExpenseEditViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // ナビゲーションバー表示
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "外出先編集"
            navigationItem.hidesBackButton = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
