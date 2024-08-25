//
//  SuggestionCell.swift
//  BookTalk
//
//  Created by RAFA on 7/29/24.
//

import UIKit

final class SuggestionCell: BaseTableViewCell {
    
    // MARK: - Properties
    
    let backgroundImageView = UIImageView()
    let suggestionLabel = UILabel()
    
    // MARK: - Bind
    
    func bind(_ nickname: String) {
        suggestionLabel.text = "\(nickname)님, 오늘의 추천 도서를 확인해보세요!"
    }
    
    // MARK: - Set UI
    
    override func setViews() {
        backgroundImageView.do {
            $0.image = UIImage(named: "homeBackgroundImage")
            $0.contentMode = .scaleAspectFill
        }
        
        suggestionLabel.do {
            $0.numberOfLines = 0
            $0.font = .systemFont(ofSize: 20, weight: .heavy)
            $0.textColor = .white
        }
    }
    
    override func setConstraints() {
        contentView.addSubview(backgroundImageView)
        backgroundImageView.addSubview(suggestionLabel)
        
        backgroundImageView.snp.makeConstraints {
            $0.centerX.left.bottom.equalToSuperview()
            $0.top.equalTo(contentView.safeAreaLayoutGuide.snp.top)
        }
        
        suggestionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.left.equalTo(20)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
}
