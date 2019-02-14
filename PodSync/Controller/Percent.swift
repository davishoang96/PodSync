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
    // Percent of eachsong
    private static var totalsong = Utilities.getTotalSong() - Synchronize.num_existedSong()
    
    static func calpercent() -> Double
    {
        let percent = 100 / totalsong
    
        print(percent)
        
        return percent
    }
    
    static func remainedPercent() -> Double
    {
        let percent_eachsong = calpercent()
        let ongoingPercent = percent_eachsong * Synchronize.num_existedSong()
        print(ongoingPercent)
        return 100 - ongoingPercent
    }
    
    

}
