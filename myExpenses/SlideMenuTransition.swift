//
//  SlideMenuTransition.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/03/08.
//
//

import UIKit
import RxSwift

class SlideMenuTransition: UIPercentDrivenInteractiveTransition {
    private let bag: DisposeBag = DisposeBag()
    private var vc: UIViewController!

    init(vc: UIViewController) {
        super.init()

        self.vc = vc

        let panGesture = UIPanGestureRecognizer()
        panGesture.rx_event
            .subscribeNext { _ in
                print("pangesture")
            }
            .addDisposableTo(bag)

        self.vc.view.addGestureRecognizer(panGesture)
    }
}