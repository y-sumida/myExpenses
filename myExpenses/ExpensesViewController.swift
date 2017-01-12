//
//  ExpensesViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2016/12/31.
//
//

import UIKit
import RxSwift

class ExpensesViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate {
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
                self.table.reloadData()
            }
            .addDisposableTo(bag)

        let width: CGFloat = UIScreen.mainScreen().bounds.size.width
        footer = ExpensesFooterView(frame: CGRectMake(0, 0, width, 40))

        viewModel.fareTotal.asObservable()
            .bindTo(header.fareTotal.rx_text)
            .addDisposableTo(bag)

        viewModel.fetchTrigger.onNext(())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            viewModel.deleteDestination(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
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
                })
                let copyAction: UIAlertAction = UIAlertAction(title: "複製", style: UIAlertActionStyle.Default, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("copy")
                })
                let bookmarkAction: UIAlertAction = UIAlertAction(title: "お気に入りから", style: UIAlertActionStyle.Default, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("bookmark")
                })
                let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("cancelAction")
                })
                let deleteAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertActionStyle.Destructive, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("削除")
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
}
