//
//  OpenTalkPageCell.swift
//  BookTalk
//
//  Created by 김민 on 8/1/24.
//

import UIKit

import SnapKit
import Then

final class OpenTalkPageCell: BaseCollectionViewCell {

    private let pageTitleLabel = UILabel()
    private let lineView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        didSet {
            lineView.isHidden = isSelected ? false : true
        }
    }

    override func setViews() {
        contentView.backgroundColor = .white

        pageTitleLabel.do {
            $0.font = .systemFont(ofSize: 17, weight: .regular)
            $0.textColor = .black
            $0.text = "오픈톡 저짜구"
        }

        lineView.do {
            $0.backgroundColor = .black
            $0.isHidden = true
        }
    }

    override func setConstraints() {
        [pageTitleLabel, lineView].forEach {
            contentView.addSubview($0)
        }

        pageTitleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        lineView.snp.makeConstraints {
            $0.leading.trailing.equalTo(contentView.safeAreaLayoutGuide)
            $0.bottom.equalTo(contentView)
            $0.height.equalTo(1)
        }
    }

    func bind(_ talkPage: String) {
        pageTitleLabel.text = talkPage
    }
}
