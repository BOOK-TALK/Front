//
//  AddBookViewModel.swift
//  BookTalk
//
//  Created by 김민 on 8/13/24.
//

import Foundation

final class AddBookViewModel {

    enum Action {
        case loadFavoriteBooks
        case loadResult(query: String)
    }

    // MARK: - Properties

    private(set) var books = Observable<[Book]>([])
    private(set) var searchText = Observable("")
    private(set) var loadState = Observable(LoadState.initial)

    private let bookName: String?

    // MARK: - Initializer

    init(bookName: String? = nil) {
        self.bookName = bookName

        searchText.value = bookName ?? ""
    }

    // MARK: - Helpers

    func send(action: Action) {
        switch action {
        case .loadFavoriteBooks:
            Task {
                do {
                    let favoriteBookResult = try await UserService.getFavoriteBooks()

                    await MainActor.run {
                        books.value = favoriteBookResult
                    }
                } catch let error as NetworkError {
                    print(error.localizedDescription)
                }
            }

        case let .loadResult(query):
            loadState.value = .loading
            
            Task {
                do {
                    let searchResult = try await SearchService.getSearchSimpleRsult(
                        input: query,
                        pageNo: 1,
                        pageSize: 30
                    )

                    await MainActor.run {
                        books.value = searchResult
                        loadState.value = .completed
                    }
                } catch let error as NetworkError {
                    print(error.localizedDescription)
                    loadState.value = .completed
                }
            }
        }
    }
}
