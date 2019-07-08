//
//  RxGestureTest.swift
//  RxGesture-iOS-Tests
//
//  Created by Anton Nazarov on 06/07/2019.
//  Copyright © 2019 RxSwiftCommunity. All rights reserved.
//

import XCTest
import RxSwift
import Foundation

class RxGestureTest: XCTestCase {
    private var startResourceCount: Int32 = 0

    override func setUp() {
        super.setUp()
        setUpActions()
    }

    override func tearDown() {
        super.tearDown()
        tearDownActions()
    }
}

// MARK: - Private
private extension RxGestureTest {
    func setUpActions(){
        _ = Hooks.defaultErrorHandler
        _ = Hooks.customCaptureSubscriptionCallstack
        self.startResourceCount = Resources.total
    }

    func tearDownActions() {
        for _ in 0..<30 {
            if self.startResourceCount < Resources.total {
                // main schedulers need to finish work
                print("Waiting for resource cleanup ...")
                let mode = RunLoop.Mode.default
                RunLoop.current.run(mode: mode, before: Date(timeIntervalSinceNow: 0.05))
            }
            else {
                break
            }
        }

        XCTAssertEqual(startResourceCount, Resources.total)
    }
}
