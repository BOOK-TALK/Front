//
//  OpenTalkJoinResponseDTO.swift
//  BookTalk
//
//  Created by 김민 on 8/25/24.
//

import Foundation

struct OpenTalkJoinResponseDTO: Decodable {
    let openTalkId: Int
    let messageResponseDTO: [ChatResponseDTO]?
    let favorite: Bool

    enum CodingKeys: String, CodingKey {
        case openTalkId = "opentalkId"
        case messageResponseDTO = "messageResponseDto"
        case favorite 
    }
}

extension OpenTalkJoinResponseDTO {

    func toModel() -> OpenTalkModel {
        return .init(
            openTalkId: openTalkId,
            chats: messageResponseDTO?.map { $0.toModel() } ?? [],
            isFavorite: favorite
        )
    }
}
