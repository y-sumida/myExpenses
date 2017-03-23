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
    func showErrorDialog(_ error: APIResult, handler: ((UIAlertAction) -> Void)?)
    func showCompleteDialog(_ message: String, handler: ((UIAlertAction) -> Void)?)
    func showConfirmDialog(_ message: String, defaultHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?)
}

extension ShowDialog where Self: UIViewController {
    var root: UIViewController {
        var root = UIApplication.shared.keyWindow?.rootViewController
        while let present = root?.presentedViewController {
            root = present
        }
        return root!
    }

    func showErrorDialog(_ error: APIResult, handler: ((UIAlertAction) -> Void)? = nil) {
        let dialog = UIAlertController(title: error.code.rawValue, message: error.message, preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))

        self.root.present(dialog, animated: true, completion: nil)
    }

    func showCompleteDialog(_ message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let dialog = UIAlertController(title: message, message: "", preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))

        self.root.present(dialog, animated: true, completion: nil)
    }

    func showConfirmDialog(_ message: String, defaultHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?) {
        let dialog: UIAlertController = UIAlertController(title: message, message: "", preferredStyle:  UIAlertControllerStyle.alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: defaultHandler))
        dialog.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: cancelHandler))

        self.root.present(dialog, animated: true, completion: nil)
    }
}
