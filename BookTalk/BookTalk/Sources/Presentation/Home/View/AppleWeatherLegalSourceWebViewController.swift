//
//  AppleWeatherLegalSourceWebViewController.swift
//  BookTalk
//
//  Created by RAFA on 10/12/24.
//

import UIKit
import WebKit

final class AppleWeatherLegalSourceWebViewController: BaseViewController {

    // MARK: - Properties

    private var webView: WKWebView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        loadURL()
    }

    // MARK: - Helpers

    private func loadURL() {
        if let url = URL(string: "https://developer.apple.com/weatherkit/data-source-attribution/") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    // MARK: - UI

    override func setConstraints() {
        webView = WKWebView(frame: view.bounds)
        view.addSubview(webView)
    }
}
