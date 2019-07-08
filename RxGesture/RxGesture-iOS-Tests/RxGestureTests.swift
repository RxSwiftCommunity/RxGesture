//
//  Utilities.swift
//  RxGesture-iOS-Tests
//
//  Created by Jérôme Alves on 05/11/2017.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation
import XCTest 
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
import SceneKit
@testable import RxGesture

class RxGestureTests: RxGestureTest {

    var disposeBag: DisposeBag!
    var view: UIView!
    var gesture: UIGestureRecognizer!

    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        view = UIView()
        gesture = UIGestureRecognizer()
    }

    override func tearDown() {
        disposeBag = nil
        view = nil
        gesture = nil
        super.tearDown()
    }

    func testObservable() {

        let states: [UIGestureRecognizer.State] = [.began, .changed, .changed, .changed, .ended]

        send(states)

        let expected = [.possible] + states

        let result = try? view.rx.gesture(gesture)
            .map { $0.state }
            .take(expected.count)
            .toBlocking(timeout: 1)
            .toArray()

        XCTAssertEqual(result ?? [], expected)
    }

    func send(_ states: [UIGestureRecognizer.State]) {
        guard let first = states.first else {
            return
        }
        DispatchQueue.main.async {
            self.gesture.state = first
            self.send(Array(states[1...]))
        }
    }

    func testMemoryLeak() {
        _ = TestViewController()
    }
}

// MARK: - Private
private extension RxGestureTest {
    final class TestViewController {
        private let scnView = SCNView()
        private let disposeBag = DisposeBag()

        init() {
            scnView.rx.tapGesture().when(.recognized).subscribe().disposed(by: disposeBag)
        }
    }
}
