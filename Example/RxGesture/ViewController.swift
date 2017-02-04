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
]

let codeList = [
    "myView.rx\n\t.tapGesture()\n\t.subscribeNext {...}",
    "myView.rx\n\t.tapGesture(numberOfTapsRequired: 2)\n\t.subscribeNext {...}",
    "myView.rx\n\t.swipeDownGesture()\n\t.subscribeNext {...}",
    "myView.rx\n\t.swipeGesture(direction: [.left, .right])\n\t.subscribeNext {",
    "myView.rx\n\t.longPressGesture()\n\t.subscribeNext {...}",
    "let panGesture = myView.rx\n\t.panGesture()\n\t.shareReplay(1)\n\npanGesture\n\t.filterState(in: [.changed])\n\t.subscribeNext {...}\n\npanGesture\n\t.filterState(in: [.ended])\n\t.subscribeNext {...}",
    "let rotationGesture = myView.rx\n\t.rotationGesture()\n\t.shareReplay(1)\n\nrotationGesture\n\t.filterState(in: [.changed])\n\t.subscribeNext {...}\n\nrotationGesture\n\t.filterState(in: [.ended])\n\t.subscribeNext {...}",
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
                return acc < 6 ? acc + 1 : 0
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

            myView.rx.tapGesture().subscribe(onNext: {[weak self] _ in
                guard let this = self else {return}
                UIView.animate(withDuration: 0.5, animations: {
                    this.myView.backgroundColor = UIColor.green
                    this.nextStep😁.onNext()
                })
            })
                .addDisposableTo(stepBag)

        case 1: //tap number of times recognizer
            myView.rx.tapGesture(numberOfTapsRequired: 2).subscribe(onNext: {[weak self] _ in
                guard let this = self else {return}
                UIView.animate(withDuration: 0.5, animations: {
                    this.myView.backgroundColor = UIColor.blue
                    this.nextStep😁.onNext()
                })
            })
                .addDisposableTo(stepBag)

        case 2: //swipe down
            myView.rx.swipeDownGesture().subscribe(onNext: {[weak self] _ in
                guard let this = self else {return}
                UIView.animate(withDuration: 0.5, animations: {
                    this.myView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
                    this.nextStep😁.onNext()
                })
            })
                .addDisposableTo(stepBag)

        case 3: //swipe horizontally
            myView.rx.swipeGesture(direction: [.left, .right]).subscribe(onNext: {[weak self] _ in
                guard let this = self else {return}
                UIView.animate(withDuration: 0.5, animations: {
                    this.myView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                    this.nextStep😁.onNext()
                })
            })
                .addDisposableTo(stepBag)

        case 4: //long press
            myView.rx.longPressGesture().subscribe(onNext: {[weak self] _ in
                guard let this = self else {return}
                UIView.animate(withDuration: 0.5, animations: {
                    this.myView.transform = CGAffineTransform.identity
                    this.nextStep😁.onNext()
                })
            })
                .addDisposableTo(stepBag)

        case 5: //panning
            let panGesture = myView.rx.panGesture().shareReplay(1)

            panGesture
                .filterState(in: [.changed])
                .translation()
                .subscribe(onNext: {[weak self] translation in
                    guard let this = self else {return}
                    this.myViewText.text = "(\(translation.x), \(translation.y))"
                    this.myView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
                })
                .addDisposableTo(stepBag)

            panGesture
                .filterState(in: [.ended])
                .subscribe(onNext: {[weak self] gesture in
                    guard let this = self else {return}
                    UIView.animate(withDuration: 0.5, animations: {
                        this.myViewText.text = nil
                        this.myView.transform = CGAffineTransform.identity
                        this.nextStep😁.onNext()
                    })
                })
                .addDisposableTo(stepBag)

        case 6: //rotating
            let rotationGesture = myView.rx.rotationGesture().shareReplay(1)

            rotationGesture
                .filterState(in: [.changed])
                .rotation
                .subscribe(onNext: {[weak self] rotation in
                    guard let this = self else {return}
                    this.myViewText.text = String(format: "angle: %.2f", rotation)
                    this.myView.transform = CGAffineTransform(rotationAngle: rotation)
                })
                .addDisposableTo(stepBag)

            rotationGesture
                .filterState(in: [.ended])
                .subscribe(onNext: {[weak self] gesture in
                    guard let this = self else {return}
                    UIView.animate(withDuration: 0.5, animations: {
                        this.myViewText.text = nil
                        this.myView.transform = CGAffineTransform.identity
                        this.nextStep😁.onNext()
                    })
                })
                .addDisposableTo(stepBag)

        default: break
        }
        
        print("active gestures: \(myView.gestureRecognizers!.count)")
    }
}
