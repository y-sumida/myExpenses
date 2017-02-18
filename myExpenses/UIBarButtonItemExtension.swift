//
//  UIBarButtonItemExtension.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/18.
//
//

import Foundation
import UIKit

extension UIBarButtonItem {
    func asLabel(color color: UIColor) {
        self.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blackColor()], forState: .Normal)
        self.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blackColor()], forState: .Disabled)
        self.enabled = false
    }
}