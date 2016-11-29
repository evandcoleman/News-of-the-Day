//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Font_Awesome_Swift
import Mortar
import Then
import UIKit

class HeaderCell: UICollectionReusableView {
    static let resuseIdentifier = "HeaderCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // MARK: Configure Subviews
        
        let label = UILabel().then {
            $0.setFAText(prefixText: "", icon: .FANewspaperO, postfixText: "News", size: 24)
        }
        
        // MARK: Add Subviews
        
        self.addSubview(label)
        
        // MARK: Layout
        
        label |=| self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
