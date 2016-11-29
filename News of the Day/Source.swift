//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import  ObjectMapper

struct Source: Mappable {
    var id: String?
    var name: String?
    var description: String?
    var category: Category?
    var logoURL: URL?
    var availableSortOrders: [SortOrder]?
    
    enum Field: String {
        case id = "id"
        case name = "name"
        case description = "description"
        case category = "category"
        case language = "language"
        case country = "country"
        case logoURL = "urlsToLogos.large"
        case availableSortOrders = "sortBysAvailable"
    }
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        self.id <- map[Field.id.rawValue]
        self.name <- map[Field.name.rawValue]
        self.description <- map[Field.description.rawValue]
        self.category <- map[Field.category.rawValue]
        self.logoURL <- (map[Field.logoURL.rawValue], URLTransform())
        self.availableSortOrders <- map[Field.availableSortOrders.rawValue]
    }
}
