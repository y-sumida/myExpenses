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

final class SlideMenuTransition: UIPercentDrivenInteractiveTransition {
    private let bag: DisposeBag = DisposeBag()
    private var vc: UIViewController!
    var isInteractiveDissmalTransition = false

    init(targetViewController: UIViewController) {
        super.init()

        self.vc = targetViewController

        let panGesture = UIPanGestureRecognizer()
        panGesture.rx_event
            .subscribeNext { recognizer  in
                // ドラッグ中以外はこのトランジションを使わないように
                self.isInteractiveDissmalTransition = recognizer.state == .Began || recognizer.state == .Changed

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