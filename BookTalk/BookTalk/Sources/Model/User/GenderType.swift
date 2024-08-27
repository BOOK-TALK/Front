//
//  GenderType.swift
//  BookTalk
//
//  Created by 김민 on 8/22/24.
//

import Foundation

enum GenderType: String, Codable {
    case notSelected = "NOT_SELECTED"
    case man = "MAN"
    case woman = "WOMAN"

    var code: String {
        switch self {
        case .notSelected:
            return "G0"
        case .man:
            return "G1"
        case .woman:
            return "G2"
        }
    }

    var koreanTitle: String {
        switch self {
        case .notSelected:
            return "선택 없음"
        case .man:
            return "남"
        case .woman:
            return "여"
        }
    }

    init(code: String) {
        switch code {
        case "G0":
            self = .notSelected
        case "G1":
            self = .man
        case "G2":
            self = .woman
        default:
            self = .notSelected
        }
    }
}
