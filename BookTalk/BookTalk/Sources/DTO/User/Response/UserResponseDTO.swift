//
//  UserResponseDTO.swift
//  BookTalk
//
//  Created by 김민 on 8/23/24.
//

import Foundation

struct UserInfoResponseDTO: Decodable {
    let userDto: UserResponseDTO
    let libraries: [LibraryResponseDTO]
    let dibsBooks: [UserBookResponseDTO]
    let readBooks: [UserBookResponseDTO]
}

extension UserInfoResponseDTO {

    func toModel() -> UserInfo {
        return .init(
            userInfo: userDto.toModel(),
            dibs: dibsBooks.map { $0.toModel() },
            readBooks: readBooks.map { $0.toModel() }
        )
    }
}

struct UserResponseDTO: Decodable {
    let userId: Int
    let kakaoId: String?
    let appleId: String?
    let regDate: String
    let nickname: String
    let gender: String
    let birthDate: String?
    let profileImageUrl: String?
}

extension UserResponseDTO {

    func toModel() -> UserBasicInfo {
        return .init(
            profileImage: "", // TODO: 
            nickname: nickname,
            gender: GenderType(code: gender),
            birth: birthDate
        )
    }
}
