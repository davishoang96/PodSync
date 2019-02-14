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
    
    private static let builtinPlaylist = ["Music","Music Videos","TV and Movies", "Movies", "Home Videos", "TV Shows", "Podcasts", "Audiobooks","Purchased", "TV & Films", "Films", "TV Programmes"]
    
    private static var totalsong: Double?

    
    static func reloadLibrary()
    {
        library.reloadData()
    }
    
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
        library.reloadData()
        
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
                        
                        item = Array(Set(item))
                    }
                }
            }
        }
        totalsong = Double(item.count)
        return item
    }
    
    static func getTotalSong() -> Double
    {
        if let totalsong = totalsong
        {
            return totalsong
        }
        else
        {
            return 0
        }
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
    
    static func Get_FolderItemURL(_ destinationFolder: URL) -> [URL]?
    {
        var files = [URL]()
        
        do
        {
            let contents = try fileManager.contentsOfDirectory(at: destinationFolder, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            for eachfile in contents
            {
                files.append(eachfile)
            }
            
            return files
            
        }
        catch
        {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func Get_LastPathComponent(_ destinationFolder: URL) -> [String]
    {
        var fileName = [String]()
        if let items = Get_FolderItemURL(destinationFolder)
        {
            for eachItem in items
            {
                fileName.append(eachItem.lastPathComponent)
            }
        }
        return fileName
    }
    
    static func Get_SongName(_ songs: [ITLibMediaItem]) -> [String]
    {
        var SongNames = [String]()
        for eachsong in songs
        {
            if let lastPath = eachsong.location?.lastPathComponent
            {
                SongNames.append(lastPath)
            }
        }
        return SongNames
    }
    
    static func Remove_NonExistItems(itemURL: [URL], songName: [String])
    {
        var i = 0
        do
        {
            for eachitem in itemURL
            {
                if songName.contains(eachitem.lastPathComponent)
                {
                    //print(i, "MATCHED", eachitem.lastPathComponent)
                }
                else
                {
                    print(i, "NOT MATCHED", eachitem.lastPathComponent)
                    
                    try fileManager.trashItem(at: eachitem, resultingItemURL: nil)
                }
                i+=1
            }
        }
        catch
        {
            print(error.localizedDescription)
            return
        }
    }
    
    
    static func get_numOf_ExistedSongs(itemURL: [URL], songName: [String]) -> Double
    {
        var result: Double = 0
        for eachitem in itemURL
        {
            if songName.contains(eachitem.lastPathComponent)
            {
                result+=1
            }
        }
        return result
    }
    
    
    static func get_SongMDateLib(_ songs: [ITLibMediaItem]) -> [Date]
    {
        var date = [Date]()
        
        for eachsong in songs
        {
            if let modifiedDate = eachsong.modifiedDate
            {
                date.append(modifiedDate)
            }
        }
        return date
    }
    
    static func get_SongMDateFolder(items: [URL]) -> [Date]?
    {
        var date = [Date]()
        
        do
        {
            for eachitem in items
            {
                var itemDate = try fileManager.attributesOfItem(atPath: eachitem.path)
                
                if let fileDate = itemDate[FileAttributeKey.modificationDate]
                {
                    date.append(fileDate as! Date)
                }
                
            }
            return date
        }
        catch
        {
            print(error.localizedDescription)
            return nil
        }
    }    
}
