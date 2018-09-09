//
//  TestRxUITextField.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/18/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

class RxUITextFieldTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let disposeBag = DisposeBag()
        let enableTextField = UITextField()
        enableTextField.text = "aaa"
        
        let enablePublish = PublishSubject<String>()
        enableTextField.rx.text.orEmpty.changed
            .bindTo(enablePublish)
            .addDisposableTo(disposeBag)
        
        enablePublish
            .asObserver()
            .subscribe(onNext: {
                print("next: \($0)")
            })
            .addDisposableTo(disposeBag)
        
        enableTextField.text = "1"
        enableTextField.sendActions(for: .valueChanged)
        enableTextField.text = "2"
        enableTextField.text = "3"
        enableTextField.text = "4"

    }
    
    func testRatio() {

    }
    
}
