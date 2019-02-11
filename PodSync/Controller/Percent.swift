//
//  Percent.swift
//  PodSync
//
//  Created by edi on 11/2/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Foundation

class SyncPercent
{
    static func calpercent() -> Double
    {
        let totalsong = Utilities.getTotalSong()
        let percent = 100 / totalsong
        return percent
    }
}
