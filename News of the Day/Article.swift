//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import  ObjectMapper

open class PublishedAtTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = String
    
    public let dateFormatter: DateFormatter
    
    public init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    }
    
    open func transformFromJSON(_ value: Any?) -> Date? {
        if let dateString = value as? String {
            self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            
            if let date = self.dateFormatter.date(from: dateString) {
                return date
            } else {
                self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSZZZZZ"
                
                return self.dateFormatter.date(from: dateString)
            }
        }
        return nil
    }
    
    open func transformToJSON(_ value: Date?) -> String? {
        if let date = value {
            self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            
            return self.dateFormatter.string(from: date)
        }
        return nil
    }
    
}

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
        self.publishedAt <- (map[Field.publishedAt.rawValue], PublishedAtTransform())
    }
}
