//
//  RxGesture_iOS_DemoUITests.swift
//  RxGesture_iOS_DemoUITests
//
//  Created by Marin Todorov on 4/5/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest

class RxGesture_iOS_DemoUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        let app = XCUIApplication()
        let squareElement = XCUIApplication().otherElements["square"]
        
        XCTAssert(app.staticTexts["Tap the red square"].exists)

        // .Tap
        squareElement.tap()
        XCTAssert(app.staticTexts["Swipe the square down"].exists)
        
        // .SwipeDown
        squareElement.swipeDown()
        XCTAssert(app.staticTexts["Swipe horizontally (e.g. left or right)"].exists)
        
        // .SwipeRight
        squareElement.swipeRight()
        XCTAssert(app.staticTexts["Do a long press"].exists)
        
        // .LongPress
        squareElement.pressForDuration(1.0)
        XCTAssert(app.staticTexts["Drag the square to a different location"].exists)
        
    }
    
}
