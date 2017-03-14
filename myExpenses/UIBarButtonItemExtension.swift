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
    func asLabel(_ color: UIColor) {
        self.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for: UIControlState())
        self.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for: .disabled)
        self.isEnabled = false
    }
}
