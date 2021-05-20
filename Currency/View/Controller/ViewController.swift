//
//  ViewController.swift
//  Currency
//
//  Created by Matt on 19.05.21.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet var loading: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var inputTf: UITextField!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var selectedCurrencyLabel: UILabel!
    @IBOutlet var selectCurrencyBtn: UIButton!
    @IBOutlet var selectedCurrencyImage: UIImageView!
    
    var subscriptions = [AnyCancellable]()

    var viewModel = CurrencyViewModel(dependencies: CurrencyViewModel.Dependencies(api: API.shared, db: Database.shared))
    var dataSource: CurrencyListViewDataSource<CurrencyTableViewCell, QuoteCellViewModel>?

    private let appear = PassthroughSubject<Void, Never>()
    private let pressedCurrencySelection = PassthroughSubject<Void, Never>()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Currency".ll
        bindViewModel()
        setupTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appear.send()
    }

    func setupTableView() {
        self.tableView.register(UINib(nibName: "CurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: CurrencyTableViewCell.identifier)
        self.tableView.rowHeight = 70.0

        self.dataSource = CurrencyListViewDataSource<CurrencyTableViewCell, QuoteCellViewModel>(cellIdentifier: CurrencyTableViewCell.identifier, items: [], configureCell: { cell, vm in
            cell.viewModel = vm
        })
        self.tableView.dataSource = dataSource
    }

    func bindViewModel() {
        self.selectCurrencyBtn.tapPublisher.sink(receiveValue: { [unowned self] _ in
            self.performSegue(withIdentifier: "CurrencySelectionTVC", sender: nil)
        }).store(in: &subscriptions)

        let output = self.viewModel.transform(input: CurrencyViewModel.Input(amountValueText: self.inputTf.textPublisher(), selectedCountry: self.selectCurrencyBtn.tapPublisher))

        output.isInputValid.sink(receiveValue: { isValid in
            //if isValid { self.tableView.reloadData() }
            self.inputTf.backgroundColor = isValid ? .white : .systemRed
        }).store(in: &subscriptions)


        output.quotes
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {
                self.dataSource?.items = $0
                self.tableView.reloadData()

        }).store(in: &subscriptions)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CurrencySelectionTVC" {
            let vc = segue.destination as! CurrencySelectionTVC
            vc.viewModel.$selectedCurrency.map({$0 ?? ""}).assign(to: \.currency, on: self.viewModel).store(in: &subscriptions)
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
        if let _ = InputConverter.numberFromString(string: textField.text) {
            //store.amount = amount
            textField.resignFirstResponder()
            self.tableView.reloadData()
        }
        return true
    }
}
