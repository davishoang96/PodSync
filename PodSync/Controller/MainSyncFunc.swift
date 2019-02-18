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
    
    private static var isRunning: Bool?
    private static var isCompleted: Bool?
    private static var num_existedSongs: Double = 0
    private static var num_copiedSongs: Int = 0
    
    static func stop(flag: Bool)
    {
        isRunning = flag
    }
    

    static func getstop()->Bool
    {
        if let flag = isRunning
        {
            return flag
        }
        else
        {
            return false
        }
    }
    
    static func getCompleted()->Bool
    {
        if let flag = isCompleted
        {
            return flag
        }
        else
        {
            return false
        }
    }
    
    static func num_existedSong() -> Double
    {
        return num_existedSongs
    }

    
    
    static func Sync(songs: [ITLibMediaItem], destinationFolder: URL)
    {
        if isRunning == true
        {
            isCompleted = false
            
            let nc = NotificationCenter.default
            
            var songName = [String]()
            var folderItemsURL = [URL]()
            var folderItemsName = [String]()
            
            var songpath:String
            var songfilename: String
            var myPath:String
            var subPath: String
            
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
            if let data = Utilities.get_subDirectory(folderItemsURL)
            {
                //Utilities.removeEmptyDirectory(data)
            }
            
            

            
            // Get num of existed songs to calculate percent of sync
            num_existedSongs = Utilities.get_numOf_ExistedSongs(itemURL: folderItemsURL, songName: songName)
            
            print("RemainedPercent:",SyncPercent.remainedPercent())
            print("PercentEachFile:",SyncPercent.calpercent())

            
            myDataRadio.DataRadio("NotificationRemained")
            
            
            // BETA TEST
            
            var a = Utilities.get_SongMDateLib(songs)
            var b = Utilities.get_SongMDateFolder(items: folderItemsURL)
            
            
            
            // ------------------------------
            
            
            // 5. SYNC
            do
            {
                for eachsong in songs
                {
                    // if running equal to false then stop syncing
                    if isRunning == true
                    {
                        songpath = (eachsong.location?.path)!
                        songfilename = (eachsong.location?.lastPathComponent)!
                        
                        var folderLocation = destinationFolder.path + "/"
                        var artistFolder: String
                        var albumFolder: String
                        var subDirectory: String
                        
                        if let subfoldersA = eachsong.album.albumArtist
                        {
                            artistFolder = folderLocation + subfoldersA + "/"
                            
                            if let subfoldersB = eachsong.album.title
                            {
                                albumFolder = artistFolder + subfoldersB + "/"
                                
                                myPath = albumFolder + songfilename
                                
                                if let song = eachsong.location?.lastPathComponent
                                {
                                    if !folderItemsName.contains(song)
                                    {
                                        
                                        try FileManager.default.copyItem(atPath: songpath, toPath: myPath)
                                        // Update processInfo in ViewController
                                        myDataRadio.DataRadio("NotificationPercent")
                                        
                                        num_copiedSongs+=1
                                        print(num_copiedSongs)
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        isRunning = false
                        isCompleted = false
                        print("Stop sync")
                        return
                    }
                }
            }
            catch
            {
                print(error.localizedDescription)
                isRunning = false
                isCompleted = false
                print("Stop sync")
                return
            }
        }
        isRunning = false
        isCompleted = true
    }
    
    
    
}
