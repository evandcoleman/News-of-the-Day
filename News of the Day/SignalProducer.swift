//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import ReactiveSwift
import Result

extension SignalProducerProtocol {
    /// Log all events.
    public func logAll() -> SignalProducer<Value, Error> {
        return lift { $0.logAll() }
    }
    
    /// Returns a producer that drops `Error` sending `replacement` terminal event
    /// instead, defaulting to `Completed`.
    public func ignoreError(replacement: Event<Value, NoError> = .completed) -> SignalProducer<Value, NoError> {
        precondition(replacement.isTerminating)
        return lift { $0.ignoreError(replacement: replacement) }
    }
}

extension SignalProducerProtocol where Value: Sequence {
    /// Returns a producer that flattens sequences of elements. The inverse of `collect`.
    public func uncollect() -> SignalProducer<Value.Iterator.Element, Error> {
        return lift { $0.uncollect() }
    }
}

extension SignalProducerProtocol where Error == NSError {
    public func addBackgroundTask(_ name: String) -> SignalProducer<Value, Error> {
        return lift { $0.addBackgroundTask(name) }
    }
}
