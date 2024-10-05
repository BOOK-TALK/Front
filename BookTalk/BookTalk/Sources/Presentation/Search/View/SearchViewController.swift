//
//  SearchViewController.swift
//  BookTalk
//
//  Created by RAFA on 7/26/24.
//

import UIKit

final class SearchViewController: BaseViewController {

    // MARK: - Properties

    private let searchBar = UISearchBar()
    private let switchSearchModeButton = UISwitch()
    private let switchSearchModeTitle = UILabel()
    private let switchSearchModeStackView = UIStackView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let indicatorView = UIActivityIndicatorView(style: .medium)

    private let viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        setKeyboardNotifications()
        setSearchModeToggle()
        registerCell()
        setDelegate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.loadSearchHistory()
        tableView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Bind

    private func bind() {
        viewModel.input.searchWithKeyword(viewModel.searchText)

        viewModel.output.keywordSearchText.subscribe { [weak self] searchText in
            self?.searchBar.text = searchText
        }

        viewModel.output.isKeywordSearch.subscribe { [weak self] isKeywordSearch in
            self?.switchSearchModeButton.setOn(isKeywordSearch, animated: false)
            self?.searchBar.placeholder = isKeywordSearch ?
                "키워드를 입력해주세요." : "책 이름 또는 작가 이름을 입력해주세요."
        }

        viewModel.output.searchResult.subscribe { [weak self] _ in
            self?.tableView.reloadData()
        }

        viewModel.output.loadingState.subscribe { [weak self] state in
            guard let self = self else { return }

            switch state {
            case .initial:
                break

            case .loading:
                indicatorView.startAnimating()

            case .completed:
                indicatorView.stopAnimating()

                if viewModel.output.searchResult.value.isEmpty {
                    tableView.setEmptyMessage("검색 결과가 없습니다.")
                } else {
                    tableView.restore()
                }
            }
        }
    }

    // MARK: - Set UI

    override func setNavigationBar() {
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.spellCheckingType = .no
        searchBar.sizeToFit()
        
        navigationItem.titleView = searchBar
        navigationItem.backButtonTitle = ""
    }

    override func setViews() {
        view.backgroundColor = .white

        switchSearchModeButton.do {
            $0.isOn = false
            $0.onTintColor = .systemGreen
        }

        switchSearchModeTitle.do {
            $0.text = "키워드로 검색하기"
            $0.textAlignment = .right
            $0.textColor = .accentOrange
            $0.numberOfLines = 0
            $0.font = .systemFont(ofSize: 15, weight: .medium)
        }

        switchSearchModeStackView.do {
            $0.addArrangedSubview(switchSearchModeTitle)
            $0.addArrangedSubview(switchSearchModeButton)

            $0.axis = .horizontal
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 10
        }

        tableView.do {
            $0.separatorStyle = .none
            $0.rowHeight = UITableView.automaticDimension
            $0.estimatedRowHeight = 160
            $0.keyboardDismissMode = .interactive
            $0.automaticallyAdjustsScrollIndicatorInsets = false
        }

        indicatorView.do {
            $0.hidesWhenStopped = true
        }
    }

    override func setConstraints() {
        [
            switchSearchModeStackView, tableView, indicatorView
        ].forEach { view.addSubview($0) }

        switchSearchModeStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.right.equalTo(-15)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(switchSearchModeButton.snp.bottom)
            $0.centerX.left.bottom.equalToSuperview()
        }

        indicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private func registerCell() {
        tableView.do {
            $0.register(
                SearchHistoryCell.self,
                forCellReuseIdentifier: SearchHistoryCell.identifier
            )

            $0.register(
                SearchResultCell.self,
                forCellReuseIdentifier: SearchResultCell.identifier
            )

            $0.register(
                IndicatorTableViewFooterView.self,
                forHeaderFooterViewReuseIdentifier: IndicatorTableViewFooterView.identifier
            )
        }
    }

    private func setDelegate() {
        searchBar.delegate = self

        tableView.dataSource = self
        tableView.delegate = self
    }

    // MARK: - Helpers

    private func navigateToBookDetail(with book: DetailBookInfo) {
        let detailViewModel = BookDetailViewModel(isbn: book.basicBookInfo.isbn)
        let detailVC = BookDetailViewController(viewModel: detailViewModel)
        detailVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(detailVC, animated: true)
    }

    private func setKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func setSearchModeToggle() {
        switchSearchModeButton.addTarget(
            self,
            action: #selector(toggleSearchMode),
            for: .valueChanged
        )
    }

    @objc private func handleKeyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else {
            return
        }

        let bottomSafeAreaInset = view.safeAreaInsets.bottom
        let keyboardHeight = keyboardFrame.height - bottomSafeAreaInset
        tableView.contentInset.bottom = keyboardHeight
        tableView.verticalScrollIndicatorInsets.bottom = keyboardHeight
    }

    @objc private func handleKeyboardWillHide(notification: NSNotification) {
        tableView.contentInset.bottom = 0
        tableView.verticalScrollIndicatorInsets.bottom = 0
    }

    @objc private func toggleSearchMode() {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }

        if switchSearchModeButton.isOn {
            viewModel.input.keywordButtonTapped(true)
        } else {
            viewModel.input.keywordButtonTapped(false)
        }

        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        if !viewModel.output.searchResult.value.isEmpty {
            return viewModel.output.searchResult.value.count
        } else {
            return viewModel.output.searchHistory.value.count
        }
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if !viewModel.output.searchResult.value.isEmpty {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultCell.identifier,
                for: indexPath
            ) as? SearchResultCell else {
                return UITableViewCell()
            }

            let book = viewModel.output.searchResult.value[indexPath.row]
            cell.bind(book: book)

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchHistoryCell.identifier,
                for: indexPath
            ) as? SearchHistoryCell else {
                return UITableViewCell()
            }

            let history = viewModel.output.searchHistory.value[indexPath.row]
            cell.selectionStyle = .none
            cell.bind(history)
            cell.delegate = self

            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        switch cell.reuseIdentifier {
        case SearchResultCell.identifier:
            let selectedBook = viewModel.output.searchResult.value[indexPath.row]

            navigateToBookDetail(with: selectedBook)

        case SearchHistoryCell.identifier:
            let selectedHistory = viewModel.output.searchHistory.value[indexPath.row]
            viewModel.input.searchButtonTapped(selectedHistory)
            searchBar.text = selectedHistory
            tableView.reloadData()

        default:
            break
        }
    }

    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        return 50
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        let isLoadPoint = indexPath.row
            == viewModel.output.searchResult.value.count - 3
        guard isLoadPoint else { return }

        guard let footerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: IndicatorTableViewFooterView.identifier
        ) as? IndicatorTableViewFooterView else { return }
        tableView.tableFooterView = footerView

        viewModel.input.loadMoreResults()

        tableView.tableFooterView = nil
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        if let searchText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !searchText.isEmpty {

            viewModel.input.searchButtonTapped(searchText)
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.output.searchResult.value.removeAll()
            viewModel.loadSearchHistory()
            tableView.reloadData()
        }
    }
}

// MARK: - SearchHistoryCellDelegate

extension SearchViewController: SearchHistoryCellDelegate {

    func didTapDeleteButton(cell: SearchHistoryCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        let searchTermToDelete = viewModel.output.searchHistory.value[indexPath.row]
        viewModel.input.deleteSearchHistory(searchTermToDelete)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - SearchCellDelegate

extension SearchViewController: SearchResultCellDelegate {

    func searchResultCell(_ cell: SearchResultCell, didSelectBook book: DetailBookInfo) {
        navigateToBookDetail(with: book)
    }
}
