//
//  SendChatModel.swift
//  BookTalk
//
//  Created by 김민 on 9/26/24.
//

import Foundation

struct SendChatModel {
    let type: ChatType
    let openTalkId: Int
    let content: String
}

extension SendChatModel {

    func toSendChatDTO() -> ChatSendRequestDTO {
        return .init(
            opentalkId: openTalkId,
            type: type.rawValue,
            jwtToken: KeychainManager.shared.read(key: TokenKey.accessToken) ?? "",
            content: content
        )
    }
}
