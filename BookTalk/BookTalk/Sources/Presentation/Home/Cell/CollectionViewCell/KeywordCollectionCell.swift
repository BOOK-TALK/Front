//
//  KeywordCollectionCell.swift
//  BookTalk
//
//  Created by RAFA on 8/14/24.
//

import UIKit

final class KeywordCollectionCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    
    let keywordLabel = PaddedLabel()
    
    // MARK: - Bind
    
    func bind(_ keyword: String) {
        let hashtag = "#"
        let fullText = hashtag + keyword
        
        let attributedText = NSMutableAttributedString(string: fullText)
        attributedText.addAttribute(
            .foregroundColor,
            value: UIColor.accentOrange,
            range: NSRange(location: 0, length: 1)
        )
        
        attributedText.addAttribute(
            .foregroundColor,
            value: UIColor.darkGray,
            range: NSRange(location: 1, length: keyword.count)
        )
        
        keywordLabel.attributedText = attributedText
    }
    
    // MARK: - Set UI
    
    override func setViews() {
        contentView.do {
            $0.layer.cornerRadius = 10
            $0.backgroundColor = .white
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        keywordLabel.do {
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.textAlignment = .center
            $0.isUserInteractionEnabled = false
        }
    }
    
    override func setConstraints() {
        contentView.addSubview(keywordLabel)
        
        keywordLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
