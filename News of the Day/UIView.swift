//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import ReactiveSwift

extension Reactive where Base: UIView {
    public var backgroundColor: BindingTarget<UIColor?> {
        return BindingTarget(on: UIScheduler(), lifetime: self.lifetime) { [weak base = self.base] value in
            base?.backgroundColor = value
        }
    }
}
