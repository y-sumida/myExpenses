//
//  UIViewExtension.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/11.
//
//

import Foundation
import UIKit

extension UIView {
    func searchFirstResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }

        for subview in self.subviews {
            if let responder:UIResponder = subview.searchFirstResponder() {
               return responder
            }
        }

        return nil
    }
}
