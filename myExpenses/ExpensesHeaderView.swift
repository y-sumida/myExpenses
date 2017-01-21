//
//  ExpensesHeaderView.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/09.
//
//

import UIKit

class ExpensesHeaderView: UIView, UIPopoverPresentationControllerDelegate, LoadXibView{
    @IBOutlet weak var fareTotal: UILabel!
    @IBOutlet weak var periodButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadView()
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
