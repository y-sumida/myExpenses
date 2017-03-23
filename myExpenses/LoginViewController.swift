//
//  LoginViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2016/12/31.
//
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController, ShowDialog {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    fileprivate let bag: DisposeBag = DisposeBag()
    fileprivate let viewModel: LoginViewModel = LoginViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        let sharedInstance: UserDefaults = UserDefaults.standard
        if let _ = sharedInstance.string(forKey: "sessionId") {
            // セッションIDが保存してあったらログイン画面をスキップ
            // TODO ログインのviewDidLoadでよい？AppDelegateにおいたほうがいい？
            self.showExpensesView(false)
        }

        // サジェスト無効化
        email.autocapitalizationType = .none
        email.autocorrectionType = .no
        // キーボード指定
        email.keyboardType = .emailAddress

        // bind
        email.rx.text
            .bindNext { string in
                self.viewModel.email.value = string!
            }
            .addDisposableTo(bag)
        password.rx.text
            .bindNext { string in
                self.viewModel.password.value = string!
            }
            .addDisposableTo(bag)

        Observable
            .combineLatest(
                email.rx.text.asObservable(),
            password.rx.text.asObservable()) { c in c }
            .bindNext { (email, password) in
                self.loginButton.isEnabled = (email?.isNotEmpty)! && (password?.isNotEmpty)!
            }
            .addDisposableTo(bag)

        loginButton.rx.tap
            .bindNext {
                self.viewModel.loginTrigger.onNext(())
            }
            .addDisposableTo(bag)
        viewModel.result.asObservable()
            .skip(1) //初期値読み飛ばし
            .bindNext {error in
                let result = error as! APIResult

                if result.code == APIResultCode.Success {
                    self.showExpensesView(true)
                }
                else {
                    self.showErrorDialog(result)
                }
            }
            .addDisposableTo(bag)
    }

    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
        // ナビゲーションバー非表示
        if let navi = navigationController {
            navi.setNavigationBarHidden(true, animated: true)
        }
        // フォームクリア
        // TODO Rxでボタンdisableにする方法
        email.text = ""
        password.text = ""
        loginButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapRegisterButton(_ sender: AnyObject) {
        let vc:RegisterViewController = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    fileprivate func showExpensesView(_ animated: Bool) {
        let vc:ExpensesViewController = UIStoryboard(name: "Expenses", bundle: nil).instantiateViewController(withIdentifier: "ExpensesViewController") as! ExpensesViewController
        self.navigationController?.pushViewController(vc, animated: animated)
    }
}

