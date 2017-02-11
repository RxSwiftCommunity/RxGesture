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
    static var configuration: ((NSMagnificationGestureRecognizer) -> Void)? = nil
}

public struct MagnificationGestureFactory: ConfigurableGestureFactory {
    public typealias Gesture = NSMagnificationGestureRecognizer
    public let configuration: (NSMagnificationGestureRecognizer) -> Void

    public init(
        configuration: ((NSMagnificationGestureRecognizer) -> Void)? = Defaults.configuration
        ){
        self.configuration = configuration ?? { _ in }
    }
}

extension AnyGesture {

    public static func magnification(
        configuration: ((NSMagnificationGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> AnyGesture {
        let gesture = MagnificationGestureFactory(
            configuration: configuration
        )
        return AnyGesture(gesture)
    }
}

public extension Reactive where Base: NSView {

    public func magnificationGesture(
        configuration: ((NSMagnificationGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> ControlEvent<NSMagnificationGestureRecognizer> {

        return gesture(MagnificationGestureFactory(
            configuration: configuration
        ))
    }
}

public extension ObservableType where E: NSMagnificationGestureRecognizer {
    public func magnification() -> Observable<CGFloat> {
        return self.map { gesture in
            return gesture.magnification
        }
    }

    public func scale() -> Observable<CGFloat> {
        return self.map { gesture in
            return 1.0 + gesture.magnification
        }
    }

}
