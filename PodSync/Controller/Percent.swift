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
    
    
    static func calpercent() -> Double
    {
        let percent_eachsong = 100 / Utilities.getTotalSong()
        
        return percent_eachsong
    }
    
    static func remainedPercent() -> Double
    {
        let percent_eachsong = 100 / Utilities.getTotalSong()
        
        let ongoingPercent = percent_eachsong * Synchronize.num_existedSong()
        
        return ongoingPercent
    }
    
    

}
