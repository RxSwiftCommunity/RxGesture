import UIKit.UIGestureRecognizerSubclass
import RxSwift
import RxCocoa

@available(iOS 9.0, *)
public class ForceTouchGestureRecognizer: UIGestureRecognizer {

    public var numberOfTouchesRequired: Int = 1
    public var force: CGFloat = 0
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = .began
        setForce(for: touches)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        state = .changed
        setForce(for: touches)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        state = .ended
        setForce(for: touches)
    }

    private func setForce(for touches: Set<UITouch>) {
        guard touches.count == numberOfTouchesRequired, let touch = touches.first else {
            state = .failed
            return
        }
        force = Array(touches)[1...]
            .lazy
            .map { $0.force}
            .reduce(touch.force, +) / CGFloat(touches.count)
    }
}

@available(iOS 9.0, *)
extension Factory where Gesture == GestureRecognizer {

    /**
     Returns an `AnyFactory` for `ForceTouchGestureRecognizer`
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func forceTouch(
        configuration: Configuration<ForceTouchGestureRecognizer>? = nil
        ) -> AnyFactory {
        return make(configuration: configuration).abstracted()
    }
}

@available(iOS 9.0, *)
public extension Reactive where Base: View {

    /**
     Returns an observable `ForceTouchGestureRecognizer` events sequence
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func forceTouchGesture(
        configuration: Configuration<ForceTouchGestureRecognizer>? = nil
        ) -> ControlEvent<ForceTouchGestureRecognizer> {

        return gesture(make(configuration: configuration))
    }
}

@available(iOS 9.0, *)
public extension ObservableType where E: ForceTouchGestureRecognizer {

    /**
     Maps the observable `GestureRecognizer` events sequence to an observable sequence of force values.
     */
    public func asForce() -> Observable<CGFloat> {
        return self.map { $0.force }
    }
}
