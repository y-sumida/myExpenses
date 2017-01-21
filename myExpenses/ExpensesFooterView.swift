//
//  ExpensesFooterView.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/11.
//
//

import UIKit
import RxSwift

class ExpensesFooterView: UIView, LoadXibView {
    @IBOutlet weak var addButton: UIButton!
    private let bag: DisposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
        configureButtonAction()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadView()
        configureButtonAction()
    }

    private func configureButtonAction() {
        // TODO extensionとかに抽出したい
        // root として UINavigationController が取れているけど、もっといい方法がありそう。
        var root = UIApplication.sharedApplication().keyWindow?.rootViewController
        while let present = root?.presentedViewController {
            root = present
        }

       addButton.rx_tap
        .subscribeNext {
            // TODO 各メニューの処理を実装する
            let alert: UIAlertController = UIAlertController(title: "追加メニュー", message: "選択してください", preferredStyle:  UIAlertControllerStyle.ActionSheet)
            let addAction: UIAlertAction = UIAlertAction(title: "新規追加", style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
                print("add")
                let vc:ExpenseEditViewController = UIStoryboard(name: "ExpenseEdit", bundle: nil).instantiateViewControllerWithIdentifier("ExpenseEditViewController") as! ExpenseEditViewController
                let navi: UINavigationController = root as! UINavigationController
                navi.pushViewController(vc, animated: true)
            })
            let bookmarkAction: UIAlertAction = UIAlertAction(title: "お気に入りから追加", style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
                print("bookmark")
            })
            let searchAction: UIAlertAction = UIAlertAction(title: "検索", style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
                print("search")
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:nil)

            alert.addAction(addAction)
            alert.addAction(bookmarkAction)
            alert.addAction(searchAction)
            alert.addAction(cancelAction)

            root!.presentViewController(alert, animated: true, completion: nil)
        }
        .addDisposableTo(bag)
    }

}
