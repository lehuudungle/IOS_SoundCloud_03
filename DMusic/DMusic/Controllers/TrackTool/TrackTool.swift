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

class TrackTool: NSObject {
    
    static let shared = TrackTool()
    var trackPlayer = AVPlayer()
    var trackMessage: TrackMessage = TrackMessage()
    var tracks: [Track] = [Track]()
    var popUpDelegate: PopupControllerDelegate!
    let requiredAssetKeys = [
        "playable",
        "hasProtectedContent"
    ]
    private var playerItemContext = 0
    
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
        
        track.artwork_url =  track.artwork_url.convertURL
        track.streamURL = URLs.getStreamURL(id: track.id)
        trackMessage.trackModel = track
        trackMessage.isPlaying = true
        print("image urL :\(trackMessage.trackModel?.title)")
        print("trackPlyer: \(trackPlayer.currentTime().convertCMTimeString)")
        trackMessage.totalTime = CMTime(seconds: Double(track.duration/1000), preferredTimescale: 1)
        
        let asset = AVAsset(url: URL.init(string: track.streamURL)!)
        let playerItem = AVPlayerItem(asset: asset,
                                      automaticallyLoadedAssetKeys: requiredAssetKeys)
        trackPlayer.replaceCurrentItem(with: playerItem)

        playTrack()
    }
    
    func playTrack() {
        trackPlayer.currentItem?.addObserver(self,
                                            forKeyPath: #keyPath(AVPlayerItem.status),
                                            options: [.old, .new],
                                            context: &playerItemContext)
        trackPlayer.play()
        trackMessage.isPlaying = true
    }
    
    func pauseTrack() {
        trackPlayer.pause()
        trackMessage.isPlaying = false
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
            // Player item is ready to play.
            case .failed:
                // Player item failed. See error.
                print("failed")
            case .unknown:
                // Player item is not yet ready.
                print("unknown")
            }
        }
    }
    
    func remoteOldAVPlayer() {
        trackPlayer.replaceCurrentItem(with: nil)
    }
}
