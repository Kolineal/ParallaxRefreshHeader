#
# Be sure to run `pod lib lint ParallaxRefreshHeader.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'ParallaxRefreshHeader'
s.version          = '1.0.2'
s.summary          = 'Parallax Header for UIScrollView based views. Includes pull to refresh comtroll that is shown under the header'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = <<-DESC
Basically this library is a combination of a ParallaxHeader from https://github.com/romansorochak/ParallaxHeader and pull to refresh https://github.com/Yalantis/PullToRefresh . It's modified to show the refresh view at the bottom of the header without messing up the inset/offset of the scroll view
DESC

s.homepage         = 'https://github.com/Kolineal/ParallaxRefreshHeader'
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Kolineal' => 'kolineal@gmail.com' }
s.source           = { :git => 'https://github.com/Kolineal/ParallaxRefreshHeader.git', :tag => s.version.to_s }
# s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

s.ios.deployment_target = '8.0'

s.source_files = 'ParallaxRefreshHeader/Classes/**/*.swift'
# s.resource_bundles = {
#   'ParallaxRefreshHeader' => ['ParallaxRefreshHeader/Assets/*.png']
# }

# s.public_header_files = 'Pod/Classes/**/*.h'
# s.frameworks = 'UIKit', 'MapKit'
# s.dependency 'AFNetworking', '~> 2.3'
end
