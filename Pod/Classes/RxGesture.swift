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

/// An enumeration to provide a list of valid gestures
public enum RxGestureTypeOption: Equatable {
    
    //: iOS gestures
    case Tap
    case SwipeLeft, SwipeRight, SwipeUp, SwipeDown
    case LongPress
    
    //: Shared gestures
    #if os(iOS)
    case Panning(CGPoint), DidPan(CGPoint)
    #elseif os(OSX)
    case Panning(NSPoint), DidPan(NSPoint)
    #endif
    
    //: OSX gestures
    case Click, RightClick
    
    public static func all() -> [RxGestureTypeOption] {
        return [
            /* iOS */ .Tap, .SwipeLeft, .SwipeRight, .SwipeUp, .SwipeDown, .LongPress, .Panning(.zero), .DidPan(.zero),
            /* OSX */ .Click, .RightClick
        ]
    }
}

public func ==(lhs: RxGestureTypeOption, rhs: RxGestureTypeOption) -> Bool {
    switch (lhs, rhs) {

    case (.Tap, .Tap): fallthrough
    case (.SwipeLeft, .SwipeLeft): fallthrough
    case (.SwipeRight, .SwipeRight): fallthrough
    case (.SwipeUp, .SwipeUp): fallthrough
    case (.SwipeDown, .SwipeDown): fallthrough
    case (.LongPress, .LongPress): fallthrough
    case (.Panning, .Panning): fallthrough
    case (.DidPan, .DidPan): fallthrough
        
    case (.Click, .Click): fallthrough
    case (.RightClick, .RightClick):
        
    return true
        
    default: return false
    }
}