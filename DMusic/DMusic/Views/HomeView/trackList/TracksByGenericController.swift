//
//  TracksByGenericController.swift
//  DMusic
//
//  Created by le.huu.dung on 9/11/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import Reusable

class TracksByGenericController: UIViewController, AlertViewController, NIBBased {

    
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
        let fetchNextPage = (pageOffset + 1) * limit - 1 == indexPath.row
        if fetchNextPage {
            self.pageOffset += 1
            loadMoreData()
        }
    }
    
    func loadMoreData() {
        trackListRepository.fetchListOfSongs(linkURL: linkURL, limit: self.limit , offset: self.pageOffset) { (result) in
            switch result {
            case .success(let trackResponse):
                guard let infoTracks = trackResponse?.collection else { return }
                self.tracks += infoTracks
                self.tracksTable.reloadData()
            case .failure(let error):
                self.showErrorAlert(message: error?.errorMessage)
            }
        }
    }
}
