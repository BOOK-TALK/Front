//
//  NowReadingPeopleCell.swift
//  BookTalk
//
//  Created by 김민 on 8/8/24.
//

import UIKit

import SnapKit
import Then

final class ReadingPeopleCell: BaseTableViewCell {

    // MARK: - Properties

    private let profileImageView = UIImageView()
    private let nicknameLabel = UILabel()
    private let percentLabel = UILabel()

    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers

    override func setViews() {
        selectionStyle = .none
        
        contentView.backgroundColor = .clear

        profileImageView.do {
            $0.backgroundColor = .gray100
        }

        nicknameLabel.do {
            $0.font = .systemFont(ofSize: 15, weight: .regular)
            $0.text = "닉네임"
        }

        percentLabel.do {
            $0.font = .systemFont(ofSize: 15, weight: .regular)
            $0.text = "80%"
        }
    }

    override func setConstraints() {
        [profileImageView, nicknameLabel, percentLabel].forEach {
            contentView.addSubview($0)
        }

        profileImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(45)
        }

        nicknameLabel.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
        }

        percentLabel.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
}
