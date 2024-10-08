//
//  BookDetailViewModel.swift
//  BookTalk
//
//  Created by RAFA on 8/5/24.
//

import UIKit
import Combine

final class BookDetailViewModel {
    
    // MARK: - Interactions
    
    struct Input {
        let markAsReadButtonTap: () -> Void
        let favoriteButtonTap: () -> Void
        let likeButtonTap: () -> Void
        let dislikeButtonTap: () -> Void
        let loadDetailInfo: () -> Void
    }
    
    struct Output {
        let detailBook: Observable<DetailBookInfo?>
        let availabilityText: Observable<String>
        let availabilityTextColor: Observable<UIColor>
        let isMarkAsRead: Observable<Bool>
        let areChildButtonsVisible: Observable<Bool>
        let isFavorite: Observable<Bool>
        let isLiked: Observable<Bool>
        let isDisliked: Observable<Bool>
        let borrowableLibraries: Observable<[Library]?>
        let loadState: Observable<LoadState>
    }
    
    // MARK: - Properties

    private let bookDetailOb: Observable<DetailBookInfo?> = Observable(nil)
    private let availableLibs: Observable<[Library]?> = Observable(nil)

    private var availabilityText = Observable("")
    private var availabilityColor = Observable(UIColor.black)
    private var isMarkAsReadOb = Observable(false)
    private var isFavoriteOb = Observable(false)
    private var loadStateOb = Observable(LoadState.initial)

    lazy var input: Input = { return bindInput() }()
    lazy var output: Output = { return bindOutput() }()

    private var cancellables = Set<AnyCancellable>()

    private let isbn: String

    // MARK: - Initializer
    
    init(isbn: String) {
        self.isbn = isbn

        bind()
    }
    
    // MARK: - Helpers

    private func bind() {
        NotificationCenter.default.publisher(for: .detailChanged)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                loadDetail(of: isbn)
            }
            .store(in: &cancellables)
    }

    private func bindInput() -> Input {
        return Input(
            markAsReadButtonTap: { [weak self] in
                guard let self = self else { return }
                if isMarkAsReadOb.value { // 읽은 책이면
                    deleteReadBook(of: bookDetailOb.value?.basicBookInfo)
                } else { // 읽지 않은 책이면
                    addReadBook(of: bookDetailOb.value?.basicBookInfo)
                }
            },
            favoriteButtonTap: { [weak self] in
                guard let self = self else { return }

                if isFavoriteOb.value {
                    deleteFavoriteBook(of: bookDetailOb.value?.basicBookInfo)
                } else {
                    addFavoriteBook(of: bookDetailOb.value?.basicBookInfo)
                }
            },
            likeButtonTap: { [weak self] in
                self?.toggle(self?.output.isLiked, opposite: self?.output.isDisliked)
            },
            dislikeButtonTap: { [weak self] in
                self?.toggle(self?.output.isDisliked, opposite: self?.output.isLiked)
            },
            loadDetailInfo: { [weak self] in
                guard let self = self else { return }

                loadStateOb.value = .loading
                loadDetail(of: isbn)
            }
        )
    }
    
    private func bindOutput() -> Output {
        return Output(
            detailBook: bookDetailOb,
            availabilityText: availabilityText,
            availabilityTextColor: availabilityColor, 
            isMarkAsRead: isMarkAsReadOb,
            areChildButtonsVisible: Observable(false),
            isFavorite: isFavoriteOb,
            isLiked: Observable(false),
            isDisliked: Observable(false),
            borrowableLibraries: availableLibs,
            loadState: loadStateOb
        )
    }
}

extension BookDetailViewModel {

    private func toggle(
        _ property: Observable<Bool>?,
        opposite: Observable<Bool>? = nil
    ) {
        guard let property = property else { return }
        property.value.toggle()
        if let opposite = opposite, property.value { opposite.value = false }
    }

    func updateAvailability(
        _ libraries: [Library]?
    ) -> (text: String, color: UIColor) {
        guard let libraries = libraries, !libraries.isEmpty else {
            return ("대출 여부를 확인하려면 도서관을 등록해주세요.", .systemGray)
        }

        let isAvailable = libraries.contains { $0.isAvailable }
        
        return (
            isAvailable ? "대출 가능" : "대출 불가능",
            isAvailable ? .systemGreen : .systemRed
        )
    }

    private func loadDetail(of isbn: String) {
        Task { [weak self] in
            guard let self = self else { return }

            do {
                let bookDetail = try await BookService.getBookDetail(of: isbn)

                await MainActor.run { [weak self] in
                    guard let self = self else { return }

                    bookDetailOb.value = bookDetail
                    availableLibs.value = bookDetail.registeredLibraries
                    isFavoriteOb.value = bookDetail.isFavorite
                    isMarkAsReadOb.value = bookDetail.isRead ?? false

                    loadStateOb.value = .completed
                }

            } catch let error as NetworkError {
                print(error.localizedDescription)
                loadStateOb.value = .completed
            }
        }
    }

    private func addFavoriteBook(of book: BasicBookInfo?) {
        guard let book = book else { return }

        Task {
            do {
                try await BookService.postFavoriteBook(of: book)
                isFavoriteOb.value = true
            } catch let error as NetworkError {
                print(error.localizedDescription)
            }
        }
    }

    private func deleteFavoriteBook(of book: BasicBookInfo?) {
        guard let book = book else { return }

        Task {
            do {
                try await BookService.deleteFavoriteBook(of: book)
                isFavoriteOb.value = false
            } catch let error as NetworkError {
                print(error.localizedDescription)
            }
        }
    }

    private func addReadBook(of basicBook: BasicBookInfo?) {
        guard let basicBook = basicBook else { return }

        let book: Book = .init(
            isbn: basicBook.isbn,
            imageURL: basicBook.coverImageURL,
            title: basicBook.title
        )
        Task {
            do {
                try await BookService.postReadBook(of: book)

                await MainActor.run {
                    toggle(output.isMarkAsRead)
                }
            } catch let error as NetworkError {
                print(error.localizedDescription)
            }
        }
    }

    private func deleteReadBook(of basicBook: BasicBookInfo?) {
        guard let basicBook = basicBook else { return }

        let book: Book = .init(
            isbn: basicBook.isbn,
            imageURL: basicBook.coverImageURL,
            title: basicBook.title
        )
        Task {
            do {
                try await BookService.deleteReadBook(of: book)

                await MainActor.run {
                    toggle(output.isMarkAsRead)
                }
            } catch let error as NetworkError {
                print(error.localizedDescription)
            }
        }
    }
}
