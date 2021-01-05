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
#if canImport(ObjectiveC)
import RxSwift
import RxCocoa
import ObjectiveC

public typealias Configuration<Gesture: RxGestureRecognizer> = (Gesture, GenericRxGestureRecognizerDelegate<Gesture>) -> Void

public struct Factory<Gesture: RxGestureRecognizer> {
    public let gesture: Gesture
    public init(_ configuration: Configuration<Gesture>?) {
        let gesture = Gesture()
        let delegate = GenericRxGestureRecognizerDelegate<Gesture>()
        objc_setAssociatedObject(
            gesture,
            &gestureRecognizerStrongDelegateKey,
            delegate,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        gesture.delegate = delegate
        configuration?(gesture, delegate)
        self.gesture = gesture
    }

    internal func abstracted() -> AnyFactory {
        AnyFactory(self.gesture)
    }
}

internal func make<G>(configuration: Configuration<G>? = nil) -> Factory<G> {
    Factory<G>(configuration)
}

public typealias AnyFactory = Factory<RxGestureRecognizer>
extension Factory where Gesture == RxGestureRecognizer {
    private init<G: RxGestureRecognizer>(_ gesture: G) {
        self.gesture = gesture
    }
}

private var gestureRecognizerStrongDelegateKey: UInt8 = 0
#endif
