//
//  BorderView.swift
//  BitcoinPriceIndex
//
//  Created by Milos Mitrovic on 7/25/18.
//  Copyright © 2018 Milos Mitrovic. All rights reserved.
//

import UIKit

class BorderView: BaseView {

    // MARK: - Overrides
    
    override func setupView() {
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
        self.backgroundColor = UIColor.white
    }

}
