//
//  CalculateSize.swift
//  PodSync
//
//  Created by Davis Hoang on 10/4/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Foundation
import Cocoa
import iTunesLibrary

class CalculateSize
{
    public static func actualFileSize(_ songs: [ITLibMediaItem]) -> String
    {
        var size: Int64 = 0
        
        for eachsong in songs
        {
            size += Int64(eachsong.fileSize)
        }
        
        let bcf = ByteCountFormatter()
        
        bcf.allowedUnits = [.useMB]
        bcf.countStyle = .file
        
        let result = bcf.string(fromByteCount: size)
        
        
        return result
    }
    
}
