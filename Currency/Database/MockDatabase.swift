//
//  MockDatabase.swift
//  Currency
//
//  Created by Matt on 22.05.21.
//


import Foundation
import UIKit
import CoreData


class MockDatabase: DatabaseReadable, DatabaseSavable {

    static let shared = MockDatabase()

    func inititalSetup() {
        let  jsonPath = Bundle.main.path(forResource: "live", ofType: "json")

        guard self.getQuotes().isEmpty else {
            return
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath!), options: .mappedIfSafe)
            let jsonResult = try decoder.decode(CurrencyResponse.self, from: data)
            UserDefaults.standard.lastMetaDataDate = jsonResult.timestamp
            self.saveQuotes(quotes: jsonResult.quotes)
        } catch {
            fatalError("could not setup database")
        }
    }

    func saveQuotes(quotes:[String: Double]) {

    }

    func deleteAllQuotes() {

    }

    func getQuotes() -> [Currency] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Currency")
        let sort = NSSortDescriptor(key: "country", ascending: true)
        request.sortDescriptors = [sort]
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.persistentContainer.viewContext.fetch(request)
            return result as! [Currency]
        } catch {
            print("Failed")
        }
        return []
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Currency")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
