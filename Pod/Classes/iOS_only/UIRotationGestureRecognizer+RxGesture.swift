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

import UIKit
import RxSwift
import RxCocoa

/// Default values for `UIRotationGestureRecognizer` configuration
public enum RotationGestureRecognizerDefaults {
    public static var configuration: ((UIRotationGestureRecognizer, RxGestureRecognizerDelegate) -> Void)?
}

fileprivate typealias Defaults = RotationGestureRecognizerDefaults

/// A `GestureRecognizerFactory` for `UIRotationGestureRecognizer`
public struct RotationGestureRecognizerFactory: GestureRecognizerFactory {
    public typealias Gesture = UIRotationGestureRecognizer
    public let configuration: (UIRotationGestureRecognizer, RxGestureRecognizerDelegate) -> Void

    /**
     Initialiaze a `GestureRecognizerFactory` for `UIRotationGestureRecognizer`
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public init(
        configuration: ((UIRotationGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) {
        self.configuration = { gesture, delegate in
            configuration?(gesture, delegate)
        }
    }
}

extension AnyGestureRecognizerFactory {

    /**
     Returns an `AnyGestureRecognizerFactory` for `UIRotationGestureRecognizer`
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func rotation(
        configuration: ((UIRotationGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) -> AnyGestureRecognizerFactory {
        let gesture = RotationGestureRecognizerFactory(
            configuration: configuration
        )
        return AnyGestureRecognizerFactory(gesture)
    }
}

public extension Reactive where Base: UIView {

    /**
     Returns an observable `UIRotationGestureRecognizer` events sequence
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func rotationGesture(
        configuration: ((UIRotationGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) -> ControlEvent<UIRotationGestureRecognizer> {
        return gesture(RotationGestureRecognizerFactory(
            configuration: configuration
        ))
    }
}

public extension ObservableType where E: UIRotationGestureRecognizer {

    /**
     Maps the observable `GestureRecognizer` events sequence to an observable sequence of rotation values of the gesture in radians alongside the gesture velocity.
     */
    public func asRotation() -> Observable<(rotation: CGFloat, velocity: CGFloat)> {
        return self.map { gesture in
            return (gesture.rotation, gesture.velocity)
        }
    }
}
