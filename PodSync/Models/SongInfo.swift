//
//  SongInfo.swift
//  PodSync
//
//  Created by Davis Hoang on 8/4/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Foundation

class SongInfo
{
    public var artistName: String = "Hans Zimmer"
    public var albumArtist: String = "DC"
    public var albumTitle: String = "Man of Steel"
    
    init(artist_name: String, album_artist: String, album_title: String) {
        self.artistName = artist_name
        self.albumArtist = album_artist
        self.albumTitle = album_title
    }
    
    
}


