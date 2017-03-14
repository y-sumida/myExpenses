//
//  SlideMenuAnimationController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/28.
//
//

import UIKit

class SlideMenuAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let finalFrame: CGRect = transitionContext.finalFrame(for: toVC)

        let container: UIView = transitionContext.containerView

        toVC.view.frame = finalFrame.offsetBy(dx: UIScreen.main.bounds.size.width * -1, dy: 0)

        container.addSubview(toVC.view)

        let duration: TimeInterval = transitionDuration(using: transitionContext)

        UIView.animate(withDuration: duration, animations: {
            toVC.view.frame = finalFrame
            }, completion: {
                finished in
                transitionContext.completeTransition(true)
        })
    }
}
