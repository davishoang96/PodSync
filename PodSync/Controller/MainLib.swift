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
    
    public static let myItuneLibrary = getLibrary()
    
    static let fileManager = FileManager.default
    
    private static var builtinPlaylist = ["Music","Music Videos","TV and Movies", "Movies", "Home Videos", "TV Shows", "Podcasts", "Audiobooks","Purchased", "TV & Films", "Films", "TV Programmes"]
    
    private static var totalsong: Double?

    private static func LoadLibrary() -> ITLibrary?
    {
        do{
            let library = try ITLibrary.init(apiVersion: "1.1")
            return library
        }
        catch
        {
            print(error.localizedDescription)
            return myItuneLibrary
        }
    }
    
    public static func ShowMainLibrary(_ toggle: Bool)
    {
        if toggle == true
        {

            if builtinPlaylist.contains("Library")
            {
                builtinPlaylist = builtinPlaylist.filter({ $0 != "Library" })
            }
            
        }
        else
        {
            builtinPlaylist.append("Library")
            
        }
        print(builtinPlaylist)
        myDataRadio.DataRadio("ReloadLibrary")
    }
    
    public static func getLibrary() -> ITLibrary
    {
        if let library = LoadLibrary()
        {
            return library
        }
        else
        {
            return myItuneLibrary
        }
    }
    
    
    public static func reloadLibrary()
    {
        myItuneLibrary.reloadData()
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
        myItuneLibrary.reloadData()
        
        let playlists = myItuneLibrary.allPlaylists
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
        
        
        for eachplaylist in myItuneLibrary.allPlaylists
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
                if !eachitem.isDirectory && !eachitem.lastPathComponent.contains("playlists.xml")
                {
                    if !songName.contains(eachitem.lastPathComponent)
                    {
                        //print(i, "NOT MATCHED", eachitem.absoluteString)
                        
                        try fileManager.trashItem(at: eachitem, resultingItemURL: nil)
                    }
                    i+=1
                }
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
    
    static func currentDateTime(date: Date) -> String!
    {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        
        let result = dateFormatter.string(from: date)
        
        return result
    }
    
    static func get_SongMDateLib(_ songs: [ITLibMediaItem]) -> [String]
    {
        var date = [String]()
        do{
            for eachsong in songs
            {
                
                if let filePath = eachsong.location?.path
                {
                    var itemDate = try fileManager.attributesOfItem(atPath: filePath)
                    if let fileDate = itemDate[FileAttributeKey.modificationDate]
                    {
                        let d = Utilities.currentDateTime(date: fileDate as! Date)
                        date.append(d!)
                    }
                }
            }
            print("Total:",date.count)
            return date
        }
        catch
        {
            print(error.localizedDescription)
            return ["Cannot get song's modification date."]
        }
    }
        

    
    
    static func get_SongMDateFolder(items: [URL]) -> [String]?
    {
        var date = [String]()
        
        do
        {
            for eachitem in items
            {
                var itemDate = try fileManager.attributesOfItem(atPath: eachitem.path)
                
                if let fileDate = itemDate[FileAttributeKey.modificationDate]
                {
                    let d = currentDateTime(date: fileDate as! Date)
                    date.append(d!)
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
    
    
    
    
    static func getAlbumName(_ songs: [ITLibMediaItem]) -> [String]
    {
        var items = [String]()
        for eachsong in songs
        {
            if let albumName = eachsong.album.title
            {
                if !items.contains(albumName)
                {
                    items.append(albumName)
                }
            }
            
        }
        return items
    }
    
    static func getArtistName(_ songs: [ITLibMediaItem]) -> [String]
    {
        var items = [String]()
        for eachsong in songs
        {
            if let artistName = eachsong.artist?.name
            {
                if !items.contains(artistName)
                {
                    items.append(artistName)
                }
            }
        }
        return items
    }
    
    
    
    
    

}
