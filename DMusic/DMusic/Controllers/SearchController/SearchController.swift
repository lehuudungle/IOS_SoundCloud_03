//
//  SearchController.swift
//  DMusic
//
//  Created by Ledung95d on 9/17/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import Reusable

class SearchController: BaseUIViewcontroller, NIBBased, AlertViewController {

    struct Constant {
        static let limit = 20
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var resultTracks = [Track]()
    var workItem: DispatchWorkItem?
    private let trackListRepository: TrackRepository = TrackRepositoryImpl(api: APIService.shared)
    var offset = 0
    var keySearch = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(cellType: TrackCell.self)
    }
}

extension SearchController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as TrackCell
        cell.fill(track: resultTracks[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let fetchNextPage = offset + Constant.limit - 1 == indexPath.row
        if fetchNextPage {
            self.offset += Constant.limit
            loadMore()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trackItem = resultTracks[indexPath.row]
        TrackTool.shared.tracks = resultTracks
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

extension SearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.workItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.keySearch = searchBar.text!
            self!.loadMore()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: workItem)
        self.workItem = workItem
        return true
    }
    
    func loadMore() {
        trackListRepository.searchForSongsByKey(key: keySearch, limit: SearchController.Constant.limit, offset: offset) { (result) in
            switch result {
            case .success(let trackResponse):
                guard let trackArray = trackResponse?.collection else { return }
                self.resultTracks += trackArray
                self.resultLabel.text = "\(trackResponse!.total_results!) Result"
                self.tableView.reloadData()
            case .failure(let error):
                self.showErrorAlert(message: error?.errorMessage)
            }
        }
    }
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.resultLabel.text = "0 Result"
        resultTracks = [Track]()
        tableView.reloadData()
        self.searchBar.endEditing(true)
    }
}

extension SearchController {
    override func remoteControlReceived(with event: UIEvent?) {
        if let event  = event  {
            if event.type == .remoteControl {
                switch event.subtype {
                case .remoteControlPlay:
                    TrackTool.shared.playTrack()
                case .remoteControlPause:
                    TrackTool.shared.pauseTrack()
                case .remoteControlNextTrack:
                    TrackTool.shared.nextTrack()
                case .remoteControlPreviousTrack:
                    TrackTool.shared.previousTrack()
                default:
                    print("Not display")
                }
                
            }
        }
    }
}
