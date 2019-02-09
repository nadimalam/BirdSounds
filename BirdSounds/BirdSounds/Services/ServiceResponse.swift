//
//  ServiceResponse.swift
//  BirdSounds
//
//  Created by Nadim Alam on 04/02/2019.
//  Copyright © 2019 Nadim Alam. All rights reserved.
//

import Foundation

struct ServiceResponse: Codable {
    let recordings: [Recording]
    let page: Int
    let numPages: Int
}
