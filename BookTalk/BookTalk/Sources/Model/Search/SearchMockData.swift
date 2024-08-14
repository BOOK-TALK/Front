//
//  SearchMockData.swift
//  BookTalk
//
//  Created by RAFA on 7/31/24.
//

import Foundation

struct SearchMockData {
    static let books: [DetailBookInfo] = HomeMockData.sections
        .compactMap { section -> [DetailBookInfo]? in
            if case let .recommendation(books) = section.type {
                return books
            }
            return nil
        }
        .flatMap { $0 }
}
