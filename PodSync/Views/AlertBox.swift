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
    static func dialogOKCancel(question: String, text: String, button: Int) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        if button == 1{
           alert.addButton(withTitle: "Cancel")
        }
        
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    static func showNotification(_ title: String, _ info: String) -> Void {
        
        let notification = NSUserNotification()
        
        notification.title = title
        notification.informativeText = info
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
        
    }
    
}
