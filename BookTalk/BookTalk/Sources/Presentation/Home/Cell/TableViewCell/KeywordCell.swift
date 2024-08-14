//
//  KeywordCell.swift
//  BookTalk
//
//  Created by RAFA on 8/14/24.
//

import UIKit

import SnapKit

protocol KeywordCellDelegate: AnyObject {
    func didTapKeyword(_ keyword: String)
}

final class KeywordCell: BaseTableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: KeywordCellDelegate?
    
    private var keywords: [String] = []
    private let collectionView: UICollectionView
    private var collectionViewHeightConstraint: Constraint?
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 5
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = .init(top: 15, left: 15, bottom: 15, right: 15)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        registerCell()
        setDelegate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Bind
    
    func bind(keywords: [String]) {
        self.keywords = keywords
        collectionView.reloadData()
        updateCollectionViewHeight()
        UIView.animate(withDuration: 0.3) {
            if let tableView = self.superview as? UITableView {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }
    
    // MARK: - Set UI
    
    override func setViews() {
        collectionView.do {
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.2
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowRadius = 4
            $0.layer.masksToBounds = false
            $0.layer.cornerRadius = 10
            $0.backgroundColor = .white
        }
    }
    
    override func setConstraints() {
        contentView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(4)
            $0.left.equalToSuperview().inset(15)
            $0.bottom.equalToSuperview().inset(15).priority(.low)
            collectionViewHeightConstraint = $0.height.equalTo(1).constraint
        }
    }
    
    private func registerCell() {
        collectionView.register(
            KeywordCollectionCell.self,
            forCellWithReuseIdentifier: KeywordCollectionCell.identifier
        )
    }
    
    private func setDelegate() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - Helpers
    
    private func updateCollectionViewHeight() {
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
        
        let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
        let adjustedHeight = 
            contentSize.height +
            collectionView.contentInset.top +
            collectionView.contentInset.bottom
        
        collectionViewHeightConstraint?.update(offset: adjustedHeight)
    }
}

// MARK: - UICollectionViewDataSource

extension KeywordCell: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return keywords.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: KeywordCollectionCell.identifier,
            for: indexPath
        ) as? KeywordCollectionCell else {
            return UICollectionViewCell()
        }
        cell.bind(keywords[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension KeywordCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? KeywordCollectionCell,
              let keyword = cell.keywordLabel.text
        else {
            return
        }
        
        let sanitizedKeyword = keyword.replacingOccurrences(of: "#", with: "")
        delegate?.didTapKeyword(sanitizedKeyword)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        cell.transform = CGAffineTransform(translationX: 0, y: -cell.frame.height)
        cell.alpha = 0
        UIView.animate(
            withDuration: 0.3,
            delay: 0.05 * Double(indexPath.row),
            options: [.curveEaseInOut],
            animations: {
                cell.transform = .identity
                cell.alpha = 1
            }, completion: nil
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            cell.transform = CGAffineTransform(translationX: 0, y: -cell.frame.height)
            cell.alpha = 0
        }, completion: nil)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension KeywordCell: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let keyword = keywords[indexPath.item]
        let cellWidth = keyword
            .size(withAttributes: [.font:UIFont.systemFont(ofSize: 14)])
            .width + 30
        
        return CGSize(width: cellWidth, height: 30)
    }
}
