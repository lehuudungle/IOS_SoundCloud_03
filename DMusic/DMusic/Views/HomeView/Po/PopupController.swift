
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
    @IBOutlet private weak var artWorkImage: UIImageView!
    @IBOutlet private weak var nameTrackLabel: UILabel!
    @IBOutlet private weak var currentTimeLabel: UILabel!
    @IBOutlet private weak var totalTimeLabel: UILabel!
    @IBOutlet private weak var trackSlider: UISlider!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var pageController: UIPageControl!
    @IBOutlet private weak var preButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!
    
    
    
    var trackPlayer = TrackTool.shared.trackPlayer
    var trackMessage = TrackTool.shared.trackMessage
    var playLayer: AVPlayerLayer!
    var popupTimer = Timer()
    var showMessage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTrackDetails()
        TrackTool.shared.popUpDelegate = self
        
        // if show track message
        if showMessage {
            updateStatusPlay()
            setupSlider()
            progressTimer()
        }
        
    }
    
    func updateStatusPlay() {
        if trackMessage.isPlaying {
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            return
        }
        playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
    
    func setupTrackDetails() {
        configAVPlayer()
        currentTimeLabel.text = "00:00"
    }
    
    func setupSlider() {
        trackSlider.value = Float(CMTimeGetSeconds(trackPlayer.currentTime()) / CMTimeGetSeconds(trackMessage.totalTime))
        currentTimeLabel.text = trackPlayer.currentTime().convertCMTimeString
        self.totalTimeLabel.text = trackMessage.totalTime.convertCMTimeString
    }
    
    func configAVPlayer() {
        playLayer = AVPlayerLayer(player: TrackTool.shared.trackPlayer)
        playLayer.frame = playPauseButton.frame
        self.view.layer.addSublayer(playLayer)
        updateInfoTrackDetail()
    }
    
    func updateInfoTrackDetail() {
        guard let trackModel = trackMessage.trackModel else { return }
        nameTrackLabel.text = trackModel.title
        let url = URL(string: trackModel.artwork_url)
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
        
        if trackMessage.isPlaying {
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            TrackTool.shared.pauseTrack()
            return
        }
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        TrackTool.shared.playTrack()
    }
    
    @IBAction func popViewAction(_ sender: Any) {
        popupTimer.invalidate()
        TrackMessageView.shared.configView()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func nextTrack(_ sender: Any) {
        nextButton.isUserInteractionEnabled = false
        playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        TrackTool.shared.nextTrack()
        updateInfoTrackDetail()
    }
    
    @IBAction func preTrack(_ sender: Any) {
        preButton.isUserInteractionEnabled = false
        playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        TrackTool.shared.previousTrack()
        updateInfoTrackDetail()
    }
    
}

extension PopupController: PopupControllerDelegate {
    
    func reallyPlayMusic() {
        print("readlly: \(CMTimeGetSeconds(trackPlayer.currentTime()))")
        setupSlider()
        progressTimer()
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        nextButton.isUserInteractionEnabled = true
        preButton.isUserInteractionEnabled = true
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

extension PopupController {
    
}
