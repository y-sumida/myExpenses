//
//  ExpensesViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2016/12/31.
//
//

import UIKit
import RxSwift

class ExpensesViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate, ShowAPIErrorDialog {
    @IBOutlet weak var table: UITableView!
    private let bag: DisposeBag = DisposeBag()
    private var viewModel: ExpensesViewModel!
    @IBOutlet weak var header: ExpensesHeaderView!
    @IBOutlet weak var footer: ExpensesFooterView!

    var sessionId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // ナビゲーションバー表示
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "交通費"
            navigationItem.hidesBackButton = true
        }

        table.delegate = self
        table.dataSource = self
        let nib = UINib(nibName: "ExpenseCell", bundle: nil)
        table.registerNib(nib, forCellReuseIdentifier: "cell")

        // 長押し
        let longPressRecognizer = UILongPressGestureRecognizer(target: self,action: #selector(longPressAction(_:)))
        longPressRecognizer.delegate = self
        table.addGestureRecognizer(longPressRecognizer)

        // Rx
        viewModel = ExpensesViewModel(sessionId: sessionId)

        viewModel.reloadTrigger
            .asObservable()
            .subscribeNext {
                print("reload")
                self.table.reloadData()
            }
            .addDisposableTo(bag)

        let width: CGFloat = UIScreen.mainScreen().bounds.size.width
        footer = ExpensesFooterView(frame: CGRectMake(0, 0, width, 40))

        viewModel.fareTotal.asObservable()
            .bindTo(header.fareTotal.rx_text)
            .addDisposableTo(bag)

        viewModel.result.asObservable()
            .skip(1) //初期値読み飛ばし
            .subscribeNext {error in
                let result = error as! APIResult
                if result.code != APIResultCode.Success.rawValue {
                    self.showErrorDialog(result) { _ in
                        self.table.setEditing(false, animated: false)
                    }
                }
            }
            .addDisposableTo(bag)

        // 初回ロードは当月指定
        let now = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMM"
        viewModel.monthlyExpenses(formatter.stringFromDate(now))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count:" + viewModel.destinations.count.description)
       return viewModel.destinations.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ExpenseCell = tableView.dequeueReusableCellWithIdentifier("cell") as! ExpenseCell
        cell.viewModel = ExpenseCellViewModel(model: viewModel.destinations[indexPath.row])

        return cell
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            showDeleteConfirmDialog(indexPath)
        }
    }

    func longPressAction(recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.locationInView(table)

        if let index = table.indexPathForRowAtPoint(point) {
            if recognizer.state == UIGestureRecognizerState.Began  {
                // TODO 各メニューの実装
                print(index)
                let alert: UIAlertController = UIAlertController(title: "編集メニュー", message: "選択してください", preferredStyle:  UIAlertControllerStyle.ActionSheet)
                let editAction: UIAlertAction = UIAlertAction(title: "編集", style: UIAlertActionStyle.Default, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("edit")
                    let vc:ExpenseEditViewController = UIStoryboard(name: "ExpenseEdit", bundle: nil).instantiateViewControllerWithIdentifier("ExpenseEditViewController") as! ExpenseEditViewController
                    vc.viewModel = ExpenseEditViewModel(expense: self.viewModel.destinations[index.row])
                    self.navigationController!.pushViewController(vc, animated: true)
                })
                let copyAction: UIAlertAction = UIAlertAction(title: "複製", style: UIAlertActionStyle.Default, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("copy")
                })
                let bookmarkAction: UIAlertAction = UIAlertAction(title: "お気に入りに追加", style: UIAlertActionStyle.Default, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("bookmark")
                })
                let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("cancelAction")
                })
                let deleteAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertActionStyle.Destructive, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.showDeleteConfirmDialog(index)
                })

                alert.addAction(editAction)
                alert.addAction(copyAction)
                alert.addAction(bookmarkAction)
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }

    private func showDeleteConfirmDialog(indexPath: NSIndexPath) {
        let alert: UIAlertController = UIAlertController(title: "削除してよいですか", message: "", preferredStyle:  UIAlertControllerStyle.Alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            self.viewModel.deleteDestination(indexPath.row)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler: { _ in
            self.table.setEditing(false, animated: false)
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)

        presentViewController(alert, animated: true, completion: nil)
    }
}
