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

/// Default values for `NSClickGestureRecognizer` configuration
private enum Defaults {
    static var buttonMask: Int = 0x1
    static var numberOfClicksRequired: Int = 1
    static var configuration: ((NSClickGestureRecognizer) -> Void)? = nil
}

/// A `GestureRecognizerFactory` for `NSClickGestureRecognizer`
public struct ClickGestureRecognizerFactory: GestureRecognizerFactory {
    public typealias Gesture = NSClickGestureRecognizer
    public let configuration: (NSClickGestureRecognizer) -> Void

    /**
     Initialiaze a `GestureRecognizerFactory` for `NSClickGestureRecognizer`
     - parameter buttonMask: bitfield of the button(s) required to recognize this click where bit 0 is the primary button, 1 is the secondary button, etc...
     - parameter numberOfClicksRequired: The number of clicks required to match
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public init(
        buttonMask: Int = Defaults.buttonMask,
        numberOfClicksRequired: Int = Defaults.numberOfClicksRequired,
        configuration: ((NSClickGestureRecognizer) -> Void)? = Defaults.configuration
        ){
        self.configuration = { gestureRecognizer in
            gestureRecognizer.buttonMask = buttonMask
            gestureRecognizer.numberOfClicksRequired = numberOfClicksRequired
            configuration?(gestureRecognizer)
        }
    }
}

extension AnyGestureRecognizerFactory {

    /**
     Returns an `AnyGestureRecognizerFactory` for `NSClickGestureRecognizer`
     - parameter buttonMask: bitfield of the button(s) required to recognize this click where bit 0 is the primary button, 1 is the secondary button, etc...
     - parameter numberOfClicksRequired: The number of clicks required to match
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func click(
        buttonMask: Int = Defaults.buttonMask,
        numberOfClicksRequired: Int = Defaults.numberOfClicksRequired,
        configuration: ((NSClickGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> AnyGestureRecognizerFactory {
        let gesture = ClickGestureRecognizerFactory(
            buttonMask: buttonMask,
            numberOfClicksRequired: numberOfClicksRequired,
            configuration: configuration
        )
        return AnyGestureRecognizerFactory(gesture)
    }

    /**
     Returns an `AnyGestureRecognizerFactory` for `NSClickGestureRecognizer` configured to match a right click
     - parameter numberOfClicksRequired: The number of clicks required to match
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func rightClick(
        numberOfClicksRequired: Int = Defaults.numberOfClicksRequired,
        configuration: ((NSClickGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> AnyGestureRecognizerFactory {
        let gesture = ClickGestureRecognizerFactory(
            buttonMask: 0x2,
            numberOfClicksRequired: numberOfClicksRequired,
            configuration: configuration
        )
        return AnyGestureRecognizerFactory(gesture)
    }

}

public extension Reactive where Base: NSView {

    /**
     Returns an observable `NSClickGestureRecognizer` events sequence
     - parameter buttonMask: bitfield of the button(s) required to recognize this click where bit 0 is the primary button, 1 is the secondary button, etc...
     - parameter numberOfClicksRequired: The number of clicks required to match
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func clickGesture(
        buttonMask: Int = Defaults.buttonMask,
        numberOfClicksRequired: Int = Defaults.numberOfClicksRequired,
        configuration: ((NSClickGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> ControlEvent<NSClickGestureRecognizer> {

        return gesture(ClickGestureRecognizerFactory(
            buttonMask: buttonMask,
            numberOfClicksRequired: numberOfClicksRequired,
            configuration: configuration
        ))
    }

    /**
     Returns an observable `NSClickGestureRecognizer` events sequence, configured to match a right click
     - parameter numberOfClicksRequired: The number of clicks required to match
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func rightClickGesture(
        numberOfClicksRequired: Int = 1,
        configuration: ((NSClickGestureRecognizer) -> Void)? = nil
        ) -> ControlEvent<NSClickGestureRecognizer> {

        return gesture(ClickGestureRecognizerFactory(
            buttonMask: 0x2,
            numberOfClicksRequired: numberOfClicksRequired,
            configuration: configuration
        ))
    }
}
