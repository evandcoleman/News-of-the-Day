//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Foundation
import ReactiveSwift
import enum Result.NoError

class BackgroundViewModel: ViewModel {
    // MARK: Public Properties

    let title = MutableProperty<String>("News")

    // MARK: Public Actions


    // MARK: Private Properties


    // MARK: Private Actions

    let filter: Action<(), [Category], NoError>

    // MARK: Initializers

    init(filter: Action<(), [Category], NoError>) {
        self.filter = filter
    }
}
