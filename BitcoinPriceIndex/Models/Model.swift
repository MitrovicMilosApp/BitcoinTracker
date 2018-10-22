//
//  Model.swift
//  BitcoinPriceIndex
//
//  Created by Milos Mitrovic on 7/18/18.
//  Copyright © 2018 Milos Mitrovic. All rights reserved.
//

import Foundation
import Alamofire

class Model {
    
    
    // MARK: - Vars & Lets
    
    var entry = Entry()
    var entries = [Entry]()
    var cdModel = ModelToCoreData()
    var currentBitcoinPrice: Double = 0
    var totalNumberOfBitcoins: Double = 0
    var moneySpentOnBuying: Double = 0
    var moneyEarnedFromSelling: Double = 0
    var currentValue: Double = 0
    var moneyMadeTotal: Double = 0
    
    
    // MARK: - Methods
    
    func calculate() {
        calculateMoneyMadeTotal()
        calculateTotalNumberOfBitcoins()
        calculateCurrentValue(currentPrice: currentBitcoinPrice)
    }
    
    func calculateMoneyMadeTotal() {
        moneyMadeTotal = 0
        for entry in entries {
            moneyMadeTotal -= entry.numberOfBitcoins * entry.priceOfBitcoin
        }
    }
    
    func calculateTotalNumberOfBitcoins() {
        var number = Double()
        for entry in entries {
            number += entry.numberOfBitcoins
        }
        totalNumberOfBitcoins = number
    }

    func calculateCurrentValue(currentPrice: Double) {
        currentBitcoinPrice = currentPrice
        currentValue = totalNumberOfBitcoins * currentBitcoinPrice
    }
    
    func buy(price: Double, bitcoins: Double) {
        if entries.count == 0 {
            entry.counter = 1
        } else {
            entry.counter = (entries.last?.counter)! + 1
        }
        entry.numberOfBitcoins = bitcoins
        entry.priceOfBitcoin = price
        entry.entryText = "\(Int(entry.counter)). Bought \(bitcoins) bitcoins, at price \(price), for total of \(price * bitcoins)"
        entry.buy = true
        entries.append(entry)
        entry = Entry()
        calculate()
    }
    
    func sell(price: Double, bitcoins: Double) {
        // DODAO 13.09:
        if entries.count == 0 {
            entry.counter = 1
        } else {
            entry.counter = (entries.last?.counter)! + 1
        }
        entry.numberOfBitcoins -= bitcoins
        entry.priceOfBitcoin = price
        entry.entryText = "\(Int(entry.counter)). Sold \(bitcoins) bitcoins, at price \(price), for total of \(price * bitcoins)"
        entry.buy = false
        entries.append(entry)
        entry = Entry()
        calculate()
    }
    
    func coreDataRefresher() {
        cdModel.cdToModel()
        entries = cdModel.entries
        cdModel.cleanCD()
        cdModel.modelToCD()
    }
    
    func coreDataAddEntry() {
        cdModel.entries = entries
        cdModel.cleanCD()
        cdModel.modelToCD()
    }
    
    func coreDataRemoveEntry() {
        cdModel.entries = entries
        cdModel.cleanCD()
        cdModel.modelToCD()
    }
}
