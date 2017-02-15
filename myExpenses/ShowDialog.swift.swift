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
    func showErrorDialog(error: APIResult, handler: ((UIAlertAction) -> Void)?)
    func showCompleteDialog(message: String, handler: ((UIAlertAction) -> Void)?)
    func showConfirmDialog(message: String, defaultHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?)
}

extension ShowDialog {
    func showErrorDialog(error: APIResult, handler: ((UIAlertAction) -> Void)? = nil) {
        let dialog = UIAlertController(title: error.code, message: error.message, preferredStyle: .Alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .Default, handler: handler))
        // TODO extensionとかに抽出したい
        var root = UIApplication.sharedApplication().keyWindow?.rootViewController
        while let present = root?.presentedViewController {
            root = present
        }
        root!.presentViewController(dialog, animated: true, completion: nil)
    }

    func showCompleteDialog(message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let dialog = UIAlertController(title: message, message: "", preferredStyle: .Alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .Default, handler: handler))
        var root = UIApplication.sharedApplication().keyWindow?.rootViewController
        while let present = root?.presentedViewController {
            root = present
        }
        root!.presentViewController(dialog, animated: true, completion: nil)
    }

    func showConfirmDialog(message: String, defaultHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?) {
        let dialog: UIAlertController = UIAlertController(title: message, message: "", preferredStyle:  UIAlertControllerStyle.Alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: defaultHandler)
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler: cancelHandler)
        dialog.addAction(cancelAction)
        dialog.addAction(defaultAction)

        var root = UIApplication.sharedApplication().keyWindow?.rootViewController
        while let present = root?.presentedViewController {
            root = present
        }
        root!.presentViewController(dialog, animated: true, completion: nil)
    }
}