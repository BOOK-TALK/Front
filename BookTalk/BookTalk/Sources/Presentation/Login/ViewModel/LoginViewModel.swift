//
//  LoginViewModel.swift
//  BookTalk
//
//  Created by RAFA on 8/17/24.
//

import Foundation

protocol LoginCoordinatorDelegate: AnyObject {
    func authenticationDidComplete()
}

final class LoginViewModel {
    
    // MARK: - Interactions
    
    struct Input {
        let loginButtonTapped: (LoginType) -> Void
    }
    
    struct Output {
        let onboardingMessage: Observable<String>
        let progressUpdate: Observable<(Int, Float)>
    }
    
    // MARK: - Properties
    
    weak var delegate: LoginCoordinatorDelegate?
    
    let onboardingMessageManager: OnboardingManager
    
    lazy var input: Input = { bindInput() }()
    lazy var output: Output = { transform() }()
    
    // MARK: - Initializer
    
    init(onboardingMessageManager:
         OnboardingManager = OnboardingManager(
            messages: [
                "저희와 함께 마음에 드는 책을 찾아봐요!",
                "오픈톡에서 책을 주제로 대화해보세요!",
                "그래프를 통해 독서 기록을 한눈에 확인해보세요!"
            ],
            durations: [3.0, 3.0, 3.0]
         )
    ) {
        self.onboardingMessageManager = onboardingMessageManager
        setupBindings()
        onboardingMessageManager.startRotation()
    }
    
    // MARK: - Helpers
    
    private func bindInput() -> Input {
        return Input { [weak self] type in
            self?.handleLogin(type: type)
        }
    }
    
    private func transform() -> Output {
        return Output(
            onboardingMessage: Observable(""),
            progressUpdate: Observable((0, 1.0))
        )
    }
    
    private func setupBindings() {
        onboardingMessageManager.messageUpdate = { [weak self] message in
            self?.output.onboardingMessage.value = message
        }
        onboardingMessageManager.progressUpdate = { [weak self] index, progress in
            self?.output.progressUpdate.value = (index, progress)
        }
    }
    
    private func handleLogin(type: LoginType) {
        delegate?.authenticationDidComplete()
    }
    
    func cleanupTimers() {
        onboardingMessageManager.stop()
    }
}
