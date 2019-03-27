//
//  DataRadio.swift
//  PodSync
//
//  Created by edi on 16/2/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Foundation

class myDataRadio
{
    static func DataRadio(_ station: String)
    {
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(station), object: self)
    }
}
