//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import ReactiveSwift
import UIKit

class ViewController<T: ViewModel>: UIViewController {
    let viewModel: T
    
    init(viewModel: T) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        self.installErrorHandler(viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class TableViewController<T: ViewModel>: UITableViewController {
    let viewModel: T
    
    public init(viewModel: T, style: UITableViewStyle) {
        self.viewModel = viewModel
        
        super.init(style: style)
        
        self.installErrorHandler(viewModel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class CollectionViewController<T: ViewModel>: UICollectionViewController {
    let viewModel: T
    
    public init(viewModel: T, layout: UICollectionViewLayout) {
        self.viewModel = viewModel
        
        super.init(collectionViewLayout: layout)
        
        self.installErrorHandler(viewModel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIViewController {    
    func installErrorHandler(_ viewModel: ViewModel) {
        viewModel.errors
            .observe(on: UIScheduler())
            .observeValues { [weak self] error in
                guard let `self` = self else { return }
                
                print(error)
                
                let title = error.localizedDescription
                let message = error.localizedRecoverySuggestion ?? error.localizedFailureReason
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
        }
    }
}
