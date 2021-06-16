//
//  LYZVideoControllView.swift
//  OnlineVideo
//
//  Created by 刘耀宗 on 2021/6/16.
//

import UIKit
import AVFoundation
class LYZVideoControllView: UIView {

    lazy var currentTimeLabel: UILabel = {
        let lab = label(str: "00:00")
        return lab
    }()
    
    lazy var totalTimeLabel: UILabel = {
        let lab = label(str: "00:00")
        return lab
    }()
    
    lazy var sliderView: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderTouchDown(slider:)), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderUpInside(slider:)), for: .touchUpInside)
        return slider
    }()
    
    var currentTime: Int64 = 0 {
        didSet {
            DispatchQueue.main.async {
                self.currentTimeLabel.text = self.getFormatPlayTime(secounds: TimeInterval(self.currentTime))
                self.sliderView.value = Float(self.currentTime) / Float(self.totalTime)
                self.updateUI()
            }
            
        }
    }
    
    weak var playerView: LYZPlayerView?
    
    var totalTime: Int64 = 0 {
        didSet {
            DispatchQueue.main.async {
                self.totalTimeLabel.text = self.getFormatPlayTime(secounds: TimeInterval(self.totalTime))
                self.updateUI()
            }
          
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
        configSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateUI()
    }
    
    @objc func sliderValueChanged(slider: UISlider) {
        print("slider == \(slider.value)")
        let time: Float64 = Float64(self.totalTime)  * Float64(slider.value)
        print("当前跳转的时间是\(time)")
        let cmtime: CMTime = CMTimeMakeWithSeconds(Float64(time), preferredTimescale: Int32(Int(1 * NSEC_PER_SEC)))
        self.playerView?.player?.seek(to: cmtime, toleranceBefore: CMTime(value: 1, timescale: 1000), toleranceAfter: CMTime(value: 1, timescale: 1000))
    }
    
    @objc func sliderTouchDown(slider: UISlider) {
        print("按下去了")
        playerView?.pause()
    }
    
    @objc func sliderUpInside(slider: UISlider) {
         print("松开了")
        playerView?.play()
    }
    
    deinit {
        print("controllView 释放了")
    }
}

extension LYZVideoControllView {
    func configSubviews() {
        setupSubviews()
        measureSubviews()
    }
    
    func setupSubviews() {
        addSubview(currentTimeLabel)
        addSubview(totalTimeLabel)
        addSubview(sliderView)
    }
    
    func measureSubviews() {
        updateUI()
    }
    
    func updateUI() {
        currentTimeLabel.sizeToFit()
        currentTimeLabel.frame = CGRect.init(x: 5, y: (self.bounds.size.height - currentTimeLabel.bounds.size.height) / 2, width: 50, height: currentTimeLabel.bounds.size.height)
        totalTimeLabel.sizeToFit()
        totalTimeLabel.frame = CGRect.init(x: self.bounds.size.width - totalTimeLabel.bounds.size.width - 5, y: (self.bounds.size.height - totalTimeLabel.bounds.size.height) / 2, width: 50, height: totalTimeLabel.bounds.size.height)
        sliderView.frame = CGRect.init(x: currentTimeLabel.frame.maxX + 5, y: (self.bounds.size.height - 10) / 2, width: self.bounds.size.width - currentTimeLabel.frame.maxX - 5 - 50 - 5, height: 10)
    }
    
    
    func label(str: String) -> UILabel {
        let lab = UILabel()
        lab.text = str
        lab.textColor = .white
        lab.font = UIFont.systemFont(ofSize: 14)
        return lab
    }
    
    func getFormatPlayTime(secounds:TimeInterval)->String{
            if secounds.isNaN{
                return "00:00"
            }
            let Min = Int(secounds / 60)
            let Sec = Int(secounds.truncatingRemainder(dividingBy: 60))
            return String(format: "%02d:%02d", Min, Sec)
    }
}
