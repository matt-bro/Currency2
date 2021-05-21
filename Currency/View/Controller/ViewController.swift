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
    @IBOutlet var loadingContainer: UIView?
    @IBOutlet var errorContainer: UIView?
    @IBOutlet var tryAgainBtn: UIButton?


    @IBOutlet var tableView: UITableView!
    @IBOutlet var inputTf: UITextField!
    @IBOutlet var dateLabel: UILabel!

    @IBOutlet var selectedCurrencyLabel: UILabel!
    @IBOutlet var selectCurrencyBtn: UIButton!
    @IBOutlet var selectedCurrencyImage: UIImageView!
    
    var subscriptions = [AnyCancellable]()

    var viewModel = CurrencyViewModel(dependencies: CurrencyViewModel.Dependencies(api: API.shared, db: Database.shared))
    var dataSource: GenericDataSource<CurrencyTableViewCell, QuoteCellViewModel>?

    private let appear = PassthroughSubject<Void, Never>()
    private let pressedCurrencySelection = PassthroughSubject<Void, Never>()
    private let refresh = PassthroughSubject<Bool, Never>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "main.title".ll
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

        self.dataSource = GenericDataSource<CurrencyTableViewCell, QuoteCellViewModel>(cellIdentifier: CurrencyTableViewCell.identifier, items: [], configureCell: { cell, vm in
            cell.viewModel = vm
        })
        self.tableView.dataSource = dataSource
    }



    func bindViewModel() {
        let output = self.viewModel.transform(input: CurrencyViewModel.Input(amountValueText: self.inputTf.textPublisher(), selectedCountry: self.selectCurrencyBtn.tapPublisher, refresh: refresh))

        //mark the textfield for invalid input
        output.isInputValid.sink(receiveValue: { isValid in
            self.inputTf.backgroundColor = isValid ? .systemBackground : .systemRed
        }).store(in: &subscriptions)

        //by changing paremeters like selected currency, network update, input
        //we reload our tableview with fresh quotes
        output.quotes
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {
                self.dataSource?.items = $0
                self.tableView.reloadData()

        }).store(in: &subscriptions)

        //change the image an text of the currency selection button
        output.currencySelection.sink(receiveValue: { code, imgData in
            self.selectedCurrencyLabel.text = code
            if let imgData = imgData {
                self.selectedCurrencyImage.image = UIImage(data: imgData)
            }
        }).store(in: &subscriptions)

        output.loadingState.sink(receiveValue: { state in
            switch state {
            case .finished:
                self.loadingContainer?.isHidden = true
                self.errorContainer?.isHidden = true
            case .loading:
                self.loadingContainer?.isHidden = false
                self.errorContainer?.isHidden = true
            case .error(let e):
                print(e.localizedDescription)
                self.loadingContainer?.isHidden = true
                self.errorContainer?.isHidden = false
            }
        }).store(in: &subscriptions)

        //Currency btn press leads to selection screen
        self.selectCurrencyBtn.tapPublisher.sink(receiveValue: { [unowned self] _ in
            self.performSegue(withIdentifier: "CurrencySelectionTVC", sender: nil)
        }).store(in: &subscriptions)


        output.metdataText.assign(to: \.text!, on: dateLabel).store(in: &subscriptions)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CurrencySelectionTVC" {
            if let nvc = segue.destination as? UINavigationController,
               let vc = nvc.viewControllers.first as? CurrencySelectionTVC {
                vc.viewModel.$selectedCurrency.map({$0 ?? ""}).assign(to: \.currency, on: self.viewModel).store(in: &subscriptions)
            }

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
}

extension ViewController {
    @IBAction func pressedRefresh(_ sender: Any) {
        self.refresh.send(true)
    }
}
