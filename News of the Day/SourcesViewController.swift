//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Font_Awesome_Swift
import HFCardCollectionViewLayout
import Mortar
import ReactiveCocoa
import ReactiveSwift
import SafariServices
import Then
import UIKit

class SourcesViewController: ViewController<SourcesViewModel>, UICollectionViewDataSource, HFCardCollectionViewLayoutDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Configure Subviews
        
        self.view.backgroundColor = .black
        
        let headerView = HeaderView(viewModel: self.viewModel.headerViewModel)
        
        let attributionLabel = UILabel().then {
            $0.text = "Powered by News API\nnewsapi.org"
            $0.numberOfLines = 2
            $0.textAlignment = .center
            $0.textColor = .white
            $0.font = UIFont.systemFont(ofSize: 10)
            $0.reactive.isHidden <~ self.viewModel.isAttributionHidden
        }
        
        let emptyStateLabel = UILabel().then {
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.textColor = .white
            $0.font = UIFont.systemFont(ofSize: 16)
            $0.reactive.text <~ self.viewModel.emptyStateText
        }
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge).then {
            $0.hidesWhenStopped = true
            $0.reactive.isAnimating <~ self.viewModel.isLoading
        }
        
        let layout = HFCardCollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
            $0.register(SourceCell.self, forCellWithReuseIdentifier: SourceCell.reuseIdentifier)
            $0.delegate = self
            $0.dataSource = self
            $0.backgroundColor = .clear
        }
        
        // MARK: Add Subviews
        
        self.view.addSubview(headerView)
        self.view.addSubview(attributionLabel)
        self.view.addSubview(activityIndicator)
        self.view.addSubview(emptyStateLabel)
        self.view.addSubview(collectionView)
        
        // MARK: Layout
        
        let vAttributionTopMargin: CGFloat = 8
        
        headerView.m_top |=| self.m_topLayoutGuideBottom
        headerView |=| self.view.m_sides
        
        attributionLabel |=| self.view.m_sides
        attributionLabel.m_top |=| headerView.m_bottom + vAttributionTopMargin
        
        activityIndicator |=| self.view.m_center
        
        emptyStateLabel |=| self.view.m_center
        
        collectionView.m_top |=| headerView.m_bottom
        collectionView |=| self.view.m_sides
        collectionView |=| self.view.m_bottom
        
        // MARK: Logic/Bindings
        
        self.viewModel.sources.producer
            .startWithValues { _ in
                collectionView.reloadData()
            }
        
        self.viewModel.openSource.values
            .observeValues { idx in
                headerView.resignFirstResponder()
                
                layout.revealCardAt(index: idx)
            }
        
        self.viewModel.openURL.values
            .observeValues { [weak self] url in
                let viewController = SFSafariViewController(url: url, entersReaderIfAvailable: true)
                
                self?.present(viewController, animated: true, completion: nil)
            }
        
        self.viewModel.filter.values
            .observeValues { [weak self] categories in
                guard let `self` = self else { return }
                let alertController = UIAlertController(title: "Filter", message: "Select a category to filter news sources by.", preferredStyle: .actionSheet)
                let action = self.viewModel.setCategory
                
                categories.forEach {
                    alertController.reactive.addAction(withTitle: $0.title, style: .default, action: CocoaAction<UIAlertAction>(action, input: $0))
                }
                
                self.present(alertController, animated: true, completion: nil)
            }
    }
    
    // MARK: HFCardCollectionViewLayoutDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.openSource.apply(indexPath.row).start()
    }
    
    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, willRevealCardAtIndex index: Int) {
        let viewModel = self.viewModel.sources.value[index]
        
        viewModel.isRevealed.value = true
        
        self.viewModel.isSourceRevealed.value = true
    }
    
    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, willUnrevealCardAtIndex index: Int) {
        let viewModel = self.viewModel.sources.value[index]
        
        viewModel.isRevealed.value = false
    }
    
    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, didUnrevealCardAtIndex index: Int) {
        self.viewModel.isSourceRevealed.value = false
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.sources.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SourceCell.reuseIdentifier, for: indexPath) as! SourceCell
        
        cell.viewModel.value = self.viewModel.sources.value[indexPath.item]
        if let layout = collectionView.collectionViewLayout as? HFCardCollectionViewLayout {
            cell.headHeight.value = layout.cardHeadHeight
        }
        
        return cell
    }
}
