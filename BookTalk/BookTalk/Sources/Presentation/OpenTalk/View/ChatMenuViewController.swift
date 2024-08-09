//
//  ChatSideMenuViewController.swift
//  BookTalk
//
//  Created by 김민 on 8/4/24.
//

import UIKit

import SnapKit
import Then

final class ChatMenuViewController: BaseViewController {

    // MARK: - Properties

    private let chatMenuTableView = UITableView()
    private let bottomLineView = UIView()
    private let bottomView = UIView()
    private let shareGoalButton = UIButton()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setDelegate()
        registerCell()
    }

    // MARK: - UI Setup

    override func setViews() {
        view.backgroundColor = .white

        chatMenuTableView.do {
            $0.showsVerticalScrollIndicator = false
            $0.backgroundColor = .clear
            $0.separatorStyle = .none
            $0.estimatedRowHeight = 300
        }

        shareGoalButton.do {
            $0.setTitle("오픈톡에 목표 공유하기", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.backgroundColor = UIColor.accentOrange
        }
    }

    override func setConstraints() {
        [chatMenuTableView, shareGoalButton].forEach {
            view.addSubview($0)
        }

        chatMenuTableView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
        }

        shareGoalButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(70)
        }
    }

    // MARK: - Helpers

    override func setDelegate() {
        chatMenuTableView.dataSource = self
        chatMenuTableView.delegate = self
    }

    override func registerCell() {
        chatMenuTableView.register(
            NowReadingCell.self,
            forCellReuseIdentifier: NowReadingCell.identifier
        )
        chatMenuTableView.register(
            MyReadingProgressCell.self,
            forCellReuseIdentifier: MyReadingProgressCell.identifier
        )
        chatMenuTableView.register(
            CompletedReadingCell.self,
            forCellReuseIdentifier: CompletedReadingCell.identifier
        )
    }
}

// MARK: - UITableViewDataSource

extension ChatMenuViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return ChatMenuSectionType.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = ChatMenuSectionType(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch sectionType {
        case .nowReading:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NowReadingCell.identifier,
                for: indexPath
            ) as? NowReadingCell else { return UITableViewCell() }

            return cell

        case .myProgress:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MyReadingProgressCell.identifier,
                for: indexPath
            ) as? MyReadingProgressCell else { return UITableViewCell() }

            return cell

        case .completedReading:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CompletedReadingCell.identifier,
                for: indexPath
            ) as? CompletedReadingCell else { return UITableViewCell() }

            return cell
        }
    }
}

extension ChatMenuViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return UITableView.automaticDimension
    }
}
