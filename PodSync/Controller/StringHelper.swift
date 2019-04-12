//
//  StringHelper.swift
//  PodSync
//
//  Created by Davis Hoang on 4/4/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Foundation

class StringHelper
{
    private static func removeColon(_ value: String) -> String
    {
        let result = value.replacingOccurrences(of: ":", with: ".", options: String.CompareOptions.literal, range: nil)
        return result
    }
    
    private static func removeLastSpace(_ value: String) -> String
    {
        let result = value.trimmingCharacters(in: .whitespaces)
        return result
    }
    
    
    public static func process(_ value: String) -> String
    {
        let process1 = removeColon(value)
        let process2 = removeLastSpace(process1)
        return process2
    }
    
    
    
}
