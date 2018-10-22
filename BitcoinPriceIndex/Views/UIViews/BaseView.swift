//
//  BaseView.swift
//  BitcoinPriceIndex
//
//  Created by Milos Mitrovic on 7/25/18.
//  Copyright © 2018 Milos Mitrovic. All rights reserved.
//

import UIKit

class BaseView: UIView {

    // MARK: - Overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Public methods
    
    func setupView() {
        
    }

}
