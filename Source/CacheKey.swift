//
//  CacheKey.swift
//  DaisyNet
//
//  Created by pro big on 2024/6/21.
//

import UIKit
import Cache

class CacheKey {
    static func with(_ identifier: String?) -> String? {
        if let identifier = identifier, identifier.isEmpty == false {
            return MD5(identifier)
        }
        return nil
    }
}
