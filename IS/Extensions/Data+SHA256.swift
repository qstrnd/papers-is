//
//  Data+SHA256.swift
//  Permits
//
//  Created by Andrew on 10/10/21.
//  Copyright © 2020 Andrew Yakovlev. All rights reserved.
//

import Foundation
import CryptoKit

extension Data {
    func sha256() -> String {
        SHA256.hash(data: self).compactMap({ String(format: "%02x", $0) }).joined()
    }
}
