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
    static var numberOfTouchesRequired: Int = 1
    static var numberOfTapsRequired: Int = 1
    static var configuration: ((UITapGestureRecognizer) -> Void)? = nil
}

public struct TapGestureFactory: ConfigurableGestureFactory {
    public typealias Gesture = UITapGestureRecognizer
    public let configuration: (UITapGestureRecognizer) -> Void

    public init(
        numberOfTouchesRequired: Int = Defaults.numberOfTouchesRequired,
        numberOfTapsRequired: Int = Defaults.numberOfTapsRequired,
        configuration: ((UITapGestureRecognizer) -> Void)? = Defaults.configuration
        ){
        self.configuration = { gesture in
            gesture.numberOfTouchesRequired = numberOfTouchesRequired
            gesture.numberOfTapsRequired = numberOfTapsRequired
            configuration?(gesture)
        }
    }
}

extension AnyGesture {

    public static func tap(
        numberOfTouchesRequired: Int = Defaults.numberOfTouchesRequired,
        numberOfTapsRequired: Int = Defaults.numberOfTapsRequired,
        configuration: ((UITapGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> AnyGesture {
        let gesture = TapGestureFactory(
            numberOfTouchesRequired: numberOfTouchesRequired,
            numberOfTapsRequired: numberOfTapsRequired,
            configuration: configuration
        )
        return AnyGesture(gesture)
    }
}

public extension Reactive where Base: UIView {

    public func tapGesture(
        numberOfTouchesRequired: Int = Defaults.numberOfTouchesRequired,
        numberOfTapsRequired: Int = Defaults.numberOfTapsRequired,
        configuration: ((UITapGestureRecognizer) -> Void)? = Defaults.configuration
        ) -> ControlEvent<UITapGestureRecognizer> {

        return gesture(TapGestureFactory(
            numberOfTouchesRequired: numberOfTouchesRequired,
            numberOfTapsRequired: numberOfTapsRequired,
            configuration: configuration
        ))
    }
}
