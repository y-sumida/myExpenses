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
    private var header: ExpensesHeaderView!
    private var footer: ExpensesFooterView!

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
        let nib = UINib(nibName: "ExpenseCell", bundle: nil)
        table.registerNib(nib, forCellReuseIdentifier: "cell")

        viewModel = ExpensesViewModel(sessionId: sessionId)

        viewModel.reloadTrigger
            .asObservable()
            .subscribeNext {
                self.table.reloadData()
            }
            .addDisposableTo(bag)

        let width: CGFloat = UIScreen.mainScreen().bounds.size.width
        header = ExpensesHeaderView(frame: CGRectMake(0, 0, width, 40))
        footer = ExpensesFooterView(frame: CGRectMake(0, 0, width, 40))

        viewModel.fareTotal.asObservable()
            .bindTo(header.fareTotal.rx_text)
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
        let cell: ExpenseCell = tableView.dequeueReusableCellWithIdentifier("cell") as! ExpenseCell
        cell.viewModel = ExpenseCellViewModel(model: viewModel.desitations[indexPath.row])

        return cell
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return header.frame.size.height
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footer.frame.size.height
    }

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footer
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            viewModel.desitations.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
}
