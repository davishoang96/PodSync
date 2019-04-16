//
//  ConsoleMessage.swift
//  PodSync
//
//  Created by Davis Hoang on 16/4/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Foundation

class ConsoleMessage
{
    struct message{
        var time: String
        var description: String
    }
    
    public static func updateMessage(des: String) -> message
    {

        let locale = NSLocale.current
        let date_formatter = DateFormatter()
        let current_date = Date()
        date_formatter.dateFormat = "HH:mm:ss"
        date_formatter.locale = locale
        
        let time = date_formatter.string(from: current_date)
        
        let new_message = message.init(time: time, description: des)
        return new_message
        
    }
}
