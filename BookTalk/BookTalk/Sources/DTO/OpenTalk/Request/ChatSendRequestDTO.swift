//
//  ChatSendRequestDTO.swift
//  BookTalk
//
//  Created by 김민 on 8/25/24.
//

import Foundation

struct ChatSendRequestDTO: Encodable {
    let opentalkId: Int
    let type: String
    let jwtToken: String
    let content: String
}
