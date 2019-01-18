//
//  MainLib.swift
//  PodSync
//
//  Created by Viet on 17/1/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Foundation
import iTunesLibrary


class Utilities{
    
    static let library = try! ITLibrary.init(apiVersion: "1.1")
    
    static let builtinPlaylist = ["Library","Music","Music Videos","TV and Movies", "Movies", "Home Videos", "TV Shows", "Podcasts", "Audiobooks","Purchased"]
    
    static func getLibraryLocation() -> URL?
    {
        do{
            let library = try ITLibrary.init(apiVersion: "1.1")
            return library.mediaFolderLocation!
        }
        catch
        {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func getPlaylist() -> [String]
    {
        let playlists = library.allPlaylists
        var temp_plist = [String]()
        var p = [String]()
        
        for eachplaylist in playlists
        {
            temp_plist.append(eachplaylist.name)
            p = temp_plist.filter {
                !builtinPlaylist.contains($0)
            }
        }
        return p
    }
    
    static func getSong(name: [String]) -> [ITLibMediaItem]
    {
        var item = [ITLibMediaItem]()
        for eachplaylist in library.allPlaylists
        {
            for pls in name
            {
                if eachplaylist.name == pls
                {
                    for song in eachplaylist.items
                    {
                        item.append(song)
                    }
                }
            }
        }
        return item
    }
    
    
    
    static func getFolderItems(location: URL) -> [String]
    {
        return ["nil"]
    }
    
    static func sync(songs: [ITLibMediaItem])
    {
        for eachsong in songs
        {
            print(eachsong.title)
        }
    }
    
    
    
}
