//
//  TrackTool.swift
//  DMusic
//
//  Created by le.huu.dung on 9/12/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
import SDWebImage

class TrackTool: NSObject {
    
    static let shared = TrackTool()
    var trackPlayer = AVPlayer()
    var trackMessage: TrackMessage = TrackMessage()
    var tracks: [Track] = [Track]()
    var downloadArray = [DownloadTrack]()
    var popUpDelegate: PopupControllerDelegate!
    let requiredAssetKeys = [
        "playable",
        "hasProtectedContent"
    ]
    private var playerItemContext = 0
    
    var trackIndex = -1 {
        didSet {
            if trackIndex < 0 {
                trackIndex = tracks.count - 1
            }
            if trackIndex > tracks.count - 1 {
                trackIndex = 0
            }
        }
    }
    
    var statusLoop = StatusLoop.LoopAll
    var isShuffle = false
    var isLoop = 0
    var isOnline = true
    
    override init() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
        } catch {
            print(error)
            return
        }

    }
    
    func setTrackMesseage(track: Track) {
        updateTrackMessage(track)
        print("track id : \(track.title)")
        trackIndex = tracks.index{$0 === track}!
        prepareTrack()
        playTrack()
    }
    
    func updateTrackMessage(_ track: Track) {
        if isOnline {
            track.artwork_url =  track.artwork_url.convertURL
            track.streamURL = URLs.getStreamURL(id: track.id)
            trackMessage.trackModel = track
            trackMessage.isPlaying = true
            trackMessage.totalTime = CMTime(seconds: Double(track.duration/1000), preferredTimescale: 1)
        } else {
            track.streamURL = track.downloadLocal
            trackMessage.trackModel = track
            trackMessage.isPlaying = true
            trackMessage.totalTime = CMTime(seconds: Double(track.duration/1000), preferredTimescale: 1)
        }
        setupLockScreen()
    }
    
    
    func prepareTrack() {
        guard  let trackModel = trackMessage.trackModel else {
            return
        }
        let asset = AVAsset(url: URL.init(string: trackModel.streamURL)!)
        let playerItem = AVPlayerItem(asset: asset,
                                      automaticallyLoadedAssetKeys: requiredAssetKeys)
        trackPlayer.replaceCurrentItem(with: playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    @objc func playerDidFinishPlaying() {
        print("ket thuc bai hat: \(statusLoop)")
        print("title bai ket thuc: \(trackMessage.trackModel?.title)")
        trackMessage.isPlaying = false
        switch statusLoop {
        case .LoopAll:
            nextTrack()
        case .LoopOne:
            setTrackMesseage(track: tracks[trackIndex])
        case .Shuffle:
            trackIndex = Int(arc4random_uniform(UInt32(tracks.count)))
            setTrackMesseage(track: tracks[trackIndex])
            print("trackIndexShuffle: \(trackIndex)")
        default:
            nextTrack()
        }
        popUpDelegate.updateInfoTrackDetail()
        TrackMessageView.shared.configView()
    }
    
    func playTrack() {
        trackPlayer.currentItem?.addObserver(self,
                                             forKeyPath: #keyPath(AVPlayerItem.status),
                                             options: [.old, .new],
                                             context: &playerItemContext)
        trackPlayer.play()
        trackMessage.isPlaying = true
        setupLockScreen()
    }
    
    func pauseTrack() {
        trackPlayer.pause()
        trackMessage.isPlaying = false
        setupLockScreen()
    }
    
    func nextTrack() {
        trackIndex += 1
        print("nextTrack: \(trackIndex)")
        setTrackMesseage(track: tracks[trackIndex])
        setupLockScreen()
    }
    
    func previousTrack() {
        trackIndex += -1
        setTrackMesseage(track: tracks[trackIndex])
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItemStatus
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            // Switch over status value
            switch status {
            case .readyToPlay:
                print("readToPlay")
                popUpDelegate.reallyPlayMusic()
                TrackMessageView.shared.readllyStartTrack()
            // Player item is ready to play.
            case .failed:
                // Player item failed. See error.
                print("failed TRACK")
            case .unknown:
                // Player item is not yet ready.
                print("unknown TRACK")
            }
        }
    }
    
    func remoteOldAVPlayer() {
        trackPlayer.replaceCurrentItem(with: nil)
    }
    
}
// MARK SetupLockScreen

extension TrackTool {
    func setupLockScreen() {
        guard let trackModel = trackMessage.trackModel else { return }
        let title = trackModel.title
        let generic = trackModel.genre
        let trackImageView = UIImageView()
        let url = URL(string: trackModel.artwork_url)
        trackImageView.sd_setShowActivityIndicatorView(true)
        trackImageView.sd_setIndicatorStyle(.gray)
        trackImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "artworks"), options: [.progressiveDownload], completed: nil)
        var playRate: NSNumber = 0
        if self.trackMessage.isPlaying {
            playRate = 1
        }
        
        var artWork: MPMediaItemArtwork!
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                print("trackImage: \(self.trackMessage.currentTime)")
                let imageSize = CGSize(width: 300, height: 300)
                artWork = MPMediaItemArtwork.init(boundsSize: (imageSize), requestHandler: { (size) -> UIImage in
                    return trackImageView.image!
                })
                let centerInfo = MPNowPlayingInfoCenter.default()
                centerInfo.nowPlayingInfo = [
                    MPMediaItemPropertyTitle: title,
                    MPMediaItemPropertyArtwork: artWork!,
                    MPNowPlayingInfoPropertyElapsedPlaybackTime: CMTimeGetSeconds(self.trackPlayer.currentTime()),
                    MPMediaItemPropertyPlaybackDuration: CMTimeGetSeconds(self.trackMessage.totalTime),
                    MPNowPlayingInfoPropertyPlaybackRate: playRate
                ]
            }
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    
}
