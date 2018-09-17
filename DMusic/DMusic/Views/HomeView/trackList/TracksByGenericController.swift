//
//  TracksByGenericController.swift
//  DMusic
//
//  Created by le.huu.dung on 9/11/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import Reusable

class TracksByGenericController: BaseUIViewcontroller, AlertViewController, NIBBased {

    private struct Constant {
        static let limit = 10
        static let countGeneric = 6
        static let countRows = 1
        static let titleNavigation = "Home"
        static let heightScreen = UIScreen.main.bounds.height
        static let widthScreen = UIScreen.main.bounds.width
        static let heightMessageTrack: CGFloat = 60
    }
    @IBOutlet private weak var genericTrackLabel: UILabel!
    @IBOutlet private weak var tracksTable: UITableView!
    
    var tracks = [InfoTrack]()
    var linkURL = LinkURL.allAudioURL
    private let trackListRepository: TrackRepository = TrackRepositoryImpl(api: APIService.shared)
    var limit = 10
    var pageOffset = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    func configView() {
        genericTrackLabel.text = linkURL.titleGeneric
        tracksTable.register(cellType: TrackCell.self)
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension TracksByGenericController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as TrackCell
        cell.fill(track: tracks[indexPath.row].track)
        return cell 
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let fetchNextPage = pageOffset + limit - 1 == indexPath.row
        if fetchNextPage {
            self.pageOffset += limit
            loadMoreData()
        }
    }
    
    func loadMoreData() {
        trackListRepository.fetchListOfSongs(linkURL: linkURL, limit: self.limit , offset: self.pageOffset) { (result) in
            switch result {
            case .success(let trackResponse):
                guard let infoTracks = trackResponse?.collection else { return }
                self.tracks += infoTracks
                // update TrackTool
                print("loadMore")
                let trackArray = self.tracks.map({ (value) in
                    return value.track!
                })
                TrackTool.shared.tracks = trackArray
                self.tracksTable.reloadData()
            case .failure(let error):
                self.showErrorAlert(message: error?.errorMessage)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trackArray = tracks.map({ (value) in
            return value.track!
        })
        let trackItem = trackArray[indexPath.row]
        TrackTool.shared.tracks = trackArray
        let trackMessage = TrackTool.shared.trackMessage
        if let trackModel = trackMessage.trackModel {
            if trackModel.id == trackItem.id {
                TrackMessageView.shared.showOldTrack()
                return
            }
        }
        TrackTool.shared.isOnline = true
        TrackTool.shared.setTrackMesseage(track: trackItem)
        let popUpController = PopupController.instantiate()
        self.navigationController?.present(popUpController, animated: true, completion: nil)
    }
}
