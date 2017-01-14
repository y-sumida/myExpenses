//
//  ExpensesFooterView.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/11.
//
//

import UIKit
import RxSwift

class ExpensesFooterView: UIView {
    @IBOutlet weak var addButton: UIButton!
    private let bag: DisposeBag = DisposeBag()

    // コードから初期化はここから
    override init(frame: CGRect) {
        super.init(frame: frame)
        comminInit()
    }

    // Storyboard/xib から初期化はここから
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        comminInit()
    }

    // xibからカスタムViewを読み込んで準備する
    private func comminInit() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "ExpensesFooterView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil).first as! UIView
        addSubview(view)

        // カスタムViewのサイズを自分自身と同じサイズにする
        view.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": view]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|",
            options:NSLayoutFormatOptions(rawValue: 0),
            metrics:nil,
            views: bindings))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|",
            options:NSLayoutFormatOptions(rawValue: 0),
            metrics:nil,
            views: bindings))

        configureButtonAction()
    }

    private func configureButtonAction() {
       addButton.rx_tap
        .subscribeNext {
            // TODO 各メニューの処理を実装する
            let alert: UIAlertController = UIAlertController(title: "追加メニュー", message: "選択してください", preferredStyle:  UIAlertControllerStyle.ActionSheet)
            let addAction: UIAlertAction = UIAlertAction(title: "新規追加", style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
                print("add")
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

            // TODO extensionとかに抽出したい
            var root = UIApplication.sharedApplication().keyWindow?.rootViewController
            while let present = root?.presentedViewController {
                root = present
            }
            root!.presentViewController(alert, animated: true, completion: nil)
        }
        .addDisposableTo(bag)
    }

}
