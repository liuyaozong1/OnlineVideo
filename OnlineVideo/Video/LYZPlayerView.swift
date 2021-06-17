//
//  LYZPlayerView.swift
//  OnlineVideo
//
//  Created by 刘耀宗 on 2021/6/16.
//

import UIKit
import AVFoundation
class LYZPlayerView: UIView {

    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var playerLayer: AVPlayerLayer?
    
    lazy var controlView: LYZVideoControllView = {
        let view = LYZVideoControllView(frame: CGRect.init(x: 5, y: self.bounds.size.height - 10 - 10, width: 200, height: 20))
        return view
    }()
    
    lazy var stopBtn: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(onClick), for: .touchUpInside)
        btn.setImage(UIImage(named: "play"), for: .normal)
        btn.isHidden = true
        return btn
    }()
    
    lazy var loading: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        return view
    }()
    
    //当前播放的时间回调
    var currentTimeBlock: (Int64) -> Void = {_ in }
    //当前播放状态的回调
    var playerStatusBlock: (AVPlayer.Status) -> Void = {_ in}
    //视频播放结束的回调
    var playerEndBlock: () -> Void = {}
    //是否正在播放
    var isPlaying: Bool {
        get {
            return player?.timeControlStatus == .playing
        }
    }
    
    //是否自动播放
    let isAutoPlay: Bool
    //是否循环播放
    let isRoop: Bool
    //地址
    let videoUrl: URL
    
    init(videoUrl url: URL,isAutoPlay auto: Bool,isRoop roop: Bool) {
        videoUrl = url
        isRoop = roop
        isAutoPlay = auto
        super.init(frame: .zero)
        initVideo()
    }
    
    func initVideo() {
            backgroundColor = .black
            playerItem = AVPlayerItem(url: videoUrl)
            player = AVPlayer(playerItem: playerItem)
            playerLayer = AVPlayerLayer(player: player)
            layer.addSublayer(playerLayer ?? AVPlayerLayer())
            //是否自动播放
            if isAutoPlay {
                play()
            }
            loading.startAnimating()
            //添加状态观察者
            playerItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            //添加缓冲进度观察者
            playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
            let tap = UITapGestureRecognizer(target: self, action: #selector(onClick))
            addGestureRecognizer(tap)
            //添加视频播放结束通知
            NotificationCenter.default.addObserver(self, selector: #selector(moviePlayDidEnd(userinfo:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        let queue = DispatchQueue(label: "asset")
        queue.async {
            let asset = AVAsset(url: self.videoUrl)
            let totalTime = Int64(asset.duration.value) / Int64(asset.duration.timescale)
            self.controlView.totalTime = totalTime
        }
        self.controlView.playerView = self
        
        configSubviews()
    }
    
    deinit {
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        NotificationCenter.default.removeObserver(self)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func onClick() {
        if isPlaying {
            pause()
            stopBtn.isHidden = false
        } else {
            stopBtn.isHidden = true
            play()
        }
        bringSubviewToFront(stopBtn)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stopBtn.sizeToFit()
        stopBtn.frame = CGRect.init(x: (self.bounds.size.width - stopBtn.bounds.size.width) / 2, y: (self.bounds.size.height - stopBtn.bounds.size.height) / 2, width: stopBtn.bounds.size.width, height: stopBtn.bounds.size.height)
        playerLayer?.frame = self.bounds
        controlView.frame =  CGRect.init(x: 5, y: self.bounds.size.height - 60, width: self.bounds.size.width - 10, height: 20)
       
    }
    
}

extension LYZPlayerView {
    func configSubviews() {
        setupSubviews()
        measureSubviews()
    }
    
    func setupSubviews() {
        addSubview(stopBtn)
        addSubview(controlView)
        bringSubviewToFront(controlView)
    }
    
    func measureSubviews() {
     
    }
    //开始播放
    func play() {
        player?.play()
        self.stopBtn.isHidden = true
    }
    //暂停
    func pause() {
        player?.pause()
        self.stopBtn.isHidden = false
    }
}

extension LYZPlayerView {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //状态
        if keyPath == "status" {
            print(change?[NSKeyValueChangeKey(rawValue: "new")] ?? "")
            let status: Int = change?[NSKeyValueChangeKey(rawValue: "new")] as! Int
            playerStatusBlock(AVPlayer.Status(rawValue: status) ?? AVPlayer.Status.unknown)
            switch status {
            case AVPlayer.Status.unknown.rawValue:
                do {
                    print("不知道状态")
                }
            case AVPlayer.Status.readyToPlay.rawValue:
                do {
                    loading.stopAnimating()
                    print("准备开始播放")
                    self.player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 5), queue: nil, using: {[weak self] time in
                        guard let _self = self else {
                            return
                        }
                        let second: Int64 = Int64(_self.playerItem?.currentTime().value ?? 0) / Int64(_self.playerItem?.currentTime().timescale ?? 0)
                        print("时间----\(second)")
                        _self.controlView.currentTime = second
                        _self.currentTimeBlock(second)
                    })
                }
                
            case AVPlayer.Status.failed.rawValue:
                do {
                    print("播放失败")
                    loading.stopAnimating()
                }
            default: do {
                print("123")
            }
            
            }
            
        }
        //缓冲进度
        if keyPath == "loadedTimeRanges" {
            print("进度数据是--\(change?[NSKeyValueChangeKey(rawValue: "new")] ?? "")")
        }
    }
    
    
    @objc func moviePlayDidEnd(userinfo: Notification) {
        print("视频结束")
        playerEndBlock()
        if isRoop {
            //跳转到 0
            player?.seek(to: CMTime(value: 0, timescale: 600))
            play()
        }
    }
    
    
}
