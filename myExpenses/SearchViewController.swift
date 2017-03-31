//
//  SearchViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/13.
//
//

import UIKit
import RxSwift

//TODO 検索履歴

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
        table.register(nib, forCellReuseIdentifier: "cell")

        self.searchBar.rx.searchButtonClicked.asDriver()
            .drive(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.searchExpenses(self.searchBar.text!)
            })
            .addDisposableTo(bag)

        self.searchBar.rx.cancelButtonClicked.asDriver()
            .drive(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.searchBar.resignFirstResponder()
                self.dismiss(animated: true, completion: nil)
            })
            .addDisposableTo(bag)

        self.searchBar.rx.text.asDriver()
            .drive(onNext: { text in
               print(text ?? "")
            })
            .addDisposableTo(bag)

        viewModel.reloadTrigger.asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.table.reloadData()
                if self.viewModel.expenses.isNotEmpty {
                    self.searchBar.resignFirstResponder()
                }
            })
            .addDisposableTo(bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.expenses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ExpenseCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ExpenseCell
        cell.viewModel = ExpenseCellViewModel(model: viewModel.expenses[indexPath.row])

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO 選択した内容を遷移元に連携
        self.dismiss(animated: true, completion: nil)
    }
}
