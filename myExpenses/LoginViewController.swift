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

class LoginViewController: UIViewController, showAPIErrorDialog {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    private let bag: DisposeBag = DisposeBag()
    private let viewModel: LoginViewModel = LoginViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // ナビゲーションバー非表示
        if let navi = navigationController {
            navi.setNavigationBarHidden(true, animated: true)
        }

        // bind
        email.rx_text
            .bindTo(viewModel.email)
            .addDisposableTo(bag)
        password.rx_text
            .bindTo(viewModel.password)
            .addDisposableTo(bag)
        loginButton.rx_tap.subscribeNext {
            self.viewModel.loginTrigger.onNext(())
            }
            .addDisposableTo(bag)
        viewModel.result.asObservable()
            .skip(1) //初期値読み飛ばし
            .subscribeNext {error in
                let result = error as! APIResult

                if result.code == APIResultCode.Success.rawValue {
                    //TODO ログイン成功時にID/パスワードの保存
                    let vc:ExpensesViewController = UIStoryboard(name: "Expenses", bundle: nil).instantiateViewControllerWithIdentifier("ExpensesViewController") as! ExpensesViewController
                    vc.sessionId = result.sessionId
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    self.showErrorDialog(result)
                }
            }
            .addDisposableTo(bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapRegisterButton(sender: AnyObject) {
        let vc:RegisterViewController = UIStoryboard(name: "Register", bundle: nil).instantiateViewControllerWithIdentifier("RegisterViewController") as! RegisterViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

