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

class HeaderView: UIView {
    let viewModel: HeaderViewModel
    
    private let searchField = UITextField()
    
    init(viewModel: HeaderViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        // MARK: Configure Subviews
        
        self.backgroundColor = .black
        self.clipsToBounds = true
        
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
        
        let filterButton = UIButton(type: .custom).then {
            $0.setFAIcon(icon: .FAFilter, iconSize: 24, forState: .normal)
            $0.setFATitleColor(color: .white)
            $0.reactive.pressed = CocoaAction<UIButton>(viewModel.filter)
        }
        
        let searchButton = UIButton(type: .custom).then {
            $0.setFAIcon(icon: .FASearch, iconSize: 24, forState: .normal)
            $0.setFATitleColor(color: .white)
            $0.reactive.pressed = CocoaAction<UIButton>(viewModel.search)
        }
        
        let searchFieldMask = UIView().then {
            $0.backgroundColor = self.backgroundColor
        }
        
        self.searchField.do {
            $0.attributedPlaceholder = NSAttributedString(string: "Search Publications", attributes: [NSForegroundColorAttributeName: UIColor.lightText])
            $0.textColor = .white
            $0.returnKeyType = .done
            $0.delegate = self
            $0.reactive.continuousTextValues.observe(viewModel.searchSink)
        }
        
        // MARK: Add Subviews
        
        self.addSubview(iconLabel)
        self.addSubview(textLabel)
        self.addSubview(searchButton)
        self.addSubview(self.searchField)
        self.addSubview(searchFieldMask)
        self.addSubview(filterButton)
        
        // MARK: Layout
        
        let vMargin: CGFloat = 8
        let hMargin: CGFloat = 8
        let hInterLabelMargin: CGFloat = 8
        let hInterButtonMargin: CGFloat = 8
        
        iconLabel |=| self.m_top + vMargin
        iconLabel |=| self.m_leading + hMargin
        iconLabel |=| self.m_bottom - vMargin
        
        textLabel |=| iconLabel.m_centerY
        textLabel.m_leading |=| iconLabel.m_trailing + hInterLabelMargin
        
        filterButton |=| iconLabel.m_centerY
        filterButton |=| self.m_trailing - hMargin
        
        searchButton |=| filterButton.m_centerY
        searchButton.m_trailing |=| filterButton.m_leading - hInterButtonMargin
        
        self.searchField |=| searchButton.m_centerY
        self.searchField.m_leading |=| searchButton.m_trailing + hInterButtonMargin
        
        searchFieldMask |=| self.searchField.m_leading
        searchFieldMask |=| self.m_trailing
        searchFieldMask |=| self.searchField.m_height
        searchFieldMask |=| self.searchField.m_centerY
                
        // MARK: Logic
        
        self.viewModel.isSearching.producer
            .skipRepeats()
            .startWithValues { [weak self] isSearching in
                guard let `self` = self else { return }
                
                if isSearching {
                    UIView.animate(withDuration: 0.36, animations: { 
                        let deltaY = max(iconLabel.bounds.height, textLabel.bounds.height) * 2
                        iconLabel.transform = CGAffineTransform(translationX: 0, y: deltaY)
                        textLabel.transform = CGAffineTransform(translationX: 0, y: deltaY)
                        
                        let deltaX = -(searchButton.frame.minX - iconLabel.frame.minX)
                        searchButton.transform = CGAffineTransform(translationX: deltaX, y: 0)
                        self.searchField.transform = CGAffineTransform(translationX: deltaX, y: 0)
                    }) { _ in
                        self.searchField.becomeFirstResponder()
                        
                        iconLabel.isHidden = true
                        textLabel.isHidden = true
                    }
                } else {
                    self.searchField.resignFirstResponder()
                    iconLabel.isHidden = false
                    textLabel.isHidden = false
                    
                    UIView.animate(withDuration: 0.36) {
                        iconLabel.transform = .identity
                        textLabel.transform = .identity
                        searchButton.transform = .identity
                        self.searchField.transform = .identity
                    }
                }
            }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIResponder
    
    override var canResignFirstResponder: Bool {
        return self.searchField.canResignFirstResponder
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        return self.searchField.resignFirstResponder()
    }
}

// MARK: UITextFieldDelegate

extension HeaderView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return false
    }
}
