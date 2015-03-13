Pod::Spec.new do |spec|
  spec.name         = "ZLPhotoLib"
  spec.version      = "1.0.0"
  spec.license      = "MIT"
  spec.homepage     = "https://github.com/MakeZL/ZLPhotoLib"
  spec.authors      = { 'MakeZL' => ‘120886865@qq.com' }
  spec.summary      = "iOS photo album select and photoBrowser"
  spec.source       = { :git => 'https://github.com/MakeZL/ZLPhotoLib.git', :tag =>spec.version }
  spec.source_files = "ZLPhotoLib/ZLPhotoLib/ZLPhotoLib.{h,m}"
  spec.frameworks   = "AVFoundation","AssetsLibrary"
  spec.requires_arc = true
end