//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Font_Awesome_Swift
import Mortar
import ReactiveCocoa
import ReactiveSwift
import Then
import UIKit

class BackgroundView: UIView {
    let viewModel: BackgroundViewModel
    
    init(viewModel: BackgroundViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        // MARK: Configure Subviews
        
        let container = UIView()
        
        let iconLabel = UILabel().then {
            $0.textColor = .white
            $0.setFAIcon(icon: .FANewspaperO, iconSize: 24)
        }
        
        let textLabel = UILabel().then {
            $0.textColor = .white
            $0.font = UIFont.systemFont(ofSize: 17)
            $0.text = "News"
            $0.reactive.text <~ viewModel.title
        }
        
        let attributionLabel = UILabel().then {
            $0.text = "Powered by News API\nnewsapi.org"
            $0.numberOfLines = 2
            $0.textAlignment = .center
            $0.textColor = .white
            $0.font = UIFont.systemFont(ofSize: 10)
            $0.reactive.isHidden <~ viewModel.showAttribution.map { !$0 }
        }
        
        let filterButton = UIButton(type: .custom).then {
            $0.setFAIcon(icon: .FAFilter, iconSize: 24, forState: .normal)
            $0.setFATitleColor(color: .white)
            $0.reactive.pressed = CocoaAction<UIButton>(viewModel.filter)
        }
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge).then {
            $0.hidesWhenStopped = true
            $0.reactive.isAnimating <~ viewModel.isLoading
        }
        
        // MARK: Add Subviews
        
        container.addSubview(iconLabel)
        container.addSubview(textLabel)
        container.addSubview(filterButton)
        container.addSubview(attributionLabel)
        container.addSubview(activityIndicator)
        self.addSubview(container)
        
        // MARK: Layout
        
        let vMargin: CGFloat = 8
        let hMargin: CGFloat = 8
        let hInterLabelMargin: CGFloat = 8
        let vAttributionTopMargin: CGFloat = 16
        
        container |=| self.m_edges ~ (UIApplication.shared.statusBarFrame.height + vMargin, 0, 0, 0)
        
        iconLabel |=| container.m_top
        iconLabel |=| container.m_leading + hMargin
        
        textLabel |=| iconLabel.m_centerY
        textLabel.m_leading |=| iconLabel.m_trailing + hInterLabelMargin
        
        filterButton |=| iconLabel.m_centerY
        filterButton |=| container.m_trailing - hMargin
        
        attributionLabel |=| container.m_sides
        attributionLabel.m_top |=| iconLabel.m_bottom + vAttributionTopMargin
        
        activityIndicator |=| container.m_center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
