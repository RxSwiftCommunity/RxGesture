#
# Be sure to run `pod lib lint RxGesture.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = "RxGesture"
  s.version          = "4.0.4"
  s.summary          = "RxSwift reactive wrapper for view gestures."
  s.swift_version    = "5.1"

  s.description      = <<-DESC
					  RxSwift reactive wrapper for view gestures. It lets you to easily observe
					  a single gesture like tap or a custom group of gestures on a view. You can
					  combine taps, presses, or swipes in any direction
                       DESC

  s.homepage         = "https://github.com/RxSwiftCommunity/RxGesture"
  s.license          = 'MIT'
  s.authors          = { "RxSwiftCommunity" => "https://github.com/RxSwiftCommunity", "Jérôme Alves" => "j.alves@me.com" }
  s.source           = { :git => "https://github.com/RxSwiftCommunity/RxGesture.git", :tag => s.version.to_s }

  s.requires_arc = true

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'

  s.source_files = 'Pod/Classes/*.swift'

  s.ios.source_files      = 'Pod/Classes/iOS/*.swift'
  s.osx.source_files      = 'Pod/Classes/OSX/*.swift'

  s.dependency 'RxSwift', '~> 6.0'
  s.dependency 'RxCocoa', '~> 6.0'

end
