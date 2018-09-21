
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
import NFDownloadButton
import CoreData

protocol PopupControllerDelegate {
    func reallyPlayMusic()
    func updateInfoTrackDetail()
    func updateScrollTable()
}

class PopupController: BaseUIViewcontroller, NIBBased {
    
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
    @IBOutlet private weak var shuffleButton: UIButton!
    @IBOutlet private weak var loopButton: UIButton!
    @IBOutlet private weak var downloadTrack: NFDownloadButton!
    
    @IBOutlet weak var playListTable: UITableView!
    
    var trackPlayer = TrackTool.shared.trackPlayer
    var trackMessage = TrackTool.shared.trackMessage
    var playLayer: AVPlayerLayer!
    var popupTimer = Timer()
    var showMessage = false
    var isShuffle = false
    var statusLoop = StatusLoop.LoopAll
    var indexStatusLoop = 0 {
        didSet {
            if indexStatusLoop > 2 {
                indexStatusLoop = 0
            }
        }
    }
    private let trackListRepository: TrackRepository = TrackRepositoryImpl(api: APIService.shared)
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<DownloadTrackData>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTrackDetails()
        TrackTool.shared.popUpDelegate = self
        updateStatusLoop()
        // if show track message
        if showMessage {
            updateInfoTrackDetail()
            updateStatusPlay()
            updateStatusLoop()
            setupSlider()
            progressTimer()
        }
        
        self.playListTable.register(cellType: PlayListCell.self)
        self.playListTable.delegate = self
        self.playListTable.dataSource = self
        self.updateScrollTable()
    }
    
    func updateStatusLoop() {
        isShuffle = TrackTool.shared.isShuffle
        indexStatusLoop = TrackTool.shared.isLoop
        shuffleButton.setImage(TrackTool.shared.isShuffle ? #imageLiteral(resourceName: "shuffleSelected") : #imageLiteral(resourceName: "shuffle"), for: .normal)
        if indexStatusLoop == 0 {
            loopButton.setImage(#imageLiteral(resourceName: "loop"), for: .normal)
        } else if indexStatusLoop == 1 {
            loopButton.setImage(#imageLiteral(resourceName: "loopAll"), for: .normal)
        } else if indexStatusLoop == 2 {
            loopButton.setImage(#imageLiteral(resourceName: "loop1"), for: .normal)
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
        downloadTrack.isHidden = trackModel.downloadURL.isEmpty ? true : false
        downloadTrack.downloadState = .toDownload
        updateStatusDownload()
        self.playListTable.reloadData()
    }
    
    func updateStatusDownload() {
        let request = DownloadTrackData.fetchRequest() as NSFetchRequest<DownloadTrackData>
        do {
            guard let trackModel = trackMessage.trackModel else { return }
            let result = try context.fetch(request)
            for data in result as [DownloadTrackData] {
                if data.id == trackModel.id {
                    downloadTrack.downloadState = .downloaded
                }
            }
        } catch {
            print("error coredata")
        }
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
            self.playListTable.reloadData()
            return
        }
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        TrackTool.shared.playTrack()
        self.playListTable.reloadData()
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
        //        playListTable.reloadData()
        updateScrollTable()
    }
    
    @IBAction func preTrack(_ sender: Any) {
        preButton.isUserInteractionEnabled = false
        playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        TrackTool.shared.previousTrack()
        updateInfoTrackDetail()
        updateScrollTable()
    }
    
    func updateScrollTable() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let indexPath = IndexPath.init(row: TrackTool.shared.trackIndex, section: 0)
            self.playListTable.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    
    @IBAction func shuffleAction(_ sender: Any) {
        isShuffle = !isShuffle
        shuffleButton.setImage(isShuffle ? #imageLiteral(resourceName: "shuffleSelected") : #imageLiteral(resourceName: "shuffle"), for: .normal)
        actionLoop()
        TrackTool.shared.isShuffle = isShuffle
        TrackTool.shared.shuffleTrack()
        updateInfoTrackDetail()
        playListTable.reloadData()
        updateScrollTable()
    }
    
    @IBAction func loopAction(_ sender: Any) {
        indexStatusLoop += 1
        if indexStatusLoop == 0 {
            loopButton.setImage(#imageLiteral(resourceName: "loop"), for: .normal)
        } else if indexStatusLoop == 1 {
            loopButton.setImage(#imageLiteral(resourceName: "loopAll"), for: .normal)
        } else if indexStatusLoop == 2 {
            loopButton.setImage(#imageLiteral(resourceName: "loop1"), for: .normal)
        }
        actionLoop()
        TrackTool.shared.isLoop = indexStatusLoop
        playListTable.reloadData()
    }
    
    func actionLoop() {
        if indexStatusLoop < 0 {
            indexStatusLoop += 1
        }
        print("trang thai: \(indexStatusLoop)")
        switch indexStatusLoop {
        case 0:
            TrackTool.shared.statusLoop = isShuffle ? StatusLoop.Shuffle : StatusLoop.LoopAll
        case 1:
            TrackTool.shared.statusLoop = isShuffle ? StatusLoop.Shuffle : StatusLoop.LoopAll
        case 2:
            TrackTool.shared.statusLoop = StatusLoop.LoopOne
        default:
            TrackTool.shared.statusLoop = StatusLoop.LoopAll
        }
    }
    
    
    @IBAction func changeState(_ sender: NFDownloadButton) {
        
        guard let trackModel = trackMessage.trackModel else { return }
        if sender.downloadState == .toDownload {
            sender.downloadState = .willDownload
            DownloadCenter().getTrackFromServer()
            NotificationCenter.default.addObserver(self, selector: #selector(self.updatePercenDownload(notification:)), name: Notification.Name("percentDownload"), object: nil)
        } else if sender.downloadState == .downloaded {
            
            sender.downloadState = .toDownload
            
        }
    }
    
    @objc func updatePercenDownload(notification: Notification) {
        let userInfo = notification.userInfo as! [String: Double]
        downloadTrack.downloadPercent = CGFloat(userInfo["percentDownload"]!)
    }
    
    func getSaveFileUrl(idTrack: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let nameUrl = URL(string: idTrack)
        let fileURL = documentsURL.appendingPathComponent((nameUrl!.lastPathComponent)).appendingPathExtension("mp3")
        print("duong dan: \(fileURL.absoluteString)")
        return fileURL;
    }
    
}
// MARK: PopupControllerDelegate
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

// Download Music

extension PopupController {
    func saveTrack(_ saveURL: URL) {
        let downloadData = DownloadTrackData(entity: DownloadTrackData.entity(), insertInto: context)
        guard let trackModel = trackMessage.trackModel else { return }
        downloadData.artwork_url = trackModel.artwork_url
        downloadData.duration = Int64(trackModel.duration)
        downloadData.id = trackModel.id
        downloadData.url_local = "\(saveURL)"
        downloadData.title = trackModel.title
        downloadData.genre = trackModel.genre
        appDelegate.saveContext()
    }
}

extension PopupController {
    override func remoteControlReceived(with event: UIEvent?) {
        if let event  = event  {
            if event.type == .remoteControl {
                switch event.subtype {
                case .remoteControlPlay:
                    
                    TrackTool.shared.playTrack()
                    print("play")
                case .remoteControlPause:
                    TrackTool.shared.pauseTrack()
                    print("pause")
                case .remoteControlNextTrack:
                    TrackTool.shared.nextTrack()
                    print("nextTrack")
                case .remoteControlPreviousTrack:
                    TrackTool.shared.previousTrack()
                    print("previosuTrack")
                default:
                    print("Not display")
                }
                
            }
        }
    }
}

// MARK: PLAYLIST VIEW
extension PopupController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrackTool.shared.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as PlayListCell
        var isPlay = false
        if indexPath.row == TrackTool.shared.trackIndex {
            isPlay = true
        }
        cell.fill(track: TrackTool.shared.tracks[indexPath.row], isPlay)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did Selected: \(indexPath.row)")
        if indexPath.row != TrackTool.shared.trackIndex {
            nextButton.isUserInteractionEnabled = false
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            TrackTool.shared.selectedTrackInPlaylist(index: indexPath.row)
            updateInfoTrackDetail()
            updateScrollTable()
        }
    }
}

enum StatusLoop: Int {
    case LoopAll, LoopOne, Shuffle
    case countCase
}

