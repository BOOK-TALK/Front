//
//  WaveView.swift
//  BookTalk
//
//  Created by RAFA on 8/17/24.
//

import UIKit

final class WaveView: UIView {
    
    enum Direction {
        case right
        case left
    }
    
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    
    var myLayer = CAShapeLayer()
    
    var speed: Double = 10
    var frequency = 8.0
    var parameterA = 1.5
    var parameterB = 9.0
    var phase = 0.0
    
    var preferredColor = UIColor.accentOrange
    var direction: Direction = .right
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDisplayLink()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDisplayLink()
    }
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateWave))
        displayLink?.add(to: .main, forMode: .default)
    }
    
    @objc private func updateWave() {
        phase += (direction == .right ? 1 : -1) * speed * 0.01
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        myLayer.frame = rect
        let width = Double(self.frame.width)
        let height = Double(self.frame.height)
        
        let mid = height * 0.8
        let waveLength = width / self.frequency
        let waveHeightCoef = Double(self.frequency)
        
        path.move(to: CGPoint(x: 0, y: self.frame.maxY))
        path.addLine(to: CGPoint(x: 0, y: mid))
        
        for x in stride(from: 0, through: width, by: 1) {
            let actualX = x / waveLength
            let sine = -cos(
                self.parameterA * (actualX + self.phase)
            ) * sin((actualX + self.phase) / self.parameterB)
            let y = waveHeightCoef * sine
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: CGFloat(width), y: self.frame.maxY))
        path.addLine(to: CGPoint(x: 0, y: self.frame.maxY))
        
        myLayer.path = path.cgPath
        myLayer.fillColor = preferredColor.cgColor
        myLayer.strokeColor = preferredColor.cgColor
        
        if myLayer.superlayer == nil {
            self.layer.addSublayer(self.myLayer)
        }
    }
    
    deinit {
        displayLink?.invalidate()
    }
}
