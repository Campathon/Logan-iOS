//
//  DashboardTableViewCell.swift
//  Logan
//
//  Created by Anh Son Le on 5/6/18.
//  Copyright © 2018 campathon. All rights reserved.
//

import UIKit

class DashboardTableViewCell: UITableViewCell {

    @IBOutlet weak var imgAvt: UIImageView!
    @IBOutlet weak var imgCard: UIImageView!
    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var lblCard: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
