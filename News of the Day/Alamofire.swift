//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Alamofire
import ObjectMapper
import ReactiveSwift

extension DataRequest: ReactiveExtensionsProvider { }

extension Reactive where Base: DataRequest {
    func responseString() -> SignalProducer<DataResponse<String>, NSError> {
        return SignalProducer { observer, disposable in
            let request = self.base.responseString { response in
                if let error = response.result.error as? NSError {
                    observer.send(error: error)
                } else {
                    observer.send(value: response)
                    observer.sendCompleted()
                }
            }
            
            disposable += ActionDisposable() {
                request.cancel()
            }
        }
    }
}
