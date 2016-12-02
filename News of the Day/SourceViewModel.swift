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
    let category: Category?
    let logoURL: URL?
    let backgroundColor: UIColor
    let textColor: UIColor
    let sortOrders: [SortOrder]
    var showsSortOrders: Bool {
        return self.sortOrders.count > 1
    }
    
    let articles = MutableProperty<[ArticleViewModel]>([])
    let isRevealed = MutableProperty<Bool>(false)
    let sortOrder = MutableProperty<SortOrder>(.default)
    var isLoading: SignalProducer<Bool, NoError> {
        return self.loadArticles.isExecuting.producer
    }
    
    // MARK: Public Actions
    
    lazy var refreshArticles: Action<(), (), NoError> = {
        return Action { [weak self] _ in
            guard let `self` = self else { return .empty }
            
            return self.loadArticles.apply(self.sortOrder.value)
                .ignoreError()
                .map { _ in () }
        }
    }()
        
    let openArticle: Action<URL, URL, NoError>
    
    // MARK: Private Properties
    
    private let apiClient: APIClient
    
    // MARK: Private Actions
    
    lazy var loadArticles: Action<SortOrder, ArticlesResponse, NSError> = {
        return Action { [weak self] sort in
            guard let `self` = self else { return .empty }
            guard let sourceID = self.source.id else { return .empty }
            
            return self.apiClient.readArticles(sourceID: sourceID, sortOrder: sort)
        }
    }()
    
    // MARK: Methods
    
    init?(_ source: Source, backgroundColor: UIColor, apiClient: APIClient, openArticle: Action<URL, URL, NoError>) {
        guard let name = source.name else { return nil }
        
        self.openArticle = openArticle
        self.apiClient = apiClient
        self.source = source
        self.name = name
        self.category = source.category
        self.logoURL = source.logoURL
        self.backgroundColor = backgroundColor
        self.textColor = backgroundColor.contrastingTextColor
        self.sortOrders = source.availableSortOrders ?? []
        
        super.init()
        
        self.articles <~
            self.loadArticles.values
                .map { $0.articles?.flatMap { ArticleViewModel($0, backgroundColor: backgroundColor) } ?? [] }
        self.sortOrder <~
            self.loadArticles.values
                .map { $0.sortOrder ?? .top }
        
        self.sortOrder.producer
            .startWithValues { [weak self] sortOrder in
                self?.loadArticles.apply(sortOrder).start()
            }
    }
}
