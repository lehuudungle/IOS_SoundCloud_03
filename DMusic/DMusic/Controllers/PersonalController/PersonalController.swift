//
//  PersonalController.swift
//  DMusic
//
//  Created by le.huu.dung on 9/6/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import CoreData

class PersonalController: UIViewController, NIBBased {
    
    @IBOutlet private weak var personalTable: UITableView!
    
    var titleImage = [#imageLiteral(resourceName: "download"), #imageLiteral(resourceName: "shareblack")]
    var nameCell = ["Download", "Share"]
    
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
        cell.titleImage.image = titleImage[indexPath.row]
        cell.nameLabel.text = nameCell[indexPath.row]
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

