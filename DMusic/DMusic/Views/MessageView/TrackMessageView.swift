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
    var popupTimer = Timer()
    
    @IBOutlet private weak var nameTrackLabel: UILabel!
    @IBOutlet private weak var artWorkImage: UIImageView!
    @IBOutlet private weak var bottomTrackView: NSLayoutConstraint!
    @IBOutlet private weak var preButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    var trackMessage = TrackTool.shared.trackMessage
    var trackAvPlayer = TrackTool.shared.trackPlayer
    
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
        artWorkImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "artworks"), options: [.progressiveDownload], completed: nil)
        updateStatusButton()
        updateProgess()
    }
    
    func updateProgess() {
        popupTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(handerSider), userInfo: nil, repeats: true)
    }
    
    @objc func handerSider() {
        progressView.progress = Float(CMTimeGetSeconds(trackAvPlayer.currentTime()) / CMTimeGetSeconds(trackMessage.totalTime))
    }
    
    @IBAction func showPopUp(_ sender: Any) {
        showOldTrack()
    }
    
    func showOldTrack() {
        let popUpController = PopupController.instantiate()
        popUpController.showMessage = true
        let trackMessage = TrackTool.shared.trackMessage
        trackMessage.currentTime = TrackTool.shared.trackPlayer.currentTime()
        TrackTool.shared.updateListShuffle()
        MainController.shared.present(popUpController, animated: true, completion: nil)
    }
    
    
    @IBAction func playpauseButton(_ sender: Any) {
        if trackMessage.isPlaying {
            playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            TrackTool.shared.pauseTrack()
            popupTimer.invalidate()
            return
        }
        playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        TrackTool.shared.playTrack()
        popupTimer.fire()
        
        
    }
    
    func updateStatusButton() {
        if trackMessage.isPlaying {
            playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            return
        }
        playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        
    }
    
    @IBAction func nextTrack(_ sender: Any) {
        nextButton.isUserInteractionEnabled = false
        playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        TrackTool.shared.nextTrack()
        configView()
    }
    
    @IBAction func preTrack(_ sender: Any) {
        preButton.isUserInteractionEnabled = false
        playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        TrackTool.shared.previousTrack()
        configView()
    }
    
    func readllyStartTrack() {
        nextButton.isUserInteractionEnabled = true
        preButton.isUserInteractionEnabled = true
    }
    
}
