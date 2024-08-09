//
//  OpenTalkViewController.swift
//  BookTalk
//
//  Created by RAFA on 7/23/24.
//

import UIKit

import SnapKit
import Then

final class OpenTalkViewController: BaseViewController {

    private let bookBanner = UIImageView()
    private let pageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    private let bookCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegate()
        registerCell()
    }

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

            $0.collectionViewLayout = flowLayout
            $0.backgroundColor = .clear
            $0.contentInset = .init(top: 10, left: 10, bottom: 10, right: 10)
            $0.showsVerticalScrollIndicator = false
        }
    }

    override func setConstraints() {
        [bookBanner, pageCollectionView, bookCollectionView].forEach {
            view.addSubview($0)
        }

        bookBanner.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(190)
        }

        pageCollectionView.snp.makeConstraints {
            $0.top.equalTo(bookBanner.snp.bottom)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(50)
        }

        bookCollectionView.snp.makeConstraints {
            $0.top.equalTo(pageCollectionView.snp.bottom)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    override func setDelegate() {
        pageCollectionView.dataSource = self
        pageCollectionView.delegate = self

        bookCollectionView.dataSource = self
        bookCollectionView.delegate = self
    }

    override func registerCell() {
        pageCollectionView.register(OpenTalkPageCell.self, forCellWithReuseIdentifier: OpenTalkPageCell.identifier)
        bookCollectionView.register(BookImageCell.self, forCellWithReuseIdentifier: BookImageCell.identifier)
    }

    @objc private func searchIconDidTapped() {
        let searchVC = SearchViewController()

        searchVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(searchVC, animated: true)
    }
}

extension OpenTalkViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if collectionView == pageCollectionView {
            return OpenTalkPageType.allCases.count
        } else {
            return 10
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
                collectionView.selectItem(at: indexPath, animated: false , scrollPosition: .init())
                cell.isSelected = true
            }

            cell.bind(OpenTalkPageType.allCases[indexPath.row].title)

            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BookImageCell.identifier,
                for: indexPath
            ) as? BookImageCell else { return UICollectionViewCell() }

            return cell
        }
    }
}

extension OpenTalkViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView == pageCollectionView {
            return CGSize(width: ScreenSize.width/2, height: collectionView.frame.height)
        } else {
            let width = (ScreenSize.width-36) / 3
            return CGSize(width: width, height: 160)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        if collectionView == pageCollectionView {
            return CGFloat()
        } else {
            return 8
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        if collectionView == pageCollectionView {
            return CGFloat()
        } else {
            return 8
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if collectionView == bookCollectionView {
            // TODO: 디테일뷰로 이동이지만 임시로 채팅뷰로 바로 이동하도록 구현
            let chattingVC = ChatViewController()
            chattingVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(chattingVC, animated: true)
        }
    }
}
