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

#if canImport(UIKit)

import UIKit
import RxSwift
import RxCocoa


@available(iOS 13.0, *)
public typealias HoverConfiguration = Configuration<UIHoverGestureRecognizer>
@available(iOS 13.0, *)
public typealias HoverControlEvent = ControlEvent<UIHoverGestureRecognizer>
@available(iOS 13.0, *)
public typealias HoverObservable = Observable<UIHoverGestureRecognizer>


@available(iOS 13.0, *)
extension Factory where Gesture == RxGestureRecognizer {

    /**
     Returns an `AnyFactory` for `UIHoverGestureRecognizer`
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func hover(configuration: HoverConfiguration? = nil) -> AnyFactory {
        make(configuration: configuration).abstracted()
    }
}

@available(iOS 13.0, *)
extension Reactive where Base: RxGestureView {

    /**
     Returns an observable `UIHoverGestureRecognizer` events sequence
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func hoverGesture(configuration: HoverConfiguration? = nil) -> HoverControlEvent {
        gesture(make(configuration: configuration))
    }
}

#endif
