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

extension Reactive where Base: View {

    public func anyGesture(_ gestures: (AnyGesture, state: GestureRecognizerState)...) -> ControlEvent<GestureRecognizer> {
        let observables = gestures.map { gesture, state in
            self.gesture(gesture).filterState(state).asObservable() as Observable<GestureRecognizer>
        }
        let source = Observable.from(observables).merge()
        return ControlEvent(events: source)
    }

    public func anyGesture(_ gestures: AnyGesture...) -> ControlEvent<GestureRecognizer> {
        let observables = gestures.map { gesture in
            self.gesture(gesture).asObservable() as Observable<GestureRecognizer>
        }
        let source = Observable.from(observables).merge()
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for view gestures. You can observe a single gesture recognizer.
    /// It automatically attaches the gesture recognizer to the receiver view.
    /// The value the Observable emits is the gesture recognizer itself
    ///
    /// rx.addGestureRecognizer can't error and is subscribed/observed on main scheduler
    /// - parameter type: an GestureRecognizer subclass you want to add and observe
    /// - returns: `ControlEvent<G>` that emits any type one of the desired gestures is performed on the view
    /// - seealso: `RxCocoa` adds `rx.tap` to `NSButton/Button` and is sufficient if you only need to subscribe
    ///   on taps on buttons. `RxGesture` on the other hand enables `userInteractionEnabled` and handles gestures on any view

    public func gesture<GF: GestureFactory, G: GestureRecognizer where GF.Gesture == G>(_ factory: GF) -> ControlEvent<G> {

        let gesture = factory.make()
        let control = self.base
        let genericGesture = gesture as GestureRecognizer

        #if os(iOS)
        control.isUserInteractionEnabled = true
        #endif

        gesture.delegate = gesture.delegate ?? PermissiveGestureRecognizerDelegate.shared

        let source: Observable<G> = Observable
            .create { observer in
                MainScheduler.ensureExecutingOnScheduler()

                control.addGestureRecognizer(gesture)

                let disposable = genericGesture.rx.event
                    .map { gesture -> G in gesture as! G }
                    .startWith(gesture)
                    .bindNext(observer.onNext)

                return Disposables.create {
                    control.removeGestureRecognizer(gesture)
                    disposable.dispose()
                }
            }
            .takeUntil(deallocated)

        return ControlEvent(events: source)
    }
}
