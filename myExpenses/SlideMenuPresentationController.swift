//
//  SlideMenuPresentationController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/03/05.
//
//

import UIKit

final class SlideMenuPresentationController: UIPresentationController {
    private let rightMargin: CGFloat = 52.0
    private let shadowOverlay = UIView()

    override func presentationTransitionWillBegin() {
		guard let containerView = containerView else {
			return
		}

		shadowOverlay.frame = containerView.bounds
		shadowOverlay.backgroundColor = UIColor.blackColor()
		shadowOverlay.alpha = 0.0
		containerView.insertSubview(shadowOverlay, atIndex: 0)
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ [unowned self] _ in
            self.shadowOverlay.alpha = 0.3
            }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ [unowned self] _ in
            // 閉じる前に透明に
            self.shadowOverlay.alpha = 0.0
            }, completion: nil)
    }

	override func dismissalTransitionDidEnd(completed: Bool) {
            //  閉じた後の片付け
		if completed {
			shadowOverlay.removeFromSuperview()
		}
	}

    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width - rightMargin, height: parentSize.height)
    }

    override func containerViewWillLayoutSubviews() {
        var frame = CGRectZero
        let parentBounds = containerView!.bounds
        let childSize = sizeForChildContentContainer(presentedViewController, withParentContainerSize: parentBounds.size)
        frame.size = childSize
        frame.origin.x = 0.0
        frame.origin.y = 0.0

        presentedView()!.frame = frame
    }
}