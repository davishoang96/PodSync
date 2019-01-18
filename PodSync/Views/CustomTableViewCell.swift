//
//  CustomTableViewCell.swift
//  PodSync
//
//  Created by Viet on 17/1/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Cocoa

class CustomTableViewCell: NSTableCellView {
    
    var sel_checkBox: ((_ sender: NSButton) -> ())?
    @IBOutlet weak var Checkbox: NSButton!
    @IBAction func sel_checkBox(_ sender: NSButton) {
        sel_checkBox?(sender)
    }
    
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
