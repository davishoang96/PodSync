//
//  SyncedPlaylist.swift
//  PodSync
//
//  Created by Davis Hoang on 12/4/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Foundation

class SyncedPlaylist
{
    
    
    private static var xml: String = "<?xmlversion='1.0'encoding='UTF-8'?><playlists>"
    private static var playlist = [String]()
    
    
    public static func createXML(_ playlists: [String])
    {
        for playlist in playlists
        {
            let playlistNode: String = "<playlist>\(playlist)</playlist>"
            xml.append(playlistNode)
        }
        xml.append("</playlists>")
        
        let file = "playlists.xml"
        let content = xml
        let fileLocation = UserDefaults.standard.getLocationURL()
        
        let fileURL = fileLocation.appendingPathComponent(file)
        
        //writing
        do {
            try content.write(to: fileURL, atomically: false, encoding: .utf8)
        }
        catch {
            alertBox.messageBox(question: "Alert", text: "Cannot parse file: " + fileURL.absoluteString)
        }
        
    }
    
    public static func xmlParser(_ url: URL) -> [String]
    {
        
        let xmlContent = XMLParser(contentsOf: url)
        
        
        
        
        return playlist
    }
    
}
