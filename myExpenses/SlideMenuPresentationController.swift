//
//  SlideMenuPresentationController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/03/05.
//
//

import UIKit

final class SlideMenuPresentationController: UIPresentationController {
    private let shadowOverlay = UIView()

    override func presentationTransitionWillBegin() {
		guard let containerView = containerView else {
			return
		}

		shadowOverlay.frame = containerView.bounds
		shadowOverlay.backgroundColor = UIColor.black
		shadowOverlay.alpha = 0.0
		containerView.insertSubview(shadowOverlay, at: 0)
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [unowned self] _ in
            self.shadowOverlay.alpha = 0.3
            }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [unowned self] _ in
            // 閉じる前に透明に
            self.shadowOverlay.alpha = 0.0
            }, completion: nil)
    }

	override func dismissalTransitionDidEnd(_ completed: Bool) {
            //  閉じた後の片付け
		if completed {
			shadowOverlay.removeFromSuperview()
		}
	}

    override func containerViewWillLayoutSubviews() {
        var frame = CGRect.zero
        let parentBounds = containerView!.bounds
        let childSize = CGSize(width: parentBounds.width, height: parentBounds.height)
        frame.size = childSize
        frame.origin.x = 0.0
        frame.origin.y = 0.0

        presentedView!.frame = frame
    }
}
