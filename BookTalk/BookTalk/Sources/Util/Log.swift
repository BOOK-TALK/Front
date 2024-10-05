//
//  Log.swift
//  BookTalk
//
//  Created by 김민 on 9/26/24.
//

import Foundation

public func log(_ message: String) {
    #if DEBUG
    NSLog(message)
    #endif
}
