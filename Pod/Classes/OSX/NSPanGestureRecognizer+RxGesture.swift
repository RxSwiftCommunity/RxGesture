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

import AppKit
import RxSwift
import RxCocoa

/// Default values for `NSPanGestureRecognizer` configuration
public enum NSPanGestureRecognizerDefaults {
    public static var buttonMask: Int = 0x1
    public static var configuration: ((NSPanGestureRecognizer, RxGestureRecognizerDelegate) -> Void)?
}

fileprivate typealias Defaults = NSPanGestureRecognizerDefaults

/// A `GestureRecognizerFactory` for `NSPanGestureRecognizer`
public struct PanGestureRecognizerFactory: GestureRecognizerFactory {
    public typealias Gesture = NSPanGestureRecognizer
    public let configuration: (NSPanGestureRecognizer, RxGestureRecognizerDelegate) -> Void

    /**
     Initialiaze a `GestureRecognizerFactory` for `NSPanGestureRecognizer`
     - parameter buttonMask: bitfield of the button(s) required to recognize this click where bit 0 is the primary button, 1 is the secondary button, etc...
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public init(
        buttonMask: Int = Defaults.buttonMask,
        configuration: ((NSPanGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) {
        self.configuration = { gestureRecognizer, delegate in
            gestureRecognizer.buttonMask = buttonMask
            configuration?(gestureRecognizer, delegate)
        }
    }
}

extension AnyGestureRecognizerFactory {

    /**
     Returns an `AnyGestureRecognizerFactory` for `NSPanGestureRecognizer`
     - parameter buttonMask: bitfield of the button(s) required to recognize this click where bit 0 is the primary button, 1 is the secondary button, etc...
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func pan(
        buttonMask: Int = Defaults.buttonMask,
        configuration: ((NSPanGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) -> AnyGestureRecognizerFactory {
        let gesture = PanGestureRecognizerFactory(
            buttonMask: buttonMask,
            configuration: configuration
        )
        return AnyGestureRecognizerFactory(gesture)
    }
}

public extension Reactive where Base: NSView {

    /**
     Returns an observable `NSPanGestureRecognizer` events sequence
     - parameter buttonMask: bitfield of the button(s) required to recognize this click where bit 0 is the primary button, 1 is the secondary button, etc...
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func panGesture(
        buttonMask: Int = Defaults.buttonMask,
        configuration: ((NSPanGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) -> ControlEvent<NSPanGestureRecognizer> {

        return gesture(PanGestureRecognizerFactory(
            buttonMask: buttonMask,
            configuration: configuration
        ))
    }
}

public extension ObservableType where E: NSPanGestureRecognizer {

    /**
     Maps the observable `GestureRecognizer` events sequence to an observable sequence of translation values of the pan gesture in the coordinate system of the specified `view` alongside the gesture velocity.

     - parameter view: A `TargetView` value on which the gesture took place.
     */
    public func asTranslation(in view: TargetView = .view) -> Observable<(translation: NSPoint, velocity: NSPoint)> {
        return self.map { gesture in
            let view = view.targetView(for: gesture)
            return (
                gesture.translation(in: view),
                gesture.velocity(in: view)
            )
        }
    }
}
