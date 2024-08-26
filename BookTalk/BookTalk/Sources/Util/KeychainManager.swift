//
//  KeychainManager.swift
//  BookTalk
//
//  Created by 김민 on 8/14/24.
//

import Foundation

final class KeychainManager {

    static let shared = KeychainManager()

    private init() {}

    func save(key: String, token: String) {
        let query: NSDictionary = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrAccount: key,
            kSecValueData: token.data(using: .utf8, allowLossyConversion: false) as Any
        ]

        SecItemDelete(query)

        SecItemAdd(query as CFDictionary, nil)
    }

    func read(key: String) -> String? {
        let query: NSDictionary = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)

        if status == errSecSuccess,
            let data = dataTypeRef as? Data,
            let value = String(data: data, encoding: .utf8) {
            return value
        } else {
            return nil
        }
    }

    func delete(key: String) {
        let query: NSDictionary = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrAccount: key
        ]

        SecItemDelete(query)
    }

    func saveTokens(accessToken: String, refreshToken: String) {
        save(key: TokenKey.accessToken, token: accessToken)
        save(key: TokenKey.refreshToken, token: refreshToken)
    }

    func deleteTokens() {
        delete(key: TokenKey.accessToken)
        delete(key: TokenKey.refreshToken)
    }
}

