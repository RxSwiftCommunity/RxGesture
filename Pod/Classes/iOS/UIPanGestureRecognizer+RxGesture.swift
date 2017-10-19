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

/// Default values for `UIPanGestureRecognizer` configuration
public enum PanGestureRecognizerDefaults {
    public static var minimumNumberOfTouches: Int = 1
    public static var maximumNumberOfTouches: Int = Int.max
    public static var configuration: ((UIPanGestureRecognizer, RxGestureRecognizerDelegate) -> Void)?
}

fileprivate typealias Defaults = PanGestureRecognizerDefaults

/// A `GestureRecognizerFactory` for `UIPanGestureRecognizer`
public struct PanGestureRecognizerFactory: GestureRecognizerFactory {
    public typealias Gesture = UIPanGestureRecognizer
    public let configuration: (UIPanGestureRecognizer, RxGestureRecognizerDelegate) -> Void

    /**
     Initialiaze a `GestureRecognizerFactory` for `UITapGestureRecognizer`
     - parameter minimumNumberOfTouches: The minimum number of touches required to match
     - parameter maximumNumberOfTouches: The maximum number of touches that can be down
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public init(
        minimumNumberOfTouches: Int = Defaults.minimumNumberOfTouches,
        maximumNumberOfTouches: Int = Defaults.maximumNumberOfTouches,
        configuration: ((UIPanGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) {
        self.configuration = { gesture, delegate in
            gesture.minimumNumberOfTouches = minimumNumberOfTouches
            gesture.maximumNumberOfTouches = maximumNumberOfTouches
            configuration?(gesture, delegate)
        }
    }
}

extension AnyGestureRecognizerFactory {

    /**
     Returns an `AnyGestureRecognizerFactory` for `UIPanGestureRecognizer`
     - parameter minimumNumberOfTouches: The minimum number of touches required to match
     - parameter maximumNumberOfTouches: The maximum number of touches that can be down
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func pan(
        minimumNumberOfTouches: Int = Defaults.minimumNumberOfTouches,
        maximumNumberOfTouches: Int = Defaults.maximumNumberOfTouches,
        configuration: ((UIPanGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) -> AnyGestureRecognizerFactory {
        let gesture = PanGestureRecognizerFactory(
            minimumNumberOfTouches: minimumNumberOfTouches,
            maximumNumberOfTouches: maximumNumberOfTouches,
            configuration: configuration
        )
        return AnyGestureRecognizerFactory(gesture)
    }
}

public extension Reactive where Base: UIView {

    /**
     Returns an observable `UIPanGestureRecognizer` events sequence
     - parameter minimumNumberOfTouches: The minimum number of touches required to match
     - parameter maximumNumberOfTouches: The maximum number of touches that can be down
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func panGesture(
        minimumNumberOfTouches: Int = Defaults.minimumNumberOfTouches,
        maximumNumberOfTouches: Int = Defaults.maximumNumberOfTouches,
        configuration: ((UIPanGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) -> ControlEvent<UIPanGestureRecognizer> {

        return gesture(PanGestureRecognizerFactory(
            minimumNumberOfTouches: minimumNumberOfTouches,
            maximumNumberOfTouches: maximumNumberOfTouches,
            configuration: configuration
        ))
    }
}

public extension ObservableType where E: UIPanGestureRecognizer {

    /**
     Maps the observable `GestureRecognizer` events sequence to an observable sequence of translation values of the pan gesture in the coordinate system of the specified `view` alongside the gesture velocity.

     - parameter view: A `TargetView` value on which the gesture took place.
     */
    public func asTranslation(in view: TargetView = .view) -> Observable<(translation: CGPoint, velocity: CGPoint)> {
        return self.map { gesture in
            let view = view.targetView(for: gesture)
            return (
                gesture.translation(in: view),
                gesture.velocity(in: view)
            )
        }
    }
}
