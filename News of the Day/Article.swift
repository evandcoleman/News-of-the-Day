//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import  ObjectMapper

struct Article: Mappable {
    var author: String?
    var summary: String?
    var title: String?
    var URL: URL?
    var imageURL: URL?
    var publishedAt: Date?
    
    enum Field: String {
        case author = "author"
        case summary = "description"
        case title = "title"
        case URL = "url"
        case imageURL = "urlToImage"
        case publishedAt = "publishedAt"
    }
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        self.author <- map[Field.author.rawValue]
        self.summary <- map[Field.summary.rawValue]
        self.title <- map[Field.title.rawValue]
        self.URL <- (map[Field.URL.rawValue], URLTransform())
        self.imageURL <- (map[Field.imageURL.rawValue], URLTransform(shouldEncodeURLString: false))
        self.publishedAt <- (map[Field.publishedAt.rawValue], ISO8601DateTransform())
    }
}
