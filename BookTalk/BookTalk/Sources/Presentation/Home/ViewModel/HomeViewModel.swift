//
//  HomeViewModel.swift
//  BookTalk
//
//  Created by RAFA on 7/29/24.
//

import UIKit

final class HomeViewModel {
    
    // MARK: - Interactions
    
    struct Input {
        let loadBooks: () -> Void
        let toggleSection: (Int) -> Void
    }
    
    struct Output {
        let sections: Observable<[HomeSection]>
        let nickname: Observable<String>
    }
    
    // MARK: - Properties
    
    private let sections = Observable<[HomeSection]>([])
    private let nickname = Observable<String>("")
    private let userData: UserData
    private let bookService: BookService
    
    lazy var input: Input = { return bindInput() }()
    lazy var output: Output = { return transform() }()
    
    // MARK: - Initializer
    
    init(userData: UserData, bookService: BookService) {
        self.userData = userData
        self.bookService = bookService
    }

    // MARK: - Helpers
    
    func fetchSections() {
        Task {
            do {
                nickname.value = userData.getUser()?.nickname ?? ""
                
                let suggestionSection = HomeSection(
                    type: .suggestion,
                    headerTitle: "",
                    isExpanded: false
                )
                
                let keywords = try await BookService.getKeywords()
                let keywordSection = HomeSection(
                    type: .keyword(keywords),
                    headerTitle: "지난 달 키워드 확인하기",
                    isExpanded: false
                )
                
                sections.value = [suggestionSection, keywordSection]
            } catch let error as NetworkError {
                print(error)
            }
        }
    }
    
    private func toggleSection(section: Int) {
        var toggleKeywordSection = sections.value
        toggleKeywordSection[section].isExpanded.toggle()
        sections.value = toggleKeywordSection
    }
    
    private func bindInput() -> Input {
        return Input(
            loadBooks: { [weak self] in
                self?.fetchSections()
            },
            toggleSection: { [weak self] section in
                self?.toggleSection(section: section)
            }
        )
    }
    
    private func transform() -> Output {
        return Output(
            sections: sections,
            nickname: nickname
        )
    }
}
