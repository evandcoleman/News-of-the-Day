//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Foundation
import Kingfisher
import ReactiveSwift
import UIKit

extension Reactive where Base: ImageDownloader {
    func downloadImage(withURL url: URL) -> SignalProducer<UIImage?, NSError> {
        return SignalProducer { observer, disposable in
            let task = self.base.downloadImage(with: url, options: nil, progressBlock: nil) { image, error, _, _ in
                if let error = error {
                    observer.send(error: error)
                } else {
                    observer.send(value: image)
                    observer.sendCompleted()
                }
            }
            
            disposable += ActionDisposable() {
                task?.cancel()
            }
        }
    }
}
