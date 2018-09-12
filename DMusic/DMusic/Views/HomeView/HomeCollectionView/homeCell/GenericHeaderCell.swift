//
//  GenericHeaderCell.swift
//  DMusic
//
//  Created by le.huu.dung on 9/10/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import Reusable

class GenericHeaderCell: UITableViewCell, NibLoadable {

    @IBOutlet private weak var genericLabel: UILabel!
    @IBOutlet private weak var seeAllButton: UIButton!
    
    var linkGenenric = LinkURL.allAudioURL
    var seeAll: ((_ linkGenenric: LinkURL) ->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func passDataCell(index: Int) {
        linkGenenric = LinkURL(rawValue: index)!
        genericLabel.text = linkGenenric.titleGeneric
    }
    
    @IBAction func seeAll(_ sender: Any) {
        if seeAll != nil {
            seeAll!(linkGenenric)
        }
    }
}
