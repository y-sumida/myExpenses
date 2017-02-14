//
//  TextFieldCell.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/23.
//
//

import UIKit
import RxSwift

class TextFieldCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var title: UILabel!

    var placeholder: String = "" {
        didSet {
            textField.placeholder = placeholder
        }
    }
    var keyboardType: UIKeyboardType = .Default {
        didSet {
            textField.keyboardType = keyboardType
        }
    }

    private var bag: DisposeBag!
    var bindValue: Variable<String>! {
        didSet {
            bag = DisposeBag()
            bindValue.asObservable()
                .filter {
                    // 料金の初期値0の場合にプレースホルダー表示する。別クラスにしたほうがいいかも。
                    $0 != "0"
                }
                .bindTo(self.textField.rx_text)
                .addDisposableTo(bag)
            self.textField.rx_text
                .bindTo(self.bindValue)
                .addDisposableTo(bag)
        }
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        textField.delegate = self
        textField.borderStyle = .None
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = .None
        textField.autocorrectionType = .No

        // Doneボタン
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, self.frame.size.width, 40.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(self.closeKeyboard))
        toolbar.items = [flexible, done]
        textField.inputAccessoryView = toolbar

        self.selectionStyle = .None

    }

    override func prepareForReuse() {
        placeholder = ""
        title.text = ""
        textField.text = ""
        keyboardType = .Default
        textField.userInteractionEnabled = true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }

    func closeKeyboard() {
       textField.resignFirstResponder()
    }
}
