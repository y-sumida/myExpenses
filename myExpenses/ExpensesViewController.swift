//
//  ExpensesViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2016/12/31.
//
//

import UIKit
import RxSwift

class ExpensesViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate, ShowDialog {
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var periodButton: UIBarButtonItem!
    @IBOutlet weak var fareTotal: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var menuButton: UIBarButtonItem!

    private let bag: DisposeBag = DisposeBag()
    private var viewModel: ExpensesViewModel!
    private var period: Period = Period() // デフォルト当月
    var refreshControll = UIRefreshControl()
    var slideMenuTransition: SlideMenuTransition?

    override func viewDidLoad() {
        super.viewDidLoad()

        table.delegate = self
        table.dataSource = self
        let nib = UINib(nibName: "ExpenseCell", bundle: nil)
        table.registerNib(nib, forCellReuseIdentifier: "cell")

        // 長押し
        let longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.rx_event
            .subscribeNext { [unowned self] _ in
                self.longPressAction(longPressRecognizer)
            }
            .addDisposableTo(bag)
        longPressRecognizer.delegate = self
        table.addGestureRecognizer(longPressRecognizer)

        // Rx
        viewModel = ExpensesViewModel()

        viewModel.reloadTrigger
            .asDriver(onErrorJustReturn: ())
            .driveNext { [weak self] in
                guard let `self` = self else { return }
                self.table.reloadData()
                self.refreshControll.endRefreshing()
            }
            .addDisposableTo(bag)

        viewModel.fareTotal.asObservable()
            .subscribeNext { [weak self] in
                guard let `self` = self else { return }
                self.fareTotal.title = $0
            }
            .addDisposableTo(bag)

        viewModel.result.asObservable()
            .skip(1) //初期値読み飛ばし
            .subscribeNext { [weak self] error in
                guard let `self` = self else { return }
                let result = error as! APIResult
                // セッション切れの場合、ログイン画面へ戻す
                if result.code == APIResultCode.SessionError {
                    self.showCompleteDialog("セッションエラー") { _ in
                        self.navigationController?.popToRootViewControllerAnimated(false)
                    }
                }
                else if result.code != APIResultCode.Success {
                    self.showErrorDialog(result) { _ in
                        self.table.setEditing(false, animated: false)
                    }
                }
            }
            .addDisposableTo(bag)

        // Pull Refresh
        self.refreshControll.rx_controlEvent(.ValueChanged)
            .asDriver()
            .driveNext { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.monthlyExpenses(self.period)
            }
            .addDisposableTo(bag)
        table.addSubview(refreshControll)

        // 初回ロードは当月指定
        viewModel.monthlyExpenses(period)

        // TODO 表示形式
        periodButton.title = period.description

        // UIBarButtonItemをラベルとして使う
        fareTotal.asLabel(color: UIColor.blackColor())

        actionButton.rx_tap
            .asDriver()
            .driveNext { [weak self] in
                guard let `self` = self else { return }
                self.showUploadConfirmDialog()
            }
            .addDisposableTo(bag)

        // menu
        menuButton.rx_tap
            .asDriver()
            .driveNext { [weak self] in
                guard let `self` = self else { return }
                let vc:MenuViewController = UIStoryboard(name: "Menu", bundle: nil).instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
                vc.modalPresentationStyle = .Custom
                vc.transitioningDelegate = self
                vc.logoutHandler = { [weak self] in
                    guard let `self` = self else { return }
                    self.navigationController?.popToRootViewControllerAnimated(false)
                }
                self.presentViewController(vc, animated: true, completion: nil)
                self.slideMenuTransition = SlideMenuTransition(targetViewController: vc)
            }
            .addDisposableTo(bag)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // ナビゲーションバー表示
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "交通費"
            navigationItem.hidesBackButton = true
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count:" + viewModel.expenses.count.description)
        return viewModel.expenses.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ExpenseCell = tableView.dequeueReusableCellWithIdentifier("cell") as! ExpenseCell
        cell.viewModel = ExpenseCellViewModel(model: viewModel.expenses[indexPath.row])

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
                    vc.viewModel = ExpenseEditViewModel(expense: self.viewModel.expenses[index.row])
                    self.navigationController!.pushViewController(vc, animated: true)
                })
                let copyAction: UIAlertAction = UIAlertAction(title: "複製", style: UIAlertActionStyle.Default, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("copy")
                    let vc:ExpenseEditViewController = UIStoryboard(name: "ExpenseEdit", bundle: nil).instantiateViewControllerWithIdentifier("ExpenseEditViewController") as! ExpenseEditViewController
                    vc.viewModel = ExpenseEditViewModel(expense: self.viewModel.expenses[index.row], isCopy: true)
                    self.navigationController!.pushViewController(vc, animated: true)
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
        let defaultHandler: (UIAlertAction) -> Void = {
            (action: UIAlertAction!) -> Void in
            self.viewModel.deleteAtIndex(indexPath.row)
        }
        let cancelHandler: (UIAlertAction) -> Void = {
            (action: UIAlertAction!) -> Void in
            self.table.setEditing(false, animated: false)
        }
        self.showConfirmDialog("削除して良いですか", defaultHandler: defaultHandler, cancelHandler: cancelHandler)
    }

    private func showUploadConfirmDialog() {
        let defaultHandler: (UIAlertAction) -> Void = {
            (action: UIAlertAction!) -> Void in
            // TODO APIコール
            self.showCompleteDialog("登録メールアドレスに伝票を送信しました")
        }
        self.showConfirmDialog("精算伝票を作成します。\nよろしいですか？", defaultHandler: defaultHandler, cancelHandler: nil)
    }

    @IBAction func tapEditButton(sender: AnyObject) {
        // TODO 各メニューの処理を実装する
        let alert: UIAlertController = UIAlertController(title: "追加メニュー", message: "選択してください", preferredStyle:  UIAlertControllerStyle.ActionSheet)
        let addAction: UIAlertAction = UIAlertAction(title: "新規追加", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            print("add")
            let vc:ExpenseEditViewController = UIStoryboard(name: "ExpenseEdit", bundle: nil).instantiateViewControllerWithIdentifier("ExpenseEditViewController") as! ExpenseEditViewController
            self.navigationController!.pushViewController(vc, animated: true)
        })
        let bookmarkAction: UIAlertAction = UIAlertAction(title: "お気に入りから追加", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            print("bookmark")
        })
        let searchAction: UIAlertAction = UIAlertAction(title: "検索", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            print("search")
            let vc:SearchViewController = UIStoryboard(name: "Search", bundle: nil).instantiateViewControllerWithIdentifier("SearchViewController") as! SearchViewController
            vc.modalPresentationStyle = .Custom
            vc.modalTransitionStyle = .CoverVertical
            self.navigationController!.presentViewController(vc, animated: true, completion: nil)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:nil)

        alert.addAction(addAction)
        alert.addAction(bookmarkAction)
        alert.addAction(searchAction)
        alert.addAction(cancelAction)

        self.navigationController!.presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func tapPeriod(sender: AnyObject) {
        let vc:PeriodsViewController = UIStoryboard(name: "Periods", bundle: nil).instantiateViewControllerWithIdentifier("PeriodsViewController") as! PeriodsViewController

        vc.modalPresentationStyle = .Custom
        vc.modalTransitionStyle = .CrossDissolve
        vc.handler = { period in
            self.period = period
            self.periodButton.title = period.description
            self.viewModel.monthlyExpenses(period)
        }

        self.navigationController!.presentViewController(vc, animated: true, completion: nil)
    }
}
extension ExpensesViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return SlideMenuPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideMenuAnimation(isPresent: true)
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideMenuAnimation(isPresent: false)
    }
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }

    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let transition = slideMenuTransition else {
            return nil
        }

        return transition.isInteractiveDissmalTransition ? transition : nil
    }
}

