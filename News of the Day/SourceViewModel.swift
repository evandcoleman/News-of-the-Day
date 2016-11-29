//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import ReactiveSwift
import enum Result.NoError
import UIKit.UIColor

class SourceViewModel: ViewModel {
    // MARK: Public Properties
    
    let source: Source
    
    let name: String
    let backgroundColor: UIColor
    let textColor: UIColor
    
    let articles = MutableProperty<[ArticleViewModel]>([])
    
    // MARK: Public Actions
    
    lazy var refreshArticles: Action<(), (), NoError> = {
        return Action { [weak self] _ in
            guard let `self` = self else { return .empty }
            
            return self.loadArticles.apply()
                .ignoreError()
                .map { _ in () }
        }
    }()
    
    let openArticle: Action<URL, URL, NoError>
    
    // MARK: Private Properties
    
    private let apiClient: APIClient
    
    // MARK: Private Actions
    
    lazy var loadArticles: Action<(), [Article], NSError> = {
        return Action { [weak self] _ in
            guard let `self` = self else { return .empty }
            guard let sourceID = self.source.id else { return .empty }
            
            return self.apiClient.readArticles(sourceID: sourceID)
        }
    }()
    
    // MARK: Methods
    
    init?(_ source: Source, backgroundColor: UIColor, apiClient: APIClient, openArticle: Action<URL, URL, NoError>) {
        guard let name = source.name else { return nil }
        
        self.openArticle = openArticle
        self.apiClient = apiClient
        self.source = source
        self.name = name
        self.backgroundColor = backgroundColor
        self.textColor = backgroundColor.contrastingTextColor
        
        super.init()
        
        self.articles <~
            self.loadArticles.values
                .map { $0.flatMap { ArticleViewModel($0, backgroundColor: backgroundColor) } }
    }
}
