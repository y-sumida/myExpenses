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
    case Date = 0
    case Destination
    case Transport
    case Interval
    case Fare
    case Memo

    var rows: Int {
        switch self {
        case Date, .Destination, .Fare, .Memo:
            return 1
        case Transport:
            return 6
        case Interval:
            return 2
        }
    }

    var placeHolders: [String] {
        switch self {
        case Date:
            return ["日付"]
        case Destination:
            return ["外出先"]
        case Transport:
            return ["JR", "私鉄", "地下鉄", "バス", "高速", "その他"]
        case Interval:
            return ["from", "to"]
        case Fare:
            return ["料金"]
        case Memo:
            return ["備考"]
        }
    }
}

enum ExpenseEditType: Int {
    case Text = 0
    case Number
    case Switch
    case DatePicker
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
    typealias Element = NSDate
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

class ExpenseEditViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, ShowAPIErrorDialog {
    @IBOutlet weak private var table: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!

    private var isDatePickerOpen: Bool = false
    private let bag: DisposeBag = DisposeBag()

    var viewModel: ExpenseEditViewModel = ExpenseEditViewModel()
    var rowsInSection:[Array<Any>]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // ナビゲーションバー表示
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "外出先編集"
            navigationItem.hidesBackButton = false
        }

        rowsInSection = [
            [
                ExpenseEditText(placeholder: "日付", type: .Text, bindValue: viewModel.dateAsString),
                ExpenseEditDate(placeholder: "", type: .DatePicker, bindValue: viewModel.date)
            ],
            [
                ExpenseEditText(placeholder: "外出先", type: .Text, bindValue: viewModel.destination),
            ],
            [
                ExpenseEditSwitch(placeholder: "JR", type: .Switch, bindValue: viewModel.useJR),
                ExpenseEditSwitch(placeholder: "私鉄", type: .Switch, bindValue: viewModel.usePrivate),
                ExpenseEditSwitch(placeholder: "地下鉄", type: .Switch, bindValue: viewModel.useSubway),
                ExpenseEditSwitch(placeholder: "バス", type: .Switch, bindValue: viewModel.useBus),
                ExpenseEditSwitch(placeholder: "高速", type: .Switch, bindValue: viewModel.useHighway),
                ExpenseEditText(placeholder: "その他", type: .Text, bindValue: viewModel.useOther),
            ],
            [
                ExpenseEditText(placeholder: "from", type: .Text, bindValue: viewModel.from),
                ExpenseEditText(placeholder: "to", type: .Text, bindValue: viewModel.to),
            ],
            [
                ExpenseEditText(placeholder: "料金", type: .Number, bindValue: viewModel.fare),
            ],
            [
                ExpenseEditText(placeholder: "備考", type: .Text, bindValue: viewModel.memo)
            ]
        ]

        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = 100

        let transportCell = UINib(nibName: "TransportSelectCell", bundle: nil)
        table.registerNib(transportCell, forCellReuseIdentifier: "TransportSelectCell")
        let textFieldCell = UINib(nibName: "TextFieldCell", bundle: nil)
        table.registerNib(textFieldCell, forCellReuseIdentifier: "TextFieldCell")
        let datePicerCell = UINib(nibName: "DatePickerCell", bundle: nil)
        table.registerNib(datePicerCell, forCellReuseIdentifier: "DatePickerCell")

        // TODO 未入力時にDoneボタンdisable
        doneButton.rx_tap.asObservable()
            .subscribeNext {
                self.viewModel.upsertExpense()
            }
            .addDisposableTo(bag)

        viewModel.result.asObservable()
            .skip(1) //初期値読み飛ばし
            .subscribeNext {error in
                let result = error as! APIResult
                // セッション切れの場合、ログイン画面へ戻す
                if result.code == APIResultCode.SessionError.rawValue {
                    // TODO ダイアログ表示する
                    self.navigationController?.popToRootViewControllerAnimated(false)
                }
                else if result.code == APIResultCode.Success.rawValue {
                    self.showCompleteDialog("送信完了") { _ in
                        self.navigationController?.popViewControllerAnimated(true)
                    }
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

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return rowsInSection.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ExpenseEditSections(rawValue: section) == .Date && isDatePickerOpen {
                return 2
        }
        return (ExpenseEditSections(rawValue: section)?.rows)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = rowsInSection[indexPath.section][indexPath.row]

        // TODO 変数名を適切なものに
        // TODO 日付のuserInteractionEnabled
        if let text = row as? ExpenseEditText {
            let cell: TextFieldCell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell") as! TextFieldCell
            cell.title.text = text.placeholder
            cell.bindValue = text.bindValue
            if text.type == .Number {
               cell.keyboardType = .NumberPad
            }
            return cell
        }

        if let sw = row as? ExpenseEditSwitch {
            let cell: TransportSelectCell = tableView.dequeueReusableCellWithIdentifier("TransportSelectCell") as! TransportSelectCell
            cell.transportName.text = sw.placeholder
            cell.bindValue = sw.bindValue
            return cell
        }

        if let date = row as? ExpenseEditDate {
            let cell: DatePickerCell = tableView.dequeueReusableCellWithIdentifier("DatePickerCell") as! DatePickerCell
            cell.bindValue = date.bindValue
            cell.handler = { (date: NSDate) in
                self.isDatePickerOpen = false

                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat  = "yyyyMMdd";
                self.viewModel.dateAsString.value = dateFormatter.stringFromDate(date)
                self.table.reloadData()
            }
            return cell
        }

        return UITableViewCell()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO 各セルごとの処理実装
        switch indexPath.section {
        case ExpenseEditSections.Date.rawValue:
            if indexPath.row == 0 {
                isDatePickerOpen = !isDatePickerOpen
                tableView.reloadData()
            }
        case ExpenseEditSections.Fare.rawValue:
            showTextEditView(viewModel.fare, title: ExpenseEditSections.Fare.placeHolders[indexPath.row], keyboard: .NumberPad)
        default:
            break
        }
    }

    private func showTextEditView(bindValue:Variable<String>, title: String, keyboard: UIKeyboardType = .Default) {
        let vc:TextEditViewController = UIStoryboard(name: "ExpenseEdit", bundle: nil).instantiateViewControllerWithIdentifier("TextEditViewController") as! TextEditViewController
        vc.bindValue = bindValue
        vc.inputItem = title
        vc.keyboard = keyboard
        vc.modalPresentationStyle = .OverCurrentContext
        vc.modalTransitionStyle = .CoverVertical
        presentViewController(vc, animated: true, completion: nil)
    }
}
