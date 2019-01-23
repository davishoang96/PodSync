//
//  UserSettings.swift
//  PodSync
//
//  Created by Viet on 18/1/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Foundation

import Cocoa

struct Settings {
    var loadInitLocaiton: URL
    var PathURL: URL
}


extension UserDefaults{
    
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
    
    func getLocation() -> String{
        return string(forKey: "destinationFolder")!
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
