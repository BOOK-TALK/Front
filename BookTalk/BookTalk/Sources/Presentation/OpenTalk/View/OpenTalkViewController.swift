//
//  OpenTalkViewController.swift
//  BookTalk
//
//  Created by RAFA on 7/23/24.
//

import UIKit

final class OpenTalkViewController: BaseViewController {

    // MARK: - Properties

    private let bookBanner = UIImageView()
    private let pageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    private let bookCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    private let refreshControl = UIRefreshControl()
    private let indicatorView = UIActivityIndicatorView(style: .medium)

    private let viewModel: OpenTalkViewModel

    // MARK: - Initializer

    init(viewModel: OpenTalkViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegate()
        registerCell()
        bind()
        addTarget()

        viewModel.send(action: .setPageType(.hot))
    }

    // MARK: - UI Setup

    override func setNavigationBar() {
        let appearance = UINavigationBarAppearance()

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        let searchIcon = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(searchIconDidTapped)
        )

        navigationItem.rightBarButtonItem = searchIcon
    }

    override func setViews() {
        bookBanner.do {
            $0.backgroundColor = .gray100
        }

        pageCollectionView.do {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .horizontal

            $0.collectionViewLayout = flowLayout
            $0.backgroundColor = .clear
            $0.contentInset = .init()
        }

        bookCollectionView.do {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 24
            flowLayout.minimumInteritemSpacing = 8

            $0.collectionViewLayout = flowLayout
            $0.backgroundColor = .clear
            $0.contentInset = .init(top: 10, left: 10, bottom: 10, right: 10)
            $0.showsVerticalScrollIndicator = false
            $0.refreshControl = refreshControl
        }

        indicatorView.do {
            $0.hidesWhenStopped = true
        }
    }

    override func setConstraints() {
        [bookBanner, pageCollectionView, bookCollectionView, indicatorView].forEach {
            view.addSubview($0)
        }

        bookBanner.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(0)
        }

        pageCollectionView.snp.makeConstraints {
            $0.top.equalTo(bookBanner.snp.bottom)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(60)
        }

        bookCollectionView.snp.makeConstraints {
            $0.top.equalTo(pageCollectionView.snp.bottom)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        indicatorView.snp.makeConstraints {
            $0.center.equalTo(bookCollectionView)
        }
    }

    // MARK: - Helpers

    private func setDelegate() {
        pageCollectionView.dataSource = self
        pageCollectionView.delegate = self

        bookCollectionView.dataSource = self
        bookCollectionView.delegate = self
    }

    private func registerCell() {
        pageCollectionView.register(
            OpenTalkPageCell.self,
            forCellWithReuseIdentifier: OpenTalkPageCell.identifier
        )
        bookCollectionView.register(
            BookImageCell.self,
            forCellWithReuseIdentifier: BookImageCell.identifier
        )
    }

    private func addTarget() {
        refreshControl.addTarget(
            self,
            action: #selector(refreshCollectionView),
            for: .valueChanged
        )
    }

    private func bind() {
        viewModel.loadState.subscribe { [weak self] state in
            guard let self = self else { return }

            switch state {
            case .initial:
                break

            case .loading:
                indicatorView.startAnimating()
                bookCollectionView.isHidden = true

            case .completed:
                indicatorView.stopAnimating()
                bookCollectionView.isHidden = false

                var result: [OpenTalkBookModel] = .init()

                switch viewModel.selectedPageType {
                case .hot:
                    result = viewModel.hotOpenTalks.value
                case .liked:
                    result = viewModel.favoriteOpenTalks.value
                }

                if result.isEmpty {
                    bookCollectionView.setEmptyMessage("오픈톡이 없습니다.")
                } else {
                    bookCollectionView.restore()
                }

                bookCollectionView.reloadData()
            }
        }
     }

    // MARK: - Actions

    @objc private func searchIconDidTapped() {
        let viewModel = SearchViewModel()
        let searchVC = SearchViewController(viewModel: viewModel)

        searchVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(searchVC, animated: true)
    }

    @objc private func refreshCollectionView() {
        viewModel.send(action: .setPageType(.hot))

        refreshControl.endRefreshing()
    }
}

// MARK: - UICollectionViewDataSource

extension OpenTalkViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if collectionView == pageCollectionView {
            return OpenTalkPageType.allCases.count
        } else {
            switch viewModel.selectedPageType {
            case .hot:
                return viewModel.hotOpenTalks.value.count

            case .liked:
                return viewModel.favoriteOpenTalks.value.count
            }
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == pageCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: OpenTalkPageCell.identifier,
                for: indexPath
            ) as? OpenTalkPageCell else { return UICollectionViewCell() }

            if indexPath.row == 0 {
                collectionView.selectItem(
                    at: indexPath,
                    animated: false,
                    scrollPosition: .init()
                )
                cell.isSelected = true
            }

            cell.bind(OpenTalkPageType.allCases[indexPath.row].title)

            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BookImageCell.identifier,
                for: indexPath
            ) as? BookImageCell else { return UICollectionViewCell() }

            var openTalk: OpenTalkBookModel = .init(id: 0, isbn: "", bookName: "", bookImageURL: "")

            switch viewModel.selectedPageType {
            case .hot:
                openTalk = viewModel.hotOpenTalks.value[indexPath.item]

            case .liked:
                openTalk = viewModel.favoriteOpenTalks.value[indexPath.item]
            }

            cell.bind(
                with: Book(
                    isbn: openTalk.isbn,
                    imageURL: openTalk.bookImageURL,
                    title: openTalk.bookName
                )
            )

            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension OpenTalkViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView == pageCollectionView {
            return CGSize(
                width: ScreenSize.width/2,
                height: collectionView.frame.height
            )
        } else {
            let width = (ScreenSize.width-36) / 3
            return CGSize(width: width, height: 208)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if collectionView == pageCollectionView {
            viewModel.send(action: .setPageType(OpenTalkPageType.allCases[indexPath.item]))
        } else {
            var book: OpenTalkBookModel = .init(id: 0, isbn: "", bookName: "", bookImageURL: "")


            switch viewModel.selectedPageType {
            case .hot:
                book = viewModel.hotOpenTalks.value[indexPath.item]

            case .liked:
                book = viewModel.favoriteOpenTalks.value[indexPath.item]
            }

            let viewModel = ChatViewModel(isbn: book.isbn)
            let chattingVC = ChatViewController(viewModel: viewModel)
            chattingVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(chattingVC, animated: true)
        }
    }
}
