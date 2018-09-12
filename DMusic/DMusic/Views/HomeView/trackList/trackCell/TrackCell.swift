//
//  TrackCell.swift
//  DMusic
//
//  Created by le.huu.dung on 9/11/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import Reusable

class TrackCell: UITableViewCell, NibReusable {
    
    @IBOutlet private weak var trackImage: UIImageView!
    @IBOutlet private weak var nameTrackLabel: UILabel!
    @IBOutlet private weak var genericTrackLabel: UILabel!
    private struct Constant {
        static let defaultGeneric = "No Generic"
        static let defaultTitleTrack = "No Track"
        static let defaultImage = #imageLiteral(resourceName: "personal_icon")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fill(track: Track) {
        clearData()
        self.genericTrackLabel.text = track.genre
        nameTrackLabel.text = track.title
        if let url = URL(string: track.artwork_url) {
            self.trackImage.sd_setShowActivityIndicatorView(true)
            self.trackImage.sd_setIndicatorStyle(.gray)
            self.trackImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "personal_icon"), options: [.progressiveDownload], completed: nil)
        }
    }
    
    func clearData() {
        self.genericTrackLabel.text = TrackCell.Constant.defaultGeneric
        self.nameTrackLabel.text = TrackCell.Constant.defaultTitleTrack
        self.trackImage.image = TrackCell.Constant.defaultImage
    }
}
