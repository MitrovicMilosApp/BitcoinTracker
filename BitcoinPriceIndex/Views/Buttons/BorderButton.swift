//
//  BorderButton.swift
//  BitcoinPriceIndex
//
//  Created by Milos Mitrovic on 7/17/18.
//  Copyright © 2018 Milos Mitrovic. All rights reserved.
//

import UIKit

class BorderButton: BaseButton {

    // MARK: - Overrides
    
    override func setupView() {
        layer.cornerRadius = 5
        layer.borderColor = UIColor.borderColor.cgColor
        layer.borderWidth = 1
        clipsToBounds = true
        self.titleLabel?.adjustsFontSizeToFitWidth = true 
    }

}
