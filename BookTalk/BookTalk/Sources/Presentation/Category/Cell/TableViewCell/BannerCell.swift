//
//  BannerCell.swift
//  BookTalk
//
//  Created by 김민 on 7/26/24.
//

import UIKit

final class BannerCell: BaseTableViewCell {

    private let bannerImageView = UIImageView()

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
        
        contentView.backgroundColor = .clear

        bannerImageView.do {
            $0.backgroundColor = .gray100
        }
    }

    override func setConstraints() {
        [bannerImageView].forEach {
            contentView.addSubview($0)
        }

        bannerImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
