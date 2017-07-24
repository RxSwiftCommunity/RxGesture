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

import Cocoa
import RxSwift
import RxCocoa

/// Default values for `NSRotationGestureRecognizer` configuration
private enum Defaults {
    static var configuration: ((NSRotationGestureRecognizer) -> Void)? = nil
}

/// A `GestureRecognizerFactory` for `NSRotationGestureRecognizer`
public struct RotationGestureRecognizerFactory: GestureRecognizerFactory {
    public typealias Gesture = NSRotationGestureRecognizer
    public let configuration: (NSRotationGestureRecognizer) -> Void

    public init(
        configuration: ((NSRotationGestureRecognizer) -> Void)? = Defaults.configuration
        ){
        self.configuration = { gesture in
            configuration?(gesture)
        }
    }
}

extension AnyGestureRecognizerFactory {

    /**
     Returns an `AnyGestureRecognizerFactory` for `NSRotationGestureRecognizer`
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func rotation(
        configuration: ((NSRotationGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> AnyGestureRecognizerFactory {
        let gesture = RotationGestureRecognizerFactory(
            configuration: configuration
        )
        return AnyGestureRecognizerFactory(gesture)
    }
}

public extension Reactive where Base: NSView {

    /**
     Returns an observable `NSRotationGestureRecognizer` events sequence
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func rotationGesture(
        configuration: ((NSRotationGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> ControlEvent<NSRotationGestureRecognizer> {
        return gesture(RotationGestureRecognizerFactory(
            configuration: configuration
        ))
    }
}

public extension ObservableType where E: NSRotationGestureRecognizer {

    /**
     Maps the observable `GestureRecognizer` events sequence to an observable sequence of rotation values of the gesture in radians.
     */
    public func asRotation() -> Observable<CGFloat> {
        return self.map { gesture in
            return gesture.rotation
        }
    }
}
