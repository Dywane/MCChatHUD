//
//  MCVolumeView.swift
//  MCChatHUD
//
//  Created by duwei on 2018/1/30.
//  Copyright © 2018年 Dywane. All rights reserved.
//

import UIKit

class MCVolumeView: UIView {

    //MARK: Private Properties
    /// 声音表数组
    private var soundMeters: [Float]!
    
    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        contentMode = .redraw   //内容模式为重绘，因为需要多次重复绘制音量表
        NotificationCenter.default.addObserver(self, selector: #selector(updateView(notice:)), name: NSNotification.Name.init("updateMeters"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        if soundMeters != nil && soundMeters.count > 0 {
            let context = UIGraphicsGetCurrentContext()
            context?.setLineWidth(3)
            context?.setLineCap(.round)
            context?.setLineJoin(.round)
            context?.setStrokeColor(UIColor.white.cgColor)
            
            let noVoice = -46.0     // 该值代表低于-46.0的声音都认为无声音
            let maxVolume = 55.0    // 该值代表最高声音为55.0
            for (index,item) in soundMeters.enumerated() {
                let barHeight = maxVolume - (Double(item) - noVoice)    //通过当前声音表计算应该显示的声音表高度
                context?.move(to: CGPoint(x: index * 6 + 3, y: 40))     
                context?.addLine(to: CGPoint(x: index * 6 + 3, y: Int(barHeight)))
                
            }
            context?.strokePath()
        }
    }
    
    @objc private func updateView(notice: Notification) {
        soundMeters = notice.object as! [Float]
        setNeedsDisplay()
    }

}
