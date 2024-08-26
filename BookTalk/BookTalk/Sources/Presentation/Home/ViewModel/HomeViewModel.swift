//
//  HomeViewModel.swift
//  BookTalk
//
//  Created by RAFA on 7/29/24.
//

import UIKit

final class HomeViewModel {

    private(set) var isKeywordOpened = Observable(false)
    private(set) var keywordOb = Observable<[Keyword]>([])
    private(set) var thisWeekRecommendOb = Observable<BooksWithHeader>(.init(headerTitle: "", books: []))
    private(set) var popularLoansOb = Observable<BooksWithHeader>(.init(headerTitle: "", books: []))
    private(set) var ageTrendOb = Observable<BooksWithHeader>(.init(headerTitle: "", books: []))
    private(set) var loadState = Observable(LoadState.initial)

    enum Action {
        case setKeywordExpandState(newState: Bool)
        case loadBooks
    }

    func send(action: Action) {
        switch action {
        case let .setKeywordExpandState(newState):
            isKeywordOpened.value = newState

        case .loadBooks:
            Task {
                await loadKeyword()
                await loadHotTrend()
                await loadThisWeekTrend()
                await loadAgeTrend()
            }
        }
    }

    private func loadKeyword() async {
        do {
            let result = try await BookService.getKeywords()

            await MainActor.run {
                keywordOb.value = result
            }

        } catch {
            print(error.localizedDescription)
        }
    }

    private func loadHotTrend() async {
        do {
            let result = try await HomeService.getHotTrend()

            await MainActor.run {
                popularLoansOb.value.books = result
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    private func loadThisWeekTrend() async {
        do {
            let result = try await HomeService.getThisWeekTrend()

            await MainActor.run {
                thisWeekRecommendOb.value.books = result
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    private func loadAgeTrend() async {
        guard let userBirth = UserData.shared.getUser()?.birth else { return }
        let userAge = userBirth.toKoreanAge()

        do {
            let result = try await HomeService.getAgeTrend(of: userAge)

            await MainActor.run {
                ageTrendOb.value.books = result
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
