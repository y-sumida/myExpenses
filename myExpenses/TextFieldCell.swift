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
    var keyboardType: UIKeyboardType = .default {
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
                .bindTo(self.textField.rx.text)
                .addDisposableTo(bag)
            self.textField.rx.text
                .bindNext { string in
                    self.bindValue.value = string!
                    
                }
                .addDisposableTo(bag)
        }
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        textField.delegate = self
        textField.borderStyle = .none
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no

        // Doneボタン
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 40.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.closeKeyboard))
        toolbar.items = [flexible, done]
        textField.inputAccessoryView = toolbar

        self.selectionStyle = .none

    }

    override func prepareForReuse() {
        placeholder = ""
        title.text = ""
        textField.text = ""
        keyboardType = .default
        textField.isUserInteractionEnabled = true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }

    func closeKeyboard() {
       textField.resignFirstResponder()
    }
}
