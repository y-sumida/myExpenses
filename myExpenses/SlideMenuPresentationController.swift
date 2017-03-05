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

    override func presentationTransitionWillBegin() {
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ _ in }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ _ in }, completion: nil)
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