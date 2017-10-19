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

/// Default values for `UISwipeGestureRecognizer` configuration
public enum UISwipeGestureRecognizerDefaults {
    public static var numberOfTouchesRequired: Int = 1
    public static var configuration: ((UISwipeGestureRecognizer, RxGestureRecognizerDelegate) -> Void)?
}

fileprivate typealias Defaults = UISwipeGestureRecognizerDefaults

/// A `GestureRecognizerFactory` for `UISwipeGestureRecognizer`
public struct SwipeGestureRecognizerFactory: GestureRecognizerFactory {
    public typealias Gesture = UISwipeGestureRecognizer
    public let configuration: (UISwipeGestureRecognizer, RxGestureRecognizerDelegate) -> Void

    /**
     Initialiaze a `GestureRecognizerFactory` for `UISwipeGestureRecognizer`
     - parameter numberOfTouchesRequired: The number of fingers required to match
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public init(
        _ direction: UISwipeGestureRecognizerDirection,
        numberOfTouchesRequired: Int = Defaults.numberOfTouchesRequired,
        configuration: ((UISwipeGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) {
        self.configuration = { gesture, delegate in
            gesture.direction = direction
            gesture.numberOfTouchesRequired = numberOfTouchesRequired
            configuration?(gesture, delegate)
        }
    }
}

extension AnyGestureRecognizerFactory {

    /**
     Returns an `AnyGestureRecognizerFactory` for `UISwipeGestureRecognizer`
     - parameter numberOfTouchesRequired: The number of fingers required to match
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func swipe(
        _ direction: UISwipeGestureRecognizerDirection,
        numberOfTouchesRequired: Int = Defaults.numberOfTouchesRequired,
        configuration: ((UISwipeGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) -> AnyGestureRecognizerFactory {
        let gesture = SwipeGestureRecognizerFactory(
            direction,
            numberOfTouchesRequired: numberOfTouchesRequired,
            configuration: configuration
        )
        return AnyGestureRecognizerFactory(gesture)
    }
}

public extension Reactive where Base: UIView {

    /**
     Returns an observable `UISwipeGestureRecognizerDirection` events sequence
     - parameter numberOfTouchesRequired: The number of fingers required to match
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func swipeGesture(
        _ direction: UISwipeGestureRecognizerDirection,
        numberOfTouchesRequired: Int = Defaults.numberOfTouchesRequired,
        configuration: ((UISwipeGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) -> ControlEvent<UISwipeGestureRecognizer> {

        return gesture(SwipeGestureRecognizerFactory(
            direction,
            numberOfTouchesRequired: numberOfTouchesRequired,
            configuration: configuration
        ))
    }
}
