//
//  UserInfo.swift
//  BookTalk
//
//  Created by 김민 on 8/22/24.
//

import Foundation

struct UserInfo {
    let userInfo: UserBasicInfo
    let dibs: [Book]
    let readBooks: [Book]
}

struct UserBasicInfo: Codable {
    let profileImage: String
    let nickname: String
    let gender: GenderType
    let birth: String?
}
