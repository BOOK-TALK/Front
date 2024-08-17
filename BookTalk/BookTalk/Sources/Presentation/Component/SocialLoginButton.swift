//
//  SocialLoginButton.swift
//  BookTalk
//
//  Created by RAFA on 8/17/24.
//

import AuthenticationServices
import UIKit

import SnapKit
import Then

final class SocialLoginButton: UIButton {
    
    // MARK: - Properties
    
    private let loginType: LoginType
    private var appleLoginButton: ASAuthorizationAppleIDButton?
    
    // MARK: - Initializer
    
    init(type: LoginType) {
        self.loginType = type
        super.init(frame: .zero)
        
        setButtons()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Set UI
    
    private func setButtons() {
        switch loginType {
        case .apple:
            let apple = ASAuthorizationAppleIDButton(
                authorizationButtonType: .signIn,
                authorizationButtonStyle: .black
            )
            self.addSubview(apple)
            self.do {
                $0.appleLoginButton = apple
            }
            apple.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(50)
            }
        case .kakao:
            self.do {
                $0.setBackgroundImage(UIImage(named: "kakaoLoginButton"), for: .normal)
            }
        }
    }
}
