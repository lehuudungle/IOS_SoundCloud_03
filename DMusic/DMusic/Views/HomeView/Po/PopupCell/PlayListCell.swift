//
//  PlayListCell.swift
//  DMusic
//
//  Created by le.huu.dung on 9/20/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Reusable
import SDWebImage

class PlayListCell: UITableViewCell, NibReusable {

    @IBOutlet weak var CurrentPlayView: NVActivityIndicatorView!
    @IBOutlet weak var artWork: UIImageView!
    @IBOutlet weak var nameTrack: UILabel!
    @IBOutlet weak var playMark: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CurrentPlayView.type = .audioEqualizer
        CurrentPlayView.isHidden = true
        CurrentPlayView.stopAnimating()
        CurrentPlayView.color = .navColor
        playMark.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fill(track: Track,_ isPlay: Bool) {
        clearData()
        nameTrack.text = track.title
        if let url = URL(string: track.artwork_url) {
            self.artWork.sd_setShowActivityIndicatorView(true)
            self.artWork.sd_setIndicatorStyle(.gray)
            self.artWork.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "personal_icon"), options: [.progressiveDownload], completed: nil)
        }
        if isPlay {
            CurrentPlayView.isHidden = false
            CurrentPlayView.stopAnimating()
            if TrackTool.shared.trackMessage.isPlaying {
                CurrentPlayView.startAnimating()
                return
            }
            CurrentPlayView.stopAnimating()
            CurrentPlayView.isHidden = true
            playMark.isHidden = false 
            return
        }
        CurrentPlayView.isHidden = true
        CurrentPlayView.stopAnimating()
    }
    
    func clearData() {
        self.nameTrack.text = ""
        self.artWork.image = #imageLiteral(resourceName: "artworks")
        CurrentPlayView.isHidden = true
        CurrentPlayView.stopAnimating()
        CurrentPlayView.color = .navColor
        playMark.isHidden = true
    }
    
}
