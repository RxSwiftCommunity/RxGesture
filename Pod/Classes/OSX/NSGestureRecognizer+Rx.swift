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

private class GestureTarget {
    
    private var retainedSelf: GestureTarget?
    
    init() {
        retainedSelf = self
    }

    func dispose() {
        retainedSelf = nil
    }
    
    @objc func controlEvent() {
        handler?()
    }
    
    var handler: (()->Void)?
}

//
// TODO: Make a PR to RxCocoa to add rx_event to NSGestureRecognizer and remove this file from this repo
//
extension NSGestureRecognizer {
    
    /**
     Reactive wrapper for gesture recognizer events.
     */
    public var rx_event: ControlEvent<NSGestureRecognizer> {
        let source: Observable<NSGestureRecognizer> = Observable.create { [weak self] observer in
            MainScheduler.ensureExecutingOnScheduler()
            
            guard let control = self else {
                observer.on(.Completed)
                return NopDisposable.instance
            }
            
            control.enabled = true
            
            let gestureTarget = GestureTarget()
            gestureTarget.handler = {
                observer.on(.Next(control))
            }
            
            self?.target = gestureTarget
            self?.action = #selector(GestureTarget.controlEvent)
            
            return AnonymousDisposable {
                if let recognizer = self, let view = recognizer.view {
                    view.removeGestureRecognizer(recognizer)
                }
                gestureTarget.dispose()
            }
        }.takeUntil(rx_deallocated)
        
        return ControlEvent(events: source)
    }
    
}
