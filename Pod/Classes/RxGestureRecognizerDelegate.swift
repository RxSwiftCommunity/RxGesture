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
            .init(policy: policy)
    }

    public static var always: GestureRecognizerDelegatePolicy<PolicyInput> {
        .init { _ in true }
    }

    public static var never: GestureRecognizerDelegatePolicy<PolicyInput> {
        .init { _ in false }
    }

    fileprivate func isPolicyPassing(with args: PolicyInput) -> Bool {
        policy(args)
    }
}

public final class RxGestureRecognizerDelegate: NSObject, GestureRecognizerDelegate {

    /// Corresponding delegate method: gestureRecognizerShouldBegin(:_)
    public var beginPolicy: GestureRecognizerDelegatePolicy<GestureRecognizer> = .always

    /// Corresponding delegate method: gestureRecognizer(_:shouldReceive:)
    public var touchReceptionPolicy: GestureRecognizerDelegatePolicy<(GestureRecognizer, Touch)> = .always

    /// Corresponding delegate method: gestureRecognizer(_:shouldBeRequiredToFailBy:)
    public var selfFailureRequirementPolicy: GestureRecognizerDelegatePolicy<(GestureRecognizer, GestureRecognizer)> = .never

    /// Corresponding delegate method: gestureRecognizer(_:shouldRequireFailureOf:)
    public var otherFailureRequirementPolicy: GestureRecognizerDelegatePolicy<(GestureRecognizer, GestureRecognizer)> = .never

    /// Corresponding delegate method: gestureRecognizer(_:shouldRecognizeSimultaneouslyWith:)
    public var simultaneousRecognitionPolicy: GestureRecognizerDelegatePolicy<(GestureRecognizer, GestureRecognizer)> = .always

    #if os(iOS)
    // Workaround because we can't have stored properties with @available annotation
    private var _pressReceptionPolicy: Any?

    /// Corresponding delegate method: gestureRecognizer(_:shouldReceive:)
    public var pressReceptionPolicy: GestureRecognizerDelegatePolicy<(GestureRecognizer, UIPress)> {
        get {
            if let policy = _pressReceptionPolicy as? GestureRecognizerDelegatePolicy<(GestureRecognizer, UIPress)> {
                return policy
            }
            return GestureRecognizerDelegatePolicy<(GestureRecognizer, UIPress)>.always
        }
        set {
            _pressReceptionPolicy = newValue
        }
    }
    #endif

    #if os(OSX)
    /// Corresponding delegate method: gestureRecognizer(_:shouldAttemptToRecognizeWith:)
    public var eventRecognitionAttemptPolicy: GestureRecognizerDelegatePolicy<(GestureRecognizer, NSEvent)> = .always
    #endif

    public func gestureRecognizerShouldBegin(
        _ gestureRecognizer: GestureRecognizer
    ) -> Bool {
        beginPolicy.isPolicyPassing(with: gestureRecognizer)
    }

    public func gestureRecognizer(
        _ gestureRecognizer: GestureRecognizer,
        shouldReceive touch: Touch
    ) -> Bool {
        touchReceptionPolicy.isPolicyPassing(
            with: (gestureRecognizer, touch)
        )
    }

    public func gestureRecognizer(
        _ gestureRecognizer: GestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: GestureRecognizer
    ) -> Bool {
        otherFailureRequirementPolicy.isPolicyPassing(
            with: (gestureRecognizer, otherGestureRecognizer)
        )
    }

    public func gestureRecognizer(
        _ gestureRecognizer: GestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: GestureRecognizer
    ) -> Bool {
        selfFailureRequirementPolicy.isPolicyPassing(
            with: (gestureRecognizer, otherGestureRecognizer)
        )
    }

    public func gestureRecognizer(
        _ gestureRecognizer: GestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: GestureRecognizer
    ) -> Bool {
        simultaneousRecognitionPolicy.isPolicyPassing(
            with: (gestureRecognizer, otherGestureRecognizer)
        )
    }

    #if os(iOS)

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive press: UIPress
    ) -> Bool {
        pressReceptionPolicy.isPolicyPassing(
            with: (gestureRecognizer, press)
        )
    }

    #endif

    #if os(OSX)

    public func gestureRecognizer(
        _ gestureRecognizer: NSGestureRecognizer,
        shouldAttemptToRecognizeWith event: NSEvent
    ) -> Bool {
        eventRecognitionAttemptPolicy.isPolicyPassing(
            with: (gestureRecognizer, event)
        )
    }

    #endif

}
