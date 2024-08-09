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
    private let suggestionID = SuggestionCell.identifier
    private let headerID = HomeHeaderView.identifier
    private let recommendationID = RecommendationBookCell.identifier
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        viewModel.fetchSections()
    }
    
    // MARK: - Actions
    
    @objc private func searchIconTapped() {
        let searchVC = SearchViewController()
        searchVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc private func headerViewTapped(_ sender: UITapGestureRecognizer) {
        guard let headerView = sender.view as? HomeHeaderView else { return }
        guard let section = headerView.section else { return }
        
        let headerTitle = viewModel.sections[section - 1].header
        print("DEBUG: Selected \"\(headerTitle)\"")
    }
    
    // MARK: - Bind
    
    override func bind() {
        viewModel.sectionsDidChange = { [weak self] sections in
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
            $0.dataSource = self
            $0.delegate = self
            $0.separatorStyle = .none
            $0.contentInsetAdjustmentBehavior = .never
            $0.automaticallyAdjustsScrollIndicatorInsets = false
            $0.estimatedRowHeight = 100
            $0.estimatedSectionHeaderHeight = 50
            $0.sectionHeaderHeight = UITableView.automaticDimension
            $0.rowHeight = UITableView.automaticDimension
            $0.contentInset = UIEdgeInsets(top: -23, left: 0, bottom: -20, right: 0)
            
            $0.register(
                SuggestionCell.self,
                forCellReuseIdentifier: suggestionID
            )
            
            $0.register(
                HomeHeaderView.self,
                forHeaderFooterViewReuseIdentifier: headerID
            )
            
            $0.register(
                RecommendationBookCell.self,
                forCellReuseIdentifier: recommendationID
            )
        }
    }
    
    override func setConstraints() {
        tableView.snp.makeConstraints {
            $0.centerX.left.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: suggestionID,
                for: indexPath
            ) as? SuggestionCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = false
            cell.bind("OOO님, 오늘의 추천 도서를 확인해보세요!")
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: recommendationID,
            for: indexPath
        ) as? RecommendationBookCell else {
            return UITableViewCell()
        }
        
        let sectionIndex = indexPath.section - 1
        let bookInfo = viewModel.sections[sectionIndex].bookInfo
        
        cell.selectionStyle = .none
        cell.bind(bookInfo)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section != 0 else { return }
        
        let sectionHeader = viewModel.sections[indexPath.section - 1].header
        print("DEBUG: Selected \"\(sectionHeader)\"")
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: headerID
        ) as? HomeHeaderView else {
            return nil
        }
        
        headerView.bind(with: viewModel.sections[section - 1].header, section: section)
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(headerViewTapped)
        )
        
        headerView.addGestureRecognizer(tapGesture)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? UITableView.automaticDimension : 200
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
