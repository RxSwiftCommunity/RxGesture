#
# Be sure to run `pod lib lint RxGesture.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = "RxGesture"
  s.version          = "0.1.2"
  s.summary          = "RxSwfit reactive wrapper for view gestures."

  s.description      = <<-DESC
					  RxSwfit reactive wrapper for view gestures. It lets you to easily observe
					  a single gesture like tap or a custom group of gestures on a view. You can 
					  combine taps, presses, or swipes in any direction
                       DESC

  s.homepage         = "https://github.com/icanzilb/RxGesture"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Marin Todorov" => "touch-code-magazine@underplot.com" }
  s.source           = { :git => "https://github.com/icanzilb/RxGesture.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/icanzilb'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'RxGesture' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'UIKit'
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  
end
