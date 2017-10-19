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

/// Default values for `UILongPressGestureRecognizer` configuration
public enum LongPressGestureRecognizerDefaults {
    public static var numberOfTouchesRequired: Int = 1
    public static var numberOfTapsRequired: Int = 0
    public static var minimumPressDuration: CFTimeInterval = 0.5
    public static var allowableMovement: CGFloat = 10
    public static var configuration: ((UILongPressGestureRecognizer, RxGestureRecognizerDelegate) -> Void)?
}

fileprivate typealias Defaults = LongPressGestureRecognizerDefaults

/// A `GestureRecognizerFactory` for `UITapGestureRecognizer`
public struct LongPressGestureRecognizerFactory: GestureRecognizerFactory {

    public typealias Gesture = UILongPressGestureRecognizer
    public let configuration: (UILongPressGestureRecognizer, RxGestureRecognizerDelegate) -> Void

    /**
     Initialiaze a `GestureRecognizerFactory` for `UILongPressGestureRecognizer`
     - parameter numberOfTouchesRequired: Number of fingers that must be held down for the gesture to be recognized
     - parameter numberOfTapsRequired: The number of full taps required before the press for gesture to be recognized
     - parameter minimumPressDuration: Time in seconds the fingers must be held down for the gesture to be recognized
     - parameter allowableMovement: Maximum movement in pixels allowed before the gesture fails. Once recognized (after minimumPressDuration) there is no limit on finger movement for the remainder of the touch tracking
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public init(
        numberOfTouchesRequired: Int = Defaults.numberOfTouchesRequired,
        numberOfTapsRequired: Int = Defaults.numberOfTapsRequired,
        minimumPressDuration: CFTimeInterval = Defaults.minimumPressDuration,
        allowableMovement: CGFloat = Defaults.allowableMovement,
        configuration: ((UILongPressGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) {
        self.configuration = { gestureRecognizer, delegate in
            gestureRecognizer.numberOfTouchesRequired = numberOfTouchesRequired
            gestureRecognizer.numberOfTapsRequired = numberOfTapsRequired
            gestureRecognizer.minimumPressDuration = minimumPressDuration
            gestureRecognizer.allowableMovement = allowableMovement
            configuration?(gestureRecognizer, delegate)
        }
    }
}

extension AnyGestureRecognizerFactory {

    /**
     Returns an `AnyGestureRecognizerFactory` for `UILongPressGestureRecognizer`
     - parameter numberOfTouchesRequired: Number of fingers that must be held down for the gesture to be recognized
     - parameter numberOfTapsRequired: The number of full taps required before the press for gesture to be recognized
     - parameter minimumPressDuration: Time in seconds the fingers must be held down for the gesture to be recognized
     - parameter allowableMovement: Maximum movement in pixels allowed before the gesture fails. Once recognized (after minimumPressDuration) there is no limit on finger movement for the remainder of the touch tracking
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func longPress(
        numberOfTouchesRequired: Int = Defaults.numberOfTouchesRequired,
        numberOfTapsRequired: Int = Defaults.numberOfTapsRequired,
        minimumPressDuration: CFTimeInterval = Defaults.minimumPressDuration,
        allowableMovement: CGFloat = Defaults.allowableMovement,
        configuration: ((UILongPressGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) -> AnyGestureRecognizerFactory {
        let gesture = LongPressGestureRecognizerFactory(
            numberOfTouchesRequired: numberOfTouchesRequired,
            numberOfTapsRequired: numberOfTapsRequired,
            minimumPressDuration: minimumPressDuration,
            allowableMovement: allowableMovement,
            configuration: configuration
        )
        return AnyGestureRecognizerFactory(gesture)
    }
}

public extension Reactive where Base: UIView {

    /**
     Returns an observable `UILongPressGestureRecognizer` events sequence
     - parameter numberOfTouchesRequired: Number of fingers that must be held down for the gesture to be recognized
     - parameter numberOfTapsRequired: The number of full taps required before the press for gesture to be recognized
     - parameter minimumPressDuration: Time in seconds the fingers must be held down for the gesture to be recognized
     - parameter allowableMovement: Maximum movement in pixels allowed before the gesture fails. Once recognized (after minimumPressDuration) there is no limit on finger movement for the remainder of the touch tracking
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func longPressGesture(
        numberOfTouchesRequired: Int = Defaults.numberOfTouchesRequired,
        numberOfTapsRequired: Int = Defaults.numberOfTapsRequired,
        minimumPressDuration: CFTimeInterval = Defaults.minimumPressDuration,
        allowableMovement: CGFloat = Defaults.allowableMovement,
        configuration: ((UILongPressGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) -> ControlEvent<UILongPressGestureRecognizer> {

        return gesture(LongPressGestureRecognizerFactory(
            numberOfTouchesRequired: numberOfTouchesRequired,
            numberOfTapsRequired: numberOfTapsRequired,
            minimumPressDuration: minimumPressDuration,
            allowableMovement: allowableMovement,
            configuration: configuration
        ))
    }
}
