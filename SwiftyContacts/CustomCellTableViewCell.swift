//
//  CustomCellTableViewCell.swift
//  SwiftyContacts
//
//  Created by Patrick Cooke on 5/10/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class CustomCellTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
//    @IBOutlet weak var rating1StackView: UIStackView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
