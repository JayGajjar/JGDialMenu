#
# Be sure to run `pod lib lint JGDialMenu.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "JGDialMenu"
  s.version          = "0.1.1"
  s.summary          = "A circular spinning dial menu inspired from buzzfeed app. Check out the example for more details."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = "A circular spinning dial menu inspired from buzzfeed app."

  s.homepage         = "https://github.com/JayGajjar/JGDialMenu"
  s.screenshots      = "https://postimg.org/image/a0q4jqyb1/"
  s.license          = 'MIT'
  s.author           = { "Jay Gajjar" => "jaygajjar77@gmail.com" }
  s.source           = { :git => "https://github.com/JayGajjar/JGDialMenu.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'JGDialMenu' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
