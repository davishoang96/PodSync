//
//  MainSyncFunc.swift
//  PodSync
//
//  Created by viet on 8/2/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Foundation
import Cocoa
import iTunesLibrary


class Synchronize
{
    static func Sync(songs: [ITLibMediaItem], destinationFolder: URL)
    {
        var songName = [String]()
        var folderItemsURL = [URL]()
        var folderItemsName = [String]()
        
        var songpath:String
        var songfilename: String
        var myPath:String
        
        // 1. Get file URLs in Synced folder
        if let item = Utilities.Get_FolderItemURL(destinationFolder)
        {
            folderItemsURL = item
        }
        
        // 2. Get file last path component in Synced folder
        folderItemsName = Utilities.Get_LastPathComponent(destinationFolder)
        
        // 3. Get song name from the array
        songName = Utilities.Get_SongName(songs)
        
        // 4. Compare playlists and folders
        // Remove if item in folder not match with playlist
        Utilities.Remove_NonExistItems(itemURL: folderItemsURL, songName: songName)
        
        
        var a = Utilities.get_SongMDateLib(songs)
        var b = Utilities.get_SongMDateFolder(items: folderItemsURL)
        
        Utilities.updateSongs(playlist: a, folder: b!)
        
        
        // 5. SYNC
        do
        {
            for eachsong in songs
            {
                songpath = (eachsong.location?.path)!
                songfilename = (eachsong.location?.lastPathComponent)!
                myPath = destinationFolder.path + "/" + songfilename
                
                
                if let song = eachsong.location?.lastPathComponent
                {
                    if folderItemsName.contains(song)
                    {
                        print("FILE EXISTED")
                    }
                    else
                    {
                        try FileManager.default.copyItem(atPath: songpath, toPath: myPath)
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
