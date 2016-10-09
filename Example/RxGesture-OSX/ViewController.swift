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
        "Right click the square",
        "Click any button (left or right)",
        "Drag the square around",
        "Rotate the square with your trackpad, or click if you do not have a trackpad"
    ]
    
    let codeList = [
        "myView.rx.gesture(.click).subscribeNext {...}",
        "myView.rx.gesture(.rightClick).subscribeNext {...}",
        "myView.rx.gesture(RxGestureTypeOptions.all()).subscribeNext {...}",
        "myView.rx.gesture(.pan(.Changed), .pan(.Ended)).subscribeNext {...}",
        "myView.rx.gesture(.rotate(.Changed), .rotate(.Ended), .click).subscribeNext {...}"
    ]
    
    @IBOutlet weak var myView: NSView!
    @IBOutlet weak var myViewText: NSTextField!
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var code: NSTextField!
    
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
        
        nextStep😁.scan(0, accumulator: {acc, _ in
            return acc < 4 ? acc + 1 : 0
        })
        .startWith(0)
        .subscribe(onNext: step)
        .addDisposableTo(bag)
    }
    
    func step(_ step: Int) {
        //release previous recognizers
        stepBag = DisposeBag()
        
        info.stringValue = "\(step+1). \(infoList[step])"
        code.stringValue = codeList[step]
        
        //add current step recognizer
        switch step {
        case 0: //left click recognizer
            myView.rx.gesture(.click).subscribe(onNext: {[weak self] _ in
                guard let `self` = self else {return}
                
                self.myView.layer!.backgroundColor = NSColor.blue.cgColor
                
                let anim = CABasicAnimation(keyPath: "backgroundColor")
                anim.fromValue = NSColor.red.cgColor
                anim.toValue = NSColor.blue.cgColor
                self.myView.layer!.add(anim, forKey: nil)

                self.nextStep😁.onNext()
            })
            .addDisposableTo(stepBag)
            
        case 1: //right click recognizer
            myView.rx.gesture(.rightClick).subscribe(onNext: {[weak self] _ in
                guard let `self` = self else {return}
                
                self.myView.layer!.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)

                let anim = CABasicAnimation(keyPath: "transform")
                anim.duration = 0.5
                anim.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
                anim.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1.5, 1.5, 1.5))
                self.myView.layer!.add(anim, forKey: nil)
                
                self.nextStep😁.onNext()
            })
            .addDisposableTo(stepBag)
            
        case 2: //any button
            myView.rx.gesture(.click, .rightClick).subscribe(onNext: {[weak self] _ in
                guard let `self` = self else {return}
                
                self.myView.layer!.transform = CATransform3DIdentity
                self.myView.layer!.backgroundColor = NSColor.red.cgColor
                
                let anim = CABasicAnimation(keyPath: "transform")
                anim.duration = 0.5
                anim.fromValue = NSValue(caTransform3D: CATransform3DMakeScale(1.5, 1.5, 1.5))
                anim.toValue = NSValue(caTransform3D: CATransform3DIdentity)
                self.myView.layer!.add(anim, forKey: nil)
                
                self.nextStep😁.onNext()
            }).addDisposableTo(stepBag)
            
        case 3: //pan
            
            //
            // NB!: In this version of `RxGesture` under OSX you need to observe for .Changed and .Ended
            // on the same call to rx_gesture - once NSGestureRecognizer supports rx_event in RxCocoa
            // you can also observe them on separate calls - don't forget to switch on the recognizer `state`
            //
            
            myView.rx.gesture(.pan(.changed), .pan(.ended)).subscribe(onNext: {[weak self] gesture in
                guard let `self` = self else {return}
                
                switch gesture {
                case .pan(let data):
                    if let state = (data.recognizer as? NSGestureRecognizer)?.state {
                        switch state {
                        case .changed:
                            self.myViewText.stringValue = String(format: "(%.f, %.f)", arguments: [data.translation.x, data.translation.y])
                            self.myView.layer!.transform = CATransform3DMakeTranslation(data.translation.x, data.translation.y, 0.0)
                        
                        case .ended:
                            self.myViewText.stringValue = ""
                            
                            let anim = CABasicAnimation(keyPath: "transform")
                            anim.duration = 0.5
                            anim.fromValue = NSValue(caTransform3D: self.myView.layer!.transform)
                            anim.toValue = NSValue(caTransform3D: CATransform3DIdentity)
                            self.myView.layer!.add(anim, forKey: nil)
                            self.myView.layer!.transform = CATransform3DIdentity
                            
                            self.nextStep😁.onNext()
                        default: break
                        }
                    }
                default: break
                }
            })
            .addDisposableTo(stepBag)
            
        case 4: //rotate or click
            
            myView.rx.gesture(.rotate(.changed), .rotate(.ended), .click).subscribe(onNext: {[weak self] gesture in
                guard let `self` = self else {return}
                
                switch gesture {
                case .rotate(let data):
                    if let state = (data.recognizer as? NSGestureRecognizer)?.state {
                        switch state {
                        case .changed:
                            self.myViewText.stringValue = String(format: "angle: %.2f", data.rotation)
                            self.myView.layer!.transform = CATransform3DMakeRotation(data.rotation, 0, 0, 1)
                            
                        case .ended:
                            self.myViewText.stringValue = ""
                            
                            let anim = CABasicAnimation(keyPath: "transform")
                            anim.duration = 0.5
                            anim.fromValue = NSValue(caTransform3D: self.myView.layer!.transform)
                            anim.toValue = NSValue(caTransform3D: CATransform3DIdentity)
                            self.myView.layer!.add(anim, forKey: nil)
                            self.myView.layer!.transform = CATransform3DIdentity
                            
                            self.nextStep😁.onNext()
                        default: break
                        }
                    }
                case .click:
                    self.myViewText.stringValue = ""
                    
                    let anim = CABasicAnimation(keyPath: "transform")
                    anim.duration = 0.5
                    anim.fromValue = NSValue(caTransform3D: self.myView.layer!.transform)
                    anim.toValue = NSValue(caTransform3D: CATransform3DIdentity)
                    self.myView.layer!.add(anim, forKey: nil)
                    self.myView.layer!.transform = CATransform3DIdentity
                    
                    self.nextStep😁.onNext()
                default: break
                }
            })
            .addDisposableTo(stepBag)
            
        default: break
        }
        
        print("active gestures: \(myView.gestureRecognizers.count)")
    }

}

