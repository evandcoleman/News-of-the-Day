//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Kingfisher
import Mortar
import ReactiveSwift
import Then
import UIKit

class ArticleCell: UITableViewCell, Reusable {
    
    let viewModel = MutableProperty<ArticleViewModel?>(nil)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        // MARK: Configure Subviews
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        let subtitleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12)
            $0.reactive.text <~ self.viewModel.map { $0?.subtitle }
            $0.reactive.textColor <~ self.viewModel.map { $0?.textColor ?? .black }
        }
        
        let titleLabel = UILabel().then {
            $0.font = UIFont.boldSystemFont(ofSize: 17)
            $0.numberOfLines = 2
            $0.reactive.text <~ self.viewModel.map { $0?.title }
            $0.reactive.textColor <~ self.viewModel.map { $0?.textColor ?? .black }
        }
        
        let timeLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12)
            $0.textAlignment = .right
            $0.reactive.text <~ self.viewModel.map { $0?.timestamp }
            $0.reactive.textColor <~ self.viewModel.map { $0?.lightTextColor ?? .black }
        }
        
        let summaryLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12)
            $0.numberOfLines = 3
            $0.reactive.text <~ self.viewModel.map { $0?.summary }
            $0.reactive.textColor <~ self.viewModel.map { $0?.lightTextColor ?? .black }
        }
        
        let imageView = UIImageView().then {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
        
        let separatorView = UIView().then {
            $0.reactive.backgroundColor <~ self.viewModel.map { $0?.separatorColor ?? .lightGray }
        }
        
        // MARK: Add Subviews

        self.contentView.do {
            $0.addSubview(subtitleLabel)
            $0.addSubview(titleLabel)
            $0.addSubview(timeLabel)
            $0.addSubview(summaryLabel)
            $0.addSubview(imageView)
            $0.addSubview(separatorView)
        }
        
        // MARK: Layout
        
        let vMarginTop = 12.s
        let vMarginBottom = 12.s
        let hMargin = 12.s
        let vInterLabelMargin = 4.s
        let hInterLabelMargin = 12.s
        let imageViewSide = 68.s
        let hTimeLabelWidth = 56.s
        
        imageView.m_size |=| (imageViewSide, imageViewSide) ! .required
        imageView |=| self.contentView.m_trailing - hMargin
        imageView |=| titleLabel.m_top
        
        timeLabel |=| self.contentView.m_top + vMarginTop
        timeLabel |=| self.contentView.m_trailing - hMargin
        timeLabel.m_width |=| hTimeLabelWidth
        
        subtitleLabel |=| self.contentView.m_top + vMarginTop
        subtitleLabel |=| self.contentView.m_leading + hMargin
        subtitleLabel.m_trailing |=| timeLabel.m_leading - hInterLabelMargin
        
        titleLabel |=| self.contentView.m_leading + hMargin
        titleLabel.m_top |=| subtitleLabel.m_bottom + vInterLabelMargin
        titleLabel.m_trailing |=| imageView.m_leading - hMargin ! .required
        
        summaryLabel.m_top |=| titleLabel.m_bottom + vInterLabelMargin
        summaryLabel |=| self.contentView.m_leading + hMargin
        summaryLabel.m_trailing |=| imageView.m_leading - hMargin
        summaryLabel |=| self.contentView.m_bottom - vMarginBottom
        
        separatorView |=| self.contentView.m_sides ~ (hMargin, hMargin)
        separatorView |=| self.contentView.m_bottom
        separatorView.m_height |=| 1
        
        // MARK: Logic/Bindings
        
        self.viewModel.producer
            .observe(on: UIScheduler())
            .startWithValues { viewModel in
                imageView.kf.setImage(with: viewModel?.imageURL)
            }
        
        self.reactive.prepareForReuse
            .observeValues { [weak self] _ in
                self?.viewModel.value = nil
            }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
