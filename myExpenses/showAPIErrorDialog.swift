//
//  showAPIErrorDialog.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/15.
//
//

import Foundation
import UIKit

// TODO utilityクラスとかでもいい？
protocol showAPIErrorDialog {
    func showErrorDialog(error: APIResult)
}

extension showAPIErrorDialog {
    func showErrorDialog(error: APIResult) {
        let dialog = UIAlertController(title: error.code, message: error.message, preferredStyle: .Alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        // TODO extensionとかに抽出したい
        var root = UIApplication.sharedApplication().keyWindow?.rootViewController
        while let present = root?.presentedViewController {
            root = present
        }
        root!.presentViewController(dialog, animated: true, completion: nil)
    }
}