//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Foundation
import UIKit

// This allows you to use hardcoded values as determined on a 375pt width device.
// Using this property ensures that your constants will scale up or down with screen size.
extension Int {
    var s: CGFloat {
        return CGFloat(self) * (UIScreen.main.bounds.width / 375.0)
    }
}
