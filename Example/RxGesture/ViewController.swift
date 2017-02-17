//
//  ViewController.swift
//  RxGesture
//
//  Created by Marin Todorov on 03/22/2016.
//  Copyright (c) 2016 Marin Todorov. All rights reserved.
//

import UIKit

import RxSwift
import RxGesture

class Step {
    enum Action { case previous, next }

    let title: String
    let code: String
    let install: (UIView, UILabel, AnyObserver<Action>, DisposeBag) -> Void

    init(title: String, code: String, install: @escaping (UIView, UILabel, AnyObserver<Action>, DisposeBag) -> Void) {
        self.title = title
        self.code = code
        self.install = install
    }
}

class ViewController: UIViewController {

    @IBOutlet var myView: UIView!
    @IBOutlet var myViewText: UILabel!
    @IBOutlet var info: UILabel!
    @IBOutlet var code: UITextView!

    private let nextStepObserver = PublishSubject<Step.Action>()
    private let bag = DisposeBag()
    private var stepBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let steps: [Step] = [
            tapStep,
            doubleTapStep,
            swipeDownStep,
            swipeHorizontallyStep,
            longPressStep,
            panStep,
            pinchStep,
            rotateStep,
            transformStep
        ]

        func newIndex(for index: Int, action: Step.Action) -> Int {
            switch action {
            case .previous:
                return index > 0 ? index - 1 : steps.count - 1
            case .next:
                return index < steps.count - 1 ? index + 1 : 0
            }
        }

        nextStepObserver
            .scan(0, accumulator: newIndex)
            .startWith(0)
            .map { (steps[$0], $0) }
            .subscribe(onNext: updateStep)
            .addDisposableTo(bag)
    }

    @IBAction func previousStep(_ sender: Any) {
        nextStepObserver.onNext(.previous)
    }

    func updateStep(_ step: Step, at index: Int) {
        stepBag = DisposeBag()

        info.text = "\(index + 1). " + step.title
        code.text = step.code

        myViewText.text = nil
        step.install(myView, myViewText, nextStepObserver.asObserver(), stepBag)

        print("active gestures: \(myView.gestureRecognizers?.count ?? 0)")
    }

    lazy var tapStep: Step = Step(
        title: "Tap the red square",
        code: "view.rx\n\t.tapGesture()\n\t.when(.recognized)\n\t.subscribe(onNext: {...})",
        install: { view, _, nextStep, stepBag in

            view.animateTransform(to: .identity)
            view.animateBackgroundColor(to: .red)

            view.rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { _ in
                    nextStep.onNext(.next)
                })
                .addDisposableTo(stepBag)
    })

    lazy var doubleTapStep: Step = Step(
        title: "Double tap the green square",
        code: "view.rx\n\t.tapGesture(numberOfTapsRequired: 2)\n\t.when(.recognized)\n\t.subscribe(onNext: {...})",
        install: { view, _, nextStep, stepBag in

            view.animateTransform(to: .identity)
            view.animateBackgroundColor(to: .green)

            view.rx
                .tapGesture(numberOfTapsRequired: 2)
                .when(.recognized)
                .subscribe(onNext: { _ in
                    nextStep.onNext(.next)
                })
                .addDisposableTo(stepBag)
    })

    lazy var swipeDownStep: Step = Step(
        title: "Swipe the blue square down",
        code: "view.rx\n\t.swipeGesture(.down)\n\t.when(.recognized)\n\t.subscribe(onNext: {...})",
        install: { view, _, nextStep, stepBag in

            view.animateTransform(to: .identity)
            view.animateBackgroundColor(to: .blue)

            view.rx
                .swipeGesture(.down)
                .when(.recognized)
                .subscribe(onNext: { _ in
                    nextStep.onNext(.next)
                })
                .addDisposableTo(stepBag)
    })

    lazy var swipeHorizontallyStep: Step = Step(
        title: "Swipe horizontally the blue square (e.g. left or right)",
        code: "view.rx\n\t.swipeGesture([.left, .right])\n\t.when(.recognized)\n\t.subscribeNext {",
        install: { view, _, nextStep, stepBag in

            view.animateTransform(to: CGAffineTransform(scaleX: 1.0, y: 2.0))
            view.animateBackgroundColor(to: .blue)

            view.rx
                .swipeGesture([.left, .right])
                .when(.recognized)
                .subscribe(onNext: { _ in
                    nextStep.onNext(.next)
                })
                .addDisposableTo(stepBag)
    })

    lazy var longPressStep: Step = Step(
        title: "Do a long press",
        code: "view.rx\n\t.longPressGesture()\n\t.when(.began)\n\t.subscribe(onNext: {...})",
        install: { view, _, nextStep, stepBag in

            view.animateTransform(to: CGAffineTransform(scaleX: 2.0, y: 2.0))
            view.animateBackgroundColor(to: .blue)

            view.rx
                .longPressGesture()
                .when(.began)
                .subscribe(onNext: { _ in
                    nextStep.onNext(.next)
                })
                .addDisposableTo(stepBag)
    })

    lazy var panStep: Step = Step(
        title: "Drag the square to a different location",
        code: "let panGesture = view.rx\n\t.panGesture()\n\t.shareReplay(1)\n\npanGesture\n\t.when(.changed)\n\t.asTranslation()\n\t.subscribe(onNext: {...})\n\npanGesture\n\t.when(.ended)\n\t.subscribe(onNext: {...})",
        install: { view, label, nextStep, stepBag in

            view.animateTransform(to: .identity)
            view.animateBackgroundColor(to: .blue)

            let panGesture = view.rx.panGesture().shareReplay(1)

            panGesture
                .when(.changed)
                .asTranslation()
                .subscribe(onNext: { [unowned self] translation, _ in
                    label.text = String(format: "(%.2f, %.2f)",translation.x, translation.y)
                    view.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
                })
                .addDisposableTo(stepBag)

            panGesture
                .when(.ended)
                .subscribe(onNext: { _ in
                    nextStep.onNext(.next)
                })
               .addDisposableTo(stepBag)
    })

    lazy var rotateStep: Step = Step(
        title: "Rotate the square",
        code: "let rotationGesture = view.rx\n\t.rotationGesture()\n\t.shareReplay(1)\n\nrotationGesture\n\t.when(.changed)\n\t.asRotation()\n\t.subscribe(onNext: {...})\n\nrotationGesture\n\t.when(.ended)\n\t.subscribe(onNext: {...})",
        install: { view, label, nextStep, stepBag in

            view.animateTransform(to: .identity)
            view.animateBackgroundColor(to: .blue)

            let rotationGesture = view.rx.rotationGesture().shareReplay(1)

            rotationGesture
                .when(.changed)
                .asRotation()
                .subscribe(onNext: { [unowned self] rotation, _ in
                    label.text = String(format: "%.2f rad", rotation)
                    view.transform = CGAffineTransform(rotationAngle: rotation)
                })
                .addDisposableTo(stepBag)

            rotationGesture
                .when(.ended)
                .subscribe(onNext: { _ in
                    nextStep.onNext(.next)
                })
                .addDisposableTo(stepBag)
    })

    lazy var pinchStep: Step = Step(
        title: "Pinch the square",
        code: "let pinchGesture = view.rx\n\t.pinchGesture()\n\t.shareReplay(1)\n\npinchGesture\n\t.when(.changed)\n\t.asScale()\n\t.subscribe(onNext: {...})\n\npinchGesture\n\t.when(.ended)\n\t.subscribe(onNext: {...})",
        install: { view, label, nextStep, stepBag in

            view.animateTransform(to: .identity)
            view.animateBackgroundColor(to: .blue)

            let pinchGesture = view.rx.pinchGesture().shareReplay(1)

            pinchGesture
                .when(.changed)
                .asScale()
                .subscribe(onNext: { scale, _ in
                    label.text = String(format: "x%.2f", scale)
                    view.transform = CGAffineTransform(scaleX: scale, y: scale)
                })
                .addDisposableTo(stepBag)

            pinchGesture
                .when(.ended)
                .subscribe(onNext: { _ in
                    nextStep.onNext(.next)
                })
                .addDisposableTo(stepBag)
    })

    lazy var transformStep: Step = Step(
        title: "Transform the square",
        code: "let transformGestures = view.rx\n\t.transformGestures()\n\t.shareReplay(1)\n\ntransformGestures\n\t.when(.changed)\n\t.asTransform()\n\t.subscribe(onNext: {...})\n\ntransformGestures\n\t.when(.ended)\n\t.subscribe(onNext: {...})",
        install: { view, label, nextStep, stepBag in

            view.animateTransform(to: .identity)
            view.animateBackgroundColor(to: .blue)

            let transformGestures = view.rx.transformGestures().shareReplay(1)

            transformGestures
                .when(.changed)
                .asTransform()
                .subscribe(onNext: { transform, _ in
                    label.numberOfLines = 3
                    label.text = String(format: "[%.2f, %.2f,\n%.2f, %.2f,\n%.2f, %.2f]", transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty)
                    view.transform = transform
                })
                .addDisposableTo(stepBag)

            transformGestures
                .when(.ended)
                .subscribe(onNext: { _ in
                    label.numberOfLines = 1
                    nextStep.onNext(.next)
                })
                .addDisposableTo(stepBag)
    })
}

private extension UIView {

    func animateTransform(to transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.5) {
            self.transform = transform
        }
    }

    func animateBackgroundColor(to color: UIColor) {
        UIView.animate(withDuration: 0.5) {
            self.backgroundColor = color
        }
    }
}
