//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

enum Category: String {
    case business = "business"
    case entertainment = "entertainment"
    case gaming = "gaming"
    case general = "general"
    case music = "music"
    case scienceAndNature = "science-and-nature"
    case sports = "sport"
    case technology = "technology"
    
    var formatted: String {
        switch self {
        case .business: return "Business"
        case .entertainment: return "Entertainment"
        case .gaming: return "Gaming"
        case .general: return "General"
        case .music: return "Music"
        case .scienceAndNature: return "Science & Nature"
        case .sports: return "Sports"
        case .technology: return "Technology"
        }
    }
}
