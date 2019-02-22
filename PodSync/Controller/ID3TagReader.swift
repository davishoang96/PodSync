//
//  ID3TagReader.swift
//  PodSync
//
//  Created by edi on 21/2/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Foundation
import iTunesLibrary
import AVFoundation


class ID3TagReader
{
    static func audioFiles(_ songs: [ITLibMediaItem])
    {
    
        for eachsong in songs
        {
            if let songlocation = eachsong.location
            {
                readID3(songlocation)
            }
        }
        
    }
    
    static func readID3(_ audioFiles: URL)
    {
        do
        {
            let audio = AVPlayerItem(url: audioFiles)
            let meta = audio.asset.metadata(forFormat: .iTunesMetadata)
            
            for i in meta
            {
                let yeartag = AVMutableMetadataItem()
                yeartag.keySpace = AVMetadataKeySpace.iTunes
                
                
                
                
            }
            
        }
        catch
        {
            print(error.localizedDescription)
        }
    }
    
    static func itunesID3Tag()
    {
        
    }
}
