//
//  AppGlobals.swift

import Foundation
import UIKit

/// Print Debug
func printDebug<T>(_ obj : T) {
    #if DEBUG
        print(obj)
    #endif
}
