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

/// Default values for `NSMagnificationGestureRecognizer` configuration
private enum Defaults {
    static var configuration: ((NSMagnificationGestureRecognizer) -> Void)? = nil
}

/// A `GestureRecognizerFactory` for `NSMagnificationGestureRecognizer`
public struct MagnificationGestureRecognizerFactory: GestureRecognizerFactory {
    public typealias Gesture = NSMagnificationGestureRecognizer
    public let configuration: (NSMagnificationGestureRecognizer) -> Void

    /**
     Initialiaze a `GestureRecognizerFactory` for `NSMagnificationGestureRecognizer`
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public init(
        configuration: ((NSMagnificationGestureRecognizer) -> Void)? = Defaults.configuration
        ){
        self.configuration = configuration ?? { _ in }
    }
}

extension AnyGestureRecognizerFactory {

    /**
     Returns an `AnyGestureRecognizerFactory` for `NSMagnificationGestureRecognizer`
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func magnification(
        configuration: ((NSMagnificationGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> AnyGestureRecognizerFactory {
        let gesture = MagnificationGestureRecognizerFactory(
            configuration: configuration
        )
        return AnyGestureRecognizerFactory(gesture)
    }
}

public extension Reactive where Base: NSView {

    /**
     Returns an observable `NSMagnificationGestureRecognizer` events sequence
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func magnificationGesture(
        configuration: ((NSMagnificationGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> ControlEvent<NSMagnificationGestureRecognizer> {

        return gesture(MagnificationGestureRecognizerFactory(
            configuration: configuration
        ))
    }
}

public extension ObservableType where E: NSMagnificationGestureRecognizer {

    /**
     Maps the observable `GestureRecognizer` events sequence to an observable sequence of magnification amounts alongside the gesture velocity.
     */
    public func asMagnification() -> Observable<CGFloat> {
        return self.map { gesture in
            return gesture.magnification
        }
    }

    /**
     Maps the observable `GestureRecognizer` events sequence to an observable sequence of scale factors relative to the points of the two touches in screen coordinates alongside the gesture velocity.
     */
    public func asScale() -> Observable<CGFloat> {
        return self.map { gesture in
            return 1.0 + gesture.magnification
        }
    }
}
