//
//  ChatViewCell.swift
//  BookTalk
//
//  Created by 김민 on 8/2/24.
//

import UIKit

final class OtherChatBubbleCell: BaseTableViewCell {

    // MARK: - Properties
    
    private let nicknameLabel = UILabel()
    private let chatMessageLabel = UILabel()
    private let bubbleView = UIView()

    // MARK: - UI Setup

    override func setViews() {
        selectionStyle = .none

        backgroundColor = .clear

        nicknameLabel.do {
            $0.font = .systemFont(ofSize: 13, weight: .regular)
            $0.textColor = .black
        }

        bubbleView.do {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 12
        }

        chatMessageLabel.do {
            $0.font = .systemFont(ofSize: 15, weight: .regular)
            $0.textColor = .black
            $0.lineBreakMode = .byTruncatingMiddle
            $0.numberOfLines = 0
        }
    }

    override func setConstraints() {
        [nicknameLabel, bubbleView].forEach {
            contentView.addSubview($0)
        }

        bubbleView.addSubview(chatMessageLabel)

        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalTo(16)
        }

        bubbleView.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            $0.leading.equalTo(nicknameLabel)
            $0.width.lessThanOrEqualTo(250)
            $0.bottom.equalToSuperview().offset(-4)
        }

        chatMessageLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(12)
            $0.trailing.bottom.equalToSuperview().offset(-12)
        }
    }

    // MARK: - Helpers

    func bind(with chatModel: ChatModel) {
        nicknameLabel.text = chatModel.nickname
        chatMessageLabel.text = chatModel.message
    }
}
