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

    var title: String {
        switch self {
        case Date:
            return "日付"
        case Destination:
            return "外出先"
        case Transport:
            return "交通機関"
        case Interval:
            return "区間"
        case Fare:
            return "料金"
        case Memo:
            return "備考"
        }
    }

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
}

class ExpenseEditViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, ShowAPIErrorDialog {
    @IBOutlet weak private var table: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!

    private var isDatePickerOpen: Bool = false
    private let bag: DisposeBag = DisposeBag()

    var viewModel: ExpenseEditViewModel = ExpenseEditViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // ナビゲーションバー表示
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "外出先編集"
            navigationItem.hidesBackButton = false
        }

        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = 100

        let transportCell = UINib(nibName: "TransportSelectCell", bundle: nil)
        table.registerNib(transportCell, forCellReuseIdentifier: "transportCell")
        let textFieldCell = UINib(nibName: "TextFieldCell", bundle: nil)
        table.registerNib(textFieldCell, forCellReuseIdentifier: "textFieldCell")
        let datePicerCell = UINib(nibName: "DatePickerCell", bundle: nil)
        table.registerNib(datePicerCell, forCellReuseIdentifier: "datePickerCell")

        // TODO 未入力時にDoneボタンdisable
        // TODO ViewとViewModelのバインディング
        doneButton.rx_tap.asObservable()
            .subscribeNext {
                self.viewModel.upsertExpense()
            }
            .addDisposableTo(bag)

        viewModel.result.asObservable()
            .skip(1) //初期値読み飛ばし
            .subscribeNext {error in
                let result = error as! APIResult
                if result.code == APIResultCode.Success.rawValue {
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
        return 6
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ExpenseEditSections(rawValue: section) == .Date && isDatePickerOpen {
                return 2
        }
        return (ExpenseEditSections(rawValue: section)?.rows)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case ExpenseEditSections.Date.rawValue:
            if indexPath.row == 1 {
                let cell: DatePickerCell = tableView.dequeueReusableCellWithIdentifier("datePickerCell") as! DatePickerCell
                cell.handler = { (date: String) in
                    // TODO ViewModelの日付更新
                    print("date \(date)")
                    self.isDatePickerOpen = false
                    self.viewModel.date.value = date
                    self.table.reloadData()
                }
                return cell
            }
            else {
                let cell: TextFieldCell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
                cell.placeholder = ExpenseEditSections.Date.title
                cell.textField.userInteractionEnabled = false

                viewModel.date.asObservable()
                    .bindTo(cell.textField.rx_text)
                    .addDisposableTo(bag)
                cell.textField.rx_text
                    .bindTo(viewModel.date)
                    .addDisposableTo(bag)
                return cell
            }
        case ExpenseEditSections.Destination.rawValue:
            let cell: TextFieldCell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
            cell.placeholder = ExpenseEditSections.Destination.title
            return cell
        case ExpenseEditSections.Transport.rawValue:
            // TODO その他の判別方法
            if indexPath.row == 5 {
                let cell: TextFieldCell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
                cell.placeholder = "その他"
                return cell
            }
            else {
                // TODO 交通機関ごとのラベル
                let cell: TransportSelectCell = tableView.dequeueReusableCellWithIdentifier("transportCell") as! TransportSelectCell
                return cell
            }
        case ExpenseEditSections.Interval.rawValue:
            // from/toの判別方法
            if indexPath.row == 0 {
                let cell: TextFieldCell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
                cell.placeholder = "from"
                return cell
            }
            else {
                let cell: TextFieldCell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
                cell.placeholder = "to"
                return cell
            }
        case ExpenseEditSections.Fare.rawValue:
            let cell: TextFieldCell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
            cell.placeholder = ExpenseEditSections.Fare.title
            cell.textField.userInteractionEnabled = false
            return cell
        case ExpenseEditSections.Memo.rawValue:
            let cell: TextFieldCell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
            cell.placeholder = ExpenseEditSections.Memo.title
            return cell
        default:
            return UITableViewCell()
        }
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
            showTextEditView(ExpenseEditSections.Destination.title)
        default:
            break
        }
    }

    private func showTextEditView(title: String, keyboard: UIKeyboardType = .Default) {
        let vc:TextEditViewController = UIStoryboard(name: "ExpenseEdit", bundle: nil).instantiateViewControllerWithIdentifier("TextEditViewController") as! TextEditViewController
        vc.inputItem = title
        vc.keyboard = keyboard
        vc.modalPresentationStyle = .OverCurrentContext
        vc.modalTransitionStyle = .CoverVertical
        presentViewController(vc, animated: true, completion: nil)
    }
}
