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
    
    static func removeEmptyDirectory(_ directories: [URL], _ artists: [String])
    {
        let artistFolder = removeDuplicatedDirectories(directories)
        let SyncPath = UserDefaults.standard.getLocationURL().path
        let DestinationFolder = UserDefaults.standard.getLocationURL().lastPathComponent
                
        do
        {
            for eachAF in artistFolder
            {
                if !artists.contains(eachAF) && eachAF != DestinationFolder || !artists.contains("Various Artists")
                {
                    let removePath = SyncPath + "/" + eachAF
                    
                    let removePathURL = URL(fileURLWithPath: removePath)
                    
                    print(removePath)
                    
                    try fileManager.trashItem(at: removePathURL, resultingItemURL: nil)
                    
                }
            }
        }
        catch
        {
            print(error.localizedDescription)
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
        
        for eachsong in songs
        {
            
            if eachsong.album.albumArtist?.count != nil && eachsong.album.albumArtist == eachsong.artist?.name
            {
                let path  = SyncLocation + "/" + eachsong.album.albumArtist! + "/" + eachsong.album.title!
                
                if !result.contains(path)
                {
                    //print(path)
                    result.append(path)
                }
                
            }
            else if eachsong.album.albumArtist == "Various" || eachsong.album.albumArtist == "Various Artists" || eachsong.album.albumArtist == "Various Artist"
            {
                let path  = SyncLocation + "/" + "Various Artists"  + "/" + eachsong.album.title!
                
                if !result.contains(path)
                {
                    //print(path)
                    result.append(path)
                }
            }
            else if eachsong.album.albumArtist?.count == nil && eachsong.album.albumArtist != eachsong.artist?.name
            {
                let path  = SyncLocation + "/" + (eachsong.artist?.name)! + "/" + eachsong.album.title!
                
                if !result.contains(path)
                {
                    //print("->",path)
                    result.append(path)
                }
                
            }
            else
            {
                if let artistName = eachsong.artist?.name
                {
                    let path = SyncLocation + "/" + artistName + "/" + eachsong.album.title!
                    
                    if !result.contains(path)
                    {
                        //print("-->",path)
                        result.append(path)
                    }

                }
            }
        }
        print(result.count)
        return result
    }
}
