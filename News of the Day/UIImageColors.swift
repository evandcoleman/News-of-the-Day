//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import ReactiveSwift
import enum Result.NoError
import UIImageColors

extension Reactive where Base: UIImage {
    func colors(scaleDownSize: CGSize = CGSize.zero) -> SignalProducer<UIImageColors, NoError> {
        return SignalProducer { observer, _ in
            self.base.getColors(scaleDownSize: scaleDownSize) { colors in
                observer.send(value: colors)
                observer.sendCompleted()
            }
        }
    }
}
