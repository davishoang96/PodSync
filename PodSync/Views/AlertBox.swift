//
//  AlertBox.swift
//  PodSync
//
//  Created by edi on 14/2/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Foundation
import Cocoa

class alertBox
{
    static func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    
    
}
