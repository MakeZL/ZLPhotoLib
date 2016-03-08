Pod::Spec.new do |s|
s.name             = "ZLPhotoLib"
s.version          = "1.0.1"
s.summary          = "This is a photo album multiple-choice / photo browser example"
s.homepage         = "https://github.com/MakeZL/ZLPhotoLib"
s.license          = 'MIT'
s.author           = { "zhangleo" => "zhangleowork@163.com" }
s.source           = { :git => "https://github.com/MakeZL/ZLPhotoLib.git", :tag => s.version.to_s }

s.platform         = :ios, '6.0'
s.requires_arc     = true

s.frameworks       = 'AssetsLibrary' , 'AVFoundation', 'MediaPlayer'
s.source_files     = 'ZLPhotoLib/Classes/**/*'
s.resource         = "ZLPhotoLib/ZLPhotoLib.bundle"

end