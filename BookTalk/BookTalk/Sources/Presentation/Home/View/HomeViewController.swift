//
//  HomeViewController.swift
//  BookTalk
//
//  Created by RAFA on 7/23/24.
//

import UIKit

final class HomeViewController: BaseViewController {
    
    // MARK: - Properties
    
    private let viewModel = HomeViewModel()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.input.loadBooks()
        registerCell()
        setDelegate()
        bind()
    }
    
    // MARK: - Actions
    
    @objc private func searchIconTapped() {
        let searchVC = SearchViewController()
        searchVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc private func headerViewTapped(_ sender: UITapGestureRecognizer) {
        guard let headerView = sender.view as? BaseTableViewHeaderFooterView else { return }
        guard let section = headerView.section else { return }
        
        let sectionInfo = viewModel.output.sections.value[section]
        
        switch sectionInfo.type {
        case .keyword:
            viewModel.input.toggleSection(section)
        case .recommendation:
            print("DEBUG: \(viewModel.output.sections.value[section].headerTitle)")
        default:
            break
        }
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.output.sections.subscribe { [weak self] _ in
            self?.tableView.reloadData()
        }
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
            $0.separatorStyle = .none
            $0.backgroundColor = .clear
            $0.contentInsetAdjustmentBehavior = .never
            $0.automaticallyAdjustsScrollIndicatorInsets = false
            $0.estimatedRowHeight = 208
            $0.estimatedSectionHeaderHeight = 50
            $0.sectionHeaderHeight = UITableView.automaticDimension
            $0.rowHeight = UITableView.automaticDimension
            $0.contentInset = UIEdgeInsets(top: -23, left: 0, bottom: 0, right: 0)
        }
    }
    
    override func setConstraints() {
        tableView.snp.makeConstraints {
            $0.centerX.left.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
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
                HomeHeaderView.self,
                forHeaderFooterViewReuseIdentifier: HomeHeaderView.identifier
            )
            
            $0.register(
                RecommendationBookCell.self,
                forCellReuseIdentifier: RecommendationBookCell.identifier
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
        return viewModel.output.sections.value.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = viewModel.output.sections.value[section]
        switch sectionInfo.type {
        case .keyword:
            return sectionInfo.isExpanded ? 1 : 0
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionInfo = viewModel.output.sections.value[indexPath.section]
        
        switch sectionInfo.type {
        case .suggestion:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SuggestionCell.identifier,
                for: indexPath
            ) as? SuggestionCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = false
            cell.bind("OOO님, 오늘의 추천 도서를 확인해보세요!")
            return cell
        case .keyword(let keywords):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: KeywordCell.identifier,
                for: indexPath
            ) as? KeywordCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.bind(keywords: keywords.map { $0.keyword })
            return cell
        case .recommendation(let bookInfo):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: RecommendationBookCell.identifier,
                for: indexPath
            ) as? RecommendationBookCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.bind(bookInfo)
            cell.delegate = self
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionInfo = viewModel.output.sections.value[indexPath.section]
        
        switch sectionInfo.type {
        case .recommendation(let bookInfo):
            let selectedBook = bookInfo[indexPath.row]
            let detailViewModel = BookDetailViewModel(bookInfo: selectedBook)
            let detailVC = BookDetailViewController()
            detailVC.viewModel = detailViewModel
            detailVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(detailVC, animated: true)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionInfo = viewModel.output.sections.value[section]
        
        switch sectionInfo.type {
        case .suggestion: return nil
        case .keyword:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: KeywordHeaderView.identifier
            ) as? KeywordHeaderView else {
                return nil
            }
            headerView.delegate = self
            headerView.bind(sectionInfo)
            headerView.section = section
            return headerView
        default:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: HomeHeaderView.identifier
            ) as? HomeHeaderView else {
                return nil
            }
            headerView.bind(with: sectionInfo.headerTitle, section: section)
            let tapGesture = UITapGestureRecognizer(
                target: self,
                action: #selector(headerViewTapped)
            )
            headerView.addGestureRecognizer(tapGesture)
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionInfo = viewModel.output.sections.value[indexPath.section]
        switch sectionInfo.type {
        case .suggestion: return UITableView.automaticDimension
        case .keyword: return sectionInfo.isExpanded ? UITableView.automaticDimension : 0
        default: return 208
        }
    }
}

// MARK: - RecommendationBookCellDelegate

extension HomeViewController: RecommendationBookCellDelegate {
    
    func recommendationBookCell(
        _ cell: RecommendationBookCell,
        didSelectBook book: DetailBookInfo
    ) {
        let detailViewModel = BookDetailViewModel(bookInfo: book)
        let detailVC = BookDetailViewController()
        detailVC.viewModel = detailViewModel
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - KeywordHeaderViewDelegate

extension HomeViewController: KeywordHeaderViewDelegate {
    
    func didTapKeywordHeader(section: Int) {
        tableView.beginUpdates()
        viewModel.input.toggleSection(section)
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        tableView.endUpdates()
    }
}

// MARK: - KeywordCellDelegate

extension HomeViewController: KeywordCellDelegate {
    
    func didTapKeyword(_ keyword: String) {
        let searchVC = SearchViewController()
        searchVC.hidesBottomBarWhenPushed = true
        searchVC.searchWithKeyword(keyword)
        navigationController?.pushViewController(searchVC, animated: true)
    }
}
