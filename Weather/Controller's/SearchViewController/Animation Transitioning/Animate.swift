//
//  Animate.swift
//  Weather
//
//  Created by Stanislav on 01.11.2020.
//

import UIKit

class AnimationPresented: NSObject, UIViewControllerAnimatedTransitioning {
    private let timeInterval: Double
    private let animationType: AnimationType
    
    init(timeInterval: Double, animationType: AnimationType) {
        self.timeInterval = timeInterval
        self.animationType = animationType
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return timeInterval
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.viewController(forKey: .to) else { return }
        guard let fromView = transitionContext.viewController(forKey: .from) else { return }
        let container = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)

        switch animationType {
        case .present:
            container.addSubview(toView.view)
            let height = container.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            toView.view.frame = CGRect(x: 10, y: container.bounds.minY + height,
                                       width: container.bounds.width - 20, height: 112)
            toView.view.transform = CGAffineTransform(translationX: 0, y: -container.frame.height)

            UIView.animate(withDuration: duration, delay: 0,
                           usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 0.8,
                           options: [], animations: {
                            toView.view.transform = CGAffineTransform.identity
                           }, completion: { _ in
                            transitionContext.completeTransition(true)
                           })
        case .dismiss:
            UIView.animate(withDuration: duration, animations: {
                fromView.view.transform = CGAffineTransform(translationX: 0, y: -container.frame.height)
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }
    
    enum AnimationType {
        case present
        case dismiss
    }
}
