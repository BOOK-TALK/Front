//
//  SuggestionCell.swift
//  BookTalk
//
//  Created by RAFA on 7/29/24.
//

import UIKit
import WeatherKit

protocol SuggestionCellDelegate: AnyObject {
    func didTapAppleWeatherLegalSourceLink()
}

final class SuggestionCell: BaseTableViewCell {
    
    // MARK: - Properties

    weak var delegate: SuggestionCellDelegate?

    private let backgroundImageView = UIImageView()
    private let appleWeatherTrademarkLabel = UILabel()
    private let appleWeatherLegalSourceLinkButton = UIButton(type: .system)
    private let suggestionLabel = UILabel()
    private var viewModel = HomeViewModel()
    
    // MARK: - Actions

    @objc private func navigateToAppleWeatherLegalSourceLink() {
        print("DEBUG: Tapped..")
        delegate?.didTapAppleWeatherLegalSourceLink()
    }

    // MARK: - Bind
    
    func bind(_ text: String, weatherCondition: WeatherCondition?) {
        suggestionLabel.text = text
        backgroundImageView.image = UIImage.image(for: weatherCondition)
    }

    // MARK: - Set UI
    
    override func setViews() {
        backgroundImageView.do {
            $0.isUserInteractionEnabled = true
            $0.contentMode = .scaleAspectFill
        }

        appleWeatherTrademarkLabel.do {
            $0.text = " Weather"
            $0.textColor = .white
            $0.textAlignment = .left
            $0.font = .systemFont(ofSize: 17, weight: .bold)
        }

        appleWeatherLegalSourceLinkButton.do {
            $0.setAttributedTitle(
                NSAttributedString(
                    string: "출처 링크",
                    attributes: [
                        .underlineStyle: NSUnderlineStyle.single.rawValue,
                        .underlineColor: UIColor.link,
                        .foregroundColor: UIColor.link,
                        .font: UIFont.systemFont(ofSize: 17, weight: .bold)
                    ]
                ),
                for: .normal
            )

            $0.addTarget(
                self,
                action: #selector(navigateToAppleWeatherLegalSourceLink),
                for: .touchUpInside
            )
        }

        suggestionLabel.do {
            $0.numberOfLines = 0
            $0.font = .systemFont(ofSize: 20, weight: .heavy)
            $0.textColor = .white
        }
    }
    
    override func setConstraints() {
        contentView.addSubview(backgroundImageView)
        [appleWeatherTrademarkLabel, appleWeatherLegalSourceLinkButton, suggestionLabel].forEach {
            backgroundImageView.addSubview($0)
        }

        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        appleWeatherTrademarkLabel.snp.makeConstraints {
            $0.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(5)
            $0.left.equalTo(5)
        }

        appleWeatherLegalSourceLinkButton.snp.makeConstraints {
            $0.centerY.equalTo(appleWeatherTrademarkLabel)
            $0.left.equalTo(appleWeatherTrademarkLabel.snp.right).offset(5)
            $0.height.equalTo(30)
        }

        suggestionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.left.equalTo(20)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
}
