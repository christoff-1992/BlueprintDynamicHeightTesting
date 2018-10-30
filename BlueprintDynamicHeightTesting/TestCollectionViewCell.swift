//
//  TestCollectionViewCell.swift
//  BlueprintDynamicHeightTesting
//
//  Created by Chris on 30/10/2018.
//

import UIKit

class TestCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var subTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        configureStyle()
    }

    override func prepareForReuse() {
        textLabel.text = nil
        subTextLabel.text = nil
    }
}

extension TestCollectionViewCell {

    func configure(text: String, subText: String) {
        textLabel.text = text
        subTextLabel.text = subText
    }
}

private extension TestCollectionViewCell {

    func configureStyle() {
        layer.addShadow(color: .darkGray)
        layer.roundCorners(radius: 8)
    }
}
