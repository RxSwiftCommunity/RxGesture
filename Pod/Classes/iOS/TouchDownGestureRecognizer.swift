import UIKit.UIGestureRecognizerSubclass
import RxSwift
import RxCocoa
import RxGesture

public class TouchDownGestureRecognizer: UILongPressGestureRecognizer {

    public override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        minimumPressDuration = 0.0
    }

    var ignoreTouch: Bool = true
    @nonobjc var touches: Set<UITouch> = []

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        self.touches.formUnion(touches)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        self.touches.formUnion(touches)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        self.touches.subtract(touches)
    }

    public override  func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        self.touches.subtract(touches)
    }

    public override func reset() {
        super.reset()
        touches = []
    }

    public override func ignore(_ touch: UITouch, for event: UIEvent) {
        if !ignoreTouch {
            super.ignore(touch, for: event)
        }
    }

}

extension Factory where Gesture == GestureRecognizer {

    /**
     Returns an `AnyFactory` for `TouchDownGestureRecognizer`
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func touchDown(
        configuration: Configuration<TouchDownGestureRecognizer>? = nil
        ) -> AnyFactory {
        return make(configuration: configuration).abstracted()
    }
}

public extension Reactive where Base: View {

    /**
     Returns an observable `TouchDownGestureRecognizer` events sequence
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func touchDownGesture(
        configuration: Configuration<TouchDownGestureRecognizer>? = nil
        ) -> ControlEvent<TouchDownGestureRecognizer> {

        return gesture(make(configuration: configuration))
    }
}

public extension ObservableType where E: TouchDownGestureRecognizer {

    /**
     Maps the observable `GestureRecognizer` events sequence to an observable sequence of force values.
     */
    public func asTouches() -> Observable<Set<UITouch>> {
        return self.map { $0.touches }
    }
}
