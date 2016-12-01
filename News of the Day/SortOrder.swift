//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

enum SortOrder: String {
    case `default` = "default"
    case top = "top"
    case latest = "latest"
    case popular = "popular"
    
    func name() -> String {
        return self.rawValue.capitalized
    }
}
