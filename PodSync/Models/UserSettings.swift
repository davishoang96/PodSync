//
//  UserSettings.swift
//  PodSync
//
//  Created by Viet on 18/1/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Foundation
import iTunesLibrary

import Cocoa

struct TablePlaylist{
    var playlist: [String]
}

struct folder {
    var FolderLocationURL: URL
}


extension UserDefaults{
    
    func setAlwaysOnTop(value: Bool)
    {
        set(value, forKey: "WindowAlwaysOnTop")
    }
    
    func setShowLibrary(value: Bool)
    {
        set(value, forKey: "ShowLibrary")
    }
    
    func getShowLibrary() -> Bool
    {
        return bool(forKey: "ShowLibrary")
    }
    
    func getAlwaysOnTop() -> Bool
    {
        return bool(forKey: "WindowAlwaysOnTop")
    }
    
    func setUserFolder(value: URL){
        set(value, forKey: "UserHomeDirectory")
    }
    
    func getUserFolder() -> URL{
        
        if let result = url(forKey: "UserHomeDirectory")
        {
            return result
        }
        else
        {
            return Utilities.getUserHomeDirectory()
        }
    }
    
    func setLocation(value: String) {
        set(value, forKey: "destinationFolder")
    }
    
    
    func setLocationURL(value: URL) {
        set(value, forKey: "destinationURL")
    }
    
    func getLocation() -> String
    {
        if let location = string(forKey: "destincationFolder")
        {
            return location
        }
        else
        {
            return "nil"
        }
    }
    
    func getLocationURL() -> URL
    {
        if let result = url(forKey: "destinationURL")
        {
            return result
        }
        else
        {
            return Utilities.getUserHomeDirectory()
        }
    }
    
}
