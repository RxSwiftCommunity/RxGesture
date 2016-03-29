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

public struct PanConfig {
    public enum Type {
        case Began, Changed, Ended, Any
    }
    
    #if os(iOS)
    public let translation: CGPoint
    public let velocity: CGPoint
    #elseif os(OSX)
    public let translation: NSPoint
    public let velocity: NSPoint
    #endif
    
    public let type: Type
    public var recognizer: AnyObject?
    
    public static let Began: PanConfig = {
        return PanConfig(translation: .zero, velocity: .zero, type: .Began, recognizer: nil)
    }()

    public static let Changed: PanConfig = {
        return PanConfig(translation: .zero, velocity: .zero, type: .Changed, recognizer: nil)
    }()

    public static let Ended: PanConfig = {
        return PanConfig(translation: .zero, velocity: .zero, type: .Ended, recognizer: nil)
    }()
    
    public static let Any: PanConfig = {
        return PanConfig(translation: .zero, velocity: .zero, type: .Any, recognizer: nil)
    }()
}
