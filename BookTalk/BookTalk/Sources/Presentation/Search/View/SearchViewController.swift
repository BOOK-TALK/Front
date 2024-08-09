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
    private var isSearching: Bool = false
    private var searchHistory: [String] = []
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let historyID = SearchHistoryCell.identifier
    private let searchResultID = SearchCell.identifier
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setupKeyboardNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Set UI
    
    override func setNavigationBar() {
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.spellCheckingType = .no
        searchBar.placeholder = "책 이름 / 작가 이름"
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
    }
    
    override func setViews() {
        view.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160
        tableView.keyboardDismissMode = .interactive
        tableView.automaticallyAdjustsScrollIndicatorInsets = false
        tableView.register(SearchHistoryCell.self, forCellReuseIdentifier: historyID)
        tableView.register(SearchCell.self, forCellReuseIdentifier: searchResultID)
    }
    
    override func setConstraints() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.centerX.left.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
    
    // MARK: - Helpers
    
    override func bind() {
        viewModel.onBooksUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func navigateToBookDetail(with book: DetailBookInfo) {
        let detailViewModel = BookDetailViewModel(bookInfo: book)
        let detailVC = BookDetailViewController()
        detailVC.viewModel = detailViewModel
        detailVC.hidesBottomBarWhenPushed = true
        navigationItem.title = ""
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func setupKeyboardNotifications() {
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
    
    @objc private func handleKeyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
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
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching && !viewModel.filteredBooks.isEmpty {
            return viewModel.filteredBooks.count
        } else {
            return searchHistory.count > 0 ? searchHistory.count : 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching && !viewModel.filteredBooks.isEmpty {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: searchResultID,
                for: indexPath
            ) as? SearchCell else {
                return UITableViewCell()
            }
            let book = viewModel.filteredBooks[indexPath.row]
            cell.delegate = self
            cell.selectionStyle = .none
            cell.bind(book)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: historyID,
                for: indexPath
            ) as? SearchHistoryCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            if searchHistory.count > 0 {
                cell.delegate = self
                cell.bind(searchHistory[indexPath.row])
            } else {
                cell.bind("최근 검색어가 없습니다.")
            }
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching && !viewModel.filteredBooks.isEmpty {
            let selectedBook = viewModel.filteredBooks[indexPath.row]
            navigateToBookDetail(with: selectedBook)
        } else if !isSearching && searchHistory.count > 0 {
            let selectedHistory = searchHistory[indexPath.row]
            searchBar.text = selectedHistory
            isSearching = true
            viewModel.filterBooks(searchText: selectedHistory.lowercased())
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if isSearching && !viewModel.filteredBooks.isEmpty {
            tableView.separatorStyle = .singleLine
            cell.separatorInset = .zero
        } else if !isSearching && searchHistory.count > 0 {
            tableView.separatorStyle = .singleLine
            cell.separatorInset = .zero
        } else {
            tableView.separatorStyle = .none
        }
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            viewModel.filterBooks(searchText: "")
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text, !searchText.isEmpty {
            isSearching = true
            viewModel.filterBooks(searchText: searchText.lowercased())
            
            if !searchHistory.contains(searchText) {
                searchHistory.append(searchText)
            }
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

extension SearchViewController: SearchCellDelegate {
    
    func searchCell(_ cell: SearchCell, didSelectBook book: DetailBookInfo) {
        navigateToBookDetail(with: book)
    }
}
