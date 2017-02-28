//
//  SlideMenuAnimationController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/28.
//
//

import UIKit

class SlideMenuAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toVC: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let finalFrame: CGRect = transitionContext.finalFrameForViewController(toVC)

        let container: UIView = transitionContext.containerView()!

        toVC.view.frame = CGRectOffset(finalFrame, UIScreen.mainScreen().bounds.size.width * -1, 0)

        container.addSubview(toVC.view)

        let duration: NSTimeInterval = transitionDuration(transitionContext)

        UIView.animateWithDuration(duration, animations: {
            toVC.view.frame = finalFrame
            }, completion: {
                finished in
                transitionContext.completeTransition(true)
        })
    }
}
