//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Foundation
import ReactiveSwift
import enum Result.NoError

class HeaderViewModel: ViewModel {
    // MARK: Public Properties

    let title = MutableProperty<String>("News")
    let isSearching = MutableProperty<Bool>(false)
    let (searchText, searchSink) = Signal<String?, NoError>.pipe()

    // MARK: Public Actions

    lazy var search: Action<(), Bool, NoError> = {
        return Action { [weak self] _ in
            guard let `self` = self else { return .empty }
            
            return SignalProducer(value: !self.isSearching.value)
        }
    }()

    // MARK: Private Properties


    // MARK: Private Actions

    let filter: Action<(), [Category], NoError>

    // MARK: Initializers

    init(filter: Action<(), [Category], NoError>) {
        self.filter = filter
        
        super.init()
        
        self.isSearching <~ self.search.values
        
        self.isSearching.producer
            .filter { !$0 }
            .startWithValues { [weak self] _ in
                self?.searchSink.send(value: nil)
            }
    }
}
