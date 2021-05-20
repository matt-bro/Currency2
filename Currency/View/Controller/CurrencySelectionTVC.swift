//
//  CurrencySelectionTVC.swift
//  Currency
//
//  Created by Matt on 20.05.21.
//

import UIKit
import Combine

class CurrencySelectionTVC: UITableViewController {

    var dataSource: CurrencyListViewDataSource<CurrencyTableViewCell, QuoteCellViewModel>?
    let viewModel = CurrencySelectionTVCViewModel(dependencies: CurrencySelectionTVCViewModel.Dependencies(db: Database.shared))

    var subscriptions = [AnyCancellable]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindViewModel()
    }

    func setupTableView() {
        self.dataSource = CurrencyListViewDataSource<CurrencyTableViewCell, QuoteCellViewModel>
            .init(cellIdentifier: CurrencyTableViewCell.identifier, items: [], configureCell: { cell, vm in
                cell.viewModel = vm
                cell.valueLabel.isHidden = true
                cell.accessoryType = .disclosureIndicator
        })
        self.tableView.dataSource = dataSource

        self.tableView.register(UINib(nibName: "CurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: CurrencyTableViewCell.identifier)
        self.tableView.reloadData()
    }

    func bindViewModel() {
        let output = viewModel.transform()
        self.dataSource?.items = output.quotes
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vm = dataSource?.items[indexPath.row] {
            self.viewModel.didSelectCurrency(code: vm.title!)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

final class CurrencySelectionTVCViewModel {

    @Published var selectedCurrency: String? = nil

    struct Dependencies {
        let db: DatabaseProtocol
    }
    struct Output {
        let quotes: [QuoteCellViewModel]
    }

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func transform() -> Output {
        let quotes = dependencies.db.getQuotes().map({
            QuoteCellViewModel(code: $0.id ?? "", title: $0.country, image: $0.image, value: $0.value, sign: $0.sign)
        })
        return Output(quotes: quotes)
    }

    func didSelectCurrency(code: String) {
        selectedCurrency = code
    }
}
