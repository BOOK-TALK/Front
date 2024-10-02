//
//  SecondCategoryViewController.swift
//  BookTalk
//
//  Created by 김민 on 7/26/24.
//

import UIKit

final class SubcategoryViewController: BaseViewController {

    // MARK: - Properties

    private let subcategoryTableView = UITableView(frame: .zero)
    private let indicatorView = UIActivityIndicatorView(style: .medium)
    private let indicatorBackgroundView = UIView()

    private let viewModel: SubcategoryViewModel

    // MARK: - Initializer

    init(viewModel: SubcategoryViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setCollectionView()
        registerCell()
        bind()

        viewModel.send(action: .setSubcategory(subcategoryIdx: 0))
    }

    // MARK: - Helpers

    override func setNavigationBar() {
        navigationItem.title = viewModel.firstCategoryType.title
        navigationItem.backButtonTitle = ""
        navigationItem.largeTitleDisplayMode = .never
    }

    override func setViews() {
        view.backgroundColor = .white

        subcategoryTableView.do {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.separatorInset = .init(top: 0, left: 12, bottom: 0, right: 12)
        }

        indicatorView.do {
            $0.hidesWhenStopped = true
            $0.color = .white
        }

        indicatorBackgroundView.do {
            $0.backgroundColor = .lightGray.withAlphaComponent(0.9)
            $0.layer.cornerRadius = 10
        }
    }

    override func setConstraints() {
        [subcategoryTableView, indicatorBackgroundView].forEach {
            view.addSubview($0)
        }

        indicatorBackgroundView.addSubview(indicatorView)

        subcategoryTableView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }

        indicatorBackgroundView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(50)
        }

        indicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private func setCollectionView() {
        subcategoryTableView.dataSource = self
        subcategoryTableView.delegate = self
    }

    private func registerCell() {
        subcategoryTableView.register(BannerCell.self, forCellReuseIdentifier: BannerCell.identifier)
        subcategoryTableView.register(CategoryTitleCell.self, forCellReuseIdentifier: CategoryTitleCell.identifier)
        subcategoryTableView.register(ShowAllBookCell.self, forCellReuseIdentifier: ShowAllBookCell.identifier)
        subcategoryTableView.register(BookWithHeaderCell.self, forCellReuseIdentifier: BookWithHeaderCell.identifier)
    }

    private func bind() {
        viewModel.subcategory.subscribe { [weak self] _ in
            self?.subcategoryTableView.reloadData()
        }

        viewModel.popularBooks.subscribe { _ in
            Task { [weak self] in
                await MainActor.run {
                    self?.subcategoryTableView.reloadSections(
                        IndexSet(integer: CategorySectionKind.popularBooks.rawValue), with: .fade
                    )
                }
            }
        }

        viewModel.newBooks.subscribe { _ in
            Task { [weak self] in
                await MainActor.run {
                    self?.subcategoryTableView.reloadSections(
                        IndexSet(integer: CategorySectionKind.newBooks.rawValue), with: .automatic
                    )
                }
            }
        }

        viewModel.isLoading.subscribe { [weak self] isLoading in
            guard let self = self else { return }

            isLoading ? indicatorView.startAnimating() : indicatorView.stopAnimating()
            indicatorBackgroundView.isHidden = !isLoading
        }
    }
}

// MARK: - UITableViewDataSource

extension SubcategoryViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return CategorySectionKind.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = CategorySectionKind.allCases[indexPath.section]

        switch section {
        case .banner:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BannerCell.identifier, for: indexPath) as? BannerCell else { return UITableViewCell() }

            return cell

        case .category:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTitleCell.identifier, for: indexPath) as? CategoryTitleCell else { return UITableViewCell() }

            let category: Category = .init(
                firstCategory: viewModel.firstCategoryType.title,
                subcategory: viewModel.subcategory.value
            )
            cell.bind(category)

            return cell

        case .allBookButton:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ShowAllBookCell.identifier, for: indexPath) as? ShowAllBookCell else { return UITableViewCell() }

            return cell

        case .popularBooks, .newBooks:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BookWithHeaderCell.identifier, for: indexPath) as? BookWithHeaderCell else { return UITableViewCell() }

            cell.bind(
                book:section == .popularBooks ?
                viewModel.popularBooks.value : viewModel.newBooks.value
            )

            cell.delegate = self

            return cell
        }
    }
}


// MARK: - UITableViewDelegate

extension SubcategoryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = CategorySectionKind.allCases[indexPath.section]

        switch section {

        case .banner:
            return .zero

        case .category, .allBookButton, .newBooks, .popularBooks:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = CategorySectionKind.allCases[indexPath.section]

        switch section {

        case .category:
            let viewModel = CategorySelectModalViewModel(
                firstCategory: viewModel.firstCategoryType,
                subcategory: viewModel.subcategory.value
            )
            let modalViewController = CategorySelectModalViewController(viewModel: viewModel)

            modalViewController.modalPresentationStyle = .pageSheet
            modalViewController.delegate = self

            present(modalViewController, animated: true)

        case .allBookButton:
            let viewModel = AllBooksViewModel(
                genreCode: "\(viewModel.firstCategoryType.rawValue)\(viewModel.subcategoryIdx)"
            )
            let allBooksViewController = AllBooksViewController(viewModel: viewModel)

            allBooksViewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(allBooksViewController, animated: true)

        case .banner, .newBooks, .popularBooks:
            return
        }
    }
}

// MARK: - CategorySelectModalViewControllerDelegate

extension SubcategoryViewController: CategorySelectModalViewControllerDelegate {

    func subcategorySelected(subcategoryIndex: Int) {
        viewModel.send(action: .setSubcategory(subcategoryIdx: subcategoryIndex))
    }
}

extension SubcategoryViewController: BookWithHeaderCellDelegate {

    func bookImageTapped(of isbn: String) {
        let viewModel = BookDetailViewModel(isbn: isbn)
        let detailVC = BookDetailViewController(viewModel: viewModel)
        detailVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(detailVC, animated: true)
    }
}
