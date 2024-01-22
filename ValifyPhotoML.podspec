#
# Be sure to run `pod lib lint ValifyPhotoML.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ValifyPhotoML'
  s.version          = '0.1.1'
  s.summary          = 'Face detection by ValifyPhotoML.'
  s.description      = 'By using ValifyPhotoML you can use your selfi camera to valify you identity.'
  s.homepage         = 'https://github.com/esraamasuad/ValifyPhotoML'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'esraa' => 'esraa.masuad@gmail.com' }
  s.source           = { :git => 'https://github.com/esraamasuad/ValifyPhotoML.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.platform = :ios, "11.0"
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  s.source_files = 'ValifyPhotoML/Classes/*.swift'
  s.frameworks = 'UIKit'

  # s.resource_bundles = {
  #   'ValifyPhotoML' => ['ValifyPhotoML/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.dependency 'AFNetworking', '~> 2.3'
end
