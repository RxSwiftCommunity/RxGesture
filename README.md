# RxGesture

[![Version](https://img.shields.io/cocoapods/v/RxGesture.svg?style=flat)](http://cocoapods.org/pods/RxGesture)
[![License](https://img.shields.io/cocoapods/l/RxGesture.svg?style=flat)](http://cocoapods.org/pods/RxGesture)
[![Platform](https://img.shields.io/cocoapods/p/RxGesture.svg?style=flat)](http://cocoapods.org/pods/RxGesture)

## Usage

To run the example project, clone the repo, in the __Example__ folder open `RxGesture.xcworkspace`.

You _might_ need to run `pod install` from the Example directory first.

__RxGesture__ allows you to easily turn any view into a tappable or swipeable control like so:

```ruby
myView.rx_gesture(.Tap).subscribeNext {_ in
   //react to taps
}.addDisposableTo(stepBag)
```

You can also react to more than one type of gesture. For example to dismiss a photo preview you might want to do that when the user taps it, or swipes up or down:

```ruby
myView.rx_gesture([.Tap, .SwipeUp, .SwipeDown]).subscribeNext {_ in
   //dismiss presented photo
}.addDisposableTo(stepBag)
```

`rx_gesture` is defined as `Observable<RxGestureTypeOptions>` so what it emits is the concrete type of the gesture that was triggered (handy if you are observing more than one type)

## Requirements

This library depends on both __RxSwift__ and __RxCocoa__.

## Installation

RxGesture is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RxGesture"
```

## Author

Marin Todorov, [www.underplot.com](www.underplot.com)

## License

RxGesture is available under the MIT license. See the LICENSE file for more info.
