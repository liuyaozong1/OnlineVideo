//
//  ViewController.swift
//  OnlineVideo
//
//  Created by 刘耀宗 on 2021/6/16.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .red
        if let url =  URL(string: "https://v-cdn.zjol.com.cn/280443.mp4") {
            let playerView = LYZPlayerView(videoUrl: url, isAutoPlay: true, isRoop: true)
            playerView.frame = view.bounds
            view.addSubview(playerView)
        }
        
    }
    
    deinit {
        print("ViewController 释放了")
    }

}

