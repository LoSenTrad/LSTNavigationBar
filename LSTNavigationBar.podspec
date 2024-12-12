#
# Be sure to run `pod lib lint LSTNavigationBar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LSTNavigationBar'
  s.version          = '0.1.104'
  s.summary          = 'iOS通用导航栏组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'A short description of LSTNavigationBar'

  s.homepage         = 'https://github.com/LoSenTrad/LSTNavigationBar.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '490790096@qq.com' => 'LoSenTrad@163.com' }
  s.source           = { :git => 'https://github.com/LoSenTrad/LSTNavigationBar.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  #s.source_files = 'LSTNavigationBar/Classes/**/*'
  
  s.default_subspec = 'Code'
  
  s.subspec 'Code' do |code|
      code.source_files = 'LSTNavigationBar/Classes/Code/**/*'
      #core.public_header_files = 'ZFPlayer/Classes/Core/**/*.h'
      code.frameworks = 'UIKit'
  end
  
  # s.resource_bundles = {
  #   'LSTNavigationBar' => ['LSTNavigationBar/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'FDFullscreenPopGesture'
  s.dependency 'LSTCategory'
  
end
