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

let infoList = [
    "Tap the red square",
    "Double tap the green square",
    "Swipe the square down",
    "Swipe horizontally (e.g. left or right)",
    "Do a long press",
    "Drag the square to a different location",
    "Rotate the square",
    "Pinch the square",
]

let codeList = [
    "myView.rx\n\t.tapGesture()\n\t.filterState(.recognized)\n\t.subscribeNext {...}",
    "myView.rx\n\t.tapGesture(numberOfTapsRequired: 2)\n\t.filterState(.recognized)\n\t.subscribeNext {...}",
    "myView.rx\n\t.swipeDownGesture()\n\t.filterState(.recognized)\n\t.subscribeNext {...}",
    "myView.rx\n\t.swipeGesture(direction: [.left, .right])\n\t.filterState(.recognized)\n\t.subscribeNext {",
    "myView.rx\n\t.longPressGesture()\n\t.filterState(.began)\n\t.subscribeNext {...}",
    "let panGesture = myView.rx\n\t.panGesture()\n\t.shareReplay(1)\n\npanGesture\n\t.filterState(.changed)\n\t.translate()\n\t.subscribeNext {...}\n\npanGesture\n\t.filterState(.ended)\n\t.subscribeNext {...}",
    "let rotationGesture = myView.rx\n\t.rotationGesture()\n\t.shareReplay(1)\n\nrotationGesture\n\t.filterState(.changed)\n\t.rotation()\n\t.subscribeNext {...}\n\nrotationGesture\n\t.filterState(.ended)\n\t.subscribeNext {...}",
    "let pinchGesture = myView.rx\n\t.pinchGesture()\n\t.shareReplay(1)\n\npinchGesture\n\t.filterState(.changed)\n\t.scale()\n\t.subscribeNext {...}\n\npinchGesture\n\t.filterState(.ended)\n\t.subscribeNext {...}",
]

class ViewController: UIViewController {

    @IBOutlet var myView: UIView!
    @IBOutlet var myViewText: UILabel!
    @IBOutlet var info: UILabel!
    @IBOutlet var code: UITextView!

    private let nextStep😁 = PublishSubject<Void>()
    private let bag = DisposeBag()
    private var stepBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        nextStep😁
            .scan(0, accumulator: {acc, _ in
                return acc < infoList.count - 1 ? acc + 1 : 0
            })
            .startWith(0)
            .subscribe(onNext: step)
            .addDisposableTo(bag)
    }

    func step(step: Int) {
        //release previous recognizers
        stepBag = DisposeBag()

        info.text = "\(step+1). \(infoList[step])"
        code.text = codeList[step]

        //add current step recognizer
        switch step {
        case 0: //tap recognizer

            myView.rx
                .tapGesture()
                .filterState(.recognized)
                .subscribe(onNext: {[weak self] _ in
                    guard let this = self else {return}
                    UIView.animate(withDuration: 0.5, animations: {
                        this.myView.backgroundColor = .green
                        this.nextStep😁.onNext()
                    })
                })
                .addDisposableTo(stepBag)

        case 1: //tap number of times recognizer
            myView.rx
                .tapGesture(numberOfTapsRequired: 2)
                .filterState(.recognized)
                .subscribe(onNext: {[weak self] _ in
                    guard let this = self else {return}
                    UIView.animate(withDuration: 0.5, animations: {
                        this.myView.backgroundColor = .blue
                        this.nextStep😁.onNext()
                    })
                })
                .addDisposableTo(stepBag)

        case 2: //swipe down
            myView.rx
                .swipeDownGesture()
                .filterState(.recognized)
                .subscribe(onNext: {[weak self] _ in
                    guard let this = self else {return}
                    UIView.animate(withDuration: 0.5, animations: {
                        this.myView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
                        this.nextStep😁.onNext()
                    })
                })
                .addDisposableTo(stepBag)

        case 3: //swipe horizontally
            myView.rx
                .swipeGesture(direction: [.left, .right])
                .filterState(.recognized)
                .subscribe(onNext: {[weak self] _ in
                    guard let this = self else {return}
                    UIView.animate(withDuration: 0.5, animations: {
                        this.myView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                        this.nextStep😁.onNext()
                    })
                })
                .addDisposableTo(stepBag)

        case 4: //long press
            myView.rx
                .longPressGesture()
                .filterState(.began)
                .subscribe(onNext: {[weak self] _ in
                    guard let this = self else {return}
                    UIView.animate(withDuration: 0.5, animations: {
                        this.myView.transform = .identity
                        this.nextStep😁.onNext()
                    })
                })
                .addDisposableTo(stepBag)

        case 5: //panning
            let panGesture = myView.rx.panGesture().shareReplay(1)

            panGesture
                .filterState(.changed)
                .translation()
                .subscribe(onNext: {[weak self] translation, _ in
                    guard let this = self else {return}
                    this.myViewText.text = "(\(translation.x), \(translation.y))"
                    this.myView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
                })
                .addDisposableTo(stepBag)

            panGesture
                .filterState(.ended)
                .subscribe(onNext: {[weak self] gesture in
                    guard let this = self else {return}
                    UIView.animate(withDuration: 0.5, animations: {
                        this.myViewText.text = nil
                        this.myView.transform = .identity
                        this.nextStep😁.onNext()
                    })
                })
                .addDisposableTo(stepBag)

        case 6: //rotating
            let rotationGesture = myView.rx.rotationGesture().shareReplay(1)

            rotationGesture
                .filterState(.changed)
                .rotation()
                .subscribe(onNext: {[weak self] rotation, _ in
                    guard let this = self else {return}
                    this.myViewText.text = String(format: "angle: %.2f", rotation)
                    this.myView.transform = CGAffineTransform(rotationAngle: rotation)
                })
                .addDisposableTo(stepBag)

            rotationGesture
                .filterState(.ended)
                .subscribe(onNext: {[weak self] gesture in
                    guard let this = self else {return}
                    UIView.animate(withDuration: 0.5, animations: {
                        this.myViewText.text = nil
                        this.myView.transform = .identity
                        this.nextStep😁.onNext()
                    })
                })
                .addDisposableTo(stepBag)

        case 7: //pinching
            let pinchGesture = myView.rx.pinchGesture().shareReplay(1)

            pinchGesture
                .filterState(.changed)
                .scale()
                .subscribe(onNext: {[weak self] scale, _ in
                    guard let this = self else {return}
                    this.myViewText.text = String(format: "scale: %.2f", scale)
                    this.myView.transform = CGAffineTransform(scaleX: scale, y: scale)
                })
                .addDisposableTo(stepBag)

            pinchGesture
                .filterState(.ended)
                .subscribe(onNext: {[weak self] gesture in
                    guard let this = self else {return}
                    UIView.animate(withDuration: 0.5, animations: {
                        this.myViewText.text = nil
                        this.myView.transform = .identity
                        this.nextStep😁.onNext()
                    })
                })
                .addDisposableTo(stepBag)

        default: break
        }
        
        print("active gestures: \(myView.gestureRecognizers!.count)")
    }
}
