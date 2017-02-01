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
    @IBOutlet weak var titleLabel: UILabel!

    private let bag: DisposeBag = DisposeBag()

    var inputItem: String = ""
    var keyboard: UIKeyboardType = .Default
    var bindValue: Variable<String>!

    // TODO どうやってもとの編集画面に入力内容を連携するか検討
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = inputItem
        textField.keyboardType = keyboard

        textField.rx_text.asObservable()
            .subscribeNext { text in
                self.doneButton.enabled = text.isNotEmpty
            }
            .addDisposableTo(bag)

        closeButton.rx_tap.asObservable()
            .subscribeNext {
                self.textField.endEditing(true)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(bag)

        doneButton.rx_tap.asObservable()
            .subscribeNext {
                self.textField.endEditing(true)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(bag)

        if let value: Variable<String> = bindValue {
            value.asObservable()
                .bindTo(self.textField.rx_text)
                .addDisposableTo(bag)
            self.textField.rx_text
                .bindTo(value)
                .addDisposableTo(bag)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
