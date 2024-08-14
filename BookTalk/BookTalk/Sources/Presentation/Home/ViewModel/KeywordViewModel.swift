//
//  KeywordViewModel.swift
//  BookTalk
//
//  Created by RAFA on 8/14/24.
//

import UIKit

final class KeywordViewModel {
    
    // MARK: - Output
    
    let title: Observable<String>
    let isExpanded: Observable<Bool>
    
    // MARK: - Initializer
    
    init(title: String, isExpanded: Bool) {
        self.title = Observable(title)
        self.isExpanded = Observable(isExpanded)
    }
    
    // MARK: - Actions
    
    func toggleExpansion() {
        isExpanded.value.toggle()
    }
}
