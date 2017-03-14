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
        let className = NSStringFromClass(type(of: self))
        let bundle = Bundle(for: type(of: self))
        let nibName = className.components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(view)

        // カスタムViewのサイズを自分自身と同じサイズにする
        view.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": view]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
            options:NSLayoutFormatOptions(rawValue: 0),
            metrics:nil,
            views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
            options:NSLayoutFormatOptions(rawValue: 0),
            metrics:nil,
            views: bindings))
    }
}
