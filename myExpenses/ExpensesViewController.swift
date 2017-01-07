//
//  ExpensesViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2016/12/31.
//
//

import UIKit
import RxSwift

class ExpensesViewController: UIViewController {
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

        viewModel = ExpensesViewModel(sessionId: sessionId)
        viewModel.fetchTrigger.onNext(())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
