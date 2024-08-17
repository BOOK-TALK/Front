//
//  OnboardingManager.swift
//  BookTalk
//
//  Created by RAFA on 8/17/24.
//

import Foundation

final class OnboardingManager {
    
    // MARK: - Properties
    
    let messages: [String]
    private let durations: [TimeInterval]
    var currentIndex: Int = 0
    
    var messageUpdate: ((String) -> Void)?
    var progressUpdate: ((Int, Float) -> Void)?
    
    private var timer: DispatchSourceTimer?
    private var progressDuration: TimeInterval = 0.0
    private var remainingTime: TimeInterval = 0.0
    
    // MARK: - Initializer
    
    init(messages: [String], durations: [TimeInterval]) {
        self.messages = messages
        self.durations = durations
    }
    
    // MARK: - Helpers
    
    func startRotation() {
        currentIndex = 0
        showNextMessage()
    }
    
    private func showNextMessage() {
        guard currentIndex < messages.count else {
            resetProgress()
            return
        }
        messageUpdate?(messages[currentIndex])
        startProgressUpdate(duration: durations[currentIndex])
    }
    
    private func startProgressUpdate(duration: TimeInterval) {
        progressDuration = duration
        remainingTime = duration
        progressUpdate?(currentIndex, 0.0)

        timer?.cancel()
        timer = DispatchSource.makeTimerSource()
        timer?.schedule(deadline: .now(), repeating: 0.1)
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.remainingTime -= 0.1
            let progress = Float(
                (self.progressDuration - self.remainingTime) / self.progressDuration
            )
            
            DispatchQueue.main.async {
                self.progressUpdate?(self.currentIndex, progress)
            }
            
            if self.remainingTime <= 0 {
                self.moveToNextSegment()
            }
        }
        timer?.resume()
    }
    
    private func moveToNextSegment() {
        currentIndex += 1
        if currentIndex < messages.count {
            showNextMessage()
        } else {
            resetProgress()
        }
    }
    
    private func resetProgress() {
        currentIndex = 0
        showNextMessage()
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }
}
