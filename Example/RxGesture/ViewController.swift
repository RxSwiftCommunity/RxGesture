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
    "Swipe the square down",
    "Swipe horizontally (e.g. left or right)",
    "Do a long press",
    "Drag the square to a different location",
    "Rotate the square",
    "Do either a tap, long press, or swipe in any direction"
]

let codeList = [
    "myView.rx.gesture(.tap).subscribeNext {...}",
    "myView.rx.gesture(.swipeDown).subscribeNext {...}",
    "myView.rx.gesture(.swipeLeft, .swipeRight).subscribeNext {",
    "myView.rx.gesture(.longPress).subscribeNext {...}",
    "myView.rx.gesture(.pan(.changed), .pan(.ended)]).subscribeNext {...}",
    "myView.rx.gesture(.rotate(.changed), .rotate(.ended)]).subscribeNext {...}",
    "myView.rx.gesture().subscribeNext {...}"
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

        nextStep😁.scan(0, accumulator: {acc, _ in
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
            myView.rx.gesture(.tap).subscribe(onNext: {[weak self] _ in
                guard let this = self else {return}
                UIView.animate(withDuration: 0.5, animations: {
                    this.myView.backgroundColor = UIColor.blue
                    this.nextStep😁.onNext()
                })
            }).addDisposableTo(stepBag)
            
        case 1: //swipe down
            myView.rx.gesture(.swipeDown).subscribe(onNext: {[weak self] _ in
                guard let this = self else {return}
                UIView.animate(withDuration: 0.5, animations: {
                    this.myView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
                    this.nextStep😁.onNext()
                })
            }).addDisposableTo(stepBag)
            
        case 2: //swipe horizontally
            myView.rx.gesture(.swipeLeft, .swipeRight).subscribe(onNext: {[weak self] _ in
                guard let this = self else {return}
                UIView.animate(withDuration: 0.5, animations: {
                    this.myView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                    this.nextStep😁.onNext()
                })
            }).addDisposableTo(stepBag)

        case 3: //long press
            myView.rx.gesture(.longPress).subscribe(onNext: {[weak self] _ in
                guard let this = self else {return}
                UIView.animate(withDuration: 0.5, animations: {
                    this.myView.transform = CGAffineTransform.identity
                    this.nextStep😁.onNext()
                })
            }).addDisposableTo(stepBag)

        case 4: //panning
            myView.rx.gesture(.pan(.changed)).subscribe(onNext: {[weak self] gesture in
                guard let this = self else {return}
                switch gesture {
                case .pan(let data):
                    this.myViewText.text = "(\(data.translation.x), \(data.translation.y))"
                    this.myView.transform = CGAffineTransform(translationX: data.translation.x, y: data.translation.y)
                default: break
                }
            }).addDisposableTo(stepBag)

            myView.rx.gesture(.pan(.ended)).subscribe(onNext: {[weak self] gesture in
                guard let this = self else {return}
                switch gesture {
                case .pan(_):
                    UIView.animate(withDuration: 0.5, animations: {
                        this.myViewText.text = nil
                        this.myView.transform = CGAffineTransform.identity
                        this.nextStep😁.onNext()
                    })
                default: break
                }
            }).addDisposableTo(stepBag)
            
        case 5: //rotating
            myView.rx.gesture(.rotate(.changed)).subscribe(onNext: {[weak self] gesture in
                guard let this = self else {return}
                switch gesture {
                case .rotate(let data):
                    this.myViewText.text = String(format: "angle: %.2f", data.rotation)
                    this.myView.transform = CGAffineTransform(rotationAngle: data.rotation)
                default: break
                }
            }).addDisposableTo(stepBag)

            myView.rx.gesture(.rotate(.ended)).subscribe(onNext: {[weak self] gesture in
                guard let this = self else {return}
                switch gesture {
                case .rotate(_):
                    UIView.animate(withDuration: 0.5, animations: {
                        this.myViewText.text = nil
                        this.myView.transform = CGAffineTransform.identity
                        this.nextStep😁.onNext()
                    })
                default: break
                }
            }).addDisposableTo(stepBag)
            
        case 6: //any gesture
            myView.rx.gesture().subscribe(onNext: {[weak self] _ in
                guard let this = self else {return}
                UIView.animate(withDuration: 0.5, animations: {
                    this.myView.backgroundColor = UIColor.red
                    this.nextStep😁.onNext()
                })
            }).addDisposableTo(stepBag)

        default: break
        }
        
        print("active gestures: \(myView.gestureRecognizers!.count)")
    }
}
