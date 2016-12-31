//
//  LoginViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2016/12/31.
//
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // ナビゲーションバー非表示
        if let navi = navigationController {
            navi.setNavigationBarHidden(true, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapRegisterButton(sender: AnyObject) {
        let vc:RegisterViewController = UIStoryboard(name: "Register", bundle: nil).instantiateViewControllerWithIdentifier("RegisterViewController") as! RegisterViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

