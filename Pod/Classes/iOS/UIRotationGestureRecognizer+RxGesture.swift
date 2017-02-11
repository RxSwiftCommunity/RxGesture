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

private enum Defaults {
    static var configuration: ((UIRotationGestureRecognizer) -> Void)? = nil
}

public struct RotationGestureFactory: ConfigurableGestureFactory {
    public typealias Gesture = UIRotationGestureRecognizer
    public let configuration: (UIRotationGestureRecognizer) -> Void

    public init(
        configuration: ((UIRotationGestureRecognizer) -> Void)? = Defaults.configuration
        ){
        self.configuration = { gesture in
            configuration?(gesture)
        }
    }
}

extension AnyGesture {

    public static func rotation(
        configuration: ((UIRotationGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> AnyGesture {
        let gesture = RotationGestureFactory(
            configuration: configuration
        )
        return AnyGesture(gesture)
    }
}

public extension Reactive where Base: UIView {

    public func rotationGesture(
        configuration: ((UIRotationGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> ControlEvent<UIRotationGestureRecognizer> {
        return gesture(RotationGestureFactory(
            configuration: configuration
        ))
    }
}

public extension ObservableType where E: UIRotationGestureRecognizer {
    public func rotation() -> Observable<(rotation: CGFloat, velocity: CGFloat)> {
        return self.map { gesture in
            return (gesture.rotation, gesture.velocity)
        }
    }
}
