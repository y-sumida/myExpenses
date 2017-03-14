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

    fileprivate let bag: DisposeBag = DisposeBag()
    fileprivate var viewModel: ExpensesViewModel!
    fileprivate var period: Period = Period() // デフォルト当月
    var refreshControll = UIRefreshControl()
    var slideMenuTransition: SlideMenuTransition?

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
        table.register(nib, forCellReuseIdentifier: "cell")

        // 長押し
        let longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.rx.event
            .bindNext { [unowned self] _ in
                self.longPressAction(longPressRecognizer)
            }
            .addDisposableTo(bag)
        longPressRecognizer.delegate = self
        table.addGestureRecognizer(longPressRecognizer)

        // Rx
        viewModel = ExpensesViewModel()

        viewModel.reloadTrigger
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self]text in
                guard let `self` = self else { return }
                self.table.reloadData()
                self.refreshControll.endRefreshing()
            })
            .addDisposableTo(bag)

        viewModel.fareTotal.asObservable()
            .bindNext { [weak self] in
                guard let `self` = self else { return }
                self.fareTotal.title = $0
            }
            .addDisposableTo(bag)

        viewModel.result.asObservable()
            .skip(1) //初期値読み飛ばし
            .bindNext { [weak self] error in
                guard let `self` = self else { return }
                let result = error as! APIResult
                // セッション切れの場合、ログイン画面へ戻す
                if result.code == APIResultCode.SessionError {
                    self.showCompleteDialog("セッションエラー") { _ in
                        self.navigationController?.popToRootViewController(animated: false)
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
        self.refreshControll.rx.controlEvent(.valueChanged)
            .asDriver()
            .drive(onNext: { [weak self]text in
                guard let `self` = self else { return }
                self.viewModel.monthlyExpenses(self.period)
            })
            .addDisposableTo(bag)
        table.addSubview(refreshControll)

        // 初回ロードは当月指定
        viewModel.monthlyExpenses(period)

        // TODO 表示形式
        periodButton.title = period.description

        // UIBarButtonItemをラベルとして使う
        fareTotal.asLabel(UIColor.black)

        actionButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self]text in
                guard let `self` = self else { return }
                self.showUploadConfirmDialog()
            })
            .addDisposableTo(bag)

        // menu
        menuButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self]text in
                guard let `self` = self else { return }
                let vc:MenuViewController = UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
                vc.modalPresentationStyle = .custom
                vc.transitioningDelegate = self
                vc.logoutHandler = { [weak self] in
                    guard let `self` = self else { return }
                    self.navigationController?.popToRootViewController(animated: false)
                }
                self.present(vc, animated: true, completion: nil)
                self.slideMenuTransition = SlideMenuTransition(targetViewController: vc)
            })
            .addDisposableTo(bag)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count:" + viewModel.expenses.count.description)
        return viewModel.expenses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ExpenseCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ExpenseCell
        cell.viewModel = ExpenseCellViewModel(model: viewModel.expenses[indexPath.row])

        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            showDeleteConfirmDialog(indexPath)
        }
    }

    func longPressAction(_ recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: table)

        if let index = table.indexPathForRow(at: point) {
            if recognizer.state == UIGestureRecognizerState.began  {
                // TODO 各メニューの実装
                print(index)
                let alert: UIAlertController = UIAlertController(title: "編集メニュー", message: "選択してください", preferredStyle:  UIAlertControllerStyle.actionSheet)
                let editAction: UIAlertAction = UIAlertAction(title: "編集", style: UIAlertActionStyle.default, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("edit")
                    let vc:ExpenseEditViewController = UIStoryboard(name: "ExpenseEdit", bundle: nil).instantiateViewController(withIdentifier: "ExpenseEditViewController") as! ExpenseEditViewController
                    vc.viewModel = ExpenseEditViewModel(expense: self.viewModel.expenses[index.row])
                    vc.modalPresentationStyle = .custom
                    vc.modalTransitionStyle = .coverVertical
                    self.navigationController!.present(vc, animated: true, completion: nil)
                })
                let copyAction: UIAlertAction = UIAlertAction(title: "複製", style: UIAlertActionStyle.default, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("copy")
                    let vc:ExpenseEditViewController = UIStoryboard(name: "ExpenseEdit", bundle: nil).instantiateViewController(withIdentifier: "ExpenseEditViewController") as! ExpenseEditViewController
                    vc.viewModel = ExpenseEditViewModel(expense: self.viewModel.expenses[index.row], isCopy: true)
                    self.navigationController!.pushViewController(vc, animated: true)
                })
                let bookmarkAction: UIAlertAction = UIAlertAction(title: "お気に入りに追加", style: UIAlertActionStyle.default, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("bookmark")
                })
                let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("cancelAction")
                })
                let deleteAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertActionStyle.destructive, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.showDeleteConfirmDialog(index)
                })

                alert.addAction(editAction)
                alert.addAction(copyAction)
                alert.addAction(bookmarkAction)
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
            }
        }
    }

    fileprivate func showDeleteConfirmDialog(_ indexPath: IndexPath) {
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

    fileprivate func showUploadConfirmDialog() {
        let defaultHandler: (UIAlertAction) -> Void = {
            (action: UIAlertAction!) -> Void in
            // TODO APIコール
            self.showCompleteDialog("登録メールアドレスに伝票を送信しました")
        }
        self.showConfirmDialog("精算伝票を作成します。\nよろしいですか？", defaultHandler: defaultHandler, cancelHandler: nil)
    }

    @IBAction func tapEditButton(_ sender: AnyObject) {
        // TODO 各メニューの処理を実装する
        let alert: UIAlertController = UIAlertController(title: "追加メニュー", message: "選択してください", preferredStyle:  UIAlertControllerStyle.actionSheet)
        let addAction: UIAlertAction = UIAlertAction(title: "新規追加", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            print("add")
            let vc:ExpenseEditViewController = UIStoryboard(name: "ExpenseEdit", bundle: nil).instantiateViewController(withIdentifier: "ExpenseEditViewController") as! ExpenseEditViewController
            self.navigationController?.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .coverVertical
            self.navigationController!.present(vc, animated: true, completion: nil)
        })
        let bookmarkAction: UIAlertAction = UIAlertAction(title: "お気に入りから追加", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            print("bookmark")
        })
        let searchAction: UIAlertAction = UIAlertAction(title: "検索", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            print("search")
            let vc:SearchViewController = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .coverVertical
            self.navigationController!.present(vc, animated: true, completion: nil)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:nil)

        alert.addAction(addAction)
        alert.addAction(bookmarkAction)
        alert.addAction(searchAction)
        alert.addAction(cancelAction)

        self.navigationController!.present(alert, animated: true, completion: nil)
    }

    @IBAction func tapPeriod(_ sender: AnyObject) {
        let vc:PeriodsViewController = UIStoryboard(name: "Periods", bundle: nil).instantiateViewController(withIdentifier: "PeriodsViewController") as! PeriodsViewController

        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.handler = { period in
            self.period = period
            self.periodButton.title = period.description
            self.viewModel.monthlyExpenses(period)
        }

        self.navigationController!.present(vc, animated: true, completion: nil)
    }
}
extension ExpensesViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SlideMenuPresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideMenuAnimation(isPresent: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideMenuAnimation(isPresent: false)
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let transition = slideMenuTransition else {
            return nil
        }

        return transition.isInteractiveDissmalTransition ? transition : nil
    }
}

