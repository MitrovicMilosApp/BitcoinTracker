//
//  ModelToCoreData.swift
//  BitcoinPriceIndex
//
//  Created by Milos Mitrovic on 9/2/18.
//  Copyright © 2018 Milos Mitrovic. All rights reserved.
//

import Foundation
import CoreData

class ModelToCoreData {
    
    
    // MARK - Vars & Lets
    
    var entries = [Entry]()
    var cdEntries = [CDEntry]()
    var container = AppDelegate.persistentContainer
    var context = AppDelegate.viewContext

    
    // MARK: - Methods
    
    func cleanCD() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDEntry")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        } catch {
            print(error)
        }
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func cdToModel() {
        cdEntries = [CDEntry]()
        let request: NSFetchRequest<CDEntry> = CDEntry.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "counter", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        do {
            cdEntries = try context.fetch(request)
        } catch {
            print(error)
        }
        var temporaryArrayOfEntries = [Entry]()
        for cdEnt in cdEntries {
            let entry = Entry()
            entry.entryText = cdEnt.entryText!
            entry.numberOfBitcoins = cdEnt.numberOfBitcoins
            entry.priceOfBitcoin = cdEnt.priceOfBitcoin
            entry.counter = cdEnt.counter
            entry.buy = cdEnt.buy
            temporaryArrayOfEntries.append(entry)
        }
        entries = temporaryArrayOfEntries
    }
    
    func modelToCD() {
        for ent in entries {
            let newEntry = NSEntityDescription.insertNewObject(forEntityName: "CDEntry", into: context)
            newEntry.setValue(ent.entryText, forKey: "entryText")
            newEntry.setValue(ent.numberOfBitcoins, forKey: "numberOfBitcoins")
            newEntry.setValue(ent.priceOfBitcoin, forKey: "priceOfBitcoin")
            newEntry.setValue(ent.counter, forKey: "counter")
            newEntry.setValue(ent.buy, forKey: "buy")
        }
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
}
