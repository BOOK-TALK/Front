//
//  LoginViewController.swift
//  BookTalk
//
//  Created by RAFA on 8/17/24.
//

import AuthenticationServices
import UIKit

import Lottie

final class LoginViewController: BaseViewController {
    
    // MARK: - Properties
    
    private let viewModel = LoginViewModel()
    private let progressView = SegmentedProgressBar(numberOfSegments: 3)
    private let onboardingLabel = UILabel()
    private let waveView = WaveView()
    private let animationView: LottieAnimationView = .init(name: "login")
    private let appleLoginButton = SocialLoginButton(type: .apple)
    private let kakaoLoginButton = SocialLoginButton(type: .kakao)
    private let loginButtons = UIStackView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTargets()
        bind()
        
        viewModel.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.cleanupTimers()
    }
    
    // MARK: - Actions
    
    @objc private func appleLoginTapped() {
        viewModel.input.loginButtonTapped(.apple)
    }
    
    @objc private func kakaoLoginTapped() {
        viewModel.input.loginButtonTapped(.kakao)
    }
    
    private func addTargets() {
        appleLoginButton.addTarget(self, action: #selector(appleLoginTapped), for: .touchUpInside)
        kakaoLoginButton.addTarget(self, action: #selector(kakaoLoginTapped), for: .touchUpInside)
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.output.onboardingMessage.subscribe { [weak self] message in
            DispatchQueue.main.async {
                UIView.transition(
                    with: self?.onboardingLabel ?? UILabel(),
                    duration: 0.5,
                    options: .transitionCrossDissolve
                ) {
                    self?.onboardingLabel.text = message
                }
            }
        }
        
        viewModel.output.progressUpdate.subscribe { [weak self] index, progress in
            DispatchQueue.main.async {
                self?.progressView.updateProgress(segmentIndex: index, progress: progress)
            }
        }
    }
    
    // MARK: - Set UI
    
    override func setViews() {
        configureWaveView()
        configureAnimationView()
        
        onboardingLabel.do {
            $0.font = .systemFont(ofSize: 30, weight: .heavy)
            $0.textColor = .black
            $0.textAlignment = .left
            $0.numberOfLines = 0
        }
        
        animationView.do {
            $0.contentMode = .scaleAspectFit
            $0.clipsToBounds = true
        }
        
        loginButtons.do {
            $0.addArrangedSubview(appleLoginButton)
            $0.addArrangedSubview(kakaoLoginButton)
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fillEqually
            $0.spacing = 10
            $0.backgroundColor = #colorLiteral(red: 1, green: 0.8574997783, blue: 0.8730630279, alpha: 1)
            $0.isLayoutMarginsRelativeArrangement = true
            $0.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    override func setConstraints() {
        [progressView, onboardingLabel, waveView, animationView, loginButtons].forEach {
            view.addSubview($0)
        }
        
        progressView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.height.equalTo(20)
            $0.width.equalToSuperview().inset(20)
        }
        
        onboardingLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(progressView.snp.bottom).offset(20)
            $0.left.equalToSuperview().inset(20)
        }
        
        waveView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(view.frame.height * 2 / 3)
        }
        
        animationView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(loginButtons.snp.top)
            $0.left.equalToSuperview()
            $0.height.equalTo(animationView.snp.width)
        }
        
        loginButtons.snp.makeConstraints {
            $0.centerX.left.equalToSuperview()
            $0.bottom.equalTo(view.snp.bottom)
        }
    }
    
    private func configureWaveView() {
        waveView.preferredColor = #colorLiteral(red: 0.9988475442, green: 0.9064419866, blue: 0.7702646852, alpha: 1)
        waveView.speed = 5
        waveView.frequency = 5
        waveView.parameterA = 1.5
        waveView.parameterB = 1.5
        waveView.direction = .right
        waveView.backgroundColor = .clear
    }
    
    private func configureAnimationView() {
        animationView.play()
        animationView.loopMode = .loop
        animationView.animationSpeed = 1
    }
    
    private func makeAnimationViewCircular() {
        animationView.layer.cornerRadius = animationView.frame.width / 2
        animationView.layer.masksToBounds = true
    }
}

// MARK: - LoginCoordinatorDelegate

extension LoginViewController: LoginCoordinatorDelegate {
    
    func authenticationDidComplete() {
        let mainTab = MainTabBarController()
        mainTab.modalPresentationStyle = .fullScreen
        navigationController?.setNavigationBarHidden(true, animated: true)
        present(mainTab, animated: true)
    }
}
