//
//  TitleCell.swift
//  DMusic
//
//  Created by Ledung95d on 9/16/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import Reusable

class TitleCell: UITableViewCell, NibReusable {

    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberTrack: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
