#
# Be sure to run `pod lib lint Sluthware.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'ta-lib-swift'
s.version          = '0.0.3'
s.summary          = 'TA-LIB converted to swift'
s.description      = 'TA-LIB converted to swift'
s.homepage         = 'https://sluthware.com'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'patsluth' => 'pat.sluth@gmail.com' }
s.source           = { :git => 'https://github.com/patsluth/talib-swift.git', :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/patsluth'

s.ios.deployment_target = '9.0'

s.source_files = 'ta-lib-swift/Classes/**/*'

s.frameworks = 'Foundation', 'CoreFoundation'

end
