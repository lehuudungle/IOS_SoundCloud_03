//
//  CategoryCell.swift
//  DMusic
//
//  Created by le.huu.dung on 9/10/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import Reusable
import SDWebImage
class CategoryCell: UICollectionViewCell, NibReusable {
    private struct Constant {
        static let defaultImage = #imageLiteral(resourceName: "personal_icon")
        static let defaultTitle = "No Track"
    }
    
    @IBOutlet private weak var trackImage: UIImageView!
    @IBOutlet private weak var nameTrackLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func fill(track: Track?) {
        clearData()
        guard let track = track else { return }
        nameTrackLabel.text = track.title
        if let url = URL(string: track.artwork_url) {
            self.trackImage.sd_setShowActivityIndicatorView(true)
            self.trackImage.sd_setIndicatorStyle(.gray)
            self.trackImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "personal_icon"), options: [.progressiveDownload], completed: nil)
        }
    }
    
    func clearData() {
        self.trackImage.image = CategoryCell.Constant.defaultImage
        self.nameTrackLabel.text = CategoryCell.Constant.defaultTitle
    }
}
