//
//  RegisterViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2016/12/31.
//
//

import UIKit
import RxSwift

class RegisterViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordCheck: UITextField!
    @IBOutlet weak var registerButton: UIButton!

    private let bag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // ナビゲーションバー表示
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "ユーザー登録"
        }

        // 全部入力するまでボタンdisable
        Observable
            .combineLatest(
                email.rx.text.asObservable(),
            password.rx.text.asObservable(),
            passwordCheck.rx.text.asObservable()) { c in c }
            .bindNext { [unowned self] (email, password, passwordCheck) in
                self.registerButton.isEnabled = (email?.isNotEmpty)! && (password?.isNotEmpty)! && (passwordCheck?.isNotEmpty)!
            }
            .addDisposableTo(bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
