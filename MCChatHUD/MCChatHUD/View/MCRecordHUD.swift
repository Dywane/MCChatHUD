//
//  MCRecordHUD.swift
//  MCChatHUD
//
//  Created by duwei on 2018/1/30.
//  Copyright © 2018年 Dywane. All rights reserved.
//

import UIKit

/// HUD类型
///
/// - bar: 条状
/// - stroke: 线状
enum HUDType: Int {
    case bar = 0
    case line
}

class MCRecordHUD: UIView {

    //MARK: - Public Properties
    /// 提示Label
    public let titleLabel = UILabel()
    
    //MARK: - Private Properties
    private let progress = MCProgressView(frame: CGRect(x: 0, y: 0, width: HUDWidth, height: HUDHeight))
    private var volume: MCVolumeView!
    
    //MARK: Methods
    public func startCounting() {
        progress.countingAnimate()
        titleLabel.text = "Slide up to cancel"
    }
    
    public func stopCounting() {
        progress.stopAnimate()
    }
    
    //MARK: - Init
    
    convenience init(type: HUDType) {
        self.init(frame: .zero)
        self.frame.size.width = HUDWidth
        self.frame.size.height = HUDHeight
        center = CGPoint(x: ScreenWidth/2, y: ScreenHeight/2 - 50)
        backgroundColor = UIColor.clear
        addSubview(progress)
        
        volume = MCVolumeView(frame: CGRect(x: 56, y: 0, width: VolumeViewWidth, height: VolumeViewHeight), type: type)
        addSubview(volume)
        
        setUpLabel()
        addSubview(titleLabel)
        setUpShadow()
    }
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Setup
extension MCRecordHUD {
    
    private func setUpLabel() {
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.frame = CGRect(x: 25, y: 46, width: 120, height: 14)
    }
    
    private func setUpShadow() {
        
        let progessViewBounds = progress.frame
        let shadowWidth = progessViewBounds.size.width * 0.85
        let shadowHeight = progessViewBounds.size.height * 0.75
        
        let shadowPath = UIBezierPath(roundedRect: CGRect(x: progessViewBounds.origin.x + (progessViewBounds.width - shadowWidth) * 0.5,
                                                          y: progessViewBounds.origin.y + 20,
                                                          width: shadowWidth,
                                                          height: shadowHeight),
                                      cornerRadius: progress.layer.cornerRadius)
        
        layer.shadowColor = UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1).cgColor
        layer.shadowPath = shadowPath.cgPath
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 10)
    }
}
