//
//  Playlist.swift
//  PodSync
//
//  Created by Davis Hoang on 13/4/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Foundation
import iTunesLibrary

class struct_playlist
{
    struct playlist {
        var name: String
        var totalSongs: Int
        var size: String?
    }
    
    public static func playlistInfo(name: [String]) -> [playlist]
    {
        var result = [playlist]()
        
        let playlists = Utilities.myItuneLibrary.allPlaylists
        
        for item in playlists
        {
            for i in name
            {
                if item.name == i
                {
                    let a = playlist.init(name: item.name, totalSongs: item.items.count, size: CalculateSize.actualFileSize(item.items))
                    result.append(a)
                }
            }
        }
        
        return result
    }
    
}
