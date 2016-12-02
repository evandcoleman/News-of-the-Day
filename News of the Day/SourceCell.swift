//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Kingfisher
import Mortar
import ReactiveCocoa
import ReactiveSwift
import enum Result.NoError
import Then
import UIKit

class SourceCell: UICollectionViewCell, Reusable {
    
    let viewModel = MutableProperty<SourceViewModel?>(nil)
    let headHeight = MutableProperty<CGFloat>(0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // MARK: Configure Subviews
        
        self.layer.cornerRadius = 12.s        
        let shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shadowPath = shadowPath
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(white: 0.0, alpha: 0.2).cgColor
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.rasterizationScale = UIScreen.main.scale
        self.layer.shouldRasterize = true
        self.clipsToBounds = false
        
        let nameLabel = UILabel().then {
            $0.textColor = .black
            $0.font = UIFont.boldSystemFont(ofSize: 17)
        }
        
        let imageView = UIImageView().then {
            $0.contentMode = .scaleAspectFit
        }
        
        let sortControl = UISegmentedControl().then {
            $0.tintColor = .white
        }
        
        let refreshControl = UIRefreshControl()
        
        let tableView = UITableView().then {
            $0.register(ArticleCell.self, forCellReuseIdentifier: ArticleCell.reuseIdentifier)
            $0.delegate = self
            $0.dataSource = self
            $0.backgroundColor = .clear
            $0.separatorStyle = .none
            $0.rowHeight = UITableViewAutomaticDimension
            $0.estimatedRowHeight = 120
        }

        // MARK: Add Subviews
        
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(sortControl)
        self.contentView.addSubview(tableView)
        tableView.addSubview(refreshControl)
        tableView.sendSubview(toBack: refreshControl)
        
        // MARK: Layout
        
        let vMargin = 12.s
        let hMargin = 12.s
        let vInterMargin = 12.s
        let hInterMargin = 8.s
        
        nameLabel |=| self.contentView.m_top + vMargin
        nameLabel |=| self.contentView.m_leading + hMargin
        nameLabel |=| self.contentView.m_width * 0.75
        
        imageView.m_leading |=| nameLabel.m_trailing + hInterMargin ! .required
        imageView |=| self.contentView.m_trailing - hMargin ! .required
        let imageViewBottomConstraint = imageView.m_bottom |=| self.contentView.m_top + (self.headHeight.value - vMargin)
        let imageViewHeightConstraint = imageView.m_height |=| max(self.headHeight.value - (vMargin * 2), 0)
        
        sortControl.m_top |=| imageView.m_bottom + vInterMargin
        sortControl |=| self.contentView.m_centerX
        
        let tableViewTopConstraint = tableView.m_top |=| sortControl.m_bottom + vInterMargin
        tableView |=| self.contentView.m_sides ~ (hMargin, hMargin)
        tableView |=| self.contentView.m_bottom - vMargin
        
        // MARK: Bindings
        
        self.reactive.backgroundColor <~ self.viewModel.map { $0?.backgroundColor }
        nameLabel.reactive.text <~ self.viewModel.map { $0?.name }
        nameLabel.reactive.textColor <~ self.viewModel.map { $0?.textColor ?? .black }
        sortControl.reactive.isHidden <~ self.viewModel.map { !($0?.showsSortOrders ?? false) }
        
        sortControl.reactive
            .selectedSegmentIndexes
            .observeValues { [weak self] idx in
                let order = self?.viewModel.value?.sortOrders[idx] ?? .top
                self?.viewModel.value?.sortOrder.value = order
            }
        
        refreshControl.reactive
            .trigger(for: .valueChanged)
            .observeValues { [weak self] _ in
                self?.viewModel.value?.refreshArticles.apply().start()
            }
        
        self.viewModel.producer
            .skipNil()
            .flatMap(.latest) { SignalProducer.combineLatest($0.isRevealed.producer, SignalProducer<Bool, NoError>(value: $0.showsSortOrders)) }
            .startWithValues { [weak self] isRevealed, showsSortOrders in
                sortControl.isHidden = !isRevealed || !showsSortOrders
                tableView.isHidden = !isRevealed
                tableViewTopConstraint.layoutConstraints
                    .forEach { $0.constant = showsSortOrders ? vInterMargin : -sortControl.bounds.height }
                
                self?.contentView.setNeedsLayout()
                self?.contentView.layoutIfNeeded()
            }
        
        self.viewModel.producer
            .skipNil()
            .flatMap(.latest) { $0.isLoading }
            .startWithValues { loading in
                if loading {
                    refreshControl.beginRefreshing()
                } else {
                    refreshControl.endRefreshing()
                }
            }
        
        self.viewModel
            .map { $0?.logoURL }
            .producer
            .startWithValues { imageURL in
                imageView.kf.setImage(with: imageURL)
            }
        
        self.viewModel
            .map { ($0?.sortOrder.value ?? .top, $0?.sortOrders ?? []) }
            .producer
            .startWithValues { sortOrder, sortOrders in
                sortControl.removeAllSegments()
                sortOrders.enumerated()
                    .forEach { sortControl.insertSegment(withTitle: $1.name(), at: $0, animated: false) }
                sortControl.selectedSegmentIndex = sortOrders.index(of: sortOrder) ?? 0
            }
        
        self.headHeight.producer
            .startWithValues { [weak self] headHeight in
                imageViewBottomConstraint.layoutConstraints
                    .forEach { $0.constant = headHeight - vMargin }
                imageViewHeightConstraint.layoutConstraints
                    .forEach { $0.constant = max(headHeight - (vMargin * 2), 0) }
                
                self?.contentView.setNeedsLayout()
                self?.contentView.layoutIfNeeded()
            }
        
        self.viewModel.producer
            .flatMap(.latest) { viewModel -> SignalProducer<[ArticleViewModel], NoError> in
                return viewModel?.articles.producer ?? SignalProducer(value: [])
            }
            .observe(on: UIScheduler())
            .startWithValues { _ in
                tableView.reloadData()
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

// MARK: UITableViewDelegate

extension SourceCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let article = self.viewModel.value?.articles.value[indexPath.row] else { return }
        
        self.viewModel.value?.openArticle.apply(article.url).start()
    }
}

// MARK: UITableViewDataSource

extension SourceCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.value?.articles.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCell.reuseIdentifier, for: indexPath) as? ArticleCell else { fatalError() }
        
        cell.viewModel.value = self.viewModel.value?.articles.value[indexPath.row]
        
        return cell
    }
}
