//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import DynamicColor
import ReactiveSwift
import enum Result.NoError
import UIKit

class SourcesViewModel: ViewModel {
    // MARK: Public Properties
    
    let sources = MutableProperty<[SourceViewModel]>([])
    let backgroundViewModel: BackgroundViewModel
    
    // MARK: Private Properties
    
    private let apiClient: APIClient
    private let category = MutableProperty<Category>(.all)
    
    // MARK: Public Actions
    
    lazy var refreshSources: Action<(), (), NoError> = {
        return Action { [weak self] _ in
            guard let `self` = self else { return .empty }
            
            return self.loadSources.apply()
                .ignoreError()
                .map { _ in () }
        }
    }()
    
    lazy var setCategory: Action<Category, Category, NoError> = {
        return Action { category in
            SignalProducer(value: category)
        }
    }()
    
    lazy var openSource: Action<Int, Int, NoError> = {
        return Action { [weak self] idx in
            guard let `self` = self else { return .empty }
            
            return self.sources.value[idx]
                .refreshArticles.apply()
                .ignoreError()
                .map { _ in idx }
        }
    }()
    
    lazy var openURL: Action<URL, URL, NoError> = {
        return Action { url in
            return SignalProducer(value: url)
        }
    }()
    
    // MARK: Private Actions
    
    lazy var loadSources: Action<(), [Source], NSError> = {
        return Action { [weak self] _ in
            guard let `self` = self else { return .empty }
            
            return self.apiClient.readSources()
        }
    }()
    
    let filter = Action<(), [Category], NoError> { _ in
        return SignalProducer(value: Category.filterable)
    }
    
    // MARK: Methods
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
        self.backgroundViewModel = BackgroundViewModel(filter: self.filter)
        
        super.init()
        
        self.sources <~
            SignalProducer.combineLatest(self.category.producer, SignalProducer(signal: self.loadSources.values))
                .map { [weak self] category, sources in
                    guard let `self` = self else { return [] }
                    
                    let filteredSources = category == .all ? sources : sources.filter { $0.category == category }
                    
                    let blue = UIColor(hex: 0x5096da)
                    let red = UIColor(hex: 0xf75635)
                    let yellow = UIColor(hex: 0xfea618)
                    let green = UIColor(hex: 0x48ca2f)
                    let purple = UIColor(hex: 0x5d29a5)
                    let lightBlue = UIColor(hex: 0x7dc6e5)
                    let subColors = [blue, red, yellow, lightBlue, green, purple]
                    let repeatCount = Int(ceil(Double(filteredSources.count) / Double(subColors.count)))
                    let colors = [[UIColor]](repeating: subColors, count: repeatCount)
                        .flatMap { $0 }
                                        
                    return zip(filteredSources, colors[0..<filteredSources.count])
                        .flatMap { SourceViewModel($0, backgroundColor: $1, apiClient: apiClient, openArticle: self.openURL) }
                }
        
        self.category <~ self.setCategory.values
        
        self.backgroundViewModel.isLoading <~ self.loadSources.isExecuting
        self.backgroundViewModel.title <~
            self.category.producer
                .map { return $0 == .all ? "News" : $0.title }
        
        self.loadSources.errors.observe(self.errorSink)
        
        // Kick off first fetch
        self.refreshSources.apply().start()
    }
}
