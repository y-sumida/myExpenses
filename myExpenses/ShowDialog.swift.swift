//
//  ShowDialog.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/15.
//
//

import Foundation
import UIKit

protocol ShowDialog {
    var root: UIViewController { get }
    func showErrorDialog(error: APIResult, handler: ((UIAlertAction) -> Void)?)
    func showCompleteDialog(message: String, handler: ((UIAlertAction) -> Void)?)
    func showConfirmDialog(message: String, defaultHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?)
}

extension ShowDialog where Self: UIViewController {
    var root: UIViewController {
        var root = UIApplication.sharedApplication().keyWindow?.rootViewController
        while let present = root?.presentedViewController {
            root = present
        }
        return root!
    }

    func showErrorDialog(error: APIResult, handler: ((UIAlertAction) -> Void)? = nil) {
        let dialog = UIAlertController(title: error.code, message: error.message, preferredStyle: .Alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .Default, handler: handler))

        self.root.presentViewController(dialog, animated: true, completion: nil)
    }

    func showCompleteDialog(message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let dialog = UIAlertController(title: message, message: "", preferredStyle: .Alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .Default, handler: handler))

        self.root.presentViewController(dialog, animated: true, completion: nil)
    }

    func showConfirmDialog(message: String, defaultHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?) {
        let dialog: UIAlertController = UIAlertController(title: message, message: "", preferredStyle:  UIAlertControllerStyle.Alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .Default, handler: defaultHandler))
        dialog.addAction(UIAlertAction(title: "キャンセル", style: .Cancel, handler: cancelHandler))

        self.root.presentViewController(dialog, animated: true, completion: nil)
    }
}