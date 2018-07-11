Pod::Spec.new do |s|
  s.name             = 'ImagesPicker'
  s.version          = '0.0.1'
  s.summary          = '图片选择器'
  
  s.description      = <<-DESC
  用来进行图片选择，和拍摄照片选择
                       DESC
  s.homepage         = 'https://github.com/yaxunliu/ImagesPicker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yaxunliu' => '1175222300@qq.com' }
  s.source           = { :git => 'https://github.com/yaxunliu/ImagesPicker.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'

  s.source_files = 'ImagesPicker/Classes/**/*'
  s.resource_bundles = {
      'ImagesPicker' => ['ImagesPicker/Assets/*.png']
  }
  s.dependency 'BaseLib', '~> 0.0.7'
  
end
