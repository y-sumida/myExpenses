//
//  SlideMenuTransition.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/03/08.
//
//

import UIKit
import RxSwift

final class SlideMenuTransition: UIPercentDrivenInteractiveTransition {
    private let bag: DisposeBag = DisposeBag()
    private var targetViewController: UIViewController!
    private let completeThreshold: CGFloat = 0.3
    var isInteractiveDissmalTransition = false

    init(targetViewController: UIViewController) {
        super.init()

        self.targetViewController = targetViewController

        let panGesture = UIPanGestureRecognizer()
        panGesture.rx.event
            .bindNext { [weak self] recognizer  in
                guard let `self` = self else { return }

                // ドラッグ中以外はこのトランジションを使わないように
                self.isInteractiveDissmalTransition = recognizer.state == .began || recognizer.state == .changed

                switch recognizer.state {
                case .began:
                    self.swipeBegan(recognizer: recognizer)
                case .changed:
                    self.swipeChanged(recognizer: recognizer)
                case .ended, .cancelled:
                    self.swipeEndedOrCancelled(recognizer: recognizer)
                default:
                    break
                }
            }
            .addDisposableTo(bag)

        self.targetViewController.view.addGestureRecognizer(panGesture)
    }

    private func swipeBegan(recognizer: UIPanGestureRecognizer) {
        // メニューを閉じる
        self.targetViewController.dismiss(animated: true, completion: nil)
    }

    private func swipeChanged(recognizer: UIPanGestureRecognizer) {
        let transition: CGPoint = recognizer.translation(in: self.targetViewController.view)
        var progress: CGFloat = transition.x / self.targetViewController.view.bounds.size.width
        progress = -min(1.0, max(-1.0, progress))

        self.update(progress)
    }

    private func swipeEndedOrCancelled(recognizer: UIPanGestureRecognizer) {
        // 閾値超えたらfinish判定
        self.percentComplete > self.completeThreshold ? self.finish() : self.cancel()
    }
}
