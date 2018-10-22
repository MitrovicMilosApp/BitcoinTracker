//
//  EntryTVCell.swift
//  BitcoinPriceIndex
//
//  Created by Milos Mitrovic on 10/8/18.
//  Copyright © 2018 Milos Mitrovic. All rights reserved.
//

import UIKit

class EntryTVCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellLayout()
    }

    private func setupCellLayout() {        
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.borderColor.cgColor
        self.clipsToBounds = true
    }
}
