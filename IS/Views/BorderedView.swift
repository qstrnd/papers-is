//
//  HideView.swift
//  Permits
//
//  Created by Andrew on 5/11/20.
//  Copyright © 2020 Andrew Yakovlev. All rights reserved.
//

import Cocoa

class BorderedView: NSView {
    
    override var wantsUpdateLayer: Bool {
        return true
    }
    
    override func updateLayer() {
        super.updateLayer()
        layer?.borderWidth = 1
        layer?.borderColor = #colorLiteral(red: 0.7528718114, green: 0.7529841065, blue: 0.7528576255, alpha: 1)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        updateLayer()
    }
    
}
