//
//  SearchViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/13.
//
//

import UIKit
import RxSwift

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var table: UITableView!

    private let bag: DisposeBag = DisposeBag()
    private var viewModel: ExpensesViewModel = ExpensesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.showsCancelButton = true
        self.searchBar.becomeFirstResponder() //検索窓にフォーカス

        self.searchBar.rx_searchButtonClicked.asObservable()
            .subscribeNext {
                self.viewModel.searchExpenses(self.searchBar.text!)
                // TODO 検索結果をtableに反映
                self.searchBar.resignFirstResponder()
            }
            .addDisposableTo(bag)

        self.searchBar.rx_cancelButtonClicked.asObservable()
            .subscribeNext {
                self.searchBar.resignFirstResponder()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
