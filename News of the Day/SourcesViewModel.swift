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
    let isSourceRevealed = MutableProperty<Bool>(false)
    let isAttributionHidden = MutableProperty<Bool>(true)
    let isLoading = MutableProperty<Bool>(false)
    let emptyStateText = MutableProperty<String?>(nil)
    let headerViewModel: HeaderViewModel
    
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
        self.headerViewModel = HeaderViewModel(filter: self.filter)
        
        super.init()
        
        // Create the view models first for performance
        let sourceViewModels = SignalProducer(signal: self.loadSources.values)
            .map { [weak self] sources -> [SourceViewModel] in
                guard let `self` = self else { return [] }
                
                let blue = UIColor(hex: 0x5096da)
                let red = UIColor(hex: 0xf75635)
                let yellow = UIColor(hex: 0xfea618)
                let green = UIColor(hex: 0x48ca2f)
                let purple = UIColor(hex: 0x5d29a5)
                let lightBlue = UIColor(hex: 0x7dc6e5)
                let subColors = [blue, red, yellow, lightBlue, green, purple]
                let repeatCount = Int(ceil(Double(sources.count) / Double(subColors.count)))
                let colors = [[UIColor]](repeating: subColors, count: repeatCount)
                    .flatMap { $0 }
                
                return zip(sources, colors[0..<sources.count])
                    .flatMap { SourceViewModel($0, backgroundColor: $1, apiClient: apiClient, openArticle: self.openURL) }
            }
        
        // Filter sources based on selected category and search text
        let categoryProducer = self.category.producer
        let searchTextProducer = SignalProducer.merge(
            SignalProducer<String?, NoError>(value: nil),
            SignalProducer(signal: self.headerViewModel.searchText)
        )
        self.sources <~
            SignalProducer.combineLatest(categoryProducer, searchTextProducer, sourceViewModels)
                .map { category, searchText, sources in
                    var filteredSources = category == .all ? sources : sources.filter { $0.category == category }
                    
                    if let text = searchText {
                        if text.characters.count > 0 {
                            filteredSources = filteredSources.filter { $0.name.contains(text) }
                        }
                    }
                    
                    return filteredSources
                }
                .observe(on: UIScheduler())
        
        self.category <~ self.setCategory.values
        self.isLoading <~ self.loadSources.isExecuting
        
        self.isAttributionHidden <~
            SignalProducer.combineLatest(self.isSourceRevealed.producer, self.sources.producer)
                .map { $0 || $1.count == 0 }
        
        self.emptyStateText <~
            SignalProducer.combineLatest(searchTextProducer, self.sources.producer)
                .map { ($0?.characters.count ?? 0) > 0 && $1.count == 0 ? "No Publications Found :(" : nil }
                .observe(on: UIScheduler())
        
        self.headerViewModel.title <~
            self.category.producer
                .map { return $0 == .all ? "News" : $0.title }
        
        self.loadSources.errors.observe(self.errorSink)
        
        // Kick off first fetch
        self.refreshSources.apply().start()
    }
}
