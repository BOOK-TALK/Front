//
//  OpenTalkTarget.swift
//  BookTalk
//
//  Created by 김민 on 8/20/24.
//

import Foundation

import Alamofire

enum OpenTalkTarget {
    case postOpenTalkJoin(params: OpenTalkJoinRequestDTO)
    case postFavoriteOpenTalk(params: OpenTalkIdRequestDTO)
    case deleteFavoriteOpenTalk(params: OpenTalkIdRequestDTO)
    case getOpenTalkChatList(params: ChatListRequestDTO)
    case postChatMessage(params: ChatSendRequestDTO)
    case getHotOpenTalk
    case getFavoriteOpenTalk
}

extension OpenTalkTarget: TargetType {
    
    var path: String {
        switch self {
        case .postOpenTalkJoin:
            return "/api/opentalk/join"
        case .postFavoriteOpenTalk:
            return "/api/opentalk/favorite"
        case .deleteFavoriteOpenTalk:
            return "/api/opentalk/favorite"
        case .getOpenTalkChatList:
            return "/api/message/get"
        case .postChatMessage:
            return "/api/message/save"
        case .getHotOpenTalk:
            return "/api/opentalk/hot"
        case .getFavoriteOpenTalk:
            return "/api/opentalk/favorite"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getOpenTalkChatList,
                .getHotOpenTalk,
                .getFavoriteOpenTalk:
            return .get
        case .postOpenTalkJoin, 
                .postFavoriteOpenTalk,
                .postChatMessage:
            return .post
        case .deleteFavoriteOpenTalk:
            return .delete
        }
    }
    
    var task: APITask {
        switch self {
        case .getHotOpenTalk, .getFavoriteOpenTalk:
            return .requestPlain
            
        case let .postOpenTalkJoin(params):
            return .requestParameters(parameters: params.toDictionary())
            
        case let .postFavoriteOpenTalk(params),
            let .deleteFavoriteOpenTalk(params):
            return .requestParameters(parameters: params.toDictionary())
            
        case let .getOpenTalkChatList(params):
            return .requestParameters(parameters: params.toDictionary())
            
        case let .postChatMessage(params):
            return .requestParameters(parameters: params.toDictionary())
        }
    }
}
