//
//  NodeTableViewCell.swift
//  Annotator
//
//  Created by Philip Kluz on 2019-01-05.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

public class NodeTableViewCell: UITableViewCell {
    
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var subtitleLabel: UILabel!
    @IBOutlet public var iconImageView: UIImageView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.layer.cornerRadius = 5.0
        iconImageView.layer.borderColor = UIColor.darkGray.withAlphaComponent(0.4).cgColor
        iconImageView.layer.borderWidth = 1.5
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.05 : 0.0) {
            self.contentView.backgroundColor = selected ? UIColor(white: 0.93, alpha: 1.0) : .white
        }
    }
    
    public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.05 : 0.0) {
            self.contentView.backgroundColor = highlighted ? UIColor(white: 0.93, alpha: 1.0) : .white
        }
    }
}
