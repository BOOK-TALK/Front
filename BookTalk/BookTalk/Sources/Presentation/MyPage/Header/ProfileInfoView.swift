//
//  ProfileInfoView.swift
//  BookTalk
//
//  Created by RAFA on 8/20/24.
//

import UIKit

protocol ProfileInfoViewDelegate: AnyObject {
    func didTapAddFinishedBookButton()
    func didTapEditLibraryButton()
}

final class ProfileInfoView: BaseCollectionViewHeaderFooterView {
    
    // MARK: - Properties
    
    private let nameLabel = UILabel()
    private let genderAndAgeLabel = UILabel()
    private let userInfoStackView = UIStackView()
    private let libraryTextStackView = UIStackView()
    private let addFinishedBookButton = UIButton(type: .system)
    private let editLibraryButton = UIButton(type: .system)
    private let profileBottomButtons = UIStackView()

    weak var delegate: ProfileInfoViewDelegate?

    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc private func addFinishedBookButtonTapped() {
        delegate?.didTapAddFinishedBookButton()
    }
    
    @objc private func editLibraryButtonTapped() {
        delegate?.didTapEditLibraryButton()
    }
    
    private func addTargets() {
        addFinishedBookButton.addTarget(
            self,
            action: #selector(addFinishedBookButtonTapped),
            for: .touchUpInside
        )
        editLibraryButton.addTarget(
            self,
            action: #selector(editLibraryButtonTapped),
            for: .touchUpInside
        )
    }
    
    // MARK: - Bind
    
    func bind(with userInfo: UserBasicInfo?) {
        guard let userInfo = userInfo else { return }
        
        nameLabel.text = userInfo.nickname
        
        if let age = userInfo.birth?.toKoreanAge() {
            genderAndAgeLabel.text = "\(userInfo.gender.koreanTitle)/\(age)살"
        } else {
            genderAndAgeLabel.text = "\(userInfo.gender.koreanTitle)"
        }
    }
    
    // MARK: - Helpers
    
    private func displayAddedTexts(_ texts: [String]) {
        libraryTextStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        texts.forEach { text in
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 15)
            libraryTextStackView.addArrangedSubview(label)
        }
        
        self.invalidateCollectionViewLayout()
    }
    
    private func invalidateCollectionViewLayout() {
        if let collectionView = self.superview as? UICollectionView {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: - Set UI
    
    override func setViews() {
        nameLabel.do {
            $0.font = .systemFont(ofSize: 30, weight: .bold)
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
        
        genderAndAgeLabel.do {
            $0.textColor = .lightGray
            $0.font = .systemFont(ofSize: 20, weight: .medium)
            $0.numberOfLines = 1
            $0.textAlignment = .center
        }
        
        userInfoStackView.do {
            $0.addArrangedSubview(nameLabel)
            $0.addArrangedSubview(genderAndAgeLabel)
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fillProportionally
            $0.spacing = 5
        }
        
        libraryTextStackView.do {
            $0.axis = .vertical
            $0.alignment = .leading
            $0.spacing = 5
        }
        
        addFinishedBookButton.do {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "books.vertical")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 13, weight: .medium))
            config.imagePadding = 5
            config.imagePlacement = .leading
            config.attributedTitle = AttributedString(
                NSAttributedString(
                    string: "읽은 책 추가",
                    attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .medium)]
                )
            )
            config.baseForegroundColor = .black
            $0.configuration = config
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 10
            $0.backgroundColor = .accentOrange.withAlphaComponent(0.2)
        }
        
        editLibraryButton.do {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "building.columns")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 13, weight: .medium))
            config.imagePadding = 5
            config.imagePlacement = .leading
            config.baseForegroundColor = .black
            config.attributedTitle = AttributedString(
                NSAttributedString(
                    string: "도서관 편집",
                    attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .medium)]
                )
            )
            $0.configuration = config
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 10
            $0.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        }
        
        profileBottomButtons.do {
            $0.addArrangedSubview(addFinishedBookButton)
            $0.addArrangedSubview(editLibraryButton)
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.distribution = .fillEqually
            $0.spacing = 5
        }
    }
    
    override func setConstraints() {
        [userInfoStackView, libraryTextStackView,  profileBottomButtons].forEach {
            addSubview($0)
        }
        
        userInfoStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(20)
            $0.left.equalTo(15)
        }
        
        libraryTextStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(userInfoStackView.snp.bottom).offset(10)
            $0.left.equalTo(15)
            $0.right.equalTo(-15)
        }
        
        addFinishedBookButton.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        profileBottomButtons.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(libraryTextStackView.snp.bottom).offset(10)
            $0.left.equalTo(15)
            $0.right.equalTo(-15)
            $0.bottom.greaterThanOrEqualTo(-10)
        }
    }
}
