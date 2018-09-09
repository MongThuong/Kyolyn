//
//  GridButton.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/26/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Material
import RxSwift

fileprivate let colorPrefix = CharacterSet(charactersIn: "#")

/// The grid button
class GridButton<T: GridItemModel>: RaisedButton {
    var disposeBag: DisposeBag?
    
    let object: T
    let settings: OrderingGridSettings
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }
    
    required init(object obj: T, settings st: OrderingGridSettings) {
        object = obj
        settings = st
        super.init(frame: .zero)
    }

    override func prepare() {
        super.prepare()
        depthPreset = .depth5
        cornerRadiusPreset = .cornerRadius2
        contentEdgeInsetsPreset = .square1
        clipsToBounds = true
    }
    
    func toColorInt(_ hex: String) -> Int? {
        let trimmedValue = hex.trimmingCharacters(in: colorPrefix)
        return Int(trimmedValue, radix: 16)
    }
}
