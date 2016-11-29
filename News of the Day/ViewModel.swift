//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Foundation
import ReactiveSwift
import enum Result.NoError

open class ViewModel {
    let (errors, errorSink) = Signal<NSError, NoError>.pipe()
}
