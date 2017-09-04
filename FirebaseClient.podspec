#
# Be sure to run `pod lib lint FirebaseClient.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FirebaseClient'
  s.version          = '0.1.0'
  s.summary          = 'Build DevWorks apps fast, without managing infrastructure'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Build DevWorks apps fast, without managing infrastructure using FireBase. You never have to right particular code again.
                       DESC

  s.homepage         = 'https://github.com/DevWorksCo/FirebaseClient'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'josemantilla26' => 'jose.mantilla@gmail.com' }
  s.source           = { :git => 'https://github.com/DevWorksCo/FirebaseClient.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.xcconfig       = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/"' }
  s.pod_target_xcconfig = {
'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(SRCROOT)/**',
'OTHER_LDFLAGS' => '$(inherited) -undefined dynamic_lookup'
}


  s.source_files = 'FirebaseClient/Classes/**/*'
  
  # s.resource_bundles = {
  #   'FirebaseClient' => ['FirebaseClient/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit','SafariServices','Security','SystemConfiguration'
  s.dependency 'FBSDKLoginKit'
  s.vendored_frameworks = 'Frameworks/GoogleSignIn.framework'
  s.vendored_frameworks = 'Frameworks/Firebase.framework'
  s.vendored_frameworks = 'Frameworks/Firebase/Auth.framework'
  s.vendored_frameworks = 'Frameworks/Firebase/Database.framework'
#s.vendored_frameworks = 'Frameworks/Firebase/Analytics.framework'
end
