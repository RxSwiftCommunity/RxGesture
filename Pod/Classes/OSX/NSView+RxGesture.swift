// Copyright (c) RxSwiftCommunity

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

extension NSView {
    
    /// Shortcut to `rx_gesture` for when you need to subscribe to a single gesture
    ///
    /// - parameter type: RxGestureTypeOption value, e.g. `.Click` or `.Tap`
    /// - returns: `ControlEvent<RxGestureTypeOption>` that emits any type one of the desired gestures is performed on the view
    public func rx_gesture(type: RxGestureTypeOption) -> ControlEvent<RxGestureTypeOption> {
        return rx_gesture([type])
    }
    
    /// Reactive wrapper for view gestures. You can observe a single gesture or multiple gestures
    /// (e.g. swipe left and right); the value the Observable emits is the type of the concrete gesture
    /// out of the list you are observing.
    ///
    /// rx_gesture can't error, shares side effects and is subscribed/observed on main scheduler
    /// - parameter type: list of types you want to observe like `[.Tap]` or `[.SwipeLeft, .SwipeRight]`
    /// - returns: `ControlEvent<RxGestureTypeOptions>` that emits any type one of the desired gestures is performed on the view
    /// - seealso: `RxCocoa` adds `rx_tap` to `NSButton/UIButton` and is sufficient if you only need to subscribe
    ///   on taps on buttons. `RxGesture` on the other hand enables `userInteractionEnabled` and handles gestures on any view

    public func rx_gesture(type: [RxGestureTypeOption]) -> ControlEvent<RxGestureTypeOption> {
        let source: Observable<RxGestureTypeOption> = Observable.create { [weak self] observer in
            MainScheduler.ensureExecutingOnScheduler()
            
            guard let control = self where !type.isEmpty else {
                observer.on(.Completed)
                return NopDisposable.instance
            }
            
            var gestures = [Disposable]()
            
            //clicks
            if type.contains(.Click) {
                let click = NSClickGestureRecognizer()
                click.buttonMask = 1 << 0
                control.addGestureRecognizer(click)
                gestures.append(
                    click.rx_event.map {_ in RxGestureTypeOption.Click}
                        .bindNext(observer.onNext)
                )
            }

            //right clicks
            if type.contains(.RightClick) {
                let click = NSClickGestureRecognizer()
                click.buttonMask = 1 << 1
                control.addGestureRecognizer(click)
                gestures.append(
                    click.rx_event.map {_ in RxGestureTypeOption.RightClick}
                        .bindNext(observer.onNext)
                )
            }
            
            //panning
            if type.contains(.Panning(.zero)) || type.contains(.DidPan(.zero)) {
                
                //create a recognizer
                let pan = NSPanGestureRecognizer()
                control.addGestureRecognizer(pan)
                
                //observable
                let panEvent = pan.rx_event.shareReplay(1)
                
                //panning
                if let index = type.indexOf(.Panning(.zero)) {
                    //min offset
                    let minOffset: CGPoint
                    switch type[index] {
                    case (.Panning(let point)): minOffset = point
                    default: minOffset = .zero
                    }
                    
                    //observe panning
                    gestures.append(
                        panEvent.map {[weak self] _ in RxGestureTypeOption.Panning(pan.translationInView(self?.superview))}
                            .filter { panning in
                                if pan.state != .Changed { return false }
                                if minOffset == .zero { return true }
                                
                                switch panning {
                                case (.Panning(let offset)):
                                    return offset.x >= minOffset.x || offset.y >= minOffset.y
                                default: return false
                                }
                            }
                            .bindNext(observer.onNext)
                    )
                }
                
                //did pan
                if let index = type.indexOf(.DidPan(.zero)) {
                    //min offset
                    let minOffset: CGPoint
                    switch type[index] {
                    case (.DidPan(let point)): minOffset = point
                    default: minOffset = .zero
                    }
                    
                    gestures.append(
                        panEvent.map {[weak self] _ in RxGestureTypeOption.DidPan(pan.translationInView(self?.superview))}
                            .filter { didPan in
                                if pan.state != .Ended { return false }
                                if minOffset == .zero { return true }
                                
                                switch didPan {
                                case (.DidPan(let offset)):
                                    return offset.x >= minOffset.x || offset.y >= minOffset.y
                                default: return false
                                }
                            }
                            .bindNext(observer.onNext)
                    )
                }
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
    
}