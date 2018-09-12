//
//  TrackMessageView.swift
//  DMusic
//
//  Created by le.huu.dung on 9/13/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import Reusable

import SDWebImage
import CoreMedia

class TrackMessageView: UIViewController {
    struct Constant {
        static let heightTrackMessage: CGFloat = 60
    }
    static let shared = TrackMessageView()
    
    
    @IBOutlet private weak var nameTrackLabel: UILabel!
    @IBOutlet private weak var artWorkImage: UIImageView!
    @IBOutlet private weak var bottomTrackView: NSLayoutConstraint!
    
    @IBOutlet weak var playButton: UIButton!
    var trackMessage = TrackTool.shared.trackMessage
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    func configView() {
        view.isHidden = false
        guard let trackModel = trackMessage.trackModel else { return }
        nameTrackLabel.text = trackModel.title
        let url = URL(string: trackModel.artwork_url) 
        artWorkImage.sd_setShowActivityIndicatorView(true)
        artWorkImage.sd_setIndicatorStyle(.gray)
        print("urlImage; \(url)")
        artWorkImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "artworks"), options: [.progressiveDownload], completed: nil)
        updateTrackView()
    }
    
    func clearData() {
        
    }
    
    
    @IBAction func showPopUp(_ sender: Any) {
        showOldTrack()
    }
    
    func showOldTrack() {
        let popUpController = PopupController.instantiate()
        popUpController.showMessage = true
        let trackMessage = TrackTool.shared.trackMessage
        trackMessage.currentTime = TrackTool.shared.trackPlayer.currentTime()
        MainController.shared.present(popUpController, animated: true, completion: nil)
    }
    
    
    @IBAction func playpauseButton(_ sender: Any) {
        if trackMessage.isPlaying {
            playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            TrackTool.shared.pauseTrack()
            return
        }
        playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        TrackTool.shared.playTrack()
        
    }
    
    func updateTrackView() {
        if trackMessage.isPlaying {
            playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            return
        }
        playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        
    }
    
    @IBAction func next(_ sender: Any) {
    }
    @IBOutlet weak var pre: UIButton!
    

}
