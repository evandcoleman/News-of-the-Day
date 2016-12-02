//
//  Artist Connect
//  Copyright © 2016 King Sage Music. All rights reserved.
//

import ReactiveSwift
import enum Result.NoError
import UIKit

extension Reactive where Base: UIViewController {
    /// A signal that sends the value of `isEditing`.
    var isEditing: Signal<Bool, NoError> {
        return self.trigger(for: #selector(UIViewController.setEditing(_:animated:)))
            .map { [weak base] _ in base?.isEditing }
            .skipNil()
    }
    
    /// Returns a SignalProducer that completes after presenting the view controller.
    func present(_ viewController: UIViewController, animated: Bool = true) -> SignalProducer<Void, NoError> {
        return SignalProducer { observer, disposable in
            self.base.present(viewController, animated: animated) {
                observer.send(value: ())
                observer.sendCompleted()
            }
        }
    }
    
    /// Returns a SignalProducer that completes after dismissing the view controller.
    func dismiss(_ animated: Bool = true) -> SignalProducer<Void, NoError> {
        return SignalProducer { observer, disposable in
            self.base.dismiss(animated: animated) {
                observer.send(value: ())
                observer.sendCompleted()
            }
        }
    }
}
