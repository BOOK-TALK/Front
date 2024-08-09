//
//  CategoryViewController.swift
//  BookTalk
//
//  Created by RAFA on 7/23/24.
//

import UIKit

import SnapKit
import Then

final class FirstCategoryViewController: BaseViewController {

    private let firstCategoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()
        setCollectionView()
    }

    override func setNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "카테고리"
    }

    override func setViews() {
        firstCategoryCollectionView.do {
            let flowLayout = UICollectionViewFlowLayout()

            $0.collectionViewLayout = flowLayout
            $0.showsVerticalScrollIndicator = false
        }
    }

    override func setConstraints() {
        [firstCategoryCollectionView].forEach {
            view.addSubview($0)
        }

        firstCategoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(35)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview()
        }
    }

    override func registerCell() {
        firstCategoryCollectionView.register(
            FirstCategoryCell.self,
            forCellWithReuseIdentifier: FirstCategoryCell.identifier
        )
    }

    private func setCollectionView() {
        firstCategoryCollectionView.dataSource = self
        firstCategoryCollectionView.delegate = self
    }

    private func pushTosubcategoryViewController(_ firstCategoryType: CategoryType) {
        let viewModel = SubcategoryViewModel(firstCategoryType: firstCategoryType)
        let secondCategoryViewController = SubcategoryViewController(viewModel: viewModel)

        navigationController?.pushViewController(secondCategoryViewController, animated: true)
    }
}

extension FirstCategoryViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CategoryType.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FirstCategoryCell.identifier, for: indexPath) as? FirstCategoryCell else { return UICollectionViewCell() }

        cell.bind(CategoryType.allCases[indexPath.item].title)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pushTosubcategoryViewController(CategoryType.allCases[indexPath.row])
    }
}

extension FirstCategoryViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (ScreenSize.width-40-16)/2, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
