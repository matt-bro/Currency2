//
//  CurrencyTableViewCell.swift
//  Currency
//
//  Created by Matt on 19.05.21.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var valueLabel: UILabel?
    @IBOutlet var valueLabelContainer: CardView?
    @IBOutlet var iconIV: UIImageView?

    static let identifier = "CurrencyTableViewCell"

    var viewModel: QuoteCellViewModel? {
        didSet {
            setupViewModel()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupViewModel() {
        self.titleLabel?.text = viewModel?.title
        self.valueLabel?.text = viewModel?.amount
        self.iconIV?.image = viewModel?.image
    }
}
//
//class CurrencySelectionTableViewCell: CurrencyTableViewCell {
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//        self.valueLabel.isHidden = true
//        self.accessoryType = .disclosureIndicator
//    }
//}
