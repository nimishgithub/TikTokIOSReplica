//
//  ExploreScreenVM.swift
//  Rizzle
//
//  Created by Nimish Sharma on 16/05/20.
//  Copyright © 2020 Nimish Sharma. All rights reserved.
//

import Foundation

class ExploreScreenVM {
    
    private(set) var dataSource: [CategoryModel] = []
    
    //Call Method To Fetch Data From Server (From JSON file in current case)
    func fetchDataFromServer(_ requestFinished: @escaping()->Void, _ errorOccured: @escaping(Error)->Void) {
        
        if let path = Bundle.main.path(forResource: "ExploreData", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                self.dataSource = try JSONDecoder().decode([CategoryModel].self, from: data)
                requestFinished()
            } catch {
                printDebug("==== Parsing Error =====")
                errorOccured(error)
            }
        }
    }
    
    
}
