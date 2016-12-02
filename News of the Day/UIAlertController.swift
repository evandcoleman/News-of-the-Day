//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import ReactiveCocoa
import ReactiveSwift
import enum Result.NoError
import UIKit

extension Reactive where Base: UIAlertController {
    @discardableResult
    func addAction(withTitle title: String, style: UIAlertActionStyle, action: CocoaAction<UIAlertAction>) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: style) { action.execute($0) }
        self.base.addAction(action)
        
        return action
    }
}
