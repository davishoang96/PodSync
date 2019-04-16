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
    private static var message: String = ""
    
    static func stop(flag: Bool)
    {
        isRunning = flag
    }
    
    static func getMessage()->String
    {
        return message
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

    static func removeOldFiles(songs: [ITLibMediaItem], files: [URL])
    {
        do
        {
            let originalFiles = Utilities.get_SongMDateLib(songs)
            for eachfile in files
            {
                if !eachfile.isDirectory && !eachfile.absoluteString.contains("playlists.xml")
                {
                    let itemMB = try FileManager.default.attributesOfItem(atPath: eachfile.path)
                    let fileDate = itemMB[FileAttributeKey.modificationDate] as! Date
                    
                    if let fixDate = Utilities.currentDateTime(date: fileDate)
                    {
                        if !originalFiles.contains(fixDate)
                        {
                            //print("NOT MATCHED:",fixDate, eachfile.lastPathComponent)
                            message = "Removed: " + eachfile.lastPathComponent
                            myDataRadio.DataRadio("UpdateMessage")
                            try FileManager.default.trashItem(at: eachfile, resultingItemURL: nil)
                        }
                    }
                    
                }
                
            }
            print(originalFiles)
        }
        catch
        {
            print(error.localizedDescription)
        }
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
            
            num_copiedSongs = 0
            
            
            var newAlbumTitle: String
            var newAlbumArtist: String
            var newArtistName: String
            
            // 1. Get file URLs in Synced folder
            if let item = DirectoryUtilities.Get_FolderItemURL(destinationFolder)
            {
                folderItemsURL = item
            }
            

            // 2. Get file last path component in Synced folder
            folderItemsName = DirectoryUtilities.Get_LastPathComponent(destinationFolder)
            
            // 3. Get song name from the array
            songName = Utilities.Get_SongName(songs)
            
            
            let songPath = DirectoryUtilities.createSongPath(songs)
            DirectoryUtilities.createDirectory(songPath)
            
            
            // Get num of existed songs to calculate percent of sync
            num_existedSongs = Utilities.get_numOf_ExistedSongs(itemURL: folderItemsURL, songName: songName)
            SyncPercent.remainedPercent()
            SyncPercent.calpercent()

            
            myDataRadio.DataRadio("NotificationRemained")

            // ------------------------------
        
            message = "Begin Syncing"
            myDataRadio.DataRadio("UpdateMessage")
            
            // 5. SYNC
            do
            {
                for eachsong in songs
                {
                    // if running equal to false then stop syncing
                    if isRunning == true && DirectoryUtilities.checkDirectoryStatus(destinationFolder) == true
                    {
                        songpath = (eachsong.location?.path)!
                        songfilename = (eachsong.location?.lastPathComponent)!
                        
                        let folderLocation = destinationFolder.path + "/"
                        
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

                        if let song = eachsong.location?.lastPathComponent
                        {
                            if !folderItemsName.contains(song)
                            {
                                
                                if eachsong.album.albumArtist?.count != nil && newArtistName == newAlbumArtist
                                {
                                    myPath = folderLocation + newAlbumArtist + "/" + newAlbumTitle + "/" + song
                                }
                                else if eachsong.album.albumArtist?.count != nil && newArtistName != newAlbumArtist
                                {
                                    myPath = folderLocation + newAlbumArtist + "/" + newAlbumTitle + "/" + song
                                }
                                else if eachsong.album.albumArtist?.count == nil && newArtistName == newAlbumArtist
                                {
                                    let path1 = folderLocation + newArtistName + "/"
                                    let path2 = newAlbumTitle + "/" + song
                                    myPath = path1 + path2
                                }
                                else if eachsong.album.albumArtist?.count != nil && eachsong.album.albumArtist != eachsong.artist?.name && eachsong.album.albumArtist == "Various" || eachsong.album.albumArtist == "Various Artists" || eachsong.album.albumArtist == "Various Artist"
                                {
                                    print("2")
                                    let path1 = folderLocation + newAlbumArtist
                                    let path2 = "/" + newAlbumTitle + "/" + song
                                    myPath = path1 + path2
                                }
                                else if eachsong.album.albumArtist == "Various" || eachsong.album.albumArtist == "Various Artists" || eachsong.album.albumArtist == "Various Artist" && eachsong.artist?.name != nil
                                {
                                    print("1")
                                    myPath = folderLocation + newAlbumArtist  + "/" + newAlbumTitle + "/" + song
                                }
                                else if eachsong.album.albumArtist?.count == nil && eachsong.album.albumArtist != eachsong.artist?.name
                                {
                                    
                                    myPath = folderLocation + newArtistName + "/" + newAlbumTitle + "/" + song
                                    
                                }
                                else if eachsong.artist?.name == nil && ((eachsong.album.albumArtist?.count) != nil)
                                {
                                    
                                    myPath  = folderLocation + newAlbumArtist + "/" + newAlbumTitle + "/" + song
                                    
                                }
                                else
                                {
                                    myPath = folderLocation + newArtistName + "/" + newAlbumTitle + "/" + song
                                }
                                
                                
                    
                                try FileManager.default.copyItem(atPath: songpath, toPath: myPath)
                                
                                message = "Copying: " + songfilename
                                myDataRadio.DataRadio("UpdateMessage")
                                
                                // Update processInfo in ViewController
                                myDataRadio.DataRadio("NotificationPercent")
                                myDataRadio.DataRadio("UpdateVolumeInfo")
                                num_copiedSongs+=1
                                //print(num_copiedSongs)
                                

                            }
                        }
                    }
                    else if isRunning == true && DirectoryUtilities.checkDirectoryStatus(destinationFolder) == false
                    {
                        isRunning = false
                        isCompleted = false
                        myDataRadio.DataRadio("StopSync")
                        print("Destination Not Found")
                        return
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
                if DirectoryUtilities.checkDirectoryStatus(destinationFolder) == true
                {
                    message = "Error!!! - Destination folder not found."
                    myDataRadio.DataRadio("UpdateMessage")
                    myDataRadio.DataRadio("NotifyDirectoryGone")
                }
            
                print("Func Sync:",error.localizedDescription)
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
        message = "Finish syncing " + String(num_copiedSongs) + " songs"
        myDataRadio.DataRadio("UpdateMessage")
        alertBox.showNotification("Alert", "Finish syncing " + String(num_copiedSongs) + " songs")
    }
    
    
    
}
