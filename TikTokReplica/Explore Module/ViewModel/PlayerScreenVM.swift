//
//  PlayerScreenVM.swift
//  Rizzle
//
//  Created by Nimish Sharma on 18/05/20.
//  Copyright © 2020 Nimish Sharma. All rights reserved.
//

import Foundation

class PlayerScreenVM {
    
    private(set) var video: Video
    private(set) var index: Int
    
    init( video: Video, index: Int) {
        self.video = video
        self.index = index
    }
    
}
