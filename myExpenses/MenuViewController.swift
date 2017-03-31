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
        let sharedInstance: UserDefaults = UserDefaults.standard
        guard let mail: String = sharedInstance.string(forKey: "email") else { return "" }

        return mail
    }

    var logoutHandler: (() -> Void) = {_ in }

    override func viewDidLoad() {
        super.viewDidLoad()

        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        // ログアウト処理
        viewModel.result.asObservable()
            .skip(1) //初期値読み飛ばし
            .bindNext {[weak self] _ in
                guard let `self` = self else { return }
                self.dismiss(animated: true, completion: {self.logoutHandler()})
            }
            .addDisposableTo(bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = self.email
        }
        else {
            cell.textLabel?.text = "ログアウト"
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            viewModel.logoutTrigger.onNext(())
        }
    }
    @IBAction func tapMarginArea(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
