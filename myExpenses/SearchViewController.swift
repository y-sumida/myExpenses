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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.showsCancelButton = true

        self.searchBar.rx_searchButtonClicked.asObservable()
            .subscribeNext {
                print("search")
                // TODO 検索APIコール
                // TODO 検索結果をtableに反映
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
