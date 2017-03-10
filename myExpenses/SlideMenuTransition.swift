//
//  SlideMenuTransition.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/03/08.
//
//

import UIKit
import RxSwift

enum PanDirection {
    case Right
    case Left
}

class SlideMenuTransition: UIPercentDrivenInteractiveTransition {
    private let bag: DisposeBag = DisposeBag()
    private var vc: UIViewController!

    init(vc: UIViewController) {
        super.init()

        self.vc = vc

        let panGesture = UIPanGestureRecognizer()
        panGesture.rx_event
            .subscribeNext { recognizer  in
                switch recognizer.state {
                case .Began:
                    let startPoint = recognizer.translationInView(self.vc.view)
                    print("begin \(startPoint)")
                case .Changed:
                    let currentPoint = recognizer.translationInView(self.vc.view)
                    print("change \(currentPoint)")
                case .Ended:
                    let endPoint = recognizer.translationInView(self.vc.view)
                    print("end \(endPoint)")
                case .Cancelled:
                    print("cancel")
                default:
                    break
                }
            }
            .addDisposableTo(bag)

        self.vc.view.addGestureRecognizer(panGesture)
    }
}