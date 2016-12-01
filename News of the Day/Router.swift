//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Alamofire
import Foundation

enum Router: URLRequestConvertible {
    case sources(category: Category?, language: String?, country: String?)
    case articles(sourceID: String, sortOrder: SortOrder)
    
    static let baseURLString = "https://newsapi.org/v1/"
    
    // MARK: URLRequestConvertible
    
    func asURLRequest() throws -> URLRequest {
        let result: (path: String, parameters: Parameters) = {
            switch self {
            case let .sources(category, language, country):
                var params: [String: Any] = [:]
                if let c = category?.rawValue {
                    params[Source.Field.category.rawValue] = c
                }
                if let l = language {
                    params[Source.Field.language.rawValue] = l
                }
                if let c = country {
                    params[Source.Field.country.rawValue] = c
                }
                
                return ("/sources", params)
            case let .articles(sourceID, sortOrder):
                var params: [String: Any] = [:]
                params[ArticlesResponse.Field.sourceID.rawValue] = sourceID
                if sortOrder != .default {
                    params[ArticlesResponse.Field.sortOrder.rawValue] = sortOrder.rawValue
                }
                
                return ("/articles", params)
            }
        }()
    
        let url = try Router.baseURLString.asURL()
        let urlRequest = URLRequest(url: url.appendingPathComponent(result.path))
        
        return try URLEncoding.default.encode(urlRequest, with: result.parameters)
    }
}
