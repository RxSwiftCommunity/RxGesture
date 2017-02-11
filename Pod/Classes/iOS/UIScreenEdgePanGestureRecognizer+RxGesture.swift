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
    static var minimumNumberOfTouches: Int = 1
    static var maximumNumberOfTouches: Int = Int.max
    static var configuration: ((UIScreenEdgePanGestureRecognizer) -> Void)? = nil
}

public struct ScreenEdgePanGestureFactory: ConfigurableGestureFactory {
    public typealias Gesture = UIScreenEdgePanGestureRecognizer
    public let configuration: (UIScreenEdgePanGestureRecognizer) -> Void

    public init(
        edges: UIRectEdge,
        configuration: ((UIScreenEdgePanGestureRecognizer) -> Void)? = Defaults.configuration
        ){
        self.configuration = { gestureRecognizer in
            gestureRecognizer.edges = edges
            configuration?(gestureRecognizer)
        }
    }
}

extension AnyGesture {

    public static func pan(
        edges: UIRectEdge,
        configuration: ((UIScreenEdgePanGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> AnyGesture {
        let gesture = ScreenEdgePanGestureFactory(
            edges: edges,
            configuration: configuration
        )
        return AnyGesture(gesture)
    }
}

public extension Reactive where Base: UIView {

    public func screenEdgePanGesture(
        edges: UIRectEdge,
        configuration: ((UIScreenEdgePanGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> ControlEvent<UIScreenEdgePanGestureRecognizer> {

        return gesture(ScreenEdgePanGestureFactory(
            edges: edges,
            configuration: configuration
            ))
    }
}
