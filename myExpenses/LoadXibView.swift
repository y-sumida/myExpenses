//
//  LoadXibView.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/21.
//
//

import Foundation
import UIKit

protocol LoadXibView {
    func loadView()
}

extension LoadXibView where Self: UIView {
    func loadView() {
        let className = NSStringFromClass(self.dynamicType)
        let bundle = NSBundle(forClass: self.dynamicType)
        let nibName = className.componentsSeparatedByString(".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
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
}