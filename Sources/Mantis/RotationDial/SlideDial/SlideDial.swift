//
//  SlideDial.swift
//  Mantis
//
//  Created by Yingtao Guo on 6/16/23.
//

import UIKit

public final class SlideDial: UIView, RotationControlViewProtocol {
    public var isAttachedToCropView = true
    
    public var didUpdateRotationValue: (Angle) -> Void = { _ in }
    
    public var didFinishRotation: () -> Void = {}
    
    var indicator: UILabel!
    
    var slideRuler: SlideRuler!
    
    var viewModel = SlideDialViewModel()
    
    public var config = SlideDialConfig()
    
    public init(frame: CGRect,
         config: SlideDialConfig,
         viewModel: SlideDialViewModel,
         slideRuler: SlideRuler) {
        super.init(frame: frame)
        self.config = config
        self.viewModel = viewModel
        self.slideRuler = slideRuler
        
        addSubview(slideRuler)
        
        self.viewModel.didSetRotationAngle = { [weak self] angle in
            self?.handleRotation(by: angle)
        }
        
        setAccessibilities()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setIndicator(with angle: Angle) {
        indicator?.text = "\(Int(round(angle.degrees)))"
        indicator?.textColor = angle.degrees > 0 ? config.positiveIndicatorColor : config.notPositiveIndicatorColor
    }
    
    private func handleRotation(by angle: Angle) {
        setIndicator(with: angle)
        didUpdateRotationValue(angle)
    }
    
    @discardableResult
    public func updateRotationValue(by angle: Angle) -> Bool {
        guard abs(angle.degrees) < config.limitation else {
            return false
        }
        
        slideRuler?.setOffsetRatio(angle.degrees / config.limitation)
        setIndicator(with: angle)

        return true
    }
    
    public func reset() {
        transform = .identity
        viewModel.reset()
        if let slideRuler = slideRuler {
            slideRuler.reset()
        }
    }
    
    public func getTouchTarget(with point: CGPoint) -> UIView {
        let newPoint = convert(point, to: self)
        
        if indicator.frame.contains(newPoint) {
            return indicator
        }
        
        return slideRuler.getTouchTarget()
    }
    
    public func getLengthRatio() -> CGFloat {
        config.lengthRatio
    }
    
    public func handleDeviceRotation() {
        guard let indicator = indicator else {
            return
        }
        
        if Orientation.treatAsPortrait {
            indicator.transform = CGAffineTransform(rotationAngle: 0)
        } else if Orientation.isLandscapeRight {
            indicator.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        } else if Orientation.isLandscapeLeft {
            indicator.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        }
    }
            
    public func setupUI(withAllowableFrame allowableFrame: CGRect) {
        frame = allowableFrame
        createIndicator()
        setupSlideRuler()
    }
    
    func createIndicator() {
        let indicatorSize = config.indicatorSize
        let indicatorFrame = CGRect(origin: CGPoint(x: (frame.width - indicatorSize.width) / 2, y: 0), size: indicatorSize)
        
        if let indicator = indicator {
            indicator.frame = indicatorFrame
        } else {
            indicator = UILabel(frame: indicatorFrame)
            indicator.textColor = config.notPositiveIndicatorColor
            indicator.textAlignment = .center
            addSubview(indicator)
            
            indicator.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(indicatorTapped))
            indicator.addGestureRecognizer(tap)
        }
    }
    
    @objc public func indicatorTapped() {
        reset()
        didFinishRotation()
    }
    
    func setupSlideRuler() {
        let sliderFrame = CGRect(x: 0,
                                 y: frame.height - config.slideRulerHeight,
                                 width: frame.width,
                                 height: config.slideRulerHeight)
        slideRuler.frame = sliderFrame
        slideRuler.delegate = self
        slideRuler.forceAlignCenterFeedback = true
        slideRuler.setupUI()
    }
    
    public override func accessibilityIncrement() {
        viewModel.rotationAngle += Angle(degrees: 1)
        setAccessibilityValue()
    }
    
    public override func accessibilityDecrement() {
        viewModel.rotationAngle -= Angle(degrees: -1)
        setAccessibilityValue()
    }
        
    public func getTotalRotationValue() -> CGFloat {
        viewModel.rotationAngle.degrees
    }
}

extension SlideDial: SlideRulerDelegate {
    public func didFinishScroll() {
        didFinishRotation()
    }
    
    public func didGetOffsetRatio(from slideRuler: SlideRuler, offsetRatio: CGFloat) {
        let angle = Angle(degrees: config.limitation * offsetRatio)
        viewModel.rotationAngle = angle
    }
}
