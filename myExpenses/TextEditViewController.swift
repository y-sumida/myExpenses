//
//  TextEditViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/21.
//
//

import UIKit
import RxSwift

class TextEditViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var textField: UITextField!

    private let bag: DisposeBag = DisposeBag()

    // TODO どうやってもとの編集画面に入力内容を連携するか検討
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.rx_text.asObservable()
            .subscribeNext { text in
                self.doneButton.enabled = !text.isEmpty
            }
            .addDisposableTo(bag)

        closeButton.rx_tap.asObservable()
            .subscribeNext {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(bag)

        doneButton.rx_tap.asObservable()
            .subscribeNext {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
