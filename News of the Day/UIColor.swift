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
    
    class func colors(_ count: Int) -> [UIColor] {
        var colors: [UIColor] = []
        
        let inc = 360.0 / Double(count)
        for h in stride(from: 0, to: 360, by: inc) {
            colors.append(UIColor(hue: CGFloat(h / 360.0), saturation: 1, brightness: 1, alpha: 1))
        }
        
        return colors
    }
}
