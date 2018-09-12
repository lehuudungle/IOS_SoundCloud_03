
//
//  PopupController.swift
//  DMusic
//
//  Created by le.huu.dung on 9/12/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import Reusable
import AVKit
import AVFoundation
import SDWebImage

protocol PopupControllerDelegate {
    func reallyPlayMusic()
}
class PopupController: UIViewController, NIBBased {
    
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var preButton: UIButton!
    @IBOutlet private weak var artWorkImage: UIImageView!
    @IBOutlet private weak var nameTrackLabel: UILabel!
    @IBOutlet private weak var currentTimeLabel: UILabel!
    @IBOutlet private weak var totalTimeLabel: UILabel!
    @IBOutlet private weak var trackSlider: UISlider!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageController: UIPageControl!
    var trackPlayer = TrackTool.shared.trackPlayer
    var trackMessage = TrackTool.shared.trackMessage
    var isPlayer = false
    var playLayer: AVPlayerLayer!
    var popupTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTrackDetails()
        TrackTool.shared.popUpDelegate = self
    }
    
    func setupTrackDetails() {
        configAVPlayer()
        TrackTool.shared.playTrack()
    }
    
    func configAVPlayer() {
        playLayer = AVPlayerLayer(player: TrackTool.shared.trackPlayer)
        playLayer.frame = playPauseButton.frame
        self.view.layer.addSublayer(playLayer)
        guard let trackModel = trackMessage.trackModel,
            let url = URL(string: trackModel.artwork_url) else { return }
        artWorkImage.sd_setShowActivityIndicatorView(true)
        artWorkImage.sd_setIndicatorStyle(.gray)
        artWorkImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "artworks"), options: [.progressiveDownload], completed: nil)
    }
    
    @IBAction func changeValueSlider(_ sender: Any) {
        let totalSecond  = CMTimeGetSeconds(trackMessage.totalTime)
        let currentSecond = Float(totalSecond) * trackSlider.value
        let seeToTime = CMTime(value: CMTimeValue(currentSecond), timescale: 1)
        trackPlayer.seek(to: seeToTime) { (completion) in
        }
        self.currentTimeLabel.text = seeToTime.convertCMTimeString
        self.trackSlider.value = currentSecond / Float(totalSecond)
    }
    @IBAction func playAction(_ sender: Any) {
        if isPlayer {
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            TrackTool.shared.playTrack()
        } else {
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            TrackTool.shared.pauseTrack()
        }
        isPlayer = !isPlayer
    }
    
    @IBAction func popViewAction(_ sender: Any) {
        popupTimer.invalidate()
        TrackTool.shared.remoteOldAVPlayer()
        self.dismiss(animated: true, completion: nil)
    }
}

extension PopupController: PopupControllerDelegate {
    
    func reallyPlayMusic() {
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        setupSlider()
        progressTimer()
    }
    
    func setupSlider() {
        self.totalTimeLabel.text = trackMessage.totalTime.convertCMTimeString
        self.currentTimeLabel.text = trackMessage.currentTime.convertCMTimeString
    }
    
    func progressTimer() {
        popupTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(handerSider), userInfo: nil, repeats: true)
    }
    
    @objc func handerSider() {
        if !trackMessage.isPlaying {
            return
        }
        self.trackSlider.value = Float(CMTimeGetSeconds(trackPlayer.currentItem!.currentTime()) / CMTimeGetSeconds(trackMessage.totalTime))
        self.currentTimeLabel.text = trackPlayer.currentItem?.currentTime().convertCMTimeString
    }
}

// MARK UIScrollViewDelegate
extension PopupController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageController.currentPage = Int(pageIndex)
    }
}
