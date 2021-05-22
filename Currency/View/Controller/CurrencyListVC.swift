//
//  ViewController.swift
//  Currency
//
//  Created by Matt on 19.05.21.
//

import UIKit
import Combine

class CurrencyListVC: UIViewController {

    // Outlets for our state container for error and loading
    //loading
    @IBOutlet var loading: UIActivityIndicatorView!
    @IBOutlet var loadingContainer: UIView?
    //error
    @IBOutlet var errorContainer: UIView?
    @IBOutlet var tryAgainBtn: UIButton?
    //last update label
    @IBOutlet var dateLabel: UILabel!

    @IBOutlet var tableView: UITableView!
    @IBOutlet var inputTf: UITextField!

    //Outlets for currency selection button
    @IBOutlet var selectedCurrencyLabel: UILabel!
    @IBOutlet var selectCurrencyBtn: UIButton!
    @IBOutlet var selectedCurrencyImage: UIImageView!

    var subscriptions = [AnyCancellable]()

    private let appear = PassthroughSubject<Void, Never>()
    //use to inform vm that selection happened
    private let pressedCurrencySelection = PassthroughSubject<Void, Never>()
    //use to inform vm for refreshing data
    private let refresh = PassthroughSubject<Bool, Never>()

    var viewModel = CurrencyListVCViewModel(dependencies: CurrencyListVCViewModel.Dependencies(api: API.shared, db: Database.shared))
    var dataSource: GenericDataSource<QuoteCell, QuoteCellViewModel>?

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
        self.tableView.register(UINib(nibName: "QuoteCell", bundle: nil), forCellReuseIdentifier: QuoteCell.identifier)
        self.tableView.rowHeight = 70.0

        self.dataSource = GenericDataSource<QuoteCell, QuoteCellViewModel>(cellIdentifier: QuoteCell.identifier, items: [], configureCell: { cell, vm in
            cell.viewModel = vm
        })
        self.tableView.dataSource = dataSource
    }

    func bindViewModel() {
        let output = self.viewModel.transform(input: CurrencyListVCViewModel.Input(amountValueText: self.inputTf.textPublisher(), refresh: refresh))

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
            if let code = code {
                self.selectedCurrencyLabel.text = code
            }
            if let imgData = imgData {
                self.selectedCurrencyImage.image = UIImage(data: imgData)
            }
        }).store(in: &subscriptions)

        //Dependend on our network state we will show loading, error or just nothing
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

        //show our current datas date
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

extension CurrencyListVC: UITextFieldDelegate {

    //we want to limit the input options for our textfield to only numbers and ,.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == inputTf {
            let allowedCharacters = CharacterSet(charactersIn: ".,0123456789 ")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
}

extension CurrencyListVC {
    //pressing refresh triggers our publisher
    @IBAction func pressedRefresh(_ sender: Any) {
        self.refresh.send(true)
    }
}
