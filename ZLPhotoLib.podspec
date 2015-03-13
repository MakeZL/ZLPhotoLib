Pod::Spec.new do |s|
  s.name         = "ZLPhotoLib"
  s.version      = "1.0.0"
  s.summary      = "iOS photo album select and photoBrowser"
  s.homepage     = "https://github.com/MakeZL/ZLPhotoLib"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "zhangleo" => "120886865@qq.com" }
  s.social_media_url = "weibo.com/makezl"
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/MakeZL/ZLPhotoLib.git", :tag => "#{s.version}" }
 
  s.source_files  = 'ZLPhotoLib/ZLPhotoLib/ZLPhotoLib.{h,m}'
  s.frameworks   = "AVFoundation","AssetsLibrary"
  s.requires_arc = true
 
end