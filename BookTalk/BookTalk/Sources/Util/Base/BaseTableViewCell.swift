//
//  BaseTableViewCell.swift
//  BookTalk
//
//  Created by RAFA on 8/8/24.
//

import UIKit

import SnapKit
import Then

class BaseTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setViews()
        setConstraints()
        setDelegate()
        registerCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() { }
    
    func setConstraints() { }
    
    func setDelegate() { }
    
    func registerCell() { }
}
