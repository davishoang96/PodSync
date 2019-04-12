//
//  DirectoryUtilities.swift
//  PodSync
//
//  Created by edi on 21/2/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Foundation
import iTunesLibrary

class DirectoryUtilities
{
    
    private static var fileManager = FileManager.default
    
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
    
    
    static func getFile(_ destination: URL) -> [URL]?
    {
        var items = [URL]()
        if let content = Get_FolderItemURL(destination)
        {
            for item in content
            {
                if item.isFileKey
                {
                    items.append(item)
                }
            }
            return items
        }
        else
        {
            return nil
        }
    }
    
    static func getDirectory(_ destination: URL) -> [URL]?
    {
        var items = [URL]()
        if let content = Get_FolderItemURL(destination)
        {
            for item in content
            {
                if !item.isFileKey
                {
                    items.append(item)
                }
            }
            return items
        }
        else
        {
            return nil
        }
    }
    
    static func removeEmptyFolder(_ destination: URL)
    {
        do
        {
            if let directories = getDirectory(destination)
            {
                for directory in directories
                {
                    
                    while getFile(directory)?.count == 0 && getDirectory(directory)?.count == 0
                    {
                        try fileManager.trashItem(at: directory, resultingItemURL: nil)
                    }
                }
                
            }
        }
        catch
        {
            removeEmptyFolder(destination)
        }
    }
    
    
    static func removeDuplicatedDirectories(_ directories: [URL]) -> [String]
    {
        var items = [String]()
        
        for eachdirectories in directories
        {
            if !items.contains(eachdirectories.deletingLastPathComponent().lastPathComponent)
            {
                items.append(eachdirectories.deletingLastPathComponent().lastPathComponent)
            }
        }
        return items
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
    
    static func createDirectory(_ paths: [String])
    {
        do
        {
            for eachPath in paths
            {
                try fileManager.createDirectory(atPath: eachPath, withIntermediateDirectories: true, attributes: nil)
            }
        }
        catch
        {
            print(error.localizedDescription)
        }
        
    }
    
    
    static func createSongPath(_ songs: [ITLibMediaItem]) -> [String]
    {
        var result = [String]()
        
        let SyncLocation = UserDefaults.standard.getLocationURL().path
        
        var newAlbumTitle: String
        var newAlbumArtist: String
        var newArtistName: String
        
        for eachsong in songs
        {
            let albumTitle = eachsong.album.title
            if albumTitle == nil
            {
                newAlbumTitle = "Unknown Album"
            }
            else
            {
                newAlbumTitle = StringHelper.process(albumTitle!)
            }
            
            let artistName = eachsong.artist?.name
            if artistName == nil
            {
                newArtistName = "Unknown Artist"
            }
            else
            {
                newArtistName = StringHelper.process(artistName!)
            }
            
            let albumArtist = eachsong.album.albumArtist
            if albumArtist == nil
            {
                newAlbumArtist = "Unknown Artist"
            }
            else
            {
                newAlbumArtist = StringHelper.process(albumArtist!)
            }
            
            
            if eachsong.album.albumArtist?.count != nil && newAlbumArtist == newArtistName
            {
                let path  = SyncLocation + "/" + newAlbumArtist + "/" + newAlbumTitle
                
                if !result.contains(path)
                {
                    print(path)
                    result.append(path)
                }
                
            }
            else if eachsong.album.albumArtist?.count != nil && newAlbumArtist != newArtistName
            {
                
                
                let path  = SyncLocation + "/" + newAlbumArtist + "/" + newAlbumTitle
                
                if !result.contains(path)
                {
                    print(path)
                    result.append(path)
                }
                
            }
            else if eachsong.album.albumArtist?.count == nil && newAlbumArtist == newArtistName
            {
                let path  = SyncLocation + "/" + newAlbumArtist + "/" + newAlbumTitle
                
                if !result.contains(path)
                {
                    print(path)
                    result.append(path)
                }
                
            }
            else if eachsong.album.albumArtist == "Various" || eachsong.album.albumArtist == "Various Artists" || eachsong.album.albumArtist == "Various Artist" && eachsong.artist?.name != nil
            {
                let path  = SyncLocation + "/" + newAlbumArtist  + "/" + newAlbumTitle
                
                if !result.contains(path)
                {
                    print(path)
                    result.append(path)
                }
            }
            else if eachsong.album.albumArtist?.count == nil && eachsong.album.albumArtist != eachsong.artist?.name
            {
                let path  = SyncLocation + "/" + newArtistName + "/" + newAlbumTitle
                
                if !result.contains(path)
                {
                    print("->",path)
                    result.append(path)
                }
            }
            else if eachsong.album.albumArtist?.count != nil && eachsong.album.albumArtist != eachsong.artist?.name && eachsong.album.albumArtist == "Various" || eachsong.album.albumArtist == "Various Artists" || eachsong.album.albumArtist == "Various Artist"
            {
                let path  = SyncLocation + "/" + newAlbumArtist + "/" + newAlbumTitle
                
                if !result.contains(path)
                {
                    print("-o>",path)
                    result.append(path)
                }
            }
            else if eachsong.artist?.name == nil && eachsong.album.albumArtist?.count != nil
            {
                let path  = SyncLocation + "/" + newAlbumArtist + "/" + newAlbumTitle
                
                if !result.contains(path)
                {
                    print("->",path)
                    result.append(path)
                }
            }
            else if eachsong.album.albumArtist?.count == nil || eachsong.artist?.name == nil 
            {
                let path: String
                
                if eachsong.album.title != nil
                {
                   path  = SyncLocation + "/" + newAlbumArtist + "/" + newAlbumTitle
                }
                else
                {
                   path  = SyncLocation + "/" + newAlbumArtist + "/" + newAlbumTitle
                }
                
                if !result.contains(path)
                {
                    print("->",path)
                    result.append(path)
                }
            }

            else
            {
                if let artistName = eachsong.artist?.name
                {
                    let path = SyncLocation + "/" + artistName + "/" + newAlbumTitle
                    
                    if !result.contains(path)
                    {
                        print("-->",path)
                        result.append(path)
                    }
                }
            }
        }
        print(result.count)
        return result
    }
}
