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
        let vc:PeriodSelectViewController = UIStoryboard(name: "PeriodSelect", bundle: nil).instantiateViewControllerWithIdentifier("PeriodSelectViewController") as! PeriodSelectViewController

        vc.modalPresentationStyle = .Custom
        vc.modalTransitionStyle = .CrossDissolve

        var root = UIApplication.sharedApplication().keyWindow?.rootViewController
        while let present = root?.presentedViewController {
            root = present
        }
        root!.presentViewController(vc, animated: true, completion: nil)
    }
}
