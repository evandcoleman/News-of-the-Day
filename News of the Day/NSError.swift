//
//  News of the Day
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Foundation
import ReactiveSwift

enum ErrorCode: Int {
    case generic = 9000
}

let ErrorDomain = Bundle.main.bundleIdentifier ?? ""

extension NSError {
    static func generic(_ description: String, underlyingError: NSError? = nil) -> NSError {
        var userInfo: [String: AnyObject] = [NSLocalizedDescriptionKey: description as AnyObject]
        if let error = underlyingError {
            userInfo[NSUnderlyingErrorKey] = error
        }
        
        return NSError(domain: ErrorDomain, code: ErrorCode.generic.rawValue, userInfo: userInfo)
    }
    
    static func error(_ code: ErrorCode, description: String) -> NSError {
        return NSError(domain: ErrorDomain, code: code.rawValue, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
