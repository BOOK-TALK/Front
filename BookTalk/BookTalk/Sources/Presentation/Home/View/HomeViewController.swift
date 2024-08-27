//
//  HomeViewController.swift
//  BookTalk
//
//  Created by RAFA on 7/23/24.
//

import UIKit

final class HomeViewController: BaseViewController {

    // MARK: - Properties

    private let tableView = UITableView(frame: .zero, style: .grouped)

    private let viewModel = HomeViewModel()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()
        setDelegate()
        bind()

        viewModel.send(action: .loadBooks)
    }

    // MARK: - Bind

    private func bind() {
        viewModel.thisWeekRecommendOb.subscribe { [weak self] _ in
            guard let self = self else { return }
            let sectionIndex = HomeSectionKind.weekRecommendation.rawValue
            self.tableView.reloadSections(IndexSet(integer: sectionIndex), with: .none)
        }

        viewModel.ageTrendOb.subscribe { [weak self] _ in
            guard let self = self else { return }
            let sectionIndex = HomeSectionKind.ageRecommend.rawValue
            self.tableView.reloadSections(IndexSet(integer: sectionIndex), with: .none)
        }

        viewModel.popularLoansOb.subscribe { [weak self] _ in
            guard let self = self else { return }
            let sectionIndex = HomeSectionKind.popularLoan.rawValue
            self.tableView.reloadSections(IndexSet(integer: sectionIndex), with: .none)
        }
    }

    // MARK: - Actions

    @objc private func searchIconTapped() {
        let viewModel = SearchViewModel()
        let searchVC = SearchViewController(viewModel: viewModel)
        searchVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(searchVC, animated: true)
    }

    // MARK: - Set UI

    override func setNavigationBar() {
        let appearance = UINavigationBarAppearance()

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        let searchIcon = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(searchIconTapped)
        )

        navigationItem.rightBarButtonItem = searchIcon
    }

    override func setViews() {
        view.addSubview(tableView)

        tableView.do {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.separatorInset = .init(top: 0, left: 12, bottom: 0, right: 12)
        }
    }

    override func setConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func registerCell() {
        tableView.do {
            $0.register(
                SuggestionCell.self,
                forCellReuseIdentifier: SuggestionCell.identifier
            )

            $0.register(
                KeywordHeaderView.self,
                forHeaderFooterViewReuseIdentifier: KeywordHeaderView.identifier
            )

            $0.register(KeywordCell.self, forCellReuseIdentifier: KeywordCell.identifier)

            $0.register(
                BookWithHeaderCell.self,
                forCellReuseIdentifier: BookWithHeaderCell.identifier
            )
        }
    }

    private func setDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return HomeSectionKind.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionKind = HomeSectionKind.allCases[section]

        switch sectionKind {
        case .keyword:
            return viewModel.isKeywordOpened.value ? 1 : 0
        default:
            return 1
        }
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let sectionKind = HomeSectionKind.allCases[indexPath.section]

        switch sectionKind {
        case .suggestion:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SuggestionCell.identifier,
                for: indexPath
            ) as? SuggestionCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = false
            cell.bind(
                "\(UserData.shared.getUser()?.nickname ?? "이름 없음")님, 오늘의 추천 도서를 확인해보세요!"
            )
            return cell

        case .keyword:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: KeywordCell.identifier,
                for: indexPath
            ) as? KeywordCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.bind(keywords: viewModel.keywordOb.value.map { $0.keyword })
            return cell

        case .weekRecommendation, .ageRecommend, .popularLoan:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BookWithHeaderCell.identifier, for: indexPath) as? BookWithHeaderCell else { return UITableViewCell() }

            if sectionKind == .weekRecommendation {
                cell.bind(
                    .init(
                        headerTitle: "이번 주 인기 도서를 확인해 보세요",
                        books: viewModel.thisWeekRecommendOb.value.books
                    ))
            } else if sectionKind == .popularLoan {
                cell.bind(
                    .init(
                        headerTitle: "대출 급상승 🔥",
                        books: viewModel.popularLoansOb.value.books
                    ))
            } else if sectionKind == .ageRecommend {
                cell.bind(
                    .init(
                        headerTitle:
                            UserData.shared.getUser()?.birth != nil ?
                        "\(UserData.shared.getUser()?.nickname ?? "이름 없음")님 나이대에서 인기 있는 도서" : "인기 대출 도서",
                        books: viewModel.ageTrendOb.value.books
                    ))
            }

            cell.delegate = self

            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let sectionType = HomeSectionKind.allCases[section]

        switch sectionType {
        case .keyword:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: KeywordHeaderView.identifier
            ) as? KeywordHeaderView else {
                return nil
            }
            headerView.delegate = self
            headerView.bind(viewModel.isKeywordOpened.value)
            headerView.section = section

            return headerView

        default:
            return nil
        }
    }

    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        let sectionType = HomeSectionKind.allCases[section]

        switch sectionType {
        case .keyword:
            return 60
        default:
            return .zero
        }
    }

    func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
    ) -> UIView? {
        return nil
    }

    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        return .zero
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionType = HomeSectionKind.allCases[indexPath.section]

        switch sectionType {
        case .keyword: return viewModel.isKeywordOpened.value ?
            UITableView.automaticDimension : 0
        default:
            return UITableView.automaticDimension
        }
    }
}

// MARK: - RecommendationBookCellDelegate

extension HomeViewController: RecommendationBookCellDelegate {

    func recommendationBookCell(
        _ cell: RecommendationBookCell,
        didSelectBook book: DetailBookInfo
    ) {
        let detailViewModel = BookDetailViewModel(
            isbn: book.basicBookInfo.isbn
        )
        let detailVC = BookDetailViewController(viewModel: detailViewModel)
        detailVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - KeywordHeaderViewDelegate

extension HomeViewController: KeywordHeaderViewDelegate {

    func didTapKeywordHeader(section: Int) {
        tableView.beginUpdates()
        viewModel.send(
            action: .setKeywordExpandState(newState: !viewModel.isKeywordOpened.value)
        )
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        tableView.endUpdates()
    }
}

// MARK: - KeywordCellDelegate

extension HomeViewController: KeywordCellDelegate {

    func didTapKeyword(_ keyword: String) {
        let viewModel = SearchViewModel(searchText: keyword)
        let searchVC = SearchViewController(viewModel: viewModel)

        searchVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(searchVC, animated: true)
    }
}

extension HomeViewController: BookWithHeaderCellDelegate {

    func bookImageTapped(of isbn: String) {
        let detailViewModel = BookDetailViewModel(isbn: isbn)
        let detailVC = BookDetailViewController(viewModel: detailViewModel)
        detailVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(detailVC, animated: true)
    }
}
