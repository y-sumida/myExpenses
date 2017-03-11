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

    init(isPresent: Bool) {
        self.isPresenting = isPresent
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)

        if isPresenting {
            // 遷移
            presentTransition(transitionContext, toView: toVC!.view, fromView: fromVC!.view)
        } else {
            // 戻る
            dismissTransition(transitionContext, toView: toVC!.view, fromView: fromVC!.view)
        }
    }

   func presentTransition(transitionContext: UIViewControllerContextTransitioning, toView: UIView, fromView: UIView) {
        guard let containerView: UIView = transitionContext.containerView() else { return }

        containerView.addSubview(toView)

        // 遷移先viewの初期位置を画面の左側に移動
        toView.frame = CGRectOffset(toView.frame, -containerView.frame.size.width, 0)

        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.05, options: .CurveEaseInOut, animations: { () -> Void in
            toView.frame = containerView.frame
        }) { (finished) -> Void in
            transitionContext.completeTransition(true)
        }
    }

    private func dismissTransition(transitionContext: UIViewControllerContextTransitioning, toView: UIView, fromView: UIView) {
        guard let containerView: UIView = transitionContext.containerView() else { return }

        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            fromView.frame = CGRectOffset(fromView.frame, -containerView.frame.size.width, 0)
        }) { (finished) -> Void in
            transitionContext.completeTransition(true)
        }
    }
}
