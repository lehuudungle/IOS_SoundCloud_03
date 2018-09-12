//
//  HomeTableViewCell.swift
//  DMusic
//
//  Created by le.huu.dung on 9/10/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import Reusable

class HomeTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var itemCollectionView: UICollectionView!
    
    var tracks = [Track]()
    var didSelected: ((_ track: Track) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configCell()
    }
    func configCell() {
        itemCollectionView.register(cellType: CategoryCell.self)
        itemCollectionView.delegate = self
        itemCollectionView.dataSource = self
        itemCollectionView.contentInset = UIEdgeInsetsMake(0, 10, 0, 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fill(infoTracks: [InfoTrack]?) {
        guard let infoTracks = infoTracks else {
            return
        }
        tracks = infoTracks.map { (infoTracks)in
            return infoTracks.track
        }
        itemCollectionView.reloadData()
    }
}

extension HomeTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as CategoryCell
        cell.fill(track: tracks[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let didSelected = didSelected {
            didSelected(tracks[indexPath.row])
        }
    }
}
