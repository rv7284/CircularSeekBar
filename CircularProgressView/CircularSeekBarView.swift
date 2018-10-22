//
//  CircularSeekBarView.swift
//  CircularSeekBarView
//
//  Created by Ravi on 17/10/18.
//  Copyright © 2018 Ravi. All rights reserved.
//

import UIKit

protocol CirclularSeekBarDelegate {
    func seekBar(_ seekbar:CircularSeekBarView, valueUpdate value:CGFloat)
}

 @IBDesignable class CircularSeekBarView: UIView {
    
    fileprivate var trackLayer = CAShapeLayer()
    fileprivate var thumbLayer = CAShapeLayer()
    fileprivate var progressLayer = CAShapeLayer()
    fileprivate var currentValue:CGFloat = 0.0 {
        didSet {
            delelegate?.seekBar(self, valueUpdate: currentValue)
        }
    }
    fileprivate var initialAngle:CGFloat = 0.0
    
    override var bounds: CGRect {
        didSet {
            createCircularPath()
        }
    }
    
    fileprivate var radius:CGFloat {
        return min(frame.width, frame.height)/2 - max(trackWidth, max(progressWidth, thumbWidth))/2
    }
    
    var delelegate:CirclularSeekBarDelegate?

    var value:CGFloat {
        return currentValue
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        createCircularPath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        createCircularPath()
    }
    
    @IBInspectable var trackWidth:CGFloat = 2.0 {
        didSet {
            trackLayer.lineWidth = trackWidth
        }
    }
    
    @IBInspectable var trackColor:UIColor = UIColor.blue {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    @IBInspectable var progressWidth:CGFloat = 2.2 {
        didSet {
            progressLayer.lineWidth = progressWidth
        }
    }
    
    @IBInspectable var progressColor:UIColor = UIColor.blue {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    
    @IBInspectable var thumbWidth:CGFloat = 40.0 {
        didSet {
            thumbLayer.lineWidth = thumbWidth
        }
    }
    
    @IBInspectable var thumbColor:UIColor = UIColor.red {
        didSet {
            thumbLayer.strokeColor = thumbColor.cgColor
        }
    }
    
    func createCircularPath() {
        self.backgroundColor = .clear
        self.layer.cornerRadius = min(frame.width, frame.height)/2
        let viewCenter = CGPoint(x: frame.width/2, y: frame.height/2)
        let circularPath = UIBezierPath(arcCenter: viewCenter, radius: radius, startAngle: -.pi/2, endAngle: .pi*1.5, clockwise: true)
        
        //track
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = trackWidth
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        //progress
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = progressWidth
        progressLayer.strokeEnd = CGFloat(currentValue)
        progressLayer.lineCap = .round
        layer.addSublayer(progressLayer)
        
        //thumb
        let thumbCenter = findPoint(currentValue)
        initialAngle = 2 * .pi * currentValue
        let thumbRect = CGRect(x: thumbCenter.x, y: thumbCenter.y - radius, width: thumbWidth, height: thumbWidth)
        let cgPath = CGPath(ellipseIn: thumbRect, transform: nil)
        thumbLayer.position = viewCenter
        thumbLayer.path = cgPath
        thumbLayer.fillColor = thumbColor.cgColor
        thumbLayer.strokeColor = UIColor.clear.cgColor
        self.thumbLayer.setAffineTransform(CGAffineTransform(rotationAngle: (2 * .pi * currentValue) - initialAngle))
        layer.addSublayer(thumbLayer)
    }
    
    func findPoint(_ currentValue:CGFloat) ->CGPoint {
        let thumbRadius = thumbWidth / 2
        let thumbAngle = 2 * .pi * currentValue - (.pi/2)
        let thumbX = (CGFloat(cos(thumbAngle)) * (radius) - thumbRadius)
        let thumbY = (CGFloat(sin(thumbAngle)) * (radius) - thumbRadius) + radius
        let point = CGPoint(x: thumbX, y: thumbY)
        return point
    }
    
    func setProgress(_ value:CGFloat, _ animated :Bool) {
        let duration = 1.0
        let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        progressAnimation.duration = animated ? duration : 0.0
        progressAnimation.fromValue = currentValue
        progressAnimation.toValue = value
        progressAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(progressAnimation, forKey: "animateprogress")

        let animation = CABasicAnimation(keyPath: "transform.rotation")
        let to = 2 * .pi * (value - currentValue)
        animation.fromValue = initialAngle
        animation.toValue = to + initialAngle
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = animated ? duration : 0.0
        animation.isAdditive = true
        animation.delegate = self
        thumbLayer.add(animation, forKey: nil)
        if animated {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration - 0.2) {
                self.thumbLayer.setAffineTransform(CGAffineTransform(rotationAngle: (2 * .pi * value) - self.initialAngle))
            }
        } else {
            self.thumbLayer.setAffineTransform(CGAffineTransform(rotationAngle: (2 * .pi * value) - initialAngle))
        }
        
        currentValue = value
    }
    
    func getAngle(forPoint point:CGPoint) -> CGFloat {
        let viewCenter = CGPoint(x: frame.width/2, y: frame.height/2)
        let xDist = (point.x - viewCenter.x)
        let yDist = (viewCenter.y - point.y)
        let tanValue = atan(xDist/yDist)
        
        if yDist > 0 && xDist > 0 {
            return abs(tanValue)
        } else if yDist < 0 && xDist > 0 {
            return abs(tanValue + .pi)
        } else if yDist < 0 && xDist < 0 {
            return abs(tanValue + (.pi))
        } else {
            return (tanValue + (.pi*2))
        }
        
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let firstTouch = touches.first else { return }
//        let angle = getAngle(forPoint: firstTouch.preciseLocation(in: self))
//    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else { return }
        let angle = getAngle(forPoint: firstTouch.preciseLocation(in: self))
        let progress = angle/(.pi * 2)
        currentValue = progress
        initialAngle = 2 * .pi * currentValue
        createCircularPath()
    }
    
}

extension CircularSeekBarView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        createCircularPath()
    }
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
