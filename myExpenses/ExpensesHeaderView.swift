//
//  ExpensesHeaderView.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/09.
//
//

import UIKit

class ExpensesHeaderView: UIView, UIPopoverPresentationControllerDelegate{
    @IBOutlet weak var fareTotal: UILabel!
    @IBOutlet weak var periodButton: UIButton!

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
    // TODO Utilityクラスなりに切り出す
    private func comminInit() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "ExpensesHeaderView", bundle: bundle)
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
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

    @IBAction func tapButton(sender: AnyObject) {
        //TODO あとでViewを作る
        let vc: UIViewController = UIViewController()
        vc.modalPresentationStyle = .Popover
        vc.preferredContentSize = CGSize(width: 100, height: 100)
        vc.popoverPresentationController?.backgroundColor = UIColor.blueColor()
        vc.popoverPresentationController?.delegate = self
        vc.popoverPresentationController?.sourceView = sender as? UIView
        vc.popoverPresentationController?.sourceRect = sender.bounds
        vc.popoverPresentationController?.permittedArrowDirections = .Up

        var root = UIApplication.sharedApplication().keyWindow?.rootViewController
        while let present = root?.presentedViewController {
            root = present
        }
        root!.presentViewController(vc, animated: true, completion: nil)
    }
}
