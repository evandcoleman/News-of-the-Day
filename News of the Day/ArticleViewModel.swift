//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import DynamicColor
import Foundation
import ReactiveSwift

class ArticleViewModel: ViewModel {
    // MARK: Public Properties
    
    let title: String
    let subtitle: String
    let summary: String
    let timestamp: String
    let imageURL: URL
    let url: URL
    let textColor: UIColor
    let lightTextColor: UIColor
    let separatorColor: UIColor

    // MARK: Public Actions


    // MARK: Private Properties


    // MARK: Private Actions


    // MARK: Initializers

    init?(_ article: Article, backgroundColor: UIColor) {
        guard let title = article.title else { return nil }
        guard let summary = article.summary else { return nil }
        guard let timestamp = article.publishedAt?.timeAgoSinceNow else { return nil }
        guard let imageURL = article.imageURL else { return nil }
        guard let url = article.URL else { return nil }
        
        self.title = title
        self.subtitle = article.author?.uppercased() ?? "UNKNOWN AUTHOR"
        self.summary = summary
        self.timestamp = "\(timestamp) ago"
        self.imageURL = imageURL
        self.url = url
        self.textColor = backgroundColor.contrastingTextColor
        self.lightTextColor = self.textColor.lighter()
        self.separatorColor = self.lightTextColor.lighter()
    }
}
