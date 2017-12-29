//
//  RouteCell.swift
//  BusRoute
//
//  Created by Michael Ardizzone on 12/29/17.
//  Copyright © 2017 Michael Ardizzone. All rights reserved.
//

import UIKit

class RouteCell: UITableViewCell {

    @IBOutlet var routeName: UILabel!
    @IBOutlet var busImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        routeName.adjustsFontSizeToFitWidth = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
