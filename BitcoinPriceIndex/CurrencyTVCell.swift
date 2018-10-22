//
//  CurrencyTVCell.swift
//  BitcoinPriceIndex
//
//  Created by Milos Mitrovic on 7/20/18.
//  Copyright © 2018 Milos Mitrovic. All rights reserved.
//

import UIKit

class CurrencyTVCell: UITableViewCell {

    
    // MARK: - Lifecycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Vars & Lets
    
    var modelVC = BitcoinVC()
    
    // MARK: - Methods
    
    private func setupCellLayout() {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.borderColor.cgColor
        self.clipsToBounds = true
    }
    
    func populateCell(text: String) {
        self.textLabel?.text = text
        self.textLabel?.adjustsFontSizeToFitWidth = true 
    }
    
    func updateCells(indexPath: IndexPath) {
        if indexPath.isEmpty == false {
            if indexPath.row == 0 {
                modelVC.currencySelector = BitcoinVC.Selector.USD
                modelVC.chartViewRefresher(pricesArray: modelVC.pricesOverTimeUSD)
                modelVC.dropButtonOutlet.setTitle("USD", for: .normal)
            } else if indexPath.row == 1 {
                modelVC.currencySelector = BitcoinVC.Selector.GBP
                modelVC.chartViewRefresher(pricesArray: modelVC.pricesOverTimeGBP)
                modelVC.dropButtonOutlet.setTitle("GBP", for: .normal)
            } else {
                modelVC.currencySelector = BitcoinVC.Selector.EUR
                modelVC.chartViewRefresher(pricesArray: modelVC.pricesOverTimeEUR)
                modelVC.dropButtonOutlet.setTitle("EUR", for: .normal)
            }
        } else {
            modelVC.alertNoInternetAccess()
            modelVC.dropButtonOutlet.setTitle("LIST", for: .normal)
        }
        let currency = modelVC.arrayOfCurrencies[indexPath.row]
        if !modelVC.arrayOfPricesStringValue.isEmpty {
            let price = modelVC.arrayOfPricesStringValue[indexPath.row]
            modelVC.bitcoinPriceLabel.text = "\(currency) \(price)"
        } else {
            modelVC.alertNoInternetAccess()
        }
    }
}
