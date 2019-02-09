//
//  RecordingsResult.swift
//  BirdSounds
//
//  Created by Nadim Alam on 04/02/2019.
//  Copyright © 2019 Nadim Alam. All rights reserved.
//

import Foundation

struct RecordingsResult {
    let recordings: [Recording]?
    let error: Error?
    let currentPage: Int
    let pageCount: Int
    
    var hasMorePages: Bool {
        return currentPage < pageCount
    }
    
    var nextPage: Int {
        return hasMorePages ? currentPage + 1 : currentPage
    }
    
}
