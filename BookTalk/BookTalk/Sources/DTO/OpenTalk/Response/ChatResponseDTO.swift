//
//  ChatResponseDTO.swift
//  BookTalk
//
//  Created by 김민 on 8/25/24.
//

import Foundation

struct ChatResponseDTO: Decodable {
    let nickname: String
    let profileImageUrl: String?
    let type: String?
    let content: String
    let createdAt: String
}

extension ChatResponseDTO {

    func toModel() -> ChatModel {
        return .init(
            nickname: nickname,
            message: content,
            isMine: nickname == UserData.shared.getUser()?.nickname
        )
    }
}
