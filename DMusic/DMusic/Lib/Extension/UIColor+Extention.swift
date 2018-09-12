//
//  UIColor+Extention.swift
//  DMusic
//
//  Created by le.huu.dung on 9/6/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import Foundation
import UIKit
import CoreMedia

extension UIColor {
    // #F5F5F5
    static var whiteSmoke: UIColor {
        return UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
    }
    // #808080
    static var grayColor: UIColor {
        return UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1)
    }
}

extension String {
    var convertURL: String {
        get{
            if !self.isEmpty {
                return self.replacingOccurrences(of: "-large", with: "-t300x300")
            }
            return ""
        }
    }
}

// MARK CMTime
extension CMTime {
    var convertCMTimeString: String {
        let totalSeconds = CMTimeGetSeconds(self)
        if totalSeconds.isNaN {
            return "00:00"
        }
        let hours:Int = Int(totalSeconds / 3600)
        let minutes:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        return hours > 0 ? String(format: "%i:%02i:%02i", hours, minutes, seconds):
        String(format: "%02i:%02i", minutes, seconds)
    }
}
