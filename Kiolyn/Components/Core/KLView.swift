//
//  KLView.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 9/6/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import Material

/// Base class for all view.
class KLView: View {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
}
