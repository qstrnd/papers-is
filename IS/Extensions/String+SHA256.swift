//
//  String+SHA256.swift
//  Permits
//
//  Created by Andrew on 5/11/20.
//  Copyright © 2020 Andrew Yakovlev. All rights reserved.
//

import Foundation

extension String {
    func sha256() -> String {
        self.data(using: .utf32)!.sha256()
    }
}
