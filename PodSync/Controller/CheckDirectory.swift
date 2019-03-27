//
//  CheckDirectory.swift
//  PodSync
//
//  Created by edi on 17/2/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Foundation
import Cocoa


extension URL {
    var isDirectory: Bool {
        let values = try? resourceValues(forKeys: [.isDirectoryKey])
        return values?.isDirectory ?? false
    }
}
