//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import UIKit

extension UIColor {
    var contrastingTextColor: UIColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: nil)
        
        let brightness = ((r * 76245) + (g * 149685) + (b * 29070)) / 1000
        
        return brightness <= 125 ? .white : .black
    }
}
