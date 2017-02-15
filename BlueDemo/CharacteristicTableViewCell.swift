//
//  CharacteristicTableViewCell.swift
//  BlueDemo
//
//  Created by dev on 2017/2/15.
//  Copyright © 2017年 Chensh. All rights reserved.
//

import UIKit

class CharacteristicTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var propertyLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
