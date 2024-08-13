//
//  AddBookViewController.swift
//  BookTalk
//
//  Created by 김민 on 8/13/24.
//

import UIKit

final class AddBookViewController: BaseViewController {

    // MARK: - Properties

    private let searchBar = UISearchBar()
    private let resultCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())

    private let viewModel: AddBookViewModel

    // MARK: - Initializer

    init(viewModel: AddBookViewModel) {
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
    }

    // MARK: - UI Setup

    override func setNavigationBar() {
        navigationItem.titleView = searchBar
    }

    override func setViews() {
        view.backgroundColor = .white

        searchBar.do {
            $0.placeholder = "어떤 책을 읽고 계신가요?"
        }

        resultCollectionView.do {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .vertical

            $0.collectionViewLayout = flowLayout
            $0.backgroundColor = .clear
            $0.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            $0.showsVerticalScrollIndicator = false
        }
    }

    override func setConstraints() {
        [searchBar, resultCollectionView].forEach {
            view.addSubview($0)
        }

        resultCollectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
    }

    // MARK: - Helpers

    private func setDelegate() {
        resultCollectionView.dataSource = self
        resultCollectionView.delegate = self

        searchBar.delegate = self
    }

    private func registerCell() {
        resultCollectionView.register(
            BookImageCell.self,
            forCellWithReuseIdentifier: BookImageCell.identifier
        )

        resultCollectionView.register(
            LikedTitleHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: LikedTitleHeaderView.identifier
        )
    }

    private func bind() {
        viewModel.books.subscribe { [weak self] _ in
            self?.resultCollectionView.reloadData()
        }

        viewModel.searchText.subscribe { [weak self] text in
            self?.searchBar.text = text
        }
    }
}

// MARK: - UICollectionViewDataSource

extension AddBookViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 5
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BookImageCell.identifier,
            for: indexPath
        ) as? BookImageCell else { return UICollectionViewCell() }

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AddBookViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (ScreenSize.width-36) / 3
        return CGSize(width: width, height: 208)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 24
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 8
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: LikedTitleHeaderView.identifier,
            for: indexPath
        ) as? LikedTitleHeaderView else { return UICollectionReusableView() }

        return headerView
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}

// MARK: - UISearchBarDelegate

extension AddBookViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.send(action: .loadResult(query: searchBar.text ?? ""))
    }
}
