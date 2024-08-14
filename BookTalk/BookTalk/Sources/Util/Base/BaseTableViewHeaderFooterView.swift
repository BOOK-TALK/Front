//
//  BaseHeaderFooterView.swift
//  BookTalk
//
//  Created by RAFA on 8/8/24.
//

import UIKit

import SnapKit
import Then

class BaseTableViewHeaderFooterView: UITableViewHeaderFooterView {
    
    var section: Int?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() { }
    
    func setConstraints() { }
}
