# RxGesture

[![Version](https://img.shields.io/cocoapods/v/RxGesture.svg?style=flat)](http://cocoapods.org/pods/RxGesture)
[![License](https://img.shields.io/cocoapods/l/RxGesture.svg?style=flat)](http://cocoapods.org/pods/RxGesture)
[![Platform](https://img.shields.io/cocoapods/p/RxGesture.svg?style=flat)](http://cocoapods.org/pods/RxGesture)

## Usage

![](Pod/Assets/demo.gif)

To run the example project, clone the repo, in the __Example__ folder open `RxGesture.xcworkspace`.

You _might_ need to run `pod install` from the Example directory first.

---

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

On __iOS__ RXGesture supports:

 - .Tap
 - .SwipeLeft, SwipeRight, SwipeUp, SwipeDown
 - .LongPress

On __OSX__ RXGesture supports:

 - .Click
 - .RightClick

If you are writing multi-platform code you can eventually write:

```swift
myView.rx_gesture([.Tap, .Click]).subscribeNext {...}
```

To observe for the concrete gesture on each platform.

## Requirements

This library depends on both __RxSwift__ and __RxCocoa__.

## Installation

RxGesture is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RxGesture"
```

## TODO

- support more gestures like Pan and Rotate
- defo add tests
- make pr to rxcocoa to add native support for rx_event to `NSGestureRecognizer` and remove the implementation from this repo

## Thanks

Everyone in the RxSwift Slack channel 💯

## License

RxGesture is available under the MIT license. See the LICENSE file for more info.
