//
//  HomeHeaderView.swift
//  BookTalk
//
//  Created by RAFA on 7/29/24.
//

import UIKit

final class HomeHeaderView: BaseTableViewHeaderFooterView {
    
    // MARK: - Properties
    
    private let titleLabel = UILabel()
    private let rightArrowIcon = UIImageView()
    
    // MARK: - Bind
    
    func bind(with title: String, section: Int) {
        titleLabel.text = title
        self.section = section
    }
    
    // MARK: - Set UI
    
    override func setViews() {
        contentView.backgroundColor = .white
        
        titleLabel.do {
            $0.numberOfLines = 2
            $0.font = .systemFont(ofSize: 20, weight: .medium)
            $0.textAlignment = .left
        }
        
        rightArrowIcon.do {
            $0.image = UIImage(named: "next")
            $0.tintColor = .black
        }
    }
    
    override func setConstraints() {
        [titleLabel, rightArrowIcon].forEach { contentView.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.left.bottom.equalToSuperview().inset(15)
            $0.right.equalTo(rightArrowIcon.snp.left).offset(-15)
        }
        
        rightArrowIcon.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.right.equalTo(-15)
            $0.size.equalTo(20)
        }
    }
}
