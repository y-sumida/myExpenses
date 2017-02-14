//
//  SearchViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/13.
//
//

import UIKit
import RxSwift

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var table: UITableView!

    private let bag: DisposeBag = DisposeBag()
    private var viewModel: ExpensesViewModel = ExpensesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.showsCancelButton = true
        self.searchBar.becomeFirstResponder() //検索窓にフォーカス

        table.delegate = self
        table.dataSource = self
        let nib = UINib(nibName: "ExpenseCell", bundle: nil)
        table.registerNib(nib, forCellReuseIdentifier: "cell")

        self.searchBar.rx_searchButtonClicked.asObservable()
            .subscribeNext {
                self.viewModel.searchExpenses(self.searchBar.text!)
            }
            .addDisposableTo(bag)

        self.searchBar.rx_cancelButtonClicked.asObservable()
            .subscribeNext {
                self.searchBar.resignFirstResponder()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(bag)

        viewModel.reloadTrigger
            .asObservable()
            .subscribeNext {
                self.table.reloadData()
                if self.viewModel.expenses.isNotEmpty {
                    self.searchBar.resignFirstResponder()
                }
            }
            .addDisposableTo(bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.expenses.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ExpenseCell = tableView.dequeueReusableCellWithIdentifier("cell") as! ExpenseCell
        cell.viewModel = ExpenseCellViewModel(model: viewModel.expenses[indexPath.row])

        return cell
    }
}
