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

/// Default values for `UITapGestureRecognizer` configuration
public enum UITapGestureRecognizerDefaults {
    public static var numberOfTouchesRequired: Int = 1
    public static var numberOfTapsRequired: Int = 1
    public static var configuration: ((UITapGestureRecognizer, RxGestureRecognizerDelegate) -> Void)?
}

fileprivate typealias Defaults = UITapGestureRecognizerDefaults

/// A `GestureRecognizerFactory` for `UITapGestureRecognizer`
public struct TapGestureRecognizerFactory: GestureRecognizerFactory {
    public typealias Gesture = UITapGestureRecognizer
    public let configuration: (UITapGestureRecognizer, RxGestureRecognizerDelegate) -> Void

    /**
     Initialiaze a `GestureRecognizerFactory` for `UITapGestureRecognizer`
     - parameter numberOfTouchesRequired: The number of fingers required to match
     - parameter numberOfTapsRequired: The number of taps required to match
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public init(
        numberOfTouchesRequired: Int = Defaults.numberOfTouchesRequired,
        numberOfTapsRequired: Int = Defaults.numberOfTapsRequired,
        configuration: ((UITapGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) {
        self.configuration = { gesture, delegate in
            gesture.numberOfTouchesRequired = numberOfTouchesRequired
            gesture.numberOfTapsRequired = numberOfTapsRequired
            configuration?(gesture, delegate)
        }
    }
}

extension AnyGestureRecognizerFactory {

    /**
     Returns an `AnyGestureRecognizerFactory` for `UITapGestureRecognizer`
     - parameter numberOfTouchesRequired: The number of fingers required to match
     - parameter numberOfTapsRequired: The number of taps required to match
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func tap(
        numberOfTouchesRequired: Int = Defaults.numberOfTouchesRequired,
        numberOfTapsRequired: Int = Defaults.numberOfTapsRequired,
        configuration: ((UITapGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) -> AnyGestureRecognizerFactory {
        let gesture = TapGestureRecognizerFactory(
            numberOfTouchesRequired: numberOfTouchesRequired,
            numberOfTapsRequired: numberOfTapsRequired,
            configuration: configuration
        )
        return AnyGestureRecognizerFactory(gesture)
    }
}

public extension Reactive where Base: UIView {

    /**
     Returns an observable `UITapGestureRecognizer` events sequence
     - parameter numberOfTouchesRequired: The number of fingers required to match
     - parameter numberOfTapsRequired: The number of taps required to match
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func tapGesture(
        numberOfTouchesRequired: Int = Defaults.numberOfTouchesRequired,
        numberOfTapsRequired: Int = Defaults.numberOfTapsRequired,
        configuration: ((UITapGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) -> ControlEvent<UITapGestureRecognizer> {

        return gesture(TapGestureRecognizerFactory(
            numberOfTouchesRequired: numberOfTouchesRequired,
            numberOfTapsRequired: numberOfTapsRequired,
            configuration: configuration
        ))
    }
}
