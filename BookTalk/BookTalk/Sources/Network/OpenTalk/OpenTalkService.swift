//
//  OpenTalkService.swift
//  BookTalk
//
//  Created by 김민 on 8/20/24.
//

import Foundation

struct OpenTalkService {

    static func getHotOpenTalkList() async throws -> [OpenTalkBookModel] {
        let result: [OpenTalkResponseDTO] = try await NetworkService.shared.request(
            target: OpenTalkTarget.getHotOpenTalk
        )

        return result.map { $0.toModel() }
    }

    static func getFavoriteOpenTalkList() async throws -> [OpenTalkBookModel] {
        let result: [OpenTalkResponseDTO] = try await NetworkService.shared.request(
            target: OpenTalkTarget.getFavoriteOpenTalk
        )

        return result.map { $0.toModel() }
    }

    static func postOpenTalkJoin(
        of isbn: String,
        pageSize: Int
    ) async throws -> OpenTalkModel {
        let params: OpenTalkJoinRequestDTO = .init(isbn: isbn, pageSize: pageSize)

        let result: OpenTalkJoinResponseDTO = try await NetworkService.shared.request(
            target: OpenTalkTarget.postOpenTalkJoin(params: params)
        )

        return result.toModel()
    }

    static func postOpenTalkFavorite(of openTalkId: Int) async throws{
        let params: OpenTalkIdRequestDTO = .init(openTalkId: openTalkId)

        let _: [Int] = try await NetworkService.shared.request(
            target: OpenTalkTarget.postFavoriteOpenTalk(params: params)
        )
    }

    static func deleteOpenTalkFavorite(of openTalkId: Int) async throws{
        let params: OpenTalkIdRequestDTO = .init(openTalkId: openTalkId)

        let _: [Int] = try await NetworkService.shared.request(
            target: OpenTalkTarget.deleteFavoriteOpenTalk(params: params)
        )
    }

    static func getChatList(
        of id: Int,
        pageNo: Int,
        pageSize: Int)
    async throws -> [ChatModel] {
        let params: ChatListRequestDTO = .init(
            opentalkId: id,
            pageNo: pageNo,
            pageSize: pageSize
        )

        let result: [ChatResponseDTO] = try await NetworkService.shared.request(
            target: OpenTalkTarget.getOpenTalkChatList(params: params)
        )

        return result.map { $0.toModel() }
    }

    static func sendMessage(of id: Int, text: String) async throws -> ChatModel {
        let params: ChatSendRequestDTO = .init(opentalkId: id, text: text)

        let result: ChatResponseDTO = try await NetworkService.shared.request(
            target: OpenTalkTarget.postChatMessage(params: params)
        )

        return result.toModel()
    }
}
