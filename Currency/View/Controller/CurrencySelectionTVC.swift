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

    @IBOutlet weak var cancelBtn: UIBarButtonItem?

    private let cancel = PassthroughSubject<Void, Never>()
    var subscriptions = [AnyCancellable]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "selection.title".ll
        self.cancelBtn?.title = "cancel".ll

        setupTableView()
        bindViewModel()
    }

    func setupTableView() {
        self.dataSource = CurrencyListViewDataSource<CurrencyTableViewCell, QuoteCellViewModel>
            .init(cellIdentifier: CurrencyTableViewCell.identifier, items: [], configureCell: { cell, vm in
                cell.viewModel = vm
                //we can reuse the existing cell, we just hide the value
                cell.valueLabelContainer?.isHidden = true
                cell.accessoryType = .disclosureIndicator
        })
        self.tableView.dataSource = dataSource

        self.tableView.register(UINib(nibName: "CurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: CurrencyTableViewCell.identifier)
        self.tableView.reloadData()
    }

    func bindViewModel() {
        let input = CurrencySelectionTVCViewModel.Input(pressedCancel: cancel)

        let output = viewModel.transform(input: input)

        output.pressedCancel.sink(receiveValue: { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }).store(in: &subscriptions)

        self.dataSource?.items = output.quotes
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vm = dataSource?.items[indexPath.row] {
            self.viewModel.didSelectCurrency(code: vm.title!)
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func pressedCancel() {
        self.cancel.send()
    }
}

