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
    
    private static let builtinPlaylist = ["Music","Music Videos","TV and Movies", "Movies", "Home Videos", "TV Shows", "Podcasts", "Audiobooks","Purchased", "TV & Films", "Films", "TV Programmes"]
    
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
    
    private static func getLibrary() -> ITLibrary
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
    
    static func Get_FolderItemURL(_ destinationFolder: URL) -> [URL]?
    {
        var files = [URL]()
        
        do {
            let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let enumerator = FileManager.default.enumerator(at: destinationFolder,
                                                            includingPropertiesForKeys: resourceKeys,
                                                            options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                                print("directoryEnumerator error at \(url): ", error)
                                                                return true
            })!
            
            for case let fileURL as URL in enumerator {
                //let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                files.append(fileURL)
            }
            return files
        } catch {
            print(error)
            return nil
        }        
    }
    
    static func get_subDirectory(_ directories: [URL]) -> [URL]?
    {
        var subDirectory = [URL]()
        
        for eachDirectory in directories
        {
            if eachDirectory.isDirectory
            {
                if !subDirectory.contains(eachDirectory)
                {
                    subDirectory.append(eachDirectory)
                }
            }
        }
        return subDirectory
    }
    
    static func removeEmptyDirectory(_ directories: [URL])
    {
        do
        {
            for eachDirectory in directories
            {
                let data = try fileManager.contentsOfDirectory(atPath: eachDirectory.path)
                if data.isEmpty
                {
                    print("RemoveEmptyDirectory:","Empty", eachDirectory.path)
                    try fileManager.trashItem(at: eachDirectory, resultingItemURL: nil)
                }
                else
                {
                    print("RemoveEmptyDirectory:","!Empty", eachDirectory.path)
                    if data.contains(".DS_Store")
                    {
                        print("RemoveEmptyDirectory:","Contains .DS_Store", eachDirectory.path)
                    }
                }
            }
        }
        catch
        {
            print(error.localizedDescription)
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
                if !eachitem.isDirectory
                {
                    print(eachitem.lastPathComponent)
                    if !songName.contains(eachitem.lastPathComponent)
                    {
                        print(i, "NOT MATCHED", eachitem.absoluteString)
                        
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
    
    static func getAlbumName(_ songs: [ITLibMediaItem]) -> [String]
    {
        var items = [String]()
        for eachsong in songs
        {
            if let albumTitle = eachsong.album.title
            {
                if !items.contains(albumTitle)
                {
                    items.append(albumTitle)
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
    
    
    
    static func createDirectory(_ songs: [ITLibMediaItem])
    {
        let SyncLocation = UserDefaults.standard.getLocationURL().path

        do
        {
            for eachsong in songs
            {
                
                if let artistName = eachsong.artist?.name
                {
                    if let albumArtists = eachsong.album.albumArtist
                    {
                        if artistName == albumArtists
                        {
                            let path  = SyncLocation + "/" + artistName + "/" + eachsong.album.title!
                            print("createDirectory:",path)
                            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                        }
                        else
                        {
                            print(artistName)
                            let path  = SyncLocation + "/" + artistName + "/" + eachsong.album.title!
                            print("createDirectory2:",path)
                            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                        }
                
//                if let albumArtists = eachsong.album.albumArtist
//                {
//                    if let aritstName = eachsong.artist?.name
//                    {
//                        if albumArtists == aritstName
//                        {
//                            let path  = SyncLocation + "/" + albumArtists + "/" + eachsong.album.title!
//                            print(path)
//                            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
//                        }
//                        else if albumArtists == "Various"
//                        {
//                            let path  = SyncLocation + "/" + "Various" + "/" + eachsong.album.title!
//
//                            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
//                        }
//                        else if albumArtists == "Various Artists"
//                        {
//                            let path  = SyncLocation + "/" + "Various Artists" + "/" + eachsong.album.title!
//
//                            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
//                        }
//                        else if albumArtists == "Various Artist"
//                        {
//                            let path  = SyncLocation + "/" + "Various Artist" + "/" + eachsong.album.title!
//
//                            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
//
//                        }
          
                        
                    }
                }
            }
        }
        catch
        {
            print(error.localizedDescription)
            return
        }
    }
}
