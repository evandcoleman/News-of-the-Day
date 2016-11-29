//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Foundation

extension Date {
    var timeAgoSinceNow: String? {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .month, .year, .second]
        let components = calendar.dateComponents(unitFlags, from: self, to: Date())
        
        guard let years = components.year else { return nil }
        guard let months = components.month else { return nil }
        guard let days = components.day else { return nil }
        guard let hours = components.hour else { return nil }
        guard let minutes = components.minute else { return nil }
        guard let seconds = components.second else { return nil }
        
        if years >= 1 {
            return "\(years)yr"
        } else if months >= 1 {
            return "\(months)mo"
        } else if days >= 1 {
            return "\(days)d"
        } else if hours >= 1 {
            return "\(hours)h"
        } else if minutes >= 1 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }
}
