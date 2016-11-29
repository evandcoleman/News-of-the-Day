//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import  ObjectMapper

struct SourcesResponse: Mappable {
    var status: Status?
    var message: String?
    var sources: [Source]?
    
    enum Field: String {
        case status = "status"
        case message = "message"
        case sources = "sources"
    }
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        self.status <- map[Field.status.rawValue]
        self.message <- map[Field.message.rawValue]
        self.sources <- map[Field.sources.rawValue]
    }
}
