//
//  ExpenseEditViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/18.
//
//

import UIKit
import RxSwift

enum ExpenseEditSections: Int {
    case date = 0
    case destination
    case transport
    case interval
    case fare
    case memo
}

enum ExpenseEditType: Int {
    case text = 0
    case date
    case number
    case `switch`
    case datePicker
}

protocol ExpenseEditRow {
    associatedtype Element
    var placeholder: String { get }
    var type: ExpenseEditType { get }
    var bindValue: Variable<Element> { get }
}

struct ExpenseEditText: ExpenseEditRow {
    typealias Element = String
    var placeholder: String
    var type: ExpenseEditType
    var bindValue: Variable<Element>
}

struct ExpenseEditDate: ExpenseEditRow {
    typealias Element = Date
    var placeholder: String
    var type: ExpenseEditType
    var bindValue: Variable<Element>
}

struct ExpenseEditSwitch: ExpenseEditRow {
    typealias Element = Bool
    var placeholder: String
    var type: ExpenseEditType
    var bindValue: Variable<Element>
}

class ExpenseEditViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, ShowDialog {
    @IBOutlet weak fileprivate var table: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    fileprivate var isDatePickerOpen: Bool = false
    fileprivate let bag: DisposeBag = DisposeBag()

    var viewModel: ExpenseEditViewModel = ExpenseEditViewModel()
    var rowsInSection:[Array<Any>]!

    override func viewDidLoad() {
        super.viewDidLoad()

        rowsInSection = [
            [
                ExpenseEditText(placeholder: "日付", type: .date, bindValue: viewModel.dateAsString),
                ExpenseEditDate(placeholder: "", type: .datePicker, bindValue: viewModel.date)
            ],
            [
                ExpenseEditText(placeholder: "外出先", type: .text, bindValue: viewModel.destination),
            ],
            [
                ExpenseEditSwitch(placeholder: "JR", type: .switch, bindValue: viewModel.useJR),
                ExpenseEditSwitch(placeholder: "私鉄", type: .switch, bindValue: viewModel.usePrivate),
                ExpenseEditSwitch(placeholder: "地下鉄", type: .switch, bindValue: viewModel.useSubway),
                ExpenseEditSwitch(placeholder: "バス", type: .switch, bindValue: viewModel.useBus),
                ExpenseEditSwitch(placeholder: "高速", type: .switch, bindValue: viewModel.useHighway),
                ExpenseEditText(placeholder: "その他", type: .text, bindValue: viewModel.useOther),
            ],
            [
                ExpenseEditText(placeholder: "from", type: .text, bindValue: viewModel.from),
                ExpenseEditText(placeholder: "to", type: .text, bindValue: viewModel.to),
            ],
            [
                ExpenseEditText(placeholder: "料金", type: .number, bindValue: viewModel.fare),
            ],
            [
                ExpenseEditText(placeholder: "備考", type: .text, bindValue: viewModel.memo)
            ]
        ]

        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = 100

        let transportCell = UINib(nibName: "TransportSelectCell", bundle: nil)
        table.register(transportCell, forCellReuseIdentifier: "TransportSelectCell")
        let textFieldCell = UINib(nibName: "TextFieldCell", bundle: nil)
        table.register(textFieldCell, forCellReuseIdentifier: "TextFieldCell")
        let datePicerCell = UINib(nibName: "DatePickerCell", bundle: nil)
        table.register(datePicerCell, forCellReuseIdentifier: "DatePickerCell")

        // TODO 未入力時にDoneボタンdisable
        doneButton.rx.tap.asObservable()
            .bindNext { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.upsertExpense()
            }
            .addDisposableTo(bag)

        cancelButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                guard let `self` = self else { return }
                //self.navigationController?.popViewControllerAnimated(true)
                self.dismiss(animated: true, completion: nil)
            })
            .addDisposableTo(bag)

        viewModel.result.asObservable()
            .skip(1) //初期値読み飛ばし
            .bindNext { [weak self] error in
                guard let `self` = self else { return }
                let result = error as! APIResult
                // セッション切れの場合、ログイン画面へ戻す
                if result.code == APIResultCode.SessionError {
                    self.showCompleteDialog("セッションエラー") { _ in
                        // TODO これだと戻れなくなった
                        _ = self.navigationController?.popToRootViewController(animated: false)
                    }
                }
                else if result.code == APIResultCode.Success {
                    self.showCompleteDialog("送信完了") { _ in
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                else {
                    self.showErrorDialog(result)
                }
            }
            .addDisposableTo(bag)

        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow, object: nil)
            .bindNext { [ unowned self] notification in
                self.keyboardWillShow(notification)
            }
            .addDisposableTo(bag)

        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide, object: nil)
            .bindNext { [ unowned self] notification in
                self.keyboardWillHide(notification)
            }
            .addDisposableTo(bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return rowsInSection.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ExpenseEditSections(rawValue: section) == .date && !isDatePickerOpen {
                return 1
        }
        return rowsInSection[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rowsInSection[indexPath.section][indexPath.row]

        // TODO 変数名を適切なものに
        if let text = row as? ExpenseEditText {
            let cell: TextFieldCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell") as! TextFieldCell
            cell.title.text = text.placeholder
            cell.bindValue = text.bindValue
            if text.type == .number {
                cell.keyboardType = .numberPad
            }
            else if text.type == .date {
                cell.textField.isUserInteractionEnabled = false
            }
            return cell
        }

        if let sw = row as? ExpenseEditSwitch {
            let cell: TransportSelectCell = tableView.dequeueReusableCell(withIdentifier: "TransportSelectCell") as! TransportSelectCell
            cell.transportName.text = sw.placeholder
            cell.bindValue = sw.bindValue
            return cell
        }

        if let date = row as? ExpenseEditDate {
            let cell: DatePickerCell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell") as! DatePickerCell
            cell.bindValue = date.bindValue
            cell.handler = { (date: Date) in
                self.isDatePickerOpen = false

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat  = "yyyyMMdd";
                self.viewModel.dateAsString.value = dateFormatter.string(from: date)
                self.table.reloadData()
            }
            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case ExpenseEditSections.date.rawValue:
            if indexPath.row == 0 {
                isDatePickerOpen = !isDatePickerOpen
                tableView.reloadData()
            }
        default:
            break
        }
    }

    // TODO protocolかextensionに切り出したい
    func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
            let firstResponder: UIResponder = self.view.searchFirstResponder(),
            let textField: UITextField = firstResponder as? UITextField,
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue, let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {

            table.contentInset = UIEdgeInsets.zero
            table.scrollIndicatorInsets = UIEdgeInsets.zero

            let convertedKeyboardFrame: CGRect = table.convert(keyboardFrame, from: nil)
            let convertedTextFieldFrame: CGRect = textField.convert(textField.frame, to: table)

            let offsetY: CGFloat = convertedTextFieldFrame.maxY - convertedKeyboardFrame.minY
            if offsetY > 0 {
                UIView.beginAnimations("ResizeForKeyboard", context: nil)
                UIView.setAnimationDuration(animationDuration)

                let contentInsets = UIEdgeInsetsMake(0, 0, offsetY, 0)
                table.contentInset = contentInsets
                table.scrollIndicatorInsets = contentInsets
                table.contentOffset = CGPoint(x: 0, y: table.contentOffset.y + offsetY)

                UIView.commitAnimations()
            }
        }
    }

    func keyboardWillHide(_ notification: Notification) {
        table.contentInset = UIEdgeInsets.zero
        table.scrollIndicatorInsets = UIEdgeInsets.zero
    }

    fileprivate func showTextEditView(_ bindValue:Variable<String>, title: String, keyboard: UIKeyboardType = .default) {
        let vc:TextEditViewController = UIStoryboard(name: "ExpenseEdit", bundle: nil).instantiateViewController(withIdentifier: "TextEditViewController") as! TextEditViewController
        vc.bindValue = bindValue
        vc.inputItem = title
        vc.keyboard = keyboard
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true, completion: nil)
    }
}
