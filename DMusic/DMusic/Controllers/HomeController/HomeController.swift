//
//  HomeController.swift
//  DMusic
//
//  Created by le.huu.dung on 9/6/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import MBProgressHUD

class HomeController: UIViewController, NIBBased, AlertViewController {
    private struct Constant {
        static let limit = 10
        static let countGeneric = 6
        static let countRows = 1
        static let titleNavigation = "Home"
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
        let infoTracks = tracksByGeneric[indexPath.section]
        cell.fill(infoTracks: infoTracks)
        return cell
    }
}
