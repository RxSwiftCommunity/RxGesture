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

private func make(mask: Int, configuration: Configuration<NSClickGestureRecognizer>?) -> Factory<NSClickGestureRecognizer> {
    return make {
        $0.buttonMask = mask
        configuration?($0, $1)
    }
}

extension Factory where Gesture == GestureRecognizer {

    /**
     Returns an `AnyFactory` for `NSClickGestureRecognizer`
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func click(
        configuration: Configuration<NSClickGestureRecognizer>? = nil
        ) -> AnyFactory {
        return make(mask: 0x1, configuration: configuration).abstracted()
    }

    /**
     Returns an `AnyFactory` for `NSClickGestureRecognizer`
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func rightClick(
        configuration: Configuration<NSClickGestureRecognizer>? = nil
        ) -> AnyFactory {
        return make(mask: 0x2, configuration: configuration).abstracted()
    }
}

public extension Reactive where Base: View {

    /**
     Returns an observable `NSClickGestureRecognizer` events sequence
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func clickGesture(
        configuration: Configuration<NSClickGestureRecognizer>? = nil
        ) -> ControlEvent<NSClickGestureRecognizer> {

        return gesture(make(mask: 0x1, configuration: configuration))
    }

    /**
     Returns an observable `NSClickGestureRecognizer` events sequence
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func rightClickGesture(
        configuration: Configuration<NSClickGestureRecognizer>? = nil
        ) -> ControlEvent<NSClickGestureRecognizer> {

        return gesture(make(mask: 0x2, configuration: configuration))
    }

}
