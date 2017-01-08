//
//  ExpensesViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2016/12/31.
//
//

import UIKit
import RxSwift

class ExpensesViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var table: UITableView!
    private let bag: DisposeBag = DisposeBag()
    private var viewModel: ExpensesViewModel!

    var sessionId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // ナビゲーションバー表示
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "交通費"
            navigationItem.hidesBackButton = true
        }

        table.delegate = self
        table.dataSource = self

        viewModel = ExpensesViewModel(sessionId: sessionId)

        viewModel.reloadTrigger
            .asObservable()
            .subscribeNext {
                self.table.reloadData()
            }
            .addDisposableTo(bag)

        viewModel.fetchTrigger.onNext(())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return viewModel.desitations.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //TODO カスタムセル
        //TODO セルビューモデル
        let cell: UITableViewCell = UITableViewCell()
        cell.textLabel!.text = viewModel.desitations[indexPath.row].name

        return cell
    }
}
