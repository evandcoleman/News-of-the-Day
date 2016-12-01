//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Font_Awesome_Swift
import Mortar
import Then
import UIKit

class BackgroundView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // MARK: Configure Subviews
        
        let container = UIView()
        let textContainer = UIView()
        
        let iconLabel = UILabel().then {
            $0.textColor = .white
            $0.setFAIcon(icon: .FANewspaperO, iconSize: 24)
        }
        
        let textLabel = UILabel().then {
            $0.textColor = .white
            $0.font = UIFont.systemFont(ofSize: 17)
            $0.text = "News"
        }
        
        // MARK: Add Subviews
        
        textContainer.addSubview(iconLabel)
        textContainer.addSubview(textLabel)
        container.addSubview(textContainer)
        self.addSubview(container)
        
        // MARK: Layout
        
        let vMargin: CGFloat = 8
        let hMargin: CGFloat = 8
        let hInterLabelMargin: CGFloat = 8
        
        container |=| self.m_edges ~ (UIApplication.shared.statusBarFrame.height + vMargin, 0, 0, 0)
        
        textContainer |=| container
        
        iconLabel |=| textContainer.m_top
        iconLabel |=| textContainer.m_leading + hMargin
        
        textLabel |=| iconLabel.m_centerY
        textLabel.m_leading |=| iconLabel.m_trailing + hInterLabelMargin
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
