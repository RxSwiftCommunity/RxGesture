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

/// Default values for `UIScreenEdgePanGestureRecognizer` configuration
public enum UIScreenEdgePanGestureRecognizerDefaults {
    public static var configuration: ((UIScreenEdgePanGestureRecognizer, RxGestureRecognizerDelegate) -> Void)?
}

fileprivate typealias Defaults = UIScreenEdgePanGestureRecognizerDefaults

/// A `GestureRecognizerFactory` for `UIScreenEdgePanGestureRecognizer`
public struct ScreenEdgePanGestureRecognizerFactory: GestureRecognizerFactory {
    public typealias Gesture = UIScreenEdgePanGestureRecognizer
    public let configuration: (UIScreenEdgePanGestureRecognizer, RxGestureRecognizerDelegate) -> Void

    /**
     Initialiaze a `GestureRecognizerFactory` for `UIScreenEdgePanGestureRecognizer`
     - parameter edges: The edges on which this gesture recognizes, relative to the current interface orientation
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public init(
        edges: UIRectEdge,
        configuration: ((UIScreenEdgePanGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) {
        self.configuration = { gestureRecognizer, delegate in
            gestureRecognizer.edges = edges
            configuration?(gestureRecognizer, delegate)
        }
    }
}

extension AnyGestureRecognizerFactory {

    /**
     Returns an `AnyGestureRecognizerFactory` for `UIScreenEdgePanGestureRecognizer`
     - parameter edges: The edges on which this gesture recognizes, relative to the current interface orientation
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func screenEdgePan(
        edges: UIRectEdge,
        configuration: ((UIScreenEdgePanGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) -> AnyGestureRecognizerFactory {
        let gesture = ScreenEdgePanGestureRecognizerFactory(
            edges: edges,
            configuration: configuration
        )
        return AnyGestureRecognizerFactory(gesture)
    }
}

public extension Reactive where Base: UIView {

    /**
     Returns an observable `UIScreenEdgePanGestureRecognizer` events sequence
     - parameter edges: The edges on which this gesture recognizes, relative to the current interface orientation
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func screenEdgePanGesture(
        edges: UIRectEdge,
        configuration: ((UIScreenEdgePanGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) -> ControlEvent<UIScreenEdgePanGestureRecognizer> {

        return gesture(ScreenEdgePanGestureRecognizerFactory(
            edges: edges,
            configuration: configuration
            ))
    }
}
