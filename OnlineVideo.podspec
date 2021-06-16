Pod::Spec.new do |s|
  s.name         = "OnlineVideo"
  s.version      = "1.0.1"
  s.summary      = "在线视频播放,手动拖动进度"
  s.description  = "在线视频播放,手动拖动进度"
  s.homepage     = "https://github.com/liuyaozong1/OnlineVideo.git"
  s.license      = "MIT"
  s.author       = { "yaozong.liu" => "648731281@qq.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/liuyaozong1/OnlineVideo.git", :tag => "#{s.version}" }
  s.source_files        = 'OnlineVideo/Video/*.swift'
  s.ios.deployment_target = '11.0'
  
end
