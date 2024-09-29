//
//  OpenTalkJoinRequestDTO.swift
//  BookTalk
//
//  Created by 김민 on 8/25/24.
//

import Foundation

struct OpenTalkJoinRequestDTO: Encodable {
    let isbn: String
    let bookname: String
    let bookImageUrl: String
    let pageSize: Int
}
