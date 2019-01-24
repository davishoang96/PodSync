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
    
    static func removeDuplicate(_ songs: [ITLibMediaItem], _ playlist: [String]) -> [ITLibMediaItem]
    {
        var item = [ITLibMediaItem]()
        
        for eachplaylist in library.allPlaylists
        {
            for pls in playlist
            {
                if eachplaylist.name == pls
                {
                    for song in eachplaylist.items
                    {
                        item.append(song)
                        
                        item = Array(Set(item))
                    }
                }
            }
        }
        return item
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
                        
                        item = Array(Set(item))
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
        
        var songName = [String]()
        var folderItems = [String]()
        
        var songpath:String
        var songfilename: String
        var myPath:String
        
        let removePath = destinationFolder.path + "/"
        
        var i = 0
        
        // 1. Scan the sync folder
        if let content = getFolderItems(folderLocation: destinationFolder)
        {
            folderItems = content
        }
        
        // 2. Get song name
        for eachsong in songs
        {
            if let lastPath = eachsong.location?.lastPathComponent{
                songName.append(lastPath)
            }
            print(eachsong.title)
        }
        
        // 3. Compare playlists and folders
        // Remove if item in folder not match with playlist
        do
        {
            for eachItem in folderItems
            {
                if songName.contains(eachItem)
                {
                    print(i, "MATCHED", eachItem)
                }
                else
                {
                    print(i, "NOT MATCHED", eachItem)
                    try fileManager.removeItem(atPath: removePath + eachItem)
                }
                i+=1
            }
        }
        catch
        {
            print(error.localizedDescription)
        }

 
        // 4. SYNC
        do
        {
            for eachsong in songs
            {
                songpath = (eachsong.location?.path)!
                songfilename = (eachsong.location?.lastPathComponent)!
                myPath = destinationFolder.path + "/" + songfilename
                
                
                if let song = eachsong.location?.lastPathComponent
                {
                    if folderItems.contains(song)
                    {
                        print("FILE EXISTED")
                    }
                    else
                    {
                        try fileManager.copyItem(atPath: songpath, toPath: myPath)
                    }
                }
            }
            print(songs.count)
        }
        catch
        {
            print(error.localizedDescription)
        }   
    
    
    }
    
}
