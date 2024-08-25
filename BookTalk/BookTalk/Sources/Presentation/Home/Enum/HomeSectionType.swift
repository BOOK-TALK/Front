//
//  HomeSectionType.swift
//  BookTalk
//
//  Created by RAFA on 8/14/24.
//

import Foundation

enum HomeSectionType: Equatable {
    case suggestion
    case keyword([Keyword])
    case recommendation([DetailBookInfo])
}

enum HomeSectionKind: CaseIterable {
    case suggestion
    case keyword
    case monthRecommend
    case ageRecommend
    case popularLoan
}
