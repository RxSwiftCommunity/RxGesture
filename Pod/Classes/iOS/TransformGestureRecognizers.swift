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

#if canImport(UIKit)

import UIKit
import RxSwift
import RxCocoa

public struct TransformGestureRecognizers {
    public let panGesture: UIPanGestureRecognizer
    public let rotationGesture: UIRotationGestureRecognizer
    public let pinchGesture: UIPinchGestureRecognizer
}

public struct TransformVelocity {
    let translation: CGPoint
    let rotation: CGFloat
    let scale: CGFloat
}

public typealias TransformControlEvent = ControlEvent<TransformGestureRecognizers>
public typealias TransformObservable = Observable<TransformGestureRecognizers>

extension Reactive where Base: RxGestureView {
    public func transformGestures(
		panConfiguration: PanConfiguration? = nil,
		rotationConfiguration: RotationConfiguration? = nil,
		pinchConfiguration: PinchConfiguration? = nil
	) -> TransformControlEvent {
        let source = Observable.combineLatest(panGesture(configuration: panConfiguration),
											  rotationGesture(configuration: rotationConfiguration),
											  pinchGesture(configuration: pinchConfiguration)) {
            TransformGestureRecognizers(
                panGesture: $0,
                rotationGesture: $1,
                pinchGesture: $2
            )
        }
        return ControlEvent(events: source)
    }
}

extension ObservableType where Element == TransformGestureRecognizers {

    public func when(_ states: RxGestureRecognizerState...) -> Observable<Element> {
        filter { gestures in
            states.contains(gestures.panGesture.state)
                || states.contains(gestures.rotationGesture.state)
                || states.contains(gestures.pinchGesture.state)
        }
    }

    public func asTransform(in view: TargetView = .view) -> Observable<(transform: CGAffineTransform, velocity: TransformVelocity)> {
        map { gestures in
            let translationView = view.targetView(for: gestures.panGesture)
            let translation = gestures.panGesture.translation(in: translationView)

            let transform = CGAffineTransform.identity
                .rotated(by: gestures.rotationGesture.rotation)
                .scaledBy(x: gestures.pinchGesture.scale, y: gestures.pinchGesture.scale)
                .translatedBy(x: translation.x, y: translation.y)

            let velocity = TransformVelocity(
                translation: gestures.panGesture.velocity(in: translationView),
                rotation: gestures.rotationGesture.velocity,
                scale: gestures.pinchGesture.velocity
            )

            return (transform, velocity)
        }
    }
}

#endif
