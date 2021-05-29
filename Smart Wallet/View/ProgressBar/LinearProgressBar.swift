//
//  LinearProgressBar.swift
//  Smart Wallet
//
//  Created by Thinura Laksara on 2021-05-12.
//

import Foundation
import UIKit

class LinearProgressBar: UIView{
    @IBInspectable public var backCircleColor: UIColor = UIColor.linearBackground
    @IBInspectable public var startGradientColor: UIColor = UIColor.linearHighlight
    @IBInspectable public var endGradientColor: UIColor = UIColor.linearHighlight
    
    private var backgroundLayer: CAShapeLayer!
    private var foregroundLayer: CAShapeLayer!
    private var gradientLayer: CAGradientLayer!
    
    public var progress: CGFloat = 0 {
        didSet {
            didProgressUpdated()
        }
    }
    
    override func draw(_ rect: CGRect) {
        // To Draw the progress bar
        
        guard layer.sublayers == nil else {
            return
        }
        
        let width = rect.width
        let height = rect.height
        
        let lineWidth = 0.8 * min(width, height)
        
        backgroundLayer = createBar(rect: rect, strokeColor: backCircleColor.cgColor, fillColor: UIColor.clear.cgColor, lineWidth: lineWidth)
        
        foregroundLayer = createBar(rect: rect, strokeColor: UIColor.red.cgColor, fillColor: UIColor.clear.cgColor, lineWidth: lineWidth)
        
        gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.0)
        
        gradientLayer.colors = [startGradientColor.cgColor, endGradientColor.cgColor]
        gradientLayer.frame = rect
        gradientLayer.mask = foregroundLayer
        
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(gradientLayer)
    }
    
    private func createBar(rect: CGRect, strokeColor: CGColor, fillColor: CGColor, lineWidth: CGFloat) -> CAShapeLayer {
        
        let width = rect.width
        
        let circularPath = UIBezierPath()
        circularPath.move(to: CGPoint(x: 15, y: 15))
        circularPath.addLine(to: CGPoint(x: width, y: 15))
        
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.path = circularPath.cgPath
        
        shapeLayer.strokeColor = strokeColor
        shapeLayer.fillColor = fillColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round
        
        return shapeLayer
    }
    
    private func didProgressUpdated() {
        foregroundLayer?.strokeEnd = progress
        gradientLayer?.colors = [startGradientColor.cgColor, endGradientColor.cgColor]
    }
}
