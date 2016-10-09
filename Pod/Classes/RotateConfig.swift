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

import Foundation

public struct RotateConfig {
    public enum State {
        case began, changed, ended, any
    }
    
    public let rotation: CGFloat
    
    public let state: State
    public var recognizer: AnyObject?
    
    public static let began: RotateConfig = {
        return RotateConfig(rotation: 0, state: .began, recognizer: nil)
    }()

    public static let changed: RotateConfig = {
        return RotateConfig(rotation: 0, state: .changed, recognizer: nil)
    }()

    public static let ended: RotateConfig = {
        return RotateConfig(rotation: 0, state: .ended, recognizer: nil)
    }()
    
    public static let any: RotateConfig = {
        return RotateConfig(rotation: 0, state: .any, recognizer: nil)
    }()
}
