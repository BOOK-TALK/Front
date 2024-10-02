//
//  MyViewController.swift
//  BookTalk
//
//  Created by RAFA on 7/23/24.
//

import UIKit

final class MyViewController: BaseViewController {

    // MARK: - Properties

    private let viewModel = MyPageViewModel()

    private let collectionView: UICollectionView = {
        let layout = StickyHeaderFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionHeadersPinToVisibleBounds = true
        return UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCell()
        setDelegate()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.send(action: .loadUserInfo)
    }

    // MARK: - Bind

    private func bind() {
        viewModel.userInfoOb.subscribe { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }

    // MARK: - Actions
    
    @objc private func editInfoButtonDidTap() {
        let viewModel = UserInfoViewModel(isInitialEdit: false)
        let infoVC = UserInfoViewController(viewModel: viewModel)
        infoVC.navigationItem.backButtonTitle = ""
        infoVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(infoVC, animated: true)
    }
    
    @objc private func settingButtonDidTap() {
        let viewModel = SettingViewModel()
        let settingVC = SettingViewController(viewModel: viewModel)
        settingVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(settingVC, animated: true)
    }

    // MARK: - Set UI
    
    override func setNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.shadowColor = nil
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        let editButton = UIBarButtonItem(
            image: UIImage(systemName: "pencil"),
            style: .plain,
            target: self,
            action: #selector(editInfoButtonDidTap)
        )
        
        let settingButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingButtonDidTap)
        )

        navigationItem.rightBarButtonItems = [settingButton, editButton]
        navigationItem.title = "내 정보"
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationItem.backButtonTitle = ""
    }
    
    override func setViews() {
        collectionView.do {
            $0.backgroundColor = .clear
            $0.alwaysBounceVertical = true
            $0.contentInset = .zero
            $0.showsHorizontalScrollIndicator = false
        }
    }
    
    override func setConstraints() {
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func registerCell() {
        collectionView.do {
            $0.register(
                ProfileInfoView.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: ProfileInfoView.identifier
            )
            
            $0.register(
                MyPageStickyTabView.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: MyPageStickyTabView.identifier
            )
            
            $0.register(
                BookImageCell.self,
                forCellWithReuseIdentifier: BookImageCell.identifier
            )
        }
    }
    
    private func setDelegate() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

// MARK: - UICollectionViewDataSource

extension MyViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard section == 1 else { return 0 }

        switch viewModel.selectedTab.value {
        case 0: return viewModel.readBooksOb.value.count
        case 1: return viewModel.dibBooksOb.value.count
        default: return 0
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard indexPath.section == 1 else { return UICollectionViewCell() }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BookImageCell.identifier,
            for: indexPath
        ) as? BookImageCell else {
            return UICollectionViewCell()
        }

        switch viewModel.selectedTab.value {
        case 0:
            cell.bind(with: viewModel.readBooksOb.value[indexPath.item])
        case 1:
            cell.bind(with: viewModel.dibBooksOb.value[indexPath.item])
        default:
            break
        }

        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if indexPath.section == 0 {
                guard let profileInfoView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: ProfileInfoView.identifier,
                    for: indexPath
                ) as? ProfileInfoView else {
                    return UICollectionReusableView()
                }

                profileInfoView.delegate = self
                profileInfoView.bind(with: viewModel.userInfoOb.value?.userInfo)

                return profileInfoView
            } else {
                guard let myPageStickyTabView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: MyPageStickyTabView.identifier,
                    for: indexPath
                ) as? MyPageStickyTabView else {
                    return UICollectionReusableView()
                }
                
                myPageStickyTabView.delegate = self
                myPageStickyTabView.setSelectedTab(
                    index: viewModel.selectedTab.value
                )
                myPageStickyTabView.bind(
                    readCnt: viewModel.readBooksOb.value.count,
                    dibCnt: viewModel.dibBooksOb.value.count
                )

                return myPageStickyTabView
            }
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegate

extension MyViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        switch viewModel.selectedTab.value {
        case 0:
            let book = viewModel.readBooksOb.value[indexPath.row]
            pushToDetailViewController(of: book.isbn)
        case 1:
            let book = viewModel.dibBooksOb.value[indexPath.row]
            pushToDetailViewController(of: book.isbn)
        default:
            return
        }
    }

    private func pushToDetailViewController(of isbn: String) {
        let viewModel = BookDetailViewModel(isbn: isbn)
        let detailVC = BookDetailViewController(viewModel: viewModel)
        detailVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - MyPageStickyTabViewDelegate

extension MyViewController: MyPageStickyTabViewDelegate {
    
    func didSelectTab(index: Int) {
        viewModel.send(action: .selectTab(index: index))
        collectionView.reloadData()
    }
}

// MARK: - ProfileInfoViewModelDelegate

extension MyViewController: ProfileInfoViewDelegate {

    func didTapAddFinishedBookButton() {
        let viewModel = AddBookViewModel(addBookType: .readBook)
        let addBookVC = AddBookViewController(viewModel: viewModel)
        addBookVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(addBookVC, animated: true)
    }
    
    func didTapEditLibraryButton() {
        let myLibraryVC = MyLibraryViewController()
        navigationController?.pushViewController(myLibraryVC, animated: true)
    }
}

// MARK: - UICollectionViewLayout

private extension MyViewController {
    
    static func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, environment)
            -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0: return createProfileSection()
            case 1: return createBooksSection()
            default: return nil
            }
        }
    }
    
    static func createProfileHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(150)
        )
        
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
    
    static func createProfileSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(150)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [createProfileHeaderItem()]
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 0,
            bottom: 10,
            trailing: 0
        )
        
        return section
    }
    
    static func createStickyTabHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        headerItem.pinToVisibleBounds = true
        
        return headerItem
    }
    
    static func createBooksSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 4, bottom: 0, trailing: 4)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(180)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [createStickyTabHeaderItem()]
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 4,
            bottom: 10,
            trailing: 4
        )
        section.interGroupSpacing = 24

        return section
    }
}
