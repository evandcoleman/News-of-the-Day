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
    
    // MARK: Private Properties
    
    private let apiClient: APIClient
    
    // MARK: Public Actions
    
    lazy var refreshSources: Action<(), (), NoError> = {
        return Action { [weak self] _ in
            guard let `self` = self else { return .empty }
            
            return self.loadSources.apply()
                .ignoreError()
                .map { _ in () }
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
    
    // MARK: Methods
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
        
        super.init()
        
        self.sources <~
            self.loadSources.values
                .map { [weak self] sources in
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
        
        self.loadSources.errors.observe(self.errorSink)
    }
}
