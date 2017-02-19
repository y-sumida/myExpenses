//
//  MenuViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/19.
//
//

import UIKit

class MenuViewController: UIViewController {
    @IBOutlet weak var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // ナビゲーションバー表示
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "設定"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
