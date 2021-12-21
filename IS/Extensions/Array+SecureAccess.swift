//
//  Array+SecureAccess.swift
//  Permits
//
//  Created by Andrew on 5/22/20.
//  Copyright © 2020 Andrew Yakovlev. All rights reserved.
//

import Foundation

extension Array {
    public subscript(secure index: Int) -> Element? {
        guard index >= 0 && index <= self.count else { return nil }
        return self[index]
    }
}
