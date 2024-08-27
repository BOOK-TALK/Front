//
//  EditUserInfoResponseDTO.swift
//  BookTalk
//
//  Created by 김민 on 8/22/24.
//

import Foundation

struct EditUserInfoResponseDTO: Decodable {
    let nickname: String
    let gender: String
    let birthDate: String?
}

extension EditUserInfoResponseDTO {

    func toModel() -> UserBasicInfo {
        return .init(
            profileImage: "", // TODO:
            nickname: nickname,
            gender: GenderType(code: gender),
            birth: birthDate
        )
    }
}
