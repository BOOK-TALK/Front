//
//  MyChatViewCell.swift
//  BookTalk
//
//  Created by 김민 on 8/2/24.
//

import UIKit

import SnapKit
import Then

final class MyChatBubbleCell: BaseTableViewCell {

    private let chatMessageLabel = UILabel()
    private let bubbleView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setViews() {
        selectionStyle = .none

        backgroundColor = .clear

        bubbleView.do {
            $0.backgroundColor = .bubbleGreen
            $0.layer.cornerRadius = 15
        }

        chatMessageLabel.do {
            $0.font = .systemFont(ofSize: 15, weight: .regular)
            $0.textColor = .black
            $0.numberOfLines = 0
        }
    }

    override func setConstraints() {
        [bubbleView].forEach {
            contentView.addSubview($0)
        }

        bubbleView.addSubview(chatMessageLabel)

        bubbleView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.lessThanOrEqualTo(250)
            $0.bottom.equalToSuperview()
        }

        chatMessageLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(12)
            $0.trailing.bottom.equalToSuperview().offset(-12)
        }
    }

    func bind(with message: String) {
        chatMessageLabel.text = message
    }
}
