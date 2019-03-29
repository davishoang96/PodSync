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
            
            
            // 1. Get file URLs in Synced folder
            if let item = DirectoryUtilities.Get_FolderItemURL(destinationFolder)
            {
                folderItemsURL = item
            }
            

            // 2. Get file last path component in Synced folder
            folderItemsName = DirectoryUtilities.Get_LastPathComponent(destinationFolder)
            
            
            
            // 3. Get song name from the array
            songName = Utilities.Get_SongName(songs)
            
            // 4. Compare playlists and folders
            // Remove if item in folder not match with playlist
            Utilities.Remove_NonExistItems(itemURL: folderItemsURL, songName: songName)
            let songPath = DirectoryUtilities.createSongPath(songs)
            
            if let items = DirectoryUtilities.Get_FolderItemURL(UserDefaults.standard.getLocationURL())
            {
                DirectoryUtilities.get_subDirectory(items)
                DirectoryUtilities.removeEmptyDirectory(items, Utilities.getArtistName(songs))
            }
            
            DirectoryUtilities.createDirectory(songPath)
            
            
            
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

                        
                        
                        
                        if let song = eachsong.location?.lastPathComponent
                        {
                            if !folderItemsName.contains(song)
                            {
                                
                                if eachsong.album.albumArtist?.count != nil && eachsong.album.albumArtist == eachsong.artist?.name
                                {
                                    myPath = folderLocation + eachsong.album.albumArtist! + "/" + eachsong.album.title! + "/" + song
                                    
                                }
                                else if eachsong.album.albumArtist == "Various" || eachsong.album.albumArtist == "Various Artists" || eachsong.album.albumArtist == "Various Artist"
                                {
                                    myPath = folderLocation + "Various Artists"  + "/" + eachsong.album.title! + "/" + song
                                    
                                }
                                else if eachsong.album.albumArtist?.count == nil && eachsong.album.albumArtist != eachsong.artist?.name
                                {
                                    myPath = folderLocation + (eachsong.artist?.name)! + "/" + eachsong.album.title! + "/" + song
                                    
                                }
                                else
                                {
                                    myPath  = folderLocation + (eachsong.artist?.name)! + "/" + eachsong.album.title! + "/" + song
                                    
                                }
                                
                                
                                
                                try FileManager.default.copyItem(atPath: songpath, toPath: myPath)
                                
                                // Update processInfo in ViewController
                                myDataRadio.DataRadio("NotificationPercent")
                                
                                num_copiedSongs+=1
                                print(num_copiedSongs)
                            }
                        }
                    }
                    else
                    {
                        isRunning = false
                        isCompleted = false
                        myDataRadio.DataRadio("StopSync")
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
                myDataRadio.DataRadio("StopSync")
                return
            }
        }
        isRunning = false
        isCompleted = true
        myDataRadio.DataRadio("StopSync")
        
        alertBox.showNotification("Alert", "Finish syncing " + String(num_copiedSongs) + " songs")
    }
    
    
    
}
