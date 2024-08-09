//
//  BookDetailViewController.swift
//  BookTalk
//
//  Created by RAFA on 8/5/24.
//

import UIKit

final class BookDetailViewController: BaseViewController {
    
    // MARK: - Properties
    
    var viewModel: BookDetailViewModel!
    private var favoriteButton = UIBarButtonItem()
    private let floatingButton = UIButton(type: .system)
    private let likeButton = UIButton(type: .system)
    private let dislikeButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let bookInfoID = BookInfoCell.identifier
    private let nearbyID = NearbyCell.identifier
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    // MARK: - Actions
    
    @objc private func handleFavoriteButton() {
        viewModel.favoriteButtonDidTap()
    }
    
    @objc private func floatingButtonDidTap() {
        viewModel.toggleFloatingButton()
    }
    
    @objc private func handleLikeButton() {
        viewModel.likeButtonDidTap()
    }
    
    @objc private func handleDislikeButton() {
        viewModel.dislikeButtonDidTap()
    }
    
    @objc private func handleBookmarkButton() {
        viewModel.bookmarkButtonDidTap()
    }
    
    // MARK: - Button Animations
    
    private func updateChildButtonVisibility() {
        let buttons: [UIButton] = [likeButton, dislikeButton]
        if viewModel.areChildButtonsVisible {
            buttons.forEach { button in
                button.layer.transform = CATransform3DMakeScale(0.4, 0.4, 1)
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0.2,
                    usingSpringWithDamping: 0.55,
                    initialSpringVelocity: 0.3,
                    options: [.curveEaseInOut],
                    animations: {
                        button.layer.transform = CATransform3DIdentity
                        button.alpha = 1.0
                    }
                )
            }
        } else {
            UIView.animate(withDuration: 0.15, delay: 0.2) {
                buttons.forEach { button in
                    button.layer.transform = CATransform3DMakeScale(0.4, 0.4, 0.1)
                    button.alpha = 0.0
                }
            }
        }
        rotateFloatingButton()
    }
    
    private func rotateFloatingButton() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        let fromValue = viewModel.areChildButtonsVisible ? 0 : CGFloat.pi / 4
        let toValue = viewModel.areChildButtonsVisible ? CGFloat.pi / 4 : 0
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = 0.3
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        floatingButton.layer.add(animation, forKey: nil)
    }
    
    // MARK: - Helpers
    
    override func bind() {
        viewModel.onFavoriteButtonTapped = { [weak self] in
            self?.updateFavoriteButtonState()
        }
        
        viewModel.onFloatingButtonTapped = { [weak self] in
            self?.updateChildButtonVisibility()
        }
        
        viewModel.onLikeButtonTapped = { [weak self] in
            self?.updateLikeButtonState()
            self?.updateDislikeButtonState()
        }
        
        viewModel.onDislikeButtonTapped = { [weak self] in
            self?.updateDislikeButtonState()
            self?.updateLikeButtonState()
        }
    }
    
    private func updateFavoriteButtonState() {
        let imageName = viewModel.isFavorite ? "heart.fill" : "heart"
        favoriteButton.image = UIImage(systemName: imageName)
        
        let tintColor: UIColor = viewModel.isFavorite ? .systemRed : .black
        favoriteButton.tintColor = tintColor
    }
    
    private func updateLikeButtonState() {
        let imageName = viewModel.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    private func updateDislikeButtonState() {
        let imageName = viewModel.isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown"
        dislikeButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    // MARK: - UI Setup
    
    override func setNavigationBar() {
        favoriteButton = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(handleFavoriteButton)
        )
        
        navigationItem.rightBarButtonItem = favoriteButton
    }
    
    override func setViews() {
        view.backgroundColor = .white
        
        tableView.do {
            $0.dataSource = self
            $0.separatorInset = .zero
            $0.register(BookInfoCell.self, forCellReuseIdentifier: bookInfoID)
            $0.register(NearbyCell.self, forCellReuseIdentifier: nearbyID)
        }
        
        floatingButton.do {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .accentOrange
            config.cornerStyle = .capsule
            config.image = UIImage(systemName: "plus")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
            $0.configuration = config
            $0.layer.shadowRadius = 10
            $0.layer.shadowOpacity = 0.3
            $0.addTarget(self, action: #selector(floatingButtonDidTap), for: .touchUpInside)
        }
        
        [likeButton, dislikeButton].forEach {
            var config = UIButton.Configuration.filled()
            config.cornerStyle = .capsule
            $0.configuration = config
            $0.layer.shadowRadius = 10
            $0.layer.shadowOpacity = 0.3
            $0.alpha = 0.0
        }
        
        likeButton.do {
            $0.configuration?.baseBackgroundColor = .systemBlue
            $0.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            $0.addTarget(self, action: #selector(handleLikeButton), for: .touchUpInside)
        }

        dislikeButton.do {
            $0.configuration?.baseBackgroundColor = .systemRed
            $0.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
            $0.addTarget(self, action: #selector(handleDislikeButton), for: .touchUpInside)
        }
    }
    
    override func setConstraints() {
        [tableView,
         floatingButton,
         likeButton,
         dislikeButton].forEach { view.addSubview($0) }
        
        tableView.snp.makeConstraints {
            $0.centerX.left.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        floatingButton.snp.makeConstraints {
            $0.width.height.equalTo(60)
            $0.right.equalToSuperview().inset(15)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-15)
        }
        
        likeButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.right.equalTo(floatingButton.snp.left).offset(-10)
            $0.centerY.equalTo(floatingButton).offset(-15)
        }

        dislikeButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.centerX.equalTo(floatingButton).offset(-15)
            $0.bottom.equalTo(floatingButton.snp.top).offset(-10)
        }
    }
}

// MARK: - UITableViewDataSource

extension BookDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: bookInfoID,
                for: indexPath
            ) as? BookInfoCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.bind(viewModel)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: nearbyID,
                for: indexPath
            ) as? NearbyCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}
