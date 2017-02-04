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

    /// Reactive wrapper for view gestures. You can observe a single gesture recognizer.
    /// It automatically attaches the gesture recognizer to the receiver view.
    /// The value the Observable emits is the gesture recognizer itself
    ///
    /// rx.recognized can't error and is subscribed/observed on main scheduler
    /// - parameter type: an UIGestureRecognizer subclass you want to observe
    /// - returns: `ControlEvent<G>` that emits any type one of the desired gestures is performed on the view
    /// - seealso: `RxCocoa` adds `rx.tap` to `NSButton/UIButton` and is sufficient if you only need to subscribe
    ///   on taps on buttons. `RxGesture` on the other hand enables `userInteractionEnabled` and handles gestures on any view

    public func recognized<G: UIGestureRecognizer>(_ gesture: G, configuration: ((G) -> Void)? = nil) -> ControlEvent<G> {
        configuration?(gesture)
        let source: Observable<G> = Observable
            .create { observer in
                MainScheduler.ensureExecutingOnScheduler()

                let control = self.base

                let genericGesture = gesture as UIGestureRecognizer

                control.addGestureRecognizer(gesture)

                let disposable = genericGesture.rx.event
                    .map { gesture -> G in gesture as! G }
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
