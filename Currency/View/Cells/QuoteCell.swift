//
//  CurrencyTableViewCell.swift
//  Currency
//
//  Created by Matt on 19.05.21.
//

import UIKit

class QuoteCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var valueLabel: UILabel?
    @IBOutlet var valueLabelContainer: CardView?
    @IBOutlet var iconIV: UIImageView?

    static let identifier = "QuoteCell"

    var viewModel: QuoteCellViewModel? {
        didSet {
            setupViewModel()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
