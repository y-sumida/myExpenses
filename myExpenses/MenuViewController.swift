//
//  MenuViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/19.
//
//

import UIKit
import RxSwift

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var table: UITableView!

    private let bag: DisposeBag = DisposeBag()
    private let viewModel: LogoutViewModel = LogoutViewModel()

    private var email: String {
        let sharedInstance: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        guard let mail: String = sharedInstance.stringForKey("email") else { return "" }

        return mail
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // ナビゲーションバー表示
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "設定"
        }

        table.delegate = self
        table.dataSource = self
        table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

        // ログアウト処理
        // TODO もっとかんたんにできそう
        viewModel.result.asObservable()
            .skip(1) //初期値読み飛ばし
            .subscribeNext {[weak self] _ in
                guard let `self` = self else { return }
                self.navigationController?.popToRootViewControllerAnimated(false)
            }
            .addDisposableTo(bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = self.email
        }
        else {
            cell.textLabel?.text = "ログアウト"
        }

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            viewModel.logoutTrigger.onNext(())
        }
    }
}
