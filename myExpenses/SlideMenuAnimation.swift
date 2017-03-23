//
//  SlideMenuAnimationController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/28.
//
//

import UIKit

final class SlideMenuAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    private var isPresenting = false
    private let offset: CGFloat = -10

    init(isPresent: Bool) {
        self.isPresenting = isPresent
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)

        if isPresenting {
            // 遷移
            presentTransition(transitionContext: transitionContext, toView: toVC!.view, fromView: fromVC!.view)
        } else {
            // 戻る
            dismissTransition(transitionContext: transitionContext, toView: toVC!.view, fromView: fromVC!.view)
        }
    }

   func presentTransition(transitionContext: UIViewControllerContextTransitioning, toView: UIView, fromView: UIView) {
        let containerView: UIView = transitionContext.containerView

        containerView.addSubview(toView)

        // 遷移先viewの初期位置を画面の左側に移動
        toView.frame = toView.frame.offsetBy(dx: -containerView.frame.size.width, dy: 0)

    UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.05,
            options: .curveEaseInOut,
            animations: { () -> Void in
                toView.frame = containerView.frame
            },
            completion:{ (finished) -> Void in
                transitionContext.completeTransition(true)
            }
        )
    }

    private func dismissTransition(transitionContext: UIViewControllerContextTransitioning, toView: UIView, fromView: UIView) {
        let containerView: UIView = transitionContext.containerView

        toView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseInOut,
            animations: { () -> Void in
                fromView.frame = fromView.frame.offsetBy(dx: -containerView.frame.size.width, dy: 0)
                toView.transform = CGAffineTransform.identity
            },
            completion:{ (finished) -> Void in
                toView.transform = CGAffineTransform.identity
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}

