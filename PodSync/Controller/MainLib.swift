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
    
    private static let library = try! ITLibrary.init(apiVersion: "1.1")
    
    static let fileManager = FileManager.default
    
    private static let builtinPlaylist = ["Library","Music","Music Videos","TV and Movies", "Movies", "Home Videos", "TV Shows", "Podcasts", "Audiobooks","Purchased"]
    
    
    static func getUserHomeDirectory() -> URL
    {
        let homeDirectory = fileManager.homeDirectoryForCurrentUser
        let result = homeDirectory.absoluteURL
        return result
    }
    
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
    
    

    
    
    static func getFolderItems(folderLocation: URL) -> [String]?
    {
        var files = [String]()
        
        let content = try! fileManager.contentsOfDirectory(at: folderLocation, includingPropertiesForKeys: nil)
        
        for eachFile in content
        {
            files.append(eachFile.lastPathComponent)
        }
        
        return files
    }
    
    static func getSongLocations(songs: [ITLibMediaItem]) -> [URL]
    {
        var locations = [URL]()
        for eachsong in songs
        {
            locations.append(eachsong.location!)
        }
        return locations
    }
    
    static func sync(songs: [ITLibMediaItem], destinationFolder: URL)
    {
        
        var folderItems = [String]()
        var i = 0
        
        // 1. Scan the sync folder
        if let content = getFolderItems(folderLocation: destinationFolder)
        {
            folderItems = content
        }
        

        
        // 2. Check if songs in playlist are equal in the sync folder
        for eachsong in songs
        {
            if folderItems.contains((eachsong.location?.lastPathComponent)!)
            {
                print(i, "MATCHED")
            }
            else
            {
                print(i, "NOT MATCHED")
            }
            i+=1
        }
        
        
        // 2. Get songs
        
        
        // Sync
    }
    
    
    
    
    
}
