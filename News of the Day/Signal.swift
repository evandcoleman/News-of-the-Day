//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import ReactiveSwift
import Result
import UIKit

extension SignalProtocol {
    /// Log all events.
    public func logAll() -> Signal<Value, Error> {
        return self.on(event: { print($0) })
    }
    
    /// Returns a signal that drops `Error` sending `replacement` terminal event
    /// instead, defaulting to `Completed`.
    public func ignoreError(replacement: Event<Value, NoError> = .completed) -> Signal<Value, NoError> {
        precondition(replacement.isTerminating)
        
        return Signal<Value, NoError> { observer in
            return self.observe { event in
                switch event {
                case let .value(value):
                    observer.send(value: value)
                case .failed:
                    observer.action(replacement)
                case .completed:
                    observer.sendCompleted()
                case .interrupted:
                    observer.sendInterrupted()
                }
            }
        }
    }
}

extension SignalProtocol where Value: Sequence {
    /// Returns a signal that flattens sequences of elements. The inverse of `collect`.
    public func uncollect() -> Signal<Value.Iterator.Element, Error> {
        return Signal<Value.Iterator.Element, Error> { observer in
            return self.observe { event in
                switch event {
                case let .value(sequence):
                    sequence.forEach { observer.send(value: $0) }
                case let .failed(error):
                    observer.send(error: error)
                case .completed:
                    observer.sendCompleted()
                case .interrupted:
                    observer.sendInterrupted()
                }
            }
        }
    }
}

extension SignalProtocol where Error == NSError {
    public func addBackgroundTask(_ name: String) -> Signal<Value, Error> {
        return Signal { observer in
            let disposable = CompositeDisposable()
            
            let identifier = UIApplication.shared.beginBackgroundTask(withName: name) {
                observer.send(error: NSError.generic("Background task \(name) timed out."))
            }
            
            disposable += self.observe(observer)
            
            if identifier != UIBackgroundTaskInvalid {
                disposable += ActionDisposable {
                    UIApplication.shared.endBackgroundTask(identifier)
                }
            }
            
            return disposable
        }
    }
}
