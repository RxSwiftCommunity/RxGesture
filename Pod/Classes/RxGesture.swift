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

/// An OptionSetType to provide a list of valid gestures
public struct RxGestureTypeOptions : OptionSetType, Hashable {
    
    private let raw: UInt
    
    public init(rawValue: UInt) {
        raw = rawValue
    }
    public var rawValue: UInt {
        return raw
    }
    
    public var hashValue: Int { return Int(rawValue) }

    public static var None = RxGestureTypeOptions(rawValue: 0)

    //: iOS gestures
    public static var Tap  = RxGestureTypeOptions(rawValue: 1 << 0)
    public static var SwipeLeft  = RxGestureTypeOptions(rawValue: 1 << 1)
    public static var SwipeRight = RxGestureTypeOptions(rawValue: 1 << 2)
    public static var SwipeUp    = RxGestureTypeOptions(rawValue: 1 << 3)
    public static var SwipeDown  = RxGestureTypeOptions(rawValue: 1 << 4)
    
    public static var LongPress  = RxGestureTypeOptions(rawValue: 1 << 5)
    
    public static var Rotate   = RxGestureTypeOptions(rawValue: 1 << 6)
    
    //: OSX gestures
    public static var Click  = RxGestureTypeOptions(rawValue: 1 << 10)
    public static var RightClick  = RxGestureTypeOptions(rawValue: 1 << 11)

    //: all gestures
    public static func all() -> RxGestureTypeOptions {
        return [
            /* iOS */ .Tap, .SwipeLeft, .SwipeRight, .SwipeUp, .SwipeDown, .LongPress, .Rotate,
            /* OSX */ .Click, .RightClick
        ]
    }
    
}