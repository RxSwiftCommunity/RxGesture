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

/// Default values for `NSPressGestureRecognizer` configuration
public enum NSPressGestureRecognizerDefaults {
    public static var buttonMask: Int = 0x1
    public static var minimumPressDuration: TimeInterval?
    public static var allowableMovement: CGFloat?
    public static var configuration: ((NSPressGestureRecognizer, RxGestureRecognizerDelegate) -> Void)?
}

fileprivate typealias Defaults = NSPressGestureRecognizerDefaults

/// A `GestureRecognizerFactory` for `NSPressGestureRecognizer`
public struct PressGestureRecognizerFactory: GestureRecognizerFactory {
    public typealias Gesture = NSPressGestureRecognizer
    public let configuration: (NSPressGestureRecognizer, RxGestureRecognizerDelegate) -> Void

    /**
     Initialiaze a `GestureRecognizerFactory` for `UILongPressGestureRecognizer`
     - parameter buttonMask: bitfield of the button(s) required to recognize this click where bit 0 is the primary button, 1 is the secondary button, etc...
     - parameter minimumPressDuration: Time in seconds the fingers must be held down for the gesture to be recognized
     - parameter allowableMovement: Maximum movement in pixels allowed before the gesture fails. Once recognized (after minimumPressDuration) there is no limit on finger movement for the remainder of the touch tracking
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public init(
        buttonMask: Int = Defaults.buttonMask,
        minimumPressDuration: TimeInterval? = Defaults.minimumPressDuration,
        allowableMovement: CGFloat? = Defaults.allowableMovement,
        configuration: ((NSPressGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) {
        self.configuration = { gestureRecognizer, delegate in
            gestureRecognizer.buttonMask = buttonMask
            minimumPressDuration.map {
                gestureRecognizer.minimumPressDuration = $0
            }
            allowableMovement.map {
                gestureRecognizer.allowableMovement = $0
            }
            configuration?(gestureRecognizer, delegate)
        }
    }
}

extension AnyGestureRecognizerFactory {

    /**
     Returns an `AnyGestureRecognizerFactory` for `UILongPressGestureRecognizer`
     - parameter buttonMask: bitfield of the button(s) required to recognize this click where bit 0 is the primary button, 1 is the secondary button, etc...
     - parameter minimumPressDuration: Time in seconds the fingers must be held down for the gesture to be recognized
     - parameter allowableMovement: Maximum movement in pixels allowed before the gesture fails. Once recognized (after minimumPressDuration) there is no limit on finger movement for the remainder of the touch tracking
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func press(
        buttonMask: Int = Defaults.buttonMask,
        minimumPressDuration: TimeInterval? = Defaults.minimumPressDuration,
        allowableMovement: CGFloat? = Defaults.allowableMovement,
        configuration: ((NSPressGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) -> AnyGestureRecognizerFactory {
        let gesture = PressGestureRecognizerFactory(
            buttonMask: buttonMask,
            minimumPressDuration: minimumPressDuration,
            allowableMovement: allowableMovement,
            configuration: configuration
        )
        return AnyGestureRecognizerFactory(gesture)
    }
}

public extension Reactive where Base: NSView {

    /**
     Returns an observable `UILongPressGestureRecognizer` events sequence
     - parameter buttonMask: bitfield of the button(s) required to recognize this click where bit 0 is the primary button, 1 is the secondary button, etc...
     - parameter minimumPressDuration: Time in seconds the fingers must be held down for the gesture to be recognized
     - parameter allowableMovement: Maximum movement in pixels allowed before the gesture fails. Once recognized (after minimumPressDuration) there is no limit on finger movement for the remainder of the touch tracking
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func pressGesture(
        buttonMask: Int = Defaults.buttonMask,
        minimumPressDuration: TimeInterval? = Defaults.minimumPressDuration,
        allowableMovement: CGFloat? = Defaults.allowableMovement,
        configuration: ((NSPressGestureRecognizer, RxGestureRecognizerDelegate) -> Void)? = Defaults.configuration
        ) -> ControlEvent<NSPressGestureRecognizer> {

        return gesture(PressGestureRecognizerFactory(
            buttonMask: buttonMask,
            minimumPressDuration: minimumPressDuration,
            allowableMovement: allowableMovement,
            configuration: configuration
        ))
    }
}
