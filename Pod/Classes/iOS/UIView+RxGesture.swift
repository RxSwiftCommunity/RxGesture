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

extension Reactive where Base: UIView {

    /// Reactive wrapper for view gestures. You can observe a single gesture or multiple gestures
    /// (e.g. swipe left and right); the value the Observable emits is the type of the concrete gesture
    /// out of the list you are observing.
    ///
    /// rx_gesture can't error, shares side effects and is subscribed/observed on main scheduler
    /// - parameter type: list of types you want to observe like `[.Tap]` or `[.SwipeLeft, .SwipeRight]`
    /// - returns: `ControlEvent<RxGestureTypeOption>` that emits any type one of the desired gestures is performed on the view
    /// - seealso: `RxCocoa` adds `rx_tap` to `NSButton/UIButton` and is sufficient if you only need to subscribe
    ///   on taps on buttons. `RxGesture` on the other hand enables `userInteractionEnabled` and handles gestures on any view

    public func gesture(_ type: RxGestureTypeOption...) -> ControlEvent<RxGestureTypeOption> {
        let source: Observable<RxGestureTypeOption> = Observable.create {observer in
            MainScheduler.ensureExecutingOnScheduler()

            let control = self.base

            if control == nil {
                observer.on(.completed)
                return NopDisposable.instance
            }

            control.isUserInteractionEnabled = true
            
            var gestures = [(UIGestureRecognizer?, Disposable)]()
            
            let type = type.count > 0 ? type : RxGestureTypeOption.all()
            
            //taps
            if type.contains(.tap) {
                let tap = UITapGestureRecognizer()
                control.addGestureRecognizer(tap)
                gestures.append(
                    (tap, tap.rx.event.map {_ in RxGestureTypeOption.tap}
                        .bindNext(observer.onNext))
                )
            }
            
            //swipes
            for direction in Array<RxGestureTypeOption>([.swipeLeft, .swipeRight, .swipeUp, .swipeDown]) {
                if type.contains(direction) {
                    if let swipeDirection = self.direction(forType: direction) {
                        let swipe = UISwipeGestureRecognizer()
                        swipe.direction = swipeDirection
                        control.addGestureRecognizer(swipe)
                        gestures.append(
                            (swipe, swipe.rx.event.map {_ in direction}
                                .bindNext(observer.onNext))
                        )
                    }
                }
            }
            
            //long press
            if type.contains(.longPress) {
                let press = UILongPressGestureRecognizer()
                control.addGestureRecognizer(press)
                gestures.append(
                    (press, press.rx.event.map {_ in RxGestureTypeOption.longPress}
                        .bindNext(observer.onNext))
                )
            }
            
            //panning
            if type.contains(.pan(.any)) {
                
                //create or find existing recognizer
                var recognizer: UIPanGestureRecognizer
                
                if let existingPan = control.gestureRecognizers?.filter({ $0 is UIPanGestureRecognizer }).first as? UIPanGestureRecognizer {
                    recognizer = existingPan
                } else {
                    recognizer = UIPanGestureRecognizer()
                    control.addGestureRecognizer(recognizer)
                }
                
                //observable
                let panEvent = recognizer.rx.event.shareReplay(1)
                
                //panning
                for panGesture in type where panGesture == .pan(.any) {
                    
                    switch panGesture {
                    case (.pan(let config)):
                        //observe panning
                        let panObservable = panEvent.filter {recognizer -> Bool in
                            if config.state == .began && recognizer.state != .began {return false}
                            if config.state == .changed && recognizer.state != .changed {return false}
                            if config.state == .ended && recognizer.state != .ended {return false}
                            return true
                        }
                        .map {recognizer -> RxGestureTypeOption in
                            let recognizer = recognizer as! UIPanGestureRecognizer
                            
                            //current values
                            let newConfig = PanConfig(
                                translation: recognizer.translation(in: control.superview),
                                velocity: recognizer.translation(in: control.superview),
                                state: config.state,
                                recognizer: recognizer)
                            return RxGestureTypeOption.pan(newConfig)
                        }
                        
                        guard config.translation != .zero && config.velocity != .zero else {
                            gestures.append((recognizer, panObservable.bindNext(observer.onNext)))
                            break
                        }
                        
                        gestures.append(
                            (recognizer, panObservable.filter { gesture in
                                switch gesture {
                                case (.pan(let values)):
                                    return (values.translation.x >= config.translation.x || values.translation.y >= config.translation.y)
                                        && (values.translation.x >= config.translation.x || values.translation.y >= config.translation.y)
                                default: return false
                                }
                            }
                            .bindNext(observer.onNext))
                        )
                    default: break
                    }
                }
                
            }
            
            //rotating
            if type.contains(.rotate(.any)) {
                
                //create or find existing recognizer
                var recognizer: UIRotationGestureRecognizer
                
                if let existingRotate = control.gestureRecognizers?.filter({ $0 is UIRotationGestureRecognizer }).first as? UIRotationGestureRecognizer {
                    recognizer = existingRotate
                } else {
                    recognizer = UIRotationGestureRecognizer()
                    control.addGestureRecognizer(recognizer)
                }
                
                //observable
                let rotateEvent = recognizer.rx.event.shareReplay(1)
                
                //rotating
                for rotateGesture in type where rotateGesture == .rotate(.any) {
                    
                    switch rotateGesture {
                    case (.rotate(let config)):
                        //observe rotating
                        let rotateObservable = rotateEvent.filter {recognizer -> Bool in
                            if config.state == .began && recognizer.state != .began {return false}
                            if config.state == .changed && recognizer.state != .changed {return false}
                            if config.state == .ended && recognizer.state != .ended {return false}
                            return true
                            }
                            .map { recognizer -> RxGestureTypeOption in
                                let recognizer = recognizer as! UIRotationGestureRecognizer
                                
                                //current values
                                let newConfig = RotateConfig(rotation: recognizer.rotation, state: config.state, recognizer: recognizer)
                                return RxGestureTypeOption.rotate(newConfig)
                        }
                        
                        guard config.rotation != 0 else {
                            gestures.append((recognizer, rotateObservable.bindNext(observer.onNext)))
                            break
                        }
                        
                        gestures.append(
                            (recognizer, rotateObservable.filter { gesture in
                                switch gesture {
                                case (.rotate(let values)):
                                    return values.rotation > config.rotation
                                default: return false
                                }
                            }
                            .bindNext(observer.onNext))
                        )
                    default: break
                    }
                }
                
            }
            
            //dispose gestures
            return AnonymousDisposable {
                for (recognizer, gesture) in gestures {
                    if let recognizer = recognizer {
                        control.removeGestureRecognizer(recognizer)
                    }
                    gesture.dispose()
                }
            }
        }.takeUntil(self.deallocated)
        
        return ControlEvent(events: source)
    }
    
    private func direction(forType type: RxGestureTypeOption) -> UISwipeGestureRecognizerDirection? {
        if type == .swipeLeft  { return .left  }
        if type == .swipeRight { return .right }
        if type == .swipeUp    { return .up    }
        if type == .swipeDown  { return .down  }
        return nil
    }
}
