//
//  SegmentedProgressBar.swift
//  BookTalk
//
//  Created by RAFA on 8/17/24.
//

import UIKit

import SnapKit

final class SegmentedProgressBar: UIView {
    
    // MARK: - Properties
    
    private let numberOfSegments: Int
    private var segmentViews: [UIView] = []
    private var fillViews: [UIView] = []
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    // MARK: - Initializer
    
    init(numberOfSegments: Int) {
        self.numberOfSegments = numberOfSegments
        super.init(frame: .zero)
        
        setViews()
        setConstraints()
        feedbackGenerator.prepare()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func updateProgress(segmentIndex: Int, progress: Float) {
        guard segmentIndex < fillViews.count else { return }
        
        let updateBlock = { [weak self] in
            self?.updateFillWidths(segmentIndex: segmentIndex, progress: progress)
            self?.layoutIfNeeded()
        }
        
        progress > 0 ? animateUpdate(updateBlock) : updateWithoutAnimation(updateBlock)
    }
    
    // MARK: - Set UI
    
    private func setViews() {
        for _ in 0..<numberOfSegments {
            let segment = createSegmentView()
            let fillView = createFillView()
            
            segmentViews.append(segment)
            fillViews.append(fillView)
            
            addSubview(segment)
            segment.addSubview(fillView)
        }
    }
    
    private func setConstraints() {
        let segmentWidth = calculateSegmentWidth()
        
        for (index, segment) in segmentViews.enumerated() {
            segment.snp.makeConstraints {
                $0.width.equalTo(segmentWidth)
                $0.height.equalTo(6)
                $0.left.equalToSuperview().offset(CGFloat(index) * (segmentWidth + 10))
                $0.centerY.equalToSuperview()
            }
        }
        
        fillViews.forEach { fillView in
            fillView.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview()
                $0.height.equalTo(6)
                $0.width.equalTo(0)
            }
        }
    }
    
    private func calculateSegmentWidth() -> CGFloat {
        let totalSpacing = 10 * CGFloat(numberOfSegments - 1)
        return (UIScreen.main.bounds.width - 40 - totalSpacing) / CGFloat(numberOfSegments)
    }
    
    private func createSegmentView() -> UIView {
        let segment = UIView()
        segment.layer.cornerRadius = 2
        segment.backgroundColor = #colorLiteral(red: 0.9988475442, green: 0.9064419866, blue: 0.7702646852, alpha: 1)
        return segment
    }
    
    private func createFillView() -> UIView {
        let fillView = UIView()
        fillView.layer.cornerRadius = 2
        fillView.backgroundColor = .accentOrange
        fillView.clipsToBounds = true
        return fillView
    }
    
    private func updateFillWidths(segmentIndex: Int, progress: Float) {
        for (index, fillView) in fillViews.enumerated() {
            fillView.snp.updateConstraints {
                $0.width.equalTo(
                    calculateFillWidth(for: index, segmentIndex: segmentIndex, progress: progress)
                )
            }
        }
    }
    
    private func calculateFillWidth(for index: Int, segmentIndex: Int, progress: Float) -> CGFloat {
        if index < segmentIndex {
            return segmentViews[index].frame.width
        } else if index == segmentIndex {
            let calculatedWidth = segmentViews[index].frame.width * CGFloat(progress)
            if progress >= 1.0 { triggerHapticFeedback() }
            return calculatedWidth
        } else {
            return 0
        }
    }
    
    private func animateUpdate(_ animations: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: animations)
    }
    
    private func updateWithoutAnimation(_ updates: @escaping () -> Void) {
        UIView.performWithoutAnimation(updates)
    }
    
    private func triggerHapticFeedback() {
        feedbackGenerator.impactOccurred()
        feedbackGenerator.prepare()
    }
}
