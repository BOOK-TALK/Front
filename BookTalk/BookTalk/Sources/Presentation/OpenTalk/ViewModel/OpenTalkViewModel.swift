//
//  OpenTalkViewModel.swift
//  BookTalk
//
//  Created by 김민 on 8/20/24.
//

import Foundation

final class OpenTalkViewModel {

    // MARK: - Properties

    var selectedPageType = OpenTalkPageType.hot
    var hotOpenTalks = Observable<[OpenTalkBookModel]>([])
    var favoriteOpenTalks = Observable<[OpenTalkBookModel]>([])
    var loadState = Observable(LoadState.initial)

    // MARK: - Helpers

    enum Action {
        case setPageType(_ pageType: OpenTalkPageType)
    }

    func send(action: Action) {
        switch action {
        case let .setPageType(selectedPage):
            selectedPageType = selectedPage

            favoriteOpenTalks.value.removeAll()
            hotOpenTalks.value.removeAll()

            switch selectedPage {
            case .hot:
                loadHotOpenTalk()
            case .liked:
                loadFavoriteOpenTalk()
            }
        }
    }

    private func loadHotOpenTalk() {
        loadState.value = .loading

        Task {
            do {
                let result = try await OpenTalkService.getHotOpenTalkList()

                await MainActor.run {
                    hotOpenTalks.value = result
                    loadState.value = .completed
                }

            } catch let error as NetworkError {
                print(error.localizedDescription)
                loadState.value = .completed
            }
        }
    }

    private func loadFavoriteOpenTalk() {
        loadState.value = .loading

        Task {
            do {
                let result = try await OpenTalkService.getFavoriteOpenTalkList()

                await MainActor.run {
                    favoriteOpenTalks.value = result
                    loadState.value = .completed
                }

            } catch let error as NetworkError {
                print(error.localizedDescription)
                loadState.value = .completed
            }
        }
    }

}
