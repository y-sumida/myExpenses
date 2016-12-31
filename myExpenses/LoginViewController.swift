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

class LoginViewController: UIViewController {
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
        viewModel.resultTrigger
            .subscribe(
                onNext: {
                    print("ok")
                    let vc:ExpensesViewController = UIStoryboard(name: "Expenses", bundle: nil).instantiateViewControllerWithIdentifier("ExpensesViewController") as! ExpensesViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                },
                onError: { (error: ErrorType) -> Void in
                    print("ng")
                }
            )
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

