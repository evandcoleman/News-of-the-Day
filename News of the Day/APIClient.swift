//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Alamofire
import ObjectMapper
import ReactiveSwift
import Then

class APIClient {
    private static let supportedCountryCodes = ["au", "de", "gb", "in", "it", "us"]
    private static let supportedLanguageCodes = ["en", "de", "fr"]
    private static let defaultCountryCode = "us"
    private static let defaultLanguageCode = "en"
    
    private let session: SessionManager
    
    init(apiKey: String) {
        let configuration = URLSessionConfiguration.background(withIdentifier: "net.evancoleman.NewsOfTheDay.network").then {
            $0.httpAdditionalHeaders = [
                "X-Api-Key": apiKey
            ]
        }
        self.session = SessionManager(configuration: configuration)
    }
    
    func readSources(category: Category? = nil) -> SignalProducer<[Source], NSError> {
        let deviceLanguage = NSLocale.current.languageCode?.lowercased() ?? APIClient.defaultLanguageCode
        let deviceCountry = NSLocale.current.regionCode?.lowercased() ?? APIClient.defaultCountryCode
        
        let language = APIClient.supportedLanguageCodes.contains(deviceLanguage) ? deviceLanguage : APIClient.defaultLanguageCode
        let country = APIClient.supportedCountryCodes.contains(deviceCountry) ? deviceCountry : APIClient.defaultCountryCode
        
        return self.session
            .request(Router.sources(category: category, language: language, country: country))
            .reactive
            .responseString()
            .attemptMap { response in
                guard let jsonString = response.result.value else { return .failure(NSError.generic("Unexpected response.")) }
                guard let sourcesResponse = Mapper<SourcesResponse>().map(JSONString: jsonString) else { return .failure(NSError.generic("Couldn't parse sources.")) }
                
                if sourcesResponse.status == .error {
                    let message = sourcesResponse.message ?? "An unknown error occurred"
                    
                    return .failure(NSError.generic(message))
                }
                
                return .success(sourcesResponse.sources ?? [])
            }
    }
    
    func readArticles(sourceID: String, sortOrder: SortOrder = .default) -> SignalProducer<ArticlesResponse, NSError> {
        return self.session
            .request(Router.articles(sourceID: sourceID, sortOrder: sortOrder))
            .reactive
            .responseString()
            .attemptMap { response in
                guard let jsonString = response.result.value else { return .failure(NSError.generic("Unexpected response.")) }
                guard let articlesResponse = Mapper<ArticlesResponse>().map(JSONString: jsonString) else { return .failure(NSError.generic("Couldn't parse articles.")) }
                
                if articlesResponse.status == .error {
                    let message = articlesResponse.message ?? "An unknown error occurred"
                    
                    return .failure(NSError.generic(message))
                }
                
                return .success(articlesResponse)
            }
    }
}
