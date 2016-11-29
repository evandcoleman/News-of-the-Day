//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import  ObjectMapper

struct ArticlesResponse: Mappable {
    var status: Status?
    var message: String?
    var sourceID: String?
    var sortOrder: SortOrder?
    var articles: [Article]?
    
    enum Field: String {
        case status = "status"
        case message = "message"
        case sourceID = "source"
        case sortOrder = "sortBy"
        case articles = "articles"
    }
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        self.status <- map[Field.status.rawValue]
        self.message <- map[Field.message.rawValue]
        self.sourceID <- map[Field.sourceID.rawValue]
        self.sortOrder <- map[Field.sortOrder.rawValue]
        self.articles <- map[Field.articles.rawValue]
    }
}
