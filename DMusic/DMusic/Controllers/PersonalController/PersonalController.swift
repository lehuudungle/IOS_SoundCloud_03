//
//  PersonalController.swift
//  DMusic
//
//  Created by le.huu.dung on 9/6/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import CoreData

class PersonalController: BaseUIViewcontroller, NIBBased {
    
    @IBOutlet private weak var personalTable: UITableView!
    
    var titleImage = [#imageLiteral(resourceName: "download"), #imageLiteral(resourceName: "shareblack")]
    var nameCell = ["Download", "Share"]
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        personalTable.register(cellType: TitleCell.self)
    }
}

extension PersonalController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as TitleCell
        let request = DownloadTrackData.fetchRequest() as NSFetchRequest<DownloadTrackData>
        do {
            cell.titleImage.image = titleImage[indexPath.row]
            cell.nameLabel.text = nameCell[indexPath.row]
            if indexPath.row == 0 {            
                let result = try context.fetch(request)
                cell.numberTrack.text = "\(result.count)"
            }
            
        } catch {}
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let detailTracks = DetailPersonalController.instantiate()
            self.navigationController?.pushViewController(detailTracks, animated: true)
        default:
            return
        }
    }
}

extension PersonalController {
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

