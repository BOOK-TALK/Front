//
//  ShowAllBookCell.swift
//  BookTalk
//
//  Created by 김민 on 7/26/24.
//

import UIKit

final class ShowAllBookCell: BaseTableViewCell {

    private let showAllBookLabel = UILabel()
    private let chevronImageView = UIImageView()

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
        
        contentView.backgroundColor = .white

        showAllBookLabel.do {
            $0.text = "전체 보기"
            $0.font = .systemFont(ofSize: 17, weight: .semibold)
        }

        chevronImageView.do {
            $0.image = UIImage(systemName: "chevron.right")
            $0.tintColor = .black
        }
    }

    override func setConstraints() {
        [showAllBookLabel, chevronImageView].forEach {
            contentView.addSubview($0)
        }

        showAllBookLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
        }

        chevronImageView.snp.makeConstraints {
            $0.centerY.equalTo(showAllBookLabel)
            $0.trailing.equalToSuperview().offset(-12)
        }
    }
}
