//
//  BookImageCell.swift
//  BookTalk
//
//  Created by 김민 on 7/26/24.
//

import UIKit

final class BookImageCell: BaseCollectionViewCell {

    private let bookImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setViews() {
        contentView.backgroundColor = .clear

        bookImageView.do {
            $0.backgroundColor = .gray100
        }
    }

    override func setConstraints() {
        [bookImageView].forEach {
            contentView.addSubview($0)
        }

        bookImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
