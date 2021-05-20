//MIT License
//
//Copyright (c) 2020 Matthias Brodalka
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import Foundation
import UIKit
import CoreData
import MapKit

protocol DatabaseProtocol {
    func getQuotes() -> [Currency] 
}

class Database: DatabaseProtocol {

    static let shared = Database()

    func inititalSetup() {
        let  jsonPath = Bundle.main.path(forResource: "live", ofType: "json")

        guard self.getQuotes().isEmpty else {
            return
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath!), options: .mappedIfSafe)
            let jsonResult = try JSONDecoder().decode(CurrencyResponse.self, from: data)
            self.saveQuotes(quotes: jsonResult.quotes)
        } catch {
            // handle error
        }
    }

    func saveQuotes(quotes:[String: Double]) {
        //I don't want to check for update/insert so I delete all entries before
        self.deleteAllQuotes()

        let managedContext = self.persistentContainer.viewContext
        for quote in quotes {
            let e = Currency(context: managedContext)
            e.id = quote.key
            e.code = quote.key

            //the quote key seems to be in format e.g. USDUSD, USDEUR
            //i assume I can cut the first 3 characters to get the clean currency code
            if quote.key.count >= 6 {
                e.country = quote.key[3...5]
            } else {
                e.country = quote.key
            }

            e.value = quote.value
            e.sign = getSymbol(forCurrencyCode: e.country ?? "") ?? ""
            e.image = getCountryImage(forCurrencyCode: e.country)?.pngData()
            
            self.saveContext()
        }
    }

    func deleteAllQuotes() {
        let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Currency")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch {
            print ("There was an error")
        }
    }

    //It would be nice to see also the currency symbol
    //we try to figure it out by taking the currency code e.g. USD, JPY
    func getSymbol(forCurrencyCode code: String) -> String? {
        let locale = NSLocale(localeIdentifier: code)
        if locale.displayName(forKey: .currencySymbol, value: code) == code {
            let newlocale = NSLocale(localeIdentifier: code.dropLast() + "_en")
            return newlocale.displayName(forKey: .currencySymbol, value: code)
        }
        return locale.displayName(forKey: .currencySymbol, value: code)
    }

    //we go the extra way and try to display an image for the currency/country/region
    //we display a not found image in case there we have no image
    func getCountryImage(forCurrencyCode code: String?) -> UIImage? {
        let notfound = UIImage(named: "notfound")
        guard let code = code, !code.isEmpty else { return notfound }
        return UIImage(named: code.lowercased()) ?? notfound
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
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Currency")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
