//
//  RoundTimerView.swift
//  Routine
//
//  Created by 한현규 on 10/18/23.
//

import Foundation
import UIKit


class RoundTimerView: UIControl {
    
    
    private var trackLayerStrokeColor: CGColor = UIColor.tertiaryLabel.cgColor
    private var barLayerStrokeColor: CGColor = UIColor.systemOrange.cgColor
    private var lineWidth = 16.0
    
    private lazy var trackLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = trackLayerStrokeColor
        layer.lineWidth = lineWidth
        return layer
    }()
    
    private lazy var barLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = barLayerStrokeColor
        layer.lineWidth = lineWidth
        return layer
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 8.0
        return stackView
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 44.0, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 36.0, weight: .regular)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 4.0
        return stackView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18.0, weight: .regular)
        label.textAlignment = .center
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let descriptoinLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16.0, weight: .regular)
        label.textAlignment = .center
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    init(){
        super.init(frame: .zero)
        
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        
        setLayout()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        barLayer.frame = bounds
        trackLayer.frame = bounds


        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        var radius: CGFloat { (bounds.height - lineWidth) / 2 }
        let startAngle = -90.degreesToRadians
        let basePath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: CGFloat.pi * 2,
            clockwise: true
        )
        let progressPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: CGFloat.pi * 2 + startAngle, //CGFloat.pi * 2,
            //endAngle: CGFloat.pi * 2,,
            clockwise: true
        )
        
        trackLayer.path = basePath.cgPath
        barLayer.path = progressPath.cgPath
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity            
        }
    }
    
    func bindView(_ viewModel: RoundTimerViewModel){
        emojiLabel.text = viewModel.emoji
        nameLabel.text = viewModel.name
        timeLabel.text = viewModel.time
        descriptoinLabel.text = viewModel.description
    }
    
    private func setLayout() {
        layer.addSublayer(trackLayer)
        layer.addSublayer(barLayer)
        
        addSubview(stackView)
        
        stackView.addArrangedSubview(emojiLabel)
        stackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(bottomStackView)
    
        
        bottomStackView.addArrangedSubview(nameLabel)
        bottomStackView.addArrangedSubview(descriptoinLabel)
        
                        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0 / sqrt(2), constant: -(lineWidth * 2)),
            stackView.heightAnchor.constraint(equalTo: stackView.widthAnchor),
        ])
        
        nameLabel.setContentHuggingPriority(.init(248.0), for: .vertical)
        nameLabel.setContentCompressionResistancePriority(.init(751.0), for: .vertical)
    }
    
    func setTimeLabel(time: String){
        timeLabel.text = time
    }
    

    func startProgress(duration: TimeInterval) {
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = 1.0
        strokeAnimation.toValue = 0.0
        strokeAnimation.beginTime = CACurrentMediaTime()
        //strokeAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        strokeAnimation.fillMode = .forwards
        strokeAnimation.isRemovedOnCompletion = false
        strokeAnimation.duration = duration

        barLayer.beginTime = 0.0
        barLayer.add(strokeAnimation, forKey: "strokeAnimation")
        //barLayer.strokeEnd = to
    }
    
    func updateProgress(from: CGFloat, remainDuration: TimeInterval) {
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = from
        strokeAnimation.toValue = 0.0
        strokeAnimation.beginTime = CACurrentMediaTime()
        //strokeAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        strokeAnimation.fillMode = .forwards
        strokeAnimation.isRemovedOnCompletion = false
        strokeAnimation.duration = remainDuration
                
        barLayer.add(strokeAnimation, forKey: "strokeAnimation")
        
        suspendProgress()
    }
    
    func resumeProgress(){
        let pausedTime = barLayer.timeOffset
        barLayer.speed = 1.0
        barLayer.timeOffset = 0.0
        barLayer.beginTime = 0.0
        let timeSincePause = barLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        barLayer.beginTime = timeSincePause
    }
    
    func suspendProgress(){
        let pausedTime = barLayer.convertTime(CACurrentMediaTime(), from: nil)        
        barLayer.speed = 0.0
        barLayer.timeOffset = pausedTime
    }
        

}


private extension Int {
    var degreesToRadians: CGFloat {
        return CGFloat(self) * .pi / 180
    }
}
