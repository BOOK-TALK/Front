//
//  NotificationCenter+.swift
//  BookTalk
//
//  Created by 김민 on 8/20/24.
//

import Foundation

extension Notification.Name {

    static let authStateChanged = Notification.Name(rawValue: "authStateChanged")
    static let goalChanged = Notification.Name(rawValue: "goalChanged")
    static let progressChanged = Notification.Name(rawValue: "progressChanged")
    static let detailChanged = Notification.Name(rawValue: "detailChanged")
    static let openTalkChanged = Notification.Name(rawValue: "openTalkChanged")
    static let newChatReceived = Notification.Name(rawValue: "newChatReceived")
}
