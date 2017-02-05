//
//  ViewController.swift
//  RxGesture-OSX
//
//  Created by Marin Todorov on 3/24/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Cocoa

import RxSwift
import RxCocoa
import RxGesture

class MacViewController: NSViewController {

    let infoList = [
        "Click the square",
        "Double click the square",
        "Right click the square",
        "Click any button (left or right)",
        "Long press the square",
        "Drag the square around",
        "Rotate the square with your trackpad, or click if you do not have a trackpad",
        "Pinch the square with your trackpad, or click if you do not have a trackpad",
    ]

    let codeList = [
        "myView.rx\n\t.clickGesture()\n\t.filterState(.recognized)\n\t.subscribeNext {...}",
        "myView.rx\n\t.clickGesture(numberOfClicksRequired: 2)\n\t.filterState(.recognized)\n\t.subscribeNext {...}",
        "myView.rx\n\t.rightClickGesture()\n\t.filterState(.recognized)\n\t.subscribeNext {...}",
        "Observable\n\t.of(\n\t\tmyView.rx.clickGesture().filterState(.recognized),\n\t\tmyView.rx.rightClickGesture().filterState(.recognized)\n\t)\n\t.merge()\n\t.take(1)\n\t.subscribeNext {...}",
        "myView.rx\n\t.pressGesture()\n\t.filterState(.began)\n\t.subscribeNext {...}",
        "let panGesture = myView.rx\n\t.panGesture()\n\t.shareReplay(1)\n\npanGesture\n\t.filterState(.changed)\n\t.translate()\n\t.subscribeNext {...}\n\npanGesture\n\t.filterState(.ended)\n\t.subscribeNext {...}",
        "let rotationGesture = myView.rx\n\t.rotationGesture()\n\t.shareReplay(1)\n\nrotationGesture\n\t.filterState(.changed)\n\t.rotation()\n\t.subscribeNext {...}\n\nrotationGesture\n\t.filterState(.ended)\n\t.subscribeNext {...}",
        "let magnificationGesture = myView.rx\n\t.magnificationGesture()\n\t.shareReplay(1)\n\nmagnificationGesture\n\t.filterState(.changed)\n\t.scale()\n\t.subscribeNext {...}\n\nmagnificationGesture\n\t.filterState(.ended)\n\t.subscribeNext {...}",
        ]

    @IBOutlet weak var myView: NSView!
    @IBOutlet weak var myViewText: NSTextField!
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var code: NSTextView!

    fileprivate let nextStep😁 = PublishSubject<Void>()
    fileprivate let bag = DisposeBag()
    fileprivate var stepBag = DisposeBag()

    override func viewWillAppear() {
        super.viewWillAppear()

        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor

        myView.wantsLayer = true
        myView.layer?.backgroundColor = NSColor.red.cgColor
        myView.layer?.cornerRadius = 5

        nextStep😁
            .scan(0, accumulator: { [unowned self] acc, _ in
                return acc < self.codeList.count - 1 ? acc + 1 : 0
            })
            .startWith(0)
            .subscribe(onNext: step)
            .addDisposableTo(bag)
    }

    func step(_ step: Int) {
        //release previous recognizers
        stepBag = DisposeBag()

        info.stringValue = "\(step+1). \(infoList[step])"
        code.string = codeList[step]

        //add current step recognizer
        switch step {
        case 0: //left click recognizer
            myView.rx
                .clickGesture()
                .filterState(.recognized)
                .subscribe(onNext: {[weak self] _ in
                    guard let `self` = self else {return}

                    self.myView.layer!.backgroundColor = NSColor.green.cgColor

                    let anim = CABasicAnimation(keyPath: "backgroundColor")
                    anim.fromValue = NSColor.red.cgColor
                    anim.toValue = NSColor.green.cgColor
                    self.myView.layer!.add(anim, forKey: nil)

                    self.nextStep😁.onNext()
                })
                .addDisposableTo(stepBag)

        case 1: //double click recognizer
            myView.rx
                .clickGesture(numberOfClicksRequired: 2)
                .filterState(.recognized)
                .subscribe(onNext: {[weak self] _ in
                    guard let `self` = self else {return}

                    self.myView.layer!.backgroundColor = NSColor.blue.cgColor

                    let anim = CABasicAnimation(keyPath: "backgroundColor")
                    anim.fromValue = NSColor.green.cgColor
                    anim.toValue = NSColor.blue.cgColor
                    self.myView.layer!.add(anim, forKey: nil)

                    self.nextStep😁.onNext()
                })
                .addDisposableTo(stepBag)

        case 2: //right click recognizer
            myView.rx
                .rightClickGesture()
                .filterState(.recognized)
                .subscribe(onNext: {[weak self] _ in
                    guard let `self` = self else {return}

                    self.myView.layer!.transform = CATransform3DMakeScale(1.5, 1.5, 1.0)

                    let anim = CABasicAnimation(keyPath: "transform")
                    anim.duration = 0.5
                    anim.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
                    anim.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1.5, 1.5, 1.0))
                    self.myView.layer!.add(anim, forKey: nil)

                    self.nextStep😁.onNext()
                })
                .addDisposableTo(stepBag)

        case 3: //any button
            Observable
                .of(
                    myView.rx.clickGesture().filterState(.recognized),
                    myView.rx.rightClickGesture().filterState(.recognized)
                )
                .merge()
                .take(1)
                .subscribe(onNext: {[weak self] _ in
                    guard let `self` = self else {return}

                    self.myView.layer!.transform = CATransform3DMakeScale(2.0, 2.0, 1.0)
                    self.myView.layer!.backgroundColor = NSColor.red.cgColor

                    let anim = CABasicAnimation(keyPath: "transform")
                    anim.duration = 0.5
                    anim.fromValue = NSValue(caTransform3D: CATransform3DMakeScale(1.5, 1.5, 1.0))
                    anim.toValue = NSValue(caTransform3D: CATransform3DMakeScale(2.0, 2.0, 1.0))
                    self.myView.layer!.add(anim, forKey: nil)

                    self.nextStep😁.onNext()
                }).addDisposableTo(stepBag)

        case 4: //press recognizer
            myView.rx
                .pressGesture()
                .filterState(.began)
                .subscribe(onNext: {[weak self] _ in
                    guard let `self` = self else {return}

                    self.myView.layer!.transform = CATransform3DIdentity

                    let anim = CABasicAnimation(keyPath: "transform")
                    anim.duration = 0.5
                    anim.fromValue = NSValue(caTransform3D: CATransform3DMakeScale(2.0, 2.0, 1.0))
                    anim.toValue = NSValue(caTransform3D: CATransform3DIdentity)
                    self.myView.layer!.add(anim, forKey: nil)

                    self.nextStep😁.onNext()
                })
                .addDisposableTo(stepBag)

        case 5: //pan
            let panGesture = myView.rx.panGesture().shareReplay(1)

            panGesture
                .filterState(.changed)
                .translation()
                .subscribe(onNext: {[unowned self] translation, _ in
                    self.myViewText.stringValue = String(format: "(%.f, %.f)", arguments: [translation.x, translation.y])
                    self.myView.layer!.transform = CATransform3DMakeTranslation(translation.x, translation.y, 0.0)
                })
                .addDisposableTo(stepBag)

            Observable
                .of(
                    panGesture.filterState(.ended).map { $0 as NSGestureRecognizer },
                    myView.rx.clickGesture().filterState(.recognized).map { $0 as NSGestureRecognizer }
                )
                .merge()
                .take(1)
                .subscribe(onNext: {[unowned self] _ in
                    self.myViewText.stringValue = ""

                    let anim = CABasicAnimation(keyPath: "transform")
                    anim.duration = 0.5
                    anim.fromValue = NSValue(caTransform3D: self.myView.layer!.transform)
                    anim.toValue = NSValue(caTransform3D: CATransform3DIdentity)
                    self.myView.layer!.add(anim, forKey: nil)
                    self.myView.layer!.transform = CATransform3DIdentity

                    self.nextStep😁.onNext()
                })
                .addDisposableTo(stepBag)

        case 6: //rotate or click

            let rotationGesture = myView.rx.rotationGesture().shareReplay(1)

            rotationGesture
                .filterState(.changed)
                .rotation()
                .subscribe(onNext: {[unowned self] rotation in
                    self.myViewText.stringValue = String(format: "angle: %.2f", rotation)
                    self.myView.layer!.transform = CATransform3DMakeRotation(rotation, 0, 0, 1)
                })
                .addDisposableTo(stepBag)

            Observable
                .of(
                    rotationGesture.filterState(.ended).map { $0 as NSGestureRecognizer },
                    myView.rx.clickGesture().filterState(.recognized).map { $0 as NSGestureRecognizer }
                )
                .merge()
                .take(1)
                .subscribe(onNext: {[unowned self] _ in
                    self.myViewText.stringValue = ""

                    let anim = CABasicAnimation(keyPath: "transform")
                    anim.duration = 0.5
                    anim.fromValue = NSValue(caTransform3D: self.myView.layer!.transform)
                    anim.toValue = NSValue(caTransform3D: CATransform3DIdentity)
                    self.myView.layer!.add(anim, forKey: nil)
                    self.myView.layer!.transform = CATransform3DIdentity

                    self.nextStep😁.onNext()
                })
                .addDisposableTo(stepBag)

        case 7: //magnification or click

            let magnificationGesture = myView.rx.magnificationGesture().shareReplay(1)

            magnificationGesture
                .filterState(.changed)
                .scale()
                .subscribe(onNext: {[unowned self] scale in
                    self.myViewText.stringValue = String(format: "scale: %.2f", scale)
                    self.myView.layer!.transform = CATransform3DMakeScale(scale, scale, 1)
                })
                .addDisposableTo(stepBag)

            Observable
                .of(
                    magnificationGesture.filterState(.ended).map { $0 as NSGestureRecognizer },
                    myView.rx.clickGesture().filterState(.recognized).map { $0 as NSGestureRecognizer }
                )
                .merge()
                .take(1)
                .subscribe(onNext: {[unowned self] _ in
                    self.myViewText.stringValue = ""

                    let anim = CABasicAnimation(keyPath: "transform")
                    anim.duration = 0.5
                    anim.fromValue = NSValue(caTransform3D: self.myView.layer!.transform)
                    anim.toValue = NSValue(caTransform3D: CATransform3DIdentity)
                    self.myView.layer!.add(anim, forKey: nil)
                    self.myView.layer!.transform = CATransform3DIdentity
                    
                    self.nextStep😁.onNext()
                })
                .addDisposableTo(stepBag)
            
        default: break
        }
        
        print("active gestures: \(myView.gestureRecognizers.count)")
    }
    
}

