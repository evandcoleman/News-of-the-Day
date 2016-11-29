//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Foundation

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
    
    func appending(_ elem: Iterator.Element) -> [Iterator.Element] {
        var result = Array(self)
        result.append(elem)
        return result
    }
}
