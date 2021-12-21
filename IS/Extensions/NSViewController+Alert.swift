//
//  NSViewController+Alert.swift
//  Permits
//
//  Created by Andrew on 10/10/21.
//  Copyright © 2020 Andrew Yakovlev. All rights reserved.
//

import AppKit

extension NSViewController {
    
    @discardableResult
    func presentAlert(title: String, description: String = "", style: NSAlert.Style = .informational) -> Bool {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = description
        alert.alertStyle = style
        alert.addButton(withTitle: "OK")
        return alert.runModal() == .alertFirstButtonReturn
    }
}
