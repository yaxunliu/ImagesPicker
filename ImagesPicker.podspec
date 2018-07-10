Pod::Spec.new do |s|
  s.name             = 'ImagesPicker'
  s.version          = '0.1.0'
  s.summary          = '图片选择器'
  
  s.description      = <<-DESC
  用来进行图片选择，和拍摄照片选择
                       DESC
  s.homepage         = 'https://github.com/liuyaxun/ImagesPicker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liuyaxun' => '1175222300@qq.com' }
  s.source           = { :git => 'https://github.com/liuyaxun/ImagesPicker.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'

  s.source_files = 'ImagesPicker/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ImagesPicker' => ['ImagesPicker/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'BaseLib', '~> 0.0.6'
end
