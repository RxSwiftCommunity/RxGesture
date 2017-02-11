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
    static var buttonMask: Int = 0x1
    static var configuration: ((NSPanGestureRecognizer) -> Void)? = nil
}

public struct PanGestureFactory: ConfigurableGestureFactory {
    public typealias Gesture = NSPanGestureRecognizer
    public let configuration: (NSPanGestureRecognizer) -> Void

    public init(
        buttonMask: Int = Defaults.buttonMask,
        configuration: ((NSPanGestureRecognizer) -> Void)? = Defaults.configuration
        ){
        self.configuration = { gestureRecognizer in
            gestureRecognizer.buttonMask = buttonMask
            configuration?(gestureRecognizer)
        }
    }
}

extension AnyGesture {

    public static func pan(
        buttonMask: Int = Defaults.buttonMask,
        configuration: ((NSPanGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> AnyGesture {
        let gesture = PanGestureFactory(
            buttonMask: buttonMask,
            configuration: configuration
        )
        return AnyGesture(gesture)
    }
}

public extension Reactive where Base: NSView {
    public func panGesture(
        buttonMask: Int = Defaults.buttonMask,
        configuration: ((NSPanGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> ControlEvent<NSPanGestureRecognizer> {

        return gesture(PanGestureFactory(
            buttonMask: buttonMask,
            configuration: configuration
        ))
    }
}

public extension ObservableType where E: NSPanGestureRecognizer {
    public func translation(inView view: NSView? = nil) -> Observable<(translation: NSPoint, velocity: NSPoint)> {
        return self.map { gesture in
            let view = view ?? gesture.view?.superview
            return (
                gesture.translation(in: view),
                gesture.velocity(in: view)
            )
        }
    }
}
