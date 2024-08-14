//
//  SearchViewController.swift
//  BookTalk
//
//  Created by RAFA on 7/26/24.
//

import UIKit

final class SearchViewController: BaseViewController {
    
    // MARK: - Properties
    
    private let viewModel = SearchViewModel()
    private let searchBar = UISearchBar()
    private let switchSearchModeButton = UISwitch()
    private let switchSearchModeTitle = UILabel()
    private let switchSearchModeStackView = UIStackView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var searchHistory: [String] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setKeyboardNotifications()
        setSearchModeToggle()
        registerCell()
        setDelegate()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.output.filteredBooks.subscribe { [weak self] _ in
            self?.tableView.reloadData()
        }
        
        viewModel.output.isKeywordSearch.subscribe { [weak self] isKeywordSearch in
            self?.switchSearchModeButton.setOn(isKeywordSearch, animated: false)
            self?.searchBar.placeholder = isKeywordSearch ?
                "키워드를 입력해주세요." : "책 이름 또는 작가 이름을 입력해주세요."
        }
    }
    
    // MARK: - Set UI
    
    override func setNavigationBar() {
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.spellCheckingType = .no
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
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
    }
    
    override func setConstraints() {
        [switchSearchModeStackView, tableView].forEach { view.addSubview($0) }
        
        switchSearchModeStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.right.equalTo(-15)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(switchSearchModeButton.snp.bottom)
            $0.centerX.left.bottom.equalToSuperview()
        }
    }
    
    private func registerCell() {
        tableView.do {
            $0.register(
                SearchHistoryCell.self,
                forCellReuseIdentifier: SearchHistoryCell.identifier
            )
            
            $0.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.identifier)
        }
    }
    
    private func setDelegate() {
        searchBar.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Helpers
    
    func searchWithKeyword(_ keyword: String) {
        viewModel.input.updateSearchMode(true)
        
        searchBar.text = keyword
        viewModel.input.searchTextChanged(keyword.lowercased())
        
        if !searchHistory.contains(keyword) { searchHistory.append(keyword) }
        
        tableView.reloadData()
    }
    
    private func fetchData() {
        viewModel.input.loadBooks()
    }
    
    private func navigateToBookDetail(with book: DetailBookInfo) {
        let detailViewModel = BookDetailViewModel(bookInfo: book)
        let detailVC = BookDetailViewController()
        detailVC.viewModel = detailViewModel
        detailVC.hidesBottomBarWhenPushed = true
        navigationItem.title = ""
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
        viewModel.input.updateSearchMode(switchSearchModeButton.isOn)
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let hasFilteredBooks = !viewModel.output.filteredBooks.value.isEmpty
        let hasSearchHistory = !searchHistory.isEmpty
        
        if hasFilteredBooks {
            return viewModel.output.filteredBooks.value.count
        } else if hasSearchHistory {
            return searchHistory.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.output.filteredBooks.value.isEmpty {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchHistoryCell.identifier,
                for: indexPath
            ) as? SearchHistoryCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            if searchHistory.isEmpty {
                cell.bind("최근 검색어가 없습니다.")
            } else {
                cell.delegate = self
                cell.bind(searchHistory[indexPath.row])
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultCell.identifier,
                for: indexPath
            ) as? SearchResultCell else {
                return UITableViewCell()
            }
            let book = viewModel.output.filteredBooks.value[indexPath.row]
            let availabilityText = viewModel.output.availabilityText.value[indexPath.row]
            let availabilityTextColor = viewModel.output.availabilityTextColor.value[indexPath.row]
            cell.delegate = self
            cell.selectionStyle = .none
            cell.separatorInset = .zero
            cell.bind(
                book: book,
                availabilityText: availabilityText,
                availabilityTextColor: availabilityTextColor
            )
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !viewModel.output.filteredBooks.value.isEmpty {
            let selectedBook = viewModel.output.filteredBooks.value[indexPath.row]
            navigateToBookDetail(with: selectedBook)
        } else if !searchHistory.isEmpty {
            let selectedHistory = searchHistory[indexPath.row]
            searchBar.text = selectedHistory
            viewModel.input.searchTextChanged(selectedHistory.lowercased())
            tableView.reloadData()
        }
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty { viewModel.input.searchTextChanged(searchText) }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !searchText.isEmpty {
            let sanitizedSearchText = searchText
                .replacingOccurrences(of: " ", with: "").lowercased()
            viewModel.input.searchTextChanged(sanitizedSearchText)
            
            if !searchHistory.contains(sanitizedSearchText) {
                searchHistory.append(sanitizedSearchText)
            }
            tableView.reloadData()
        }
    }
}

// MARK: - SearchHistoryCellDelegate

extension SearchViewController: SearchHistoryCellDelegate {
    
    func didTapDeleteButton(cell: SearchHistoryCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        searchHistory.remove(at: indexPath.row)
        tableView.reloadData()
    }
}

// MARK: - SearchCellDelegate

extension SearchViewController: SearchResultCellDelegate {
    
    func searchResultCell(_ cell: SearchResultCell, didSelectBook book: DetailBookInfo) {
        navigateToBookDetail(with: book)
    }
}
