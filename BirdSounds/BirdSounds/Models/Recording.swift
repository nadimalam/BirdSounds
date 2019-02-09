//
//  Recording.swift
//  BirdSounds
//
//  Created by Nadim Alam on 04/02/2019.
//  Copyright © 2019 Nadim Alam. All rights reserved.
//

import Foundation

struct Recording: Codable {
    
    let genus: String
    let species: String
    let friendlyName: String
    let country: String
    let fileURL: URL
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case genus = "gen"
        case species = "sp"
        case friendlyName = "en"
        case country = "cnt"
        case date
        case fileURL = "file"
    }
}
