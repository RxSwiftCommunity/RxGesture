#if canImport(UIKit)

import UIKit.UIGestureRecognizerSubclass
import RxSwift
import RxCocoa

public class TouchDownGestureRecognizer: UIGestureRecognizer {

    public override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)

        trigger
            .flatMapFirst { [unowned self] _ -> Observable<Void> in
                let trigger = Observable.just(())
                guard self.state == .possible else {
                    return trigger
                }
                return trigger.delay(
                    .milliseconds(Int(self.minimumTouchDuration * 1000)),
                    scheduler: MainScheduler.instance
                )
            }
            .subscribe(onNext: { [unowned self] _ in
                self.touches = self._touches
            })
            .disposed(by: triggerDisposeBag)
    }

    public var minimumTouchDuration: TimeInterval = 0

    /**
     When set to `false`, it allows to bypass the touch ignoring mechanism in order to get absolutely all touch down events.
     Defaults to `true`.
     - note: See [ignore(_ touch: UITouch, for event: UIEvent)](https://developer.apple.com/documentation/uikit/uigesturerecognizer/1620010-ignore)
     */
    public var isTouchIgnoringEnabled: Bool = true

    @nonobjc public var touches: Set<UITouch> = [] {
        didSet {
            if touches.isEmpty {
                if state == .possible {
                    state = .cancelled
                } else {
                    state = .ended
                }
            } else {
                if state == .possible {
                    state = .began
                } else {
                    state = .changed
                }
            }
        }
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        setTouches(from: event)
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        setTouches(from: event)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        setTouches(from: event)
    }

    public override  func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        setTouches(from: event)
    }

    private let triggerDisposeBag = DisposeBag()
    private let trigger = PublishSubject<Void>()
    private var _touches: Set<UITouch> = []
    private func setTouches(from event: UIEvent) {
        _touches = (event.allTouches ?? []).filter { touch in
            [.began, .stationary, .moved].contains(touch.phase)
        }
        trigger.onNext(())
    }

    public override func reset() {
        super.reset()
        touches = []
    }

    public override func ignore(_ touch: UITouch, for event: UIEvent) {
        guard isTouchIgnoringEnabled else {
            return
        }
        super.ignore(touch, for: event)
    }

}

public typealias TouchDownConfiguration = Configuration<TouchDownGestureRecognizer>
public typealias TouchDownControlEvent = ControlEvent<TouchDownGestureRecognizer>
public typealias TouchDownObservable = Observable<TouchDownGestureRecognizer>

extension Factory where Gesture == RxGestureRecognizer {

    /**
     Returns an `AnyFactory` for `TouchDownGestureRecognizer`
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func touchDown(configuration: TouchDownConfiguration? = nil) -> AnyFactory {
        make(configuration: configuration).abstracted()
    }
}

extension Reactive where Base: RxGestureView {

    /**
     Returns an observable `TouchDownGestureRecognizer` events sequence
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func touchDownGesture(configuration: TouchDownConfiguration? = nil) -> TouchDownControlEvent {
        gesture(make(configuration: configuration))
    }
}

extension ObservableType where Element: TouchDownGestureRecognizer {

    /**
     Maps the observable `GestureRecognizer` events sequence to an observable sequence of force values.
     */
    public func asTouches() -> Observable<Set<UITouch>> {
        self.map { $0.touches }
    }
}

#endif
