//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let apiClient = APIClient(apiKey: "dbc75b3007bd4af3b1eccea633c25356")
        let sourcesViewModel = SourcesViewModel(apiClient: apiClient)
        let sourcesViewController = SourcesViewController(viewModel: sourcesViewModel)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = sourcesViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

