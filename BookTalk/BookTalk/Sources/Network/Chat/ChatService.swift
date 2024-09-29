//
//  ChatService.swift
//  BookTalk
//
//  Created by 김민 on 9/23/24.
//

import Combine
import Foundation
import StompClientLib

protocol ChatServiceType {
    var openTalkId: Int? { get set }

    func registerSocket()
    func connect()
    func subscribe(to openTalkId: Int)
    func unsubscribe(from openTalkId: Int)
    func sendMessage(from chat: SendChatModel) async
    func receivedMessage(chatResponse: ChatResponseDTO)
    func disconnect()
}

final class ChatService: ChatServiceType {

    private let url = URL(string: NetworkEnvironment.webSocketURL + "/websocket")!
    private var socketClient = StompClientLib()

    var receivedMessage = PassthroughSubject<ChatModel, Never>()

    /// openTalkId 값이 추가 되면 subscribe 수행
    var openTalkId: Int? {
        didSet {
            subscribeIfConnected()
        }
    }

    /// 초기화 시 소켓 설정
    init() {
        connect()
    }

    /// deinit 시 연결 해제
    deinit {
        disconnect()
    }

    func registerSocket() {
        socketClient.openSocketWithURLRequest(
            request: NSURLRequest(url: url),
            delegate: self,
            connectionHeaders: ["heart-beat": "10000,10000"]
        )
    }

    func connect() {
        registerSocket()
    }

    func subscribe(to openTalkId: Int) {
        log("subscribed")

        socketClient.subscribe(
            destination: "/sub/message/\(openTalkId)"
        )
    }

    func unsubscribe(from openTalkId: Int) {
        socketClient.unsubscribe(destination: "/sub/message/\(openTalkId)")

        log("Unsubscribed from opentalkId: \(openTalkId)")
    }

    func subscribeIfConnected() {
        guard let openTalkId = self.openTalkId else { return }

        socketClient.subscribe(destination: "/sub/message/\(openTalkId)")

        log("subscribing to opentalkId: \(openTalkId)")
    }

    func sendMessage(from chat: SendChatModel) async {
        let dicObject = chat.toSendChatDTO().toDictionary()


        await withCheckedContinuation { continuation in
            socketClient.sendJSONForDict(dict: dicObject as AnyObject, toDestination: "/pub/message")
            continuation.resume()
        }
    }

    func receivedMessage(chatResponse: ChatResponseDTO) {
        log("\(chatResponse)")

        NotificationCenter.default.post(name: .newChatReceived, object: chatResponse.toModel())
    }

    func disconnect() {
        guard let openTalkId = openTalkId else { return }
        socketClient.unsubscribe(destination: "/sub/message/\(openTalkId)")

        socketClient.disconnect()
    }
}

extension ChatService: StompClientLibDelegate {

    func stompClient(
        client: StompClientLib!,
        didReceiveMessageWithJSONBody jsonBody: AnyObject?,
        akaStringBody stringBody: String?,
        withHeader header: [String : String]?,
        withDestination destination: String) {
            guard let json = jsonBody as? [String: AnyObject] else { return }

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
                let decoder = JSONDecoder()

                let receivedChatDTO = try decoder.decode(ChatResponseDTO.self, from: jsonData)
                receivedMessage(chatResponse: receivedChatDTO)

            } catch {
                print("Failed parsing: \(error)")
            }
    }

    func stompClientDidDisconnect(client: StompClientLib!) {
        log("socket is disconnected")
    }

    func stompClientDidConnect(client: StompClientLib!) {
        log("socket is connected")
    }

    func serverDidSendReceipt(
        client: StompClientLib!,
        withReceiptId receiptId: String
    ) {
        log("Receipt : \(receiptId)")
    }

    func serverDidSendError(
        client: StompClientLib!,
        withErrorMessage description: String,
        detailedErrorMessage message: String?
    ) {
        log("Error: \(description)")
    }

    func serverDidSendPing() {
        log("server ping")
    }
}
