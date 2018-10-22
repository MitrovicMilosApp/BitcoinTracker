//
//  CalculateVC.swift
//  BitcoinPriceIndex
//
//  Created by Milos Mitrovic on 7/17/18.
//  Copyright © 2018 Milos Mitrovic. All rights reserved.
//

import UIKit

class CalculateVC: UIViewController {
    
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.calculate()
        currencyStringSelector()
        model.calculateCurrentValue(currentPrice: model.currentBitcoinPrice)
        updateLabels()
        tableView.reloadData()
    }
    
    
    // MARK: - Vars & Lets
    
    var model = Model()
    var currencySelector = BitcoinVC.Selector.EUR
    var currencyString = "EUR"
    var buySegue = "BuySegue"
    var sellSegue = "SellSegue"
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currencyLabel: BorderLabel!
    @IBOutlet weak var numberOfBitcoinsLabel: BorderLabel!
    @IBOutlet weak var currentValueLabel: BorderLabel!
    @IBOutlet weak var moneyMadeLabel: BorderLabel!
    @IBOutlet weak var buyButtonOutlet: BorderButton!
    @IBOutlet weak var sellButtonOutlet: BorderButton!
    
    
    // MARK: - Methods
    
    func currencyStringSelector() {
        switch currencySelector {
        case .EUR:
            currencyString = "EUR"
        case .USD:
            currencyString = "USD"
        case .GBP:
            currencyString = "GBP"
        }
    }
    
    func updateLabels() {
        numberOfBitcoinsLabel.text = String(model.totalNumberOfBitcoins)
        currentValueLabel.text = String(model.currentValue)
        moneyMadeLabel.text = String(model.moneyMadeTotal)
        tableView.reloadData()
        currencyLabel.text = "Currency: \(currencyString)"
    }

    func tableCellAlert(indexPath: IndexPath, entry: Entry) {
        let entryNumber = Int(entry.counter)
        let title = "Transaction number \(entryNumber)"
        let message = model.entries[indexPath.row].entryText
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func deleteAlert() {
        let title = String()
        let message = "Are you sure that you want to delete this entry?"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let actionYes = UIAlertAction(title: "Yes, delete entry", style: .default) { (action) in
            self.removeLast()
            self.updateLabels()
        }
        let actionNo = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        self.present(alert, animated: true)
    }
    
    func removeLast() {
        if !model.entries.isEmpty {
            model.entries.removeLast()
            model.coreDataRemoveEntry()
        }
        model.calculate()
        tableView.reloadData()
    }
    
    
    // MARK: - Actions
    
    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buyButton(_ sender: BorderButton) {
        updateLabels()

    }
    @IBAction func sellButton(_ sender: BorderButton) {
        updateLabels()

    }
    @IBAction func removeLastEntryButton(_ sender: BorderButton) {
        deleteAlert()
        updateLabels()
    }
    
    
    // MARK: - Navigation
    
    @IBAction func goBackToCalculateVC(segue: UIStoryboardSegue) {
        print("unwound")
        model.coreDataRefresher()
        tableView.reloadData()
        updateLabels()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? BuySellVC {
            destination.model = model
            if segue.identifier == buySegue {
                destination.picker = .buy
            }
            if segue.identifier == sellSegue {
                destination.picker = .sell
            }
        }
    }
}

// MARK: - Extensions

// MARK: - Extensions - CalculateVC: UITableViewDataSource

extension CalculateVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EntryTVCell
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = model.entries[indexPath.row].entryText
        if model.entries[indexPath.row].buy == true {
            cell.backgroundColor = UIColor.buyColor
        } else {
            cell.backgroundColor = UIColor.sellColor
        }
        return cell
    }
    
    
}

// MARK: - Extensions - CalculateVC: UITableViewDelegate

extension CalculateVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableCellAlert(indexPath: indexPath, entry: model.entries[indexPath.row])
    }
}




