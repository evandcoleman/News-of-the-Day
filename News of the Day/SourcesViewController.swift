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

class SourcesViewController: CollectionViewController<SourcesViewModel>, HFCardCollectionViewLayoutDelegate {
    private let layout: HFCardCollectionViewLayout
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    init(viewModel: SourcesViewModel) {
        self.layout = HFCardCollectionViewLayout().then {
            $0.spaceAtTopForBackgroundView = 44
        }
    
        super.init(viewModel: viewModel, layout: self.layout)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Configure Subviews
        
        let backgroundView = BackgroundView(viewModel: self.viewModel.backgroundViewModel)
        
        self.collectionView?.do {
            $0.register(SourceCell.self, forCellWithReuseIdentifier: SourceCell.reuseIdentifier)
            $0.backgroundView = backgroundView
        }
        
        // MARK: Logic/Bindings
        
        self.viewModel.sources.producer
            .observe(on: UIScheduler())
            .startWithValues { [weak self] _ in
                self?.collectionView?.reloadData()
            }
        
        self.viewModel.openSource.values
            .observeValues { [weak self] idx in
                guard let `self` = self else { return }
                
                self.layout.revealCardAt(index: idx)
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {        
        self.viewModel.openSource.apply(indexPath.row).start()
    }
    
    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, willRevealCardAtIndex index: Int) {
        let viewModel = self.viewModel.sources.value[index]
        
        viewModel.isRevealed.value = true
        self.viewModel.backgroundViewModel.showAttribution.value = false
    }
    
    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, willUnrevealCardAtIndex index: Int) {
        let viewModel = self.viewModel.sources.value[index]
        
        viewModel.isRevealed.value = false
    }
    
    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, didUnrevealCardAtIndex index: Int) {
        self.viewModel.backgroundViewModel.showAttribution.value = true
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.sources.value.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SourceCell.reuseIdentifier, for: indexPath) as! SourceCell
        
        cell.viewModel.value = self.viewModel.sources.value[indexPath.item]
        cell.headHeight.value = self.layout.cardHeadHeight
        
        return cell
    }
}
