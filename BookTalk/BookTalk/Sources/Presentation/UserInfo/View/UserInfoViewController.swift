//
//  UserInfoViewController.swift
//  BookTalk
//
//  Created by RAFA on 8/22/24.
//

import UIKit

final class UserInfoViewController: BaseViewController {

    // MARK: - Properties
    
    private let nicknameTextField = UITextField()
    private let maleButton = UIButton(type: .system)
    private let femaleButton = UIButton(type: .system)
    private let unselectedGenderButton = UIButton(type: .system)
    private let selectGenderButtonStackView = UIStackView()
    private let birthTextField = UITextField()
    private let datePicker = UIDatePicker()
    private let signUpButton = UIButton(type: .system)
    private let credentialsStackView = UIStackView()

    // MARK: - Initializer

    private var viewModel: UserInfoViewModel

    init(viewModel: UserInfoViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTargets()
        bind()
        registerKeyboardNotifications()
        setToolBar()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    
    @objc private func nicknameChanged() {
        viewModel.updateNickname(nicknameTextField.text ?? "")
    }
    
    @objc private func selectMaleGender() {
        viewModel.updateGender(.man)
    }

    @objc private func selectFemaleGender() {
        viewModel.updateGender(.woman)
    }

    @objc private func unselectedGender() {
        viewModel.updateGender(.notSelected)
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        viewModel.updateBirthDate(sender.date)
    }
    
    @objc private func doneButtonHandler() {
        birthTextField.attributedText = dateFormat(date: datePicker.date)
        viewModel.updateBirthDate(datePicker.date)
        birthTextField.resignFirstResponder()
    }

    @objc private func registerButtonDidTapped() {
        let birthString: String = {
            if let birthDate = viewModel.birthDate.value {
                return DateFormatter.koreanDateFormat.string(from: birthDate)
            } else {
                return ""
            }
        }()

        viewModel.registerUserInfo(
            nickname: viewModel.nickname.value,
            gender: viewModel.selectedGender.value,
            birth: birthString
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        // TODO:
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        // TODO:
    }
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func addTargets() {
        nicknameTextField.addTarget(
            self,
            action: #selector(nicknameChanged),
            for: .editingChanged
        )
        maleButton.addTarget(
            self,
            action: #selector(selectMaleGender),
            for: .touchUpInside)
        femaleButton.addTarget(
            self,
            action: #selector(selectFemaleGender),
            for: .touchUpInside
        )
        unselectedGenderButton.addTarget(
            self,
            action: #selector(unselectedGender),
            for: .touchUpInside
        )
        datePicker.addTarget(
            self,
            action: #selector(dateChanged),
            for: .valueChanged
        )
        signUpButton.addTarget(
            self,
            action: #selector(registerButtonDidTapped),
            for: .touchUpInside
        )
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.nickname.subscribe { [weak self] nickname in
            self?.nicknameTextField.text = nickname
        }

        viewModel.selectedGender.subscribe { [weak self] gender in
            self?.updateGenderSelection(gender)
        }
        
        viewModel.birthDate.subscribe { [weak self] date in
            self?.birthTextField.attributedText = self?.dateFormat(date: date)
        }
        
        viewModel.isFormValid.subscribe { [weak self] isValid in
            self?.updateSignUpButtonState(isValid: isValid)
        }

        viewModel.popToMyPage.subscribe { [weak self] isCompleted in
            guard isCompleted else { return }

            self?.navigationController?.popViewController(animated: true)
        }

        viewModel.presentAlert.subscribe { [weak self] isPresented in
            DispatchQueue.main.async { [weak self] in
                guard isPresented else { return }

                let alertVC = UIAlertController(
                    title: "닉네임이 중복됐어요.\n다른 닉네임을 입력해 주세요!",
                    message: nil,
                    preferredStyle: .alert
                )

                let action = UIAlertAction(title: "확인", style: .default)
                alertVC.addAction(action)

                self?.present(alertVC, animated: true)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func updateGenderSelection(_ gender: GenderType?) {
        maleButton.backgroundColor = gender == .man ?
            .accentOrange : .accentOrange.withAlphaComponent(0.2)
        femaleButton.backgroundColor = gender ==
            .woman ? .accentOrange : .accentOrange.withAlphaComponent(0.2)
        unselectedGenderButton.backgroundColor = gender == .notSelected ?
            .accentOrange : .accentOrange.withAlphaComponent(0.2)
    }
    
    private func dateFormat(date: Date?) -> NSAttributedString {
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 MM월 dd일"
            let dateString = formatter.string(from: date)
            return NSAttributedString(
                string: dateString,
                attributes: [.foregroundColor: UIColor.label]
            )
        } else {
            return NSAttributedString(
                string: "생일을 선택해주세요. - 선택",
                attributes: [.foregroundColor: UIColor.gray100]
            )
        }
    }
    
    private func updateSignUpButtonState(isValid: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.signUpButton.isEnabled = isValid
            self.signUpButton.backgroundColor = isValid ?
                .accentOrange : .accentOrange.withAlphaComponent(0.2)
            self.signUpButton.setTitleColor(
                isValid ? .white : .systemBackground.withAlphaComponent(0.7),
                for: .normal
            )
        }
    }

    // MARK: - Set UI
    
    override func setNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "정보 등록"

    }
    
    override func setViews() {
        view.backgroundColor = .white
        
        setupTextField(
            textField: nicknameTextField,
            placeholder: "닉네임 (한글 2자 이상, 영어 3자 이상) - 필수",
            spacerWidth: 12
        )
        
        setupGenderButton(maleButton, title: "남")
        setupGenderButton(femaleButton, title: "여")
        setupGenderButton(unselectedGenderButton, title: "선택 안 함")

        selectGenderButtonStackView.do {
            $0.addArrangedSubview(unselectedGenderButton)
            $0.addArrangedSubview(maleButton)
            $0.addArrangedSubview(femaleButton)
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.distribution = .fillEqually
            $0.spacing = 5
        }
        
        setupTextField(
            textField: birthTextField,
            spacerWidth: 12
        )
        
        birthTextField.do {
            $0.tintColor = .clear
            $0.inputView = datePicker
            $0.delegate = self
        }
        
        datePicker.do {
            $0.datePickerMode = .date
            $0.preferredDatePickerStyle = .wheels
            $0.locale = .init(identifier: "ko-KR")
            $0.maximumDate = Calendar.current.date(
                byAdding: .day,
                value: -1,
                to: Date()
            )
        }
        
        signUpButton.do {
            $0.isEnabled = false
            $0.layer.cornerRadius = 10
            $0.setTitle("정보 등록하기", for: .normal)
            $0.setTitleColor(.white.withAlphaComponent(0.7), for: .normal)
            $0.backgroundColor = .accentOrange.withAlphaComponent(0.8)
        }
        
        credentialsStackView.do {
            $0.addArrangedSubview(nicknameTextField)
            $0.addArrangedSubview(selectGenderButtonStackView)
            $0.addArrangedSubview(birthTextField)
            $0.addArrangedSubview(signUpButton)
            $0.axis = .vertical
            $0.spacing = 20
        }
    }
    
    override func setConstraints() {
        [credentialsStackView].forEach { view.addSubview($0) }
        
        nicknameTextField.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        maleButton.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        credentialsStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.left.equalTo(10)
            $0.bottom.greaterThanOrEqualTo(view.keyboardLayoutGuide.snp.top).offset(-20)
        }
        
        birthTextField.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        signUpButton.snp.makeConstraints {
            $0.height.equalTo(50)
        }
    }
}

// MARK: - UITextFieldDelegate

extension UserInfoViewController: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        return false
    }
}

// MARK: - Set UI Helpers

private extension UserInfoViewController {

    func setupTextField(textField: UITextField, placeholder: String? = nil, spacerWidth: CGFloat) {
        textField.do {
            $0.textColor = .label
            $0.tintColor = .label
            $0.borderStyle = .none
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.gray100.cgColor
            $0.layer.cornerRadius = 10
            $0.backgroundColor = .white
            $0.spellCheckingType = .no
            $0.autocorrectionType = .no
            $0.autocapitalizationType = .none
            let spacer = UIView(frame: .init(x: 0, y: 0, width: spacerWidth, height: 50))
            $0.leftView = spacer
            $0.leftViewMode = .always
            if let placeholder = placeholder {
                $0.attributedPlaceholder = NSAttributedString(
                    string: placeholder,
                    attributes: [.foregroundColor: UIColor.gray100]
                )
            }
        }
    }

    func setupGenderButton(_ button: UIButton, title: String) {
        button.do {
            $0.setAttributedTitle(
                NSAttributedString(
                    string: title,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 15, weight: .medium),
                        .foregroundColor: UIColor.white
                    ]
                ),
                for: .normal
            )
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 10
        }
    }
    
    func setToolBar() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonHandler)
        )
        
        toolBar.items = [flexibleSpace, doneButton]
        toolBar.sizeToFit()
        
        birthTextField.inputAccessoryView = toolBar
    }
}
