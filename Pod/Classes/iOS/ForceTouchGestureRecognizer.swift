import UIKit.UIGestureRecognizerSubclass
import RxSwift
import RxCocoa

@available(iOS 9.0, *)
public class ForceTouchGestureRecognizer: UIGestureRecognizer {

    public override var state: UIGestureRecognizer.State {
        didSet {
//            Swift.print("State:", oldValue, "->", state)
        }
    }

    private var touch: UITouch?
    public var force: CGFloat {
        return touch?.force ?? 0
    }
    
    public var maximumPossibleForce: CGFloat {
        return touch?.maximumPossibleForce ?? 0
    }

    public var absoluteFractionCompleted: CGFloat {
        guard maximumPossibleForce > 0 else {
            return 0
        }
        return force / maximumPossibleForce
    }

    public var minimumFractionCompletedRequired: CGFloat = 0
    public var maximumFractionCompletedRequired: CGFloat = 1

    public var fractionCompleted: CGFloat {
        return lerp(
            mapMin: minimumFractionCompletedRequired, to: 0,
            mapMax: maximumFractionCompletedRequired, to: 1,
            value: absoluteFractionCompleted
        )
    }

    private func print(_ event: UIEvent, _ touches: Set<UITouch>, _ function: StaticString = #function) {
        return;

        Swift.print()
        Swift.print(function)
        Swift.print("\tevent.allTouches")
        for touch in event.allTouches ?? [] {
            Swift.print("\t\t\(touch.phase):", touch.location(in: self.view), touch.force, "(tapCount: \(touch.tapCount))")
        }
        Swift.print("\tevent.touches")
        for touch in touches {
            Swift.print("\t\t\(touch.phase):", touch.location(in: self.view), touch.force, "(tapCount: \(touch.tapCount))")
        }
        Swift.print()
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        print(event, touches)
        super.touchesBegan(touches, with: event)

        guard state == .possible else { return }
        guard touch == nil else { return }
        guard let first = touches.first(where: { $0.phase == .began }) else { return }
        touch = first
        state = .began
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        print(event, touches)
        super.touchesMoved(touches, with: event)
        guard let touch = touch, touches.contains(touch), touch.phase == .moved else { return }
        state = .changed
//        handle(event)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        print(event, touches)
        super.touchesEnded(touches, with: event)
        guard let touch = touch, touches.contains(touch), touch.phase == .ended else { return }
        self.touch = nil
        state = .ended
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        print(event, touches)
        super.touchesCancelled(touches, with: event)
        guard let touch = touch, touches.contains(touch), touch.phase == .cancelled else { return }
        self.touch = nil
        state = .cancelled
    }

//    private func handle(_ event: UIEvent) {
//        if setForce(for: event) {
//            if state == .possible {
//                state = .began
//            } else {
//                state = .changed
//            }
//        } else {
//            if state == .possible {
//                state = .cancelled
//            } else {
//                state = .ended
//            }
//        }
//    }
//
//    private let validPhases = [UITouch.Phase.began, .stationary, .moved]
//    private func setForce(for event: UIEvent) -> Bool {
//        let touches = Array(
//            event.allTouches?.filter { validPhases.contains($0.phase) } ?? []
//        )
//        guard
//            touches.count >= numberOfTouchesRequired,
//            let touch = touches.max(by: { $0.force < $1.force })
//        else {
//            self.force = 0
//            self.maximumPossibleForce = 0
//            return false
//        }
//
//        force = touch.force
//        maximumPossibleForce = touch.maximumPossibleForce
//
//        return true
//    }
}

@available(iOS 9.0, *)
public typealias ForceTouchConfiguration = Configuration<ForceTouchGestureRecognizer>
@available(iOS 9.0, *)
public typealias ForceTouchControlEvent = ControlEvent<ForceTouchGestureRecognizer>
@available(iOS 9.0, *)
public typealias ForceTouchObservable = Observable<ForceTouchGestureRecognizer>

@available(iOS 9.0, *)
extension Factory where Gesture == GestureRecognizer {

    /**
     Returns an `AnyFactory` for `ForceTouchGestureRecognizer`
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func forceTouch(configuration: ForceTouchConfiguration? = nil) -> AnyFactory {
        return make(configuration: configuration).abstracted()
    }
}

@available(iOS 9.0, *)
extension Reactive where Base: View {

    /**
     Returns an observable `ForceTouchGestureRecognizer` events sequence
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func forceTouchGesture(configuration: ForceTouchConfiguration? = nil) -> ForceTouchControlEvent {
        return gesture(make(configuration: configuration))
    }
}

@available(iOS 9.0, *)
extension ObservableType where Element: ForceTouchGestureRecognizer {

    /**
     Maps the observable `GestureRecognizer` events sequence to an observable sequence of force values.
     */
    public func asForce() -> Observable<CGFloat> {
        return self.map { $0.force }
    }

    public func when(fractionCompletedExceeds threshold: CGFloat) -> Observable<E> {
        let source = asObservable()
        return source
            .when(.began)
            .flatMapLatest { [unowned source] _ in
                return source
                    .when(.changed)
                    .filter {
                        if threshold == 0 {
                            return $0.fractionCompleted > threshold
                        } else {
                            return $0.fractionCompleted >= threshold
                        }
                    }
                    .take(1)
            }
    }
}

private func lerp<T : FloatingPoint>(_ v0: T, _ v1: T, _ t: T) -> T {
    return v0 + (v1 - v0) * t
}

private func lerp<T : FloatingPoint>(mapMin: T, to min: T, mapMax: T, to max: T, value: T) -> T {
    return  lerp(min, max, (value - mapMin) / (mapMax - mapMin))
}

extension UITouch.Phase : CustomStringConvertible {
    public var description: String {
        switch self {
        case .began:
            return ".began"
        case .moved:
            return ".moved"
        case .stationary:
            return ".stationary"
        case .ended:
            return ".ended"
        case .cancelled:
            return ".cancelled"
        }
    }
}
