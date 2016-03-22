// Copyright (c) 2016 Marin Todorov <marin@underplot.com>

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import RxSwift
import RxCocoa

/// An OptionSetType to provide a list of valid gestures
public struct RxGestureTypeOptions : OptionSetType, Hashable {
    
    private let raw: UInt
    
    public init(rawValue: UInt) {
        raw = rawValue
    }
    public var rawValue: UInt {
        return raw
    }
    
    public var hashValue: Int { return Int(rawValue) }
    
    public static var None = RxGestureTypeOptions(rawValue: 0)
    public static var Tap  = RxGestureTypeOptions(rawValue: 1 << 0)
    
    public static var SwipeLeft  = RxGestureTypeOptions(rawValue: 1 << 1)
    public static var SwipeRight = RxGestureTypeOptions(rawValue: 1 << 2)
    public static var SwipeUp    = RxGestureTypeOptions(rawValue: 1 << 3)
    public static var SwipeDown  = RxGestureTypeOptions(rawValue: 1 << 4)
    
    public static var LongPress  = RxGestureTypeOptions(rawValue: 1 << 5)
    
    public static func all() -> RxGestureTypeOptions {
        return [.Tap, .SwipeLeft, .SwipeRight, .SwipeUp, .SwipeDown, .LongPress]
    }
}

extension UIView {
    
    /// Reactive wrapper for view gestures. You can observe a single gesture or multiple gestures
    /// (e.g. swipe left and right); the value the Observable emits is the type of the concrete gesture
    /// out of the list you are observing.
    ///
    /// rx_gesture can't error, shares side effects and is subscribed/observed on main scheduler
    /// - parameter type: list of types you want to observe like `[.Tap]` or `[.SwipeLeft, .SwipeRight]`
    /// - returns: `ControlEvent<RxGestureTypeOptions>` that emits any type one of the desired gestures is performed on the view
    /// - seealso: `RxCocoa` adds `rx_tap` to `NSButton/UIButton` and is sufficient if you only need to subscribe
    ///   on taps on buttons. `RxGesture` on the other hand enables `userInteractionEnabled` and handles gestures on any view

    public func rx_gesture(type: RxGestureTypeOptions) -> ControlEvent<RxGestureTypeOptions> {
        let source: Observable<RxGestureTypeOptions> = Observable.create { [weak self] observer in
            MainScheduler.ensureExecutingOnScheduler()
            
            guard let control = self where !type.isEmpty else {
                observer.on(.Completed)
                return NopDisposable.instance
            }
            
            control.userInteractionEnabled = true
            
            var gestures = [Disposable]()
            
            //taps
            if type.contains(.Tap) {
                let tap = UITapGestureRecognizer()
                control.addGestureRecognizer(tap)
                gestures.append(
                    tap.rx_event.map {_ in RxGestureTypeOptions.Tap}
                        .bindNext(observer.onNext)
                )
            }
            
            //swipes
            for direction in Array<RxGestureTypeOptions>([.SwipeLeft, .SwipeRight, .SwipeUp, .SwipeDown]) {
                if type.contains(direction) {
                    if let swipeDirection = control.directionForGestureType(direction) {
                        let swipe = UISwipeGestureRecognizer()
                        swipe.direction = swipeDirection
                        control.addGestureRecognizer(swipe)
                        gestures.append(
                            swipe.rx_event.map {_ in direction}
                                .bindNext(observer.onNext)
                        )
                    }
                }
            }
            
            //long press
            if type.contains(.LongPress) {
                let press = UILongPressGestureRecognizer()
                control.addGestureRecognizer(press)
                gestures.append(
                    press.rx_event.map {_ in RxGestureTypeOptions.LongPress}
                        .bindNext(observer.onNext)
                )
            }
            
            //dispose gestures
            return AnonymousDisposable {
                for gesture in gestures {
                    gesture.dispose()
                }
            }
        }.takeUntil(rx_deallocated)
        
        return ControlEvent(events: source)
    }
    
    private func directionForGestureType(type: RxGestureTypeOptions) -> UISwipeGestureRecognizerDirection? {
        if type == .SwipeLeft  { return .Left  }
        if type == .SwipeRight { return .Right }
        if type == .SwipeUp    { return .Up    }
        if type == .SwipeDown  { return .Down  }
        return nil
    }
}