//
//  ExpensesFooterView.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/11.
//
//

import UIKit

class ExpensesFooterView: UIView {
    @IBOutlet weak var addButton: UIButton!

    // コードから初期化はここから
    override init(frame: CGRect) {
        super.init(frame: frame)
        comminInit()
    }

    // Storyboard/xib から初期化はここから
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        comminInit()
    }

    // xibからカスタムViewを読み込んで準備する
    private func comminInit() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "ExpensesFooterView", bundle: bundle)
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
