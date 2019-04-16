//
//  VolumeInfo.swift
//  PodSync
//
//  Created by Davis Hoang on 15/4/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Foundation
import DiskArbitration

class Volumes: CalculateSize
{
    fileprivate static let fileManager = FileManager.default
    
    struct VolumesInfo {
        var name: String
        var TotalSize: UInt64
        var RemainSize: UInt64
    }
    
    private static func byteFormat(_ value: UInt64) -> String
    {
        let bcf = ByteCountFormatter()
        
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file
        
        let result = bcf.string(fromByteCount: Int64(value))
        return result
    }
    
    public static func GetFreeSize(_ url: URL) -> String
    {
        do
        {
            let volume = try fileManager.attributesOfFileSystem(forPath: url.path)
            let volumeSize = volume[.systemFreeSize] as! UInt64
            
            return byteFormat(volumeSize)
            
        }
        catch
        {
            alertBox.messageBox(question: "Alert!", text: "Unable to get volume size")
            return "NAN"
        }
    }
    
    public static func GetSize(_ url: URL) -> String
    {
        do
        {
            let volume = try fileManager.attributesOfFileSystem(forPath: url.path)
            let volumeSize = volume[.systemSize] as! UInt64
            return byteFormat(volumeSize)
        }
        catch
        {
            alertBox.messageBox(question: "Alert!", text: "Unable to get volume size")
            return "NAN"
        }
    }
    
    public static func diskPercent(_ url: URL) -> Int
    {
        do
        {
            let volume = try fileManager.attributesOfFileSystem(forPath: url.path)
            let totalSize = volume[.systemSize] as! Double
            let freeSize = volume[.systemFreeSize] as! Double
            let result = 100 - (freeSize / totalSize) * 100
            return Int(result.rounded())
            
        }
        catch
        {
            return 0
        }
    }
}
