//
//  TrackMessage.swift
//  DMusic
//
//  Created by le.huu.dung on 9/13/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import Foundation
import CoreMedia

class TrackMessage: NSObject {
    var trackModel : Track?
    var currentTime = CMTime(seconds: 0, preferredTimescale: 1)
    var totalTime = CMTime(seconds: 0, preferredTimescale: 1)
    var isPlaying = false
    var urlLocal = ""
}
