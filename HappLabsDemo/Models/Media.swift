//
//  Media.swift
//  HappLabsDemo
//
//  Created by Pramit on 25/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit
import AVKit

enum MediaType {
    case audio
    case image
    case video
}

class MediaDetail {
    
    var name: String?
    var type: MediaType?
    var avUrlAssset: AVURLAsset? // For video
    var audioUrl: URL? //For Audio
    var videoUrl: URL? // For recorded video
}
