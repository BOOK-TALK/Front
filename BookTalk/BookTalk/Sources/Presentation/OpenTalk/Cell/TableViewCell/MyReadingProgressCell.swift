//
//  MyReadingProgressCell.swift
//  BookTalk
//
//  Created by 김민 on 8/4/24.
//

import UIKit

import SnapKit
import Then

final class MyReadingProgressCell: BaseTableViewCell {

    // MARK: - Properties

    private let titleLabel = UILabel()
    private let percentLabel = UILabel()
    private let myProfileImage = UIImageView()
    private let progressView = UIProgressView()
    private let updateButton = UIButton()

    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup

    override func setViews() {
        selectionStyle = .none

        contentView.backgroundColor = .clear

        titleLabel.do {
            $0.text = "내 진행도"
            $0.font = .systemFont(ofSize: 17, weight: .semibold)
        }

        percentLabel.do {
            $0.text = "80%"
            $0.font = .systemFont(ofSize: 17, weight: .semibold)
        }

        myProfileImage.do {
            $0.backgroundColor = .gray100
        }

        updateButton.do {
            $0.setTitle("갱신하기", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.backgroundColor = UIColor.accentOrange
            $0.layer.cornerRadius = 10
        }

        progressView.do {
            $0.tintColor = .accentOrange
            $0.setProgress(0.7, animated: true)
        }
    }

    override func setConstraints() {
        [titleLabel, percentLabel, myProfileImage, progressView, updateButton].forEach {
            contentView.addSubview($0)
        }

        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(20)
        }

        percentLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
        }

        myProfileImage.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalTo(titleLabel)
            $0.width.height.equalTo(45)
        }

        progressView.snp.makeConstraints {
            $0.centerY.equalTo(myProfileImage)
            $0.leading.equalTo(myProfileImage.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        updateButton.snp.makeConstraints {
            $0.top.equalTo(myProfileImage.snp.bottom).offset(20)
            $0.leading.equalTo(myProfileImage)
            $0.trailing.equalTo(progressView)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
}
