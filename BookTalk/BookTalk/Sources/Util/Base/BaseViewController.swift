//
//  BaseViewController.swift
//  BookTalk
//
//  Created by 김민 on 7/26/24.
//

import UIKit

import SnapKit
import Then

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        setViews()
        setConstraints()
        setDelegate()
        registerCell()
        setCollectionView()
        addTarget()
        bind()
    }
    
    /// navigation bar 설정
    func setNavigationBar() { }
    
    /// view attributes 설정
    func setViews() { }
    
    /// view hierarchy, constraints 설정
    func setConstraints() { }
    
    /// delegate 설정
    func setDelegate() { }
    
    /// cell 등록
    func registerCell() { }
    
    /// collection view 설정
    func setCollectionView() { }
    
    /// button target 추가
    func addTarget() { }
    
    /// data binding
    func bind() { }
}
