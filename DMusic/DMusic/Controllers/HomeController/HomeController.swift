//
//  HomeController.swift
//  DMusic
//
//  Created by le.huu.dung on 9/6/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import MBProgressHUD
import Reusable

protocol ShowTrackMessageDeletate {
    func showTrackMessage()
}


class HomeController: BaseUIViewcontroller, NIBBased, AlertViewController {
    private struct Constant {
        static let limit = 10
        static let countGeneric = 6
        static let countRows = 1
        static let titleNavigation = "Home"
        
        static let heightScreen = UIScreen.main.bounds.height
        static let widthScreen = UIScreen.main.bounds.width
        static let heightMessageTrack: CGFloat = 60
    }
    
    @IBOutlet private weak var tracksTableView: UITableView!
    
    private let trackListRepository: TrackRepository = TrackRepositoryImpl(api: APIService.shared)
    var tracksByGeneric = [Int: [InfoTrack]]()
    var offset = 0
    var allLinkURL = [LinkURL.allMusicURL,
                      LinkURL.allAudioURL,
                      LinkURL.alternativerockURL,
                      LinkURL.ambientURL,
                      LinkURL.classicalURL,
                      LinkURL.countryURL]
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        downloadFristData()
    }
    
    func configView() {
        tracksTableView.register(cellType: HomeTableViewCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = HomeController.Constant.titleNavigation
        TrackTool.shared.isOnline = true
        if !TrackMessageView.shared.view.isHidden {
            tracksTableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
    }
    
    func downloadFristData() {
        for itemLink in allLinkURL {
            loadUI(itemLink)
        }
    }
    
    func loadUI(_ linkURL: LinkURL) {
        let hub = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
        trackListRepository.fetchListOfSongs(linkURL: linkURL, limit: HomeController.Constant.limit, offset: 0) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success(let trackResponse):
                self.tracksByGeneric[linkURL.rawValue] = trackResponse?.collection
                hub.hide(animated: true)
                self.tracksTableView.reloadData()
            case .failure(let error):
                self.showErrorAlert(message: error?.errorMessage)
            }
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension HomeController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = GenericHeaderCell.loadFromNib()
        headerView.passDataCell(index: section)
        headerView.seeAll = {(linkGenenric) in
            let trackListController = TracksByGenericController.instantiate()
            if let firstTracks = self.tracksByGeneric[linkGenenric.rawValue] {
                trackListController.tracks += firstTracks
            }
            trackListController.linkURL = linkGenenric
            self.navigationController?.pushViewController(trackListController, animated: true)
        }
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Constant.countGeneric
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HomeController.Constant.countRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as HomeTableViewCell
        cell.didSelected = {(track) in
            
            print("indexPath:\(indexPath.section)")
            let infoTrackArray: [InfoTrack] = self.tracksByGeneric[indexPath.section]!
            let tracks = infoTrackArray.map({ (value) in
                return value.track!
            })
            TrackTool.shared.tracks = tracks
            print("track: \(tracks[0].title)")
            let trackMessage = TrackTool.shared.trackMessage
            if let trackModel = trackMessage.trackModel {
                if trackModel.id == track.id {
                    TrackMessageView.shared.showOldTrack()
                    return
                }
            }
            TrackTool.shared.isOnline = true
            TrackTool.shared.setTrackPlayer(track: track)
            let popUpController = PopupController.instantiate()
            self.navigationController?.present(popUpController, animated: true, completion: nil)
            
        }
        let infoTracks = tracksByGeneric[indexPath.section]
        cell.fill(infoTracks: infoTracks)
        return cell
    }
}

extension HomeController {
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
