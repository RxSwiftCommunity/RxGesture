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

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif
import RxSwift
import RxCocoa

public struct GestureRecognizerDelegatePolicy<PolicyInput> {
    public typealias PolicyBody = (PolicyInput) -> Bool

    private let policy: PolicyBody
    private init(policy: @escaping PolicyBody) {
        self.policy = policy
    }

    public static func custom(_ policy: @escaping PolicyBody)
        -> GestureRecognizerDelegatePolicy<PolicyInput> {
            return .init(policy: policy)
    }

    public static var always: GestureRecognizerDelegatePolicy<PolicyInput> {
        return .init { _ in true }
    }

    public static var never: GestureRecognizerDelegatePolicy<PolicyInput> {
        return .init { _ in false }
    }

    public func isPolicyPassing(with args: PolicyInput) -> Bool {
        return policy(args)
    }

}

public func || <PolicyInput>(lhs: GestureRecognizerDelegatePolicy<PolicyInput>, rhs: GestureRecognizerDelegatePolicy<PolicyInput>) -> GestureRecognizerDelegatePolicy<PolicyInput>  {
    return .custom { input in
        lhs.isPolicyPassing(with: input) || rhs.isPolicyPassing(with: input)
    }
}

public func && <PolicyInput>(lhs: GestureRecognizerDelegatePolicy<PolicyInput>, rhs: GestureRecognizerDelegatePolicy<PolicyInput>) -> GestureRecognizerDelegatePolicy<PolicyInput>  {
    return .custom { input in
        lhs.isPolicyPassing(with: input) && rhs.isPolicyPassing(with: input)
    }
}

public final class GenericRxGestureRecognizerDelegate<Gesture: RxGestureRecognizer>: NSObject, RxGestureRecognizerDelegate {

    /// Corresponding delegate method: gestureRecognizerShouldBegin(:_)
    public var beginPolicy: GestureRecognizerDelegatePolicy<Gesture> = .always

    /// Corresponding delegate method: gestureRecognizer(_:shouldReceive:)
    public var touchReceptionPolicy: GestureRecognizerDelegatePolicy<(Gesture, RxGestureTouch)> = .always

    /// Corresponding delegate method: gestureRecognizer(_:shouldBeRequiredToFailBy:)
    public var selfFailureRequirementPolicy: GestureRecognizerDelegatePolicy<(Gesture, RxGestureRecognizer)> = .never

    /// Corresponding delegate method: gestureRecognizer(_:shouldRequireFailureOf:)
    public var otherFailureRequirementPolicy: GestureRecognizerDelegatePolicy<(Gesture, RxGestureRecognizer)> = .never

    /// Corresponding delegate method: gestureRecognizer(_:shouldRecognizeSimultaneouslyWith:)
    public var simultaneousRecognitionPolicy: GestureRecognizerDelegatePolicy<(Gesture, RxGestureRecognizer)> = .always

    #if os(iOS)
    // Workaround because we can't have stored properties with @available annotation
    private var _pressReceptionPolicy: Any?

    @available(iOS 9.0, *)
    /// Corresponding delegate method: gestureRecognizer(_:shouldReceive:)
    public var pressReceptionPolicy: GestureRecognizerDelegatePolicy<(Gesture, UIPress)> {
        get {
            if let policy = _pressReceptionPolicy as? GestureRecognizerDelegatePolicy<(Gesture, UIPress)> {
                return policy
            }
            return GestureRecognizerDelegatePolicy<(Gesture, UIPress)>.always
        }
        set {
            _pressReceptionPolicy = newValue
        }
    }
    #endif

    #if os(OSX)
    /// Corresponding delegate method: gestureRecognizer(_:shouldAttemptToRecognizeWith:)
    public var eventRecognitionAttemptPolicy: GestureRecognizerDelegatePolicy<(Gesture, NSEvent)> = .always
    #endif

    public func gestureRecognizerShouldBegin(
        _ gestureRecognizer: RxGestureRecognizer
        ) -> Bool {
        return beginPolicy.isPolicyPassing(with: gestureRecognizer as! Gesture)
    }

    public func gestureRecognizer(
        _ gestureRecognizer: RxGestureRecognizer,
        shouldReceive touch: RxGestureTouch
        ) -> Bool {
        return touchReceptionPolicy.isPolicyPassing(
            with: (gestureRecognizer as! Gesture, touch)
        )
    }

    public func gestureRecognizer(
        _ gestureRecognizer: RxGestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: RxGestureRecognizer
        ) -> Bool {
        return otherFailureRequirementPolicy.isPolicyPassing(
            with: (gestureRecognizer as! Gesture, otherGestureRecognizer)
        )
    }

    public func gestureRecognizer(
        _ gestureRecognizer: RxGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: RxGestureRecognizer
        ) -> Bool {
        return selfFailureRequirementPolicy.isPolicyPassing(
            with: (gestureRecognizer as! Gesture, otherGestureRecognizer)
        )
    }

    public func gestureRecognizer(
        _ gestureRecognizer: RxGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: RxGestureRecognizer
        ) -> Bool {
        return simultaneousRecognitionPolicy.isPolicyPassing(
            with: (gestureRecognizer as! Gesture, otherGestureRecognizer)
        )
    }

    #if os(iOS)

    @available(iOS 9.0, *)
    public func gestureRecognizer(
        _ gestureRecognizer: RxGestureRecognizer,
        shouldReceive press: UIPress
        ) -> Bool {
        return pressReceptionPolicy.isPolicyPassing(
            with: (gestureRecognizer as! Gesture, press)
        )
    }

    #endif

    #if os(OSX)

    public func gestureRecognizer(
        _ gestureRecognizer: RxGestureRecognizer,
        shouldAttemptToRecognizeWith event: NSEvent
        ) -> Bool {
        return eventRecognitionAttemptPolicy.isPolicyPassing(
            with: (gestureRecognizer as! Gesture, event)
        )
    }

    #endif

}
