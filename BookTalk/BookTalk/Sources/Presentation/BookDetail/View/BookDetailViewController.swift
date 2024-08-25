//
//  BookDetailViewController.swift
//  BookTalk
//
//  Created by RAFA on 8/5/24.
//

import UIKit

final class BookDetailViewController: BaseViewController {
    
    // MARK: - Properties

    private var favoriteButton = UIBarButtonItem()
    private let floatingButton = UIButton(type: .system)
    private let likeButton = UIButton(type: .system)
    private let dislikeButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let indicatorView = UIActivityIndicatorView(style: .medium)

    private let viewModel: BookDetailViewModel

    // MARK: - Initializer

    init(viewModel: BookDetailViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.input.loadDetailInfo()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTarget()
        bind()
        registerCell()
        setDelegate()
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        let bottomInset = view.bounds.height - floatingButton.frame.minY
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
//    }
    
    // MARK: - Actions
    
    @objc private func handleFavoriteButton() {
        viewModel.input.favoriteButtonTap()
    }
    
    @objc private func floatingButtonDidTap() {
        viewModel.output.areChildButtonsVisible.value.toggle()
    }
    
    @objc private func handleLikeButton() {
        viewModel.input.likeButtonTap()
    }
    
    @objc private func handleDislikeButton() {
        viewModel.input.dislikeButtonTap()
    }
    
    private func addTarget() {
        floatingButton.addTarget(
            self,
            action: #selector(floatingButtonDidTap),
            for: .touchUpInside
        )
        likeButton.addTarget(
            self,
            action: #selector(handleLikeButton),
            for: .touchUpInside
        )
        dislikeButton.addTarget(
            self,
            action: #selector(handleDislikeButton),
            for: .touchUpInside
        )
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.output.loadState.subscribe { [weak self] state in
            guard let self = self else { return }

            switch state {
            case .loading:
                indicatorView.startAnimating()
                tableView.isHidden = true

            case .completed, .initial:
                indicatorView.stopAnimating()
                tableView.isHidden = false
            }
        }

        viewModel.output.isFavorite.subscribe { [weak self] isFavorite in
            self?.updateFavoriteButtonState(isFavorite)
        }

        viewModel.output.areChildButtonsVisible.subscribe { [weak self] _ in
            self?.updateChildButtonVisibility()
        }
        
        viewModel.output.isLiked.subscribe { [weak self] _ in
            self?.updateLikeButtonState()
        }
        
        viewModel.output.isDisliked.subscribe { [weak self] _ in
            self?.updateDislikeButtonState()
        }

        viewModel.output.detailBook.subscribe { [weak self] book in
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - Set UI
    
    override func setNavigationBar() {
        favoriteButton = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(handleFavoriteButton)
        )
        
        navigationItem.title = ""
        navigationItem.rightBarButtonItem = favoriteButton
    }
    
    override func setViews() {
        view.backgroundColor = .white
        
        tableView.do {
            $0.separatorInset = .zero
            $0.estimatedRowHeight = 600
            $0.rowHeight = UITableView.automaticDimension
        }
        
        floatingButton.do {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .accentOrange
            config.cornerStyle = .capsule
            config.image = UIImage(systemName: "ellipsis")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
            $0.configuration = config
            $0.layer.shadowRadius = 10
            $0.layer.shadowOpacity = 0.3
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
        }

        dislikeButton.do {
            $0.configuration?.baseBackgroundColor = .systemRed
            $0.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
        }
        
        indicatorView.do {
            $0.hidesWhenStopped = true
        }
    }

    override func setConstraints() {
        [tableView,
//         floatingButton,
//         likeButton,
//         dislikeButton,
         indicatorView
       ].forEach { view.addSubview($0) }

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
//        floatingButton.snp.makeConstraints {
//            $0.width.height.equalTo(60)
//            $0.right.equalToSuperview().inset(15)
//            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-15)
//        }
//        
//        likeButton.snp.makeConstraints {
//            $0.width.height.equalTo(50)
//            $0.right.equalTo(floatingButton.snp.left).offset(-10)
//            $0.centerY.equalTo(floatingButton).offset(-15)
//        }
//
//        dislikeButton.snp.makeConstraints {
//            $0.width.height.equalTo(50)
//            $0.centerX.equalTo(floatingButton).offset(-15)
//            $0.bottom.equalTo(floatingButton.snp.top).offset(-10)
//        }

        indicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func registerCell() {
        tableView.do {
            $0.register(
                BookInfoCell.self,
                forCellReuseIdentifier: BookInfoCell.identifier
            )
            $0.register(
                BorrowableLibraryCell.self,
                forCellReuseIdentifier: BorrowableLibraryCell.identifier
            )
        }
    }
    
    private func setDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Helpers
    
    private func updateFavoriteButtonState(_ isFavorite: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let imageName = isFavorite ? "heart.fill" : "heart"
            favoriteButton.image = UIImage(systemName: imageName)

            let tintColor: UIColor = isFavorite ? .systemRed : .black
            favoriteButton.tintColor = tintColor
        }
    }

    private func updateLikeButtonState() {
        let imageName = viewModel.output.isLiked.value ? "hand.thumbsup.fill" : "hand.thumbsup"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    private func updateDislikeButtonState() {
        let imageName =
            viewModel.output.isDisliked.value ? "hand.thumbsdown.fill" : "hand.thumbsdown"
        dislikeButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    private func updateChildButtonVisibility() {
        let buttons: [UIButton] = [likeButton, dislikeButton]
        let isVisible = viewModel.output.areChildButtonsVisible.value
        let transform: CATransform3D =
            isVisible ? CATransform3DIdentity : CATransform3DMakeScale(0.4, 0.4, 1)
        let alpha: CGFloat = isVisible ? 1.0 : 0.0
        let duration: TimeInterval = 0.3
        
        buttons.forEach { button in
            UIView.animate(
                withDuration: duration,
                delay: 0.2,
                usingSpringWithDamping: isVisible ? 0.55 : 1.0,
                initialSpringVelocity: isVisible ? 0.3 : 0.0,
                options: [.curveEaseInOut],
                animations: {
                    button.layer.transform = transform
                    button.alpha = alpha
                }
            )
        }
        rotateFloatingButton(isVisible: isVisible)
    }
    
    private func rotateFloatingButton(isVisible: Bool) {
        let fromValue: CGFloat = isVisible ? 0 : .pi / 4
        let toValue: CGFloat = isVisible ? .pi / 4 : 0
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = 0.3
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        floatingButton.layer.add(animation, forKey: nil)
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
                withIdentifier: BookInfoCell.identifier,
                for: indexPath
            ) as? BookInfoCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.bind(viewModel)
            cell.delegate = self
            return cell

        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: BorrowableLibraryCell.identifier,
                for: indexPath
            ) as? BorrowableLibraryCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.selectionStyle = .none
            cell.bind(viewModel)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension BookDetailViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.section == tableView.numberOfSections - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        }
    }
}

// MARK: - BorrowableLibraryCellDelegate

extension BookDetailViewController: BorrowableLibraryCellDelegate {
    
    func pushToMyLibraryVC() {
        let myLibraryVC = MyLibraryViewController()
        navigationController?.pushViewController(myLibraryVC, animated: true)
    }
}

// MARK: - BookInfoCellDelegate
extension BookDetailViewController: BookInfoCellDelegate {

    func openTalkButtonDidTapped() {
        let viewModel = ChatViewModel(
            isbn: viewModel.output.detailBook.value?.basicBookInfo.isbn ?? ""
        )
        let chatVC = ChatViewController(viewModel: viewModel)
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
