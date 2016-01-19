Pod::Spec.new do |spec|
  spec.name         = 'HsUber'
  spec.version      = '1.1.2'
  spec.summary      = '模仿Uber首页动画'
  spec.homepage     = 'https://github.com/wangjindong/HsUber'
  spec.license      = 'MIT'
  #spec.license = { :type => 'MIT', :file => 'FILE_LICENSE' }
  spec.author       = { 'wangjindong' => '419591321@qq.com' }
  #spec.social_media_url   = 'http://twitter.com/hundsun'
  spec.platform = :ios,'5.0'
  spec.source  = {:git=>'https://github.com/wangjindong/HsUber.git',:tag=>spec.version}
  spec.source_files = 'HsUber/HsUber/*'
  #spec.exclude_files = 'HsUber/**/*'
  #spec.resource = 'HsUber/HsUber/*.bundle'

  spec.requires_arc = true
  #spec.ios.deployment_target = '7.0'
  #spec.public_header_files = 'HsUber/*.h'
  spec.frameworks = 'Foundation', 'CoreGraphics', 'UIKit'

end