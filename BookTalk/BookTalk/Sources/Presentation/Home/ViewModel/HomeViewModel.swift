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
    }
    
    // MARK: - Properties
    
    private let sectionsRelay = Observable<[HomeSection]>([])
    lazy var input: Input = { return bindInput() }()
    lazy var output: Output = { return transform() }()

    // MARK: - Helpers
    
    func fetchSections() {
        sectionsRelay.value = HomeMockData.sections
        
        Task {
            do {
                let result = try await BookService.getKeywords()
                print(result)

            } catch let error as NetworkError {
                print(error)
            }
        }
    }
    
    private func toggleSection(section: Int) {
        var sections = sectionsRelay.value
        sections[section].isExpanded.toggle()
        sectionsRelay.value = sections
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
        return Output(sections: sectionsRelay)
    }
}
