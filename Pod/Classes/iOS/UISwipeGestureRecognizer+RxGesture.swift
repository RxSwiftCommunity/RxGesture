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

private enum Defaults {
    static var numberOfTouchesRequired: Int = 1
    static var configuration: ((UISwipeGestureRecognizer) -> Void)? = nil
}

public struct SwipeGestureFactory: ConfigurableGestureFactory {
    public typealias Gesture = UISwipeGestureRecognizer
    public let configuration: (UISwipeGestureRecognizer) -> Void

    public init(
        _ direction: UISwipeGestureRecognizerDirection,
        numberOfTouchesRequired: Int = Defaults.numberOfTouchesRequired,
        configuration: ((UISwipeGestureRecognizer) -> Void)? = Defaults.configuration
        ){
        self.configuration = { gesture in
            gesture.direction = direction
            gesture.numberOfTouchesRequired = numberOfTouchesRequired
            configuration?(gesture)
        }
    }
}

extension AnyGesture {

    public static func swipe(
        _ direction: UISwipeGestureRecognizerDirection,
        numberOfTouchesRequired: Int = Defaults.numberOfTouchesRequired,
        configuration: ((UISwipeGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> AnyGesture {
        let gesture = SwipeGestureFactory(
            direction,
            numberOfTouchesRequired: numberOfTouchesRequired,
            configuration: configuration
        )
        return AnyGesture(gesture)
    }
}


public extension Reactive where Base: UIView {

    public func swipeGesture(
        _ direction: UISwipeGestureRecognizerDirection,
        numberOfTouchesRequired: Int = Defaults.numberOfTouchesRequired,
        configuration: ((UISwipeGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> ControlEvent<UISwipeGestureRecognizer> {

        return gesture(SwipeGestureFactory(
            direction,
            numberOfTouchesRequired: numberOfTouchesRequired,
            configuration: configuration
        ))
    }
}
