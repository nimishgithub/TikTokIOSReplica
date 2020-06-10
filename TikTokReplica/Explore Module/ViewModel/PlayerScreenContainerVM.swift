//
//  PlayerScreenContainerVM.swift
//  Rizzle
//
//  Created by Nimish Sharma on 17/05/20.
//  Copyright © 2020 Nimish Sharma. All rights reserved.
//

import Foundation


class PlayerScreenContainerVM {
    
    // These must be videos from the same category
    private(set) var videos: [Video]
    
    init(_ videos: [Video]) {
        self.videos = videos
    }

}
