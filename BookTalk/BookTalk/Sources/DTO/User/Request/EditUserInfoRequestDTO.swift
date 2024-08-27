//
//  EditUserInfoRequestDTO.swift
//  BookTalk
//
//  Created by 김민 on 8/22/24.
//

import Foundation

struct EditUserInfoRequestDTO: Encodable {
    let nickname: String
    let gender: String
    let birthDate: String
    let profileImageUrl: String
}
