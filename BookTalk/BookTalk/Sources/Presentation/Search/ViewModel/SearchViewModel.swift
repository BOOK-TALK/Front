//
//  SearchViewModel.swift
//  BookTalk
//
//  Created by RAFA on 7/31/24.
//

import UIKit

final class SearchViewModel {
    
    // MARK: - Interactions
    
    struct Input {
        let searchTextChanged: (String) -> Void
        let updateSearchMode: (Bool) -> Void
        let loadBooks: () -> Void
    }
    
    struct Output {
        let filteredBooks: Observable<[DetailBookInfo]>
        let isKeywordSearch: Observable<Bool>
        let availabilityText: Observable<[String]>
        let availabilityTextColor: Observable<[UIColor]>
    }
    
    // MARK: - Properties
    
    private(set) var allBooks: [DetailBookInfo] = []
    private let filteredBooksRelay = Observable<[DetailBookInfo]>([])
    private let isKeywordSearchRelay = Observable<Bool>(false)
    private let availabilityTextsRelay = Observable<[String]>([])
    private let availabilityTextColorsRelay = Observable<[UIColor]>([])
    
    lazy var input: Input = { return bindInput() }()
    lazy var output: Output = { return transform() }()
    
    // MARK: - Initializer
    
    init() {
        allBooks = SearchMockData.books
    }
    
    // MARK: - Helpers
    
    private func filterBooks(searchText: String) {
        let trimmedSearchText = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).lowercased().replacingOccurrences(of: " ", with: "")
        
        if trimmedSearchText.isEmpty {
            filteredBooksRelay.value = []
            availabilityTextsRelay.value = []
            availabilityTextColorsRelay.value = []
        } else {
            let filteredBooks: [DetailBookInfo]
            if isKeywordSearchRelay.value {
                filteredBooks = allBooks.filter {
                    $0.keywords.contains {
                        $0.lowercased()
                            .replacingOccurrences(of: " ", with: "").contains(trimmedSearchText)
                    }
                }
            } else {
                filteredBooks = allBooks.filter {
                    $0.basicBookInfo.title.lowercased()
                        .replacingOccurrences(of: " ", with: "").contains(trimmedSearchText) ||
                    $0.basicBookInfo.author.lowercased()
                        .replacingOccurrences(of: " ", with: "").contains(trimmedSearchText)
                }
            }
            
            filteredBooksRelay.value = filteredBooks
            updateAvailability(for: filteredBooks)
        }
    }
    
    private func updateAvailability(for books: [DetailBookInfo]) {
        var availabilityTexts: [String] = []
        var availabilityColors: [UIColor] = []
        
        for book in books {
            let isRegistered = !book.registeredLibraries.isEmpty
            if isRegistered {
                let isAvailable = book.registeredLibraries.contains { $0.isAvailable }
                availabilityTexts.append(isAvailable ? "대출 가능" : "대출 불가능")
                availabilityColors.append(isAvailable ? UIColor.systemGreen : .systemRed)
            } else {
                availabilityTexts.append("대출 여부를 확인하려면 도서관을 등록해주세요.")
                availabilityColors.append(.systemGray)
            }
        }
        
        availabilityTextsRelay.value = availabilityTexts
        availabilityTextColorsRelay.value = availabilityColors
    }
    
    private func bindInput() -> Input {
        return Input(
            searchTextChanged: { [weak self] searchText in
                self?.filterBooks(searchText: searchText)
            },
            updateSearchMode: { [weak self] isKeywordSearch in
                self?.isKeywordSearchRelay.value = isKeywordSearch
                if let currentSearchText =
                    self?.filteredBooksRelay.value.first?.basicBookInfo.title
                {
                    self?.filterBooks(searchText: currentSearchText)
                }
            },
            loadBooks: { [weak self] in
                self?.allBooks = SearchMockData.books
            }
        )
    }
    
    private func transform() -> Output {
        return Output(
            filteredBooks: filteredBooksRelay,
            isKeywordSearch: isKeywordSearchRelay,
            availabilityText: availabilityTextsRelay,
            availabilityTextColor: availabilityTextColorsRelay
        )
    }
}
