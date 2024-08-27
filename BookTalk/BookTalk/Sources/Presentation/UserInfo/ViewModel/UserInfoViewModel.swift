//
//  RegistrationViewModel.swift
//  BookTalk
//
//  Created by RAFA on 8/22/24.
//

import UIKit

struct UserInfoViewModel {

    // MARK: - Properties

    private(set) var nickname = Observable("")
    private(set) var selectedGender = Observable(GenderType.notSelected)
    private(set) var birthDate = Observable<Date?>(nil)
    private(set) var isFormValid = Observable(false)
    private(set) var popToMyPage = Observable(false)
    private(set) var presentAlert = Observable(false)

    private let isInitialEdit: Bool

    // MARK: - Initializer

    init(isInitialEdit: Bool) {
        self.isInitialEdit = isInitialEdit

        setUserInfoIfNeeded()
    }

    // MARK: - Actions

    private func setUserInfoIfNeeded() {
        guard !isInitialEdit else { return }

        let oldUserInfo = UserData.shared.getUser()
        guard let oldUserInfo = oldUserInfo else { return }

        nickname.value = oldUserInfo.nickname
        selectedGender.value = oldUserInfo.gender
        birthDate.value = oldUserInfo.birth?.toDate() ?? nil
    }


    func updateNickname(_ text: String) {
        nickname.value = text
        validateForm()
    }
    
    func updateGender(_ gender: GenderType) {
        selectedGender.value = gender
        validateForm()
    }
    
    func updateBirthDate(_ date: Date?) {
        birthDate.value = date
        validateForm()
    }

    func registerUserInfo(
        nickname: String,
        gender: GenderType,
        birth: String
    ) {
        Task {
            do {
                let _ = try await UserService.editUserInfo(
                    nickname: nickname,
                    gender: gender,
                    birthDate: birth
                )

                await MainActor.run {
                    if isInitialEdit {
                        UserDefaults.standard.set(true, forKey: UserDefaults.Key.isLoggedIn)
                        NotificationCenter.default.post(
                            name: Notification.Name.authStateChanged,
                            object: nil
                        )
                    } else {
                        popToMyPage.value.toggle()
                    }
                }
            } catch let error as NetworkError {
                switch error {
                case let .invalidStatusCode(statusCode, message):
                    if statusCode == 400 &&
                        message == "사용자의 닉네임이 중복됩니다." {
                        presentAlert.value = true
                    }
                    return
                default:
                    print(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Helpers
    
    private func validateForm() {
        isFormValid.value = isNicknameValid()
    }
    
    private func isNicknameValid() -> Bool {
        guard !nickname.value.isEmpty else { return false }
        
        if isKorean(nickname.value) {
            return nickname.value.count >= 2
        } else {
            return nickname.value.count >= 3
        }
    }
    
    private func isKorean(_ text: String) -> Bool {
        let koreanRegex = "^[가-힣]*$"
        let koreanPredicate = NSPredicate(format: "SELF MATCHES %@", koreanRegex)
        return koreanPredicate.evaluate(with: text)
    }
}
