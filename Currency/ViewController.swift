//
//  ViewController.swift
//  Currency
//
//  Created by Matt on 19.05.21.
//

import UIKit
import Combine

class ViewController: UIViewController {

    var apiNetworkActivitySubscriber: AnyCancellable?

    @IBOutlet var loading: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var inputTf: UITextField!
    @IBOutlet var dateLabel: UILabel!

    let api = Network.shared
    var subscriptions = [AnyCancellable]()

    var viewModel: CurrencyViewModel?
    var store = DataStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        apiNetworkActivitySubscriber = Network.shared.networkActivityPublisher
                    .receive(on: RunLoop.main)
                    .sink { doingSomethingNow in
                        if (doingSomethingNow) {
                            self.loading.startAnimating()
                        } else {
                            self.loading.stopAnimating()
                        }
                    }

//        api.list()
//            .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
//            .store(in: &subscriptions)


        self.tableView.register(UINib(nibName: "CurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.rowHeight = 70.0

        store.update()
        store.$quotes.sink(receiveValue: { _ in
            self.dateLabel.text = "\(NSLocalizedString("Last update: ", comment: "")) \(self.store.lastUpdate?.string ?? "")"
            self.tableView.reloadData()
        }).store(in: &subscriptions)



    }

    func bindViewModel() {}

}

extension ViewController: UITableViewDelegate {

}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.quotes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CurrencyTableViewCell

        let quote = self.store.quotes[indexPath.row]
        self.configure(cell: cell, withQuote: quote)

        return cell
    }

    func configure(cell: CurrencyTableViewCell, withQuote quote: Currency) {
        cell.titleLabel.text = quote.country
        cell.valueLabel.text = "\(quote.sign ?? "") \(quote.value * store.amount)"
        if let data = quote.image {
            cell.iconIV.image = UIImage(data: data)
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == inputTf {
            let allowedCharacters = CharacterSet(charactersIn:".,0123456789 ")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let amount = InputConverter.numberFromString(string: textField.text) {
            store.amount = amount
            self.tableView.reloadData()
        }
        return true
    }
}
