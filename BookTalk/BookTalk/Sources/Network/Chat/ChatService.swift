//
//  ChatService.swift
//  BookTalk
//
//  Created by 김민 on 9/23/24.
//

import Foundation
import StompClientLib

protocol ChatServiceType {
    var openTalkId: Int? { get set }

    func registerSocket()
    func connect()
    func subscribe(to openTalkId: Int)
    func unsubscribe(from openTalkId: Int)
    func sendMessage(token: String, openTalkId: Int, content: String) async
    func receivedMessage(message: String) async -> ChatModel
    func disconnect()
}

final class ChatService: ChatServiceType {

    private let url = URL(string: NetworkEnvironment.webSocketURL + "/websocket")!
    private var socketClient = StompClientLib()

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
            connectionHeaders: ["heart-beat": "10000,0"]
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

    func sendMessage(token: String, openTalkId: Int, content: String) async {
        let dicObject: [String: Any] = [
            "jwtToken": token,
            "opentalkId": openTalkId,
            "content": content
        ]

        await withCheckedContinuation { continuation in
            socketClient.sendJSONForDict(dict: dicObject as AnyObject, toDestination: "/pub/message")
            continuation.resume()
        }
    }

    func receivedMessage(message: String) async -> ChatModel {
        return ChatModel(nickname: "", message: "", isMine: false)
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
            guard let JSON = jsonBody as? [String : AnyObject] else { return }
            print(JSON.values)

            print("Destination : \(destination)")
            print("JSON Body : \(String(describing: jsonBody))")
            print("String Body : \(stringBody ?? "nil")")

            Task {
                await receivedMessage(message: "")
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
