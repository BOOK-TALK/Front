//
//  ChatViewModel.swift
//  BookTalk
//
//  Created by 김민 on 8/2/24.
//

import Foundation

final class ChatViewModel {

    private(set) var isBookmarked = Observable(false)
    private(set) var chats = Observable<[ChatModel]>([])
    private(set) var message = Observable("")
    private(set) var sendMessageSucceed = Observable(false)
    private(set) var isInitialLoad = true

    private var pageSize = 10
    private var currentPage = 0
    private var hasMoreResults = true

    let isbn: String

    var openTalkId: Int? 

    private var chatService = ChatService()

    // MARK: - Initializer

    init(isbn: String) {
        self.isbn = isbn
    }

    enum Action {
        case joinToOpenTalk(isbn: String)
        case loadChats(openTalkId: Int?)
        case toggleBookmark(isFavorite: Bool)
        case textFieldChanged(text: String)
        case sendMessage(openTalkId: Int?, message: String)
    }

    func send(action: Action) {

        switch action {
        case let .joinToOpenTalk(isbn):
            Task {
                do {
                    let openTalkInfo = try await OpenTalkService.postOpenTalkJoin(
                        of: isbn,
                        pageSize: pageSize
                    )

                    chatService.openTalkId = openTalkInfo.openTalkId

                    await MainActor.run {
                        chats.value = openTalkInfo.chats.reversed()
                        isBookmarked.value = openTalkInfo.isFavorite
                        openTalkId = openTalkInfo.openTalkId
                    }
                } catch let error as NetworkError {
                    print(error.localizedDescription)
                }
            }
            
        case let .loadChats(openTalkId):
            guard let openTalkId = openTalkId else { return }
            guard hasMoreResults else { return }

            isInitialLoad = false
            currentPage += 1
            
            fetchChats(
                id: openTalkId,
                currentPage: currentPage,
                pageSize: pageSize
            )

        case let .toggleBookmark(isFavorite):
            guard let id = openTalkId else { return }

            if isFavorite {
                deleteBookMark(of: id)
            } else {
                doBookMark(of: id)
            }

        case let .textFieldChanged(text):
            message.value = text

        case let .sendMessage(openTalkId, text):
            guard let openTalkId = openTalkId else { return }
            guard let token = KeychainManager.shared.read(key: TokenKey.accessToken) else { return }

            Task {
                await chatService.sendMessage(token: token, openTalkId: openTalkId, content: text)
            }
//            chatService.sendMessage(token: token, openTalkId: openTalkId, content: text)
//            sendMessageSucceed.value = false
//
//            Task {
//                do {
//                    let newChat = try await OpenTalkService.sendMessage(of: openTalkId, text: text)
//
//                    await MainActor.run {
//                        chats.value.append(newChat)
//                        message.value.removeAll()
//                        sendMessageSucceed.value = true
//                    }
//                } catch let error as NetworkError {
//                    print(error.localizedDescription)
//                }
//            }
        }
    }

    private func fetchChats(id: Int, currentPage: Int, pageSize: Int) {
        Task {
            do {
                let chatResponse = try await OpenTalkService.getChatList(
                    of: id,
                    pageNo: currentPage,
                    pageSize: pageSize
                )

                await MainActor.run {
                    guard !chatResponse.isEmpty else {
                        hasMoreResults = false
                        return
                    }

                    if chats.value.isEmpty {
                        chats.value = chatResponse.reversed()
                    } else {
                        chats.value.insert(contentsOf: chatResponse.reversed(), at: 0)
                    }
                }

            } catch let error as NetworkError {
                print(error.localizedDescription)
            }
        }
    }

    private func doBookMark(of openTalkId: Int) {
        Task {
            do {
                try await OpenTalkService.postOpenTalkFavorite(of: openTalkId)

                await MainActor.run {
                    isBookmarked.value = true

                    NotificationCenter.default.post(name: .openTalkChanged, object: nil)
                }
            } catch let error as NetworkError {
                print(error.localizedDescription)
            }
        }
    }

    private func deleteBookMark(of openTalkId: Int) {
        Task {
            do {
                try await OpenTalkService.deleteOpenTalkFavorite(of: openTalkId)

                await MainActor.run {
                    isBookmarked.value = false

                    NotificationCenter.default.post(name: .openTalkChanged, object: nil)
                }
            } catch let error as NetworkError {
                print(error.localizedDescription)
            }
        }
    }
}
