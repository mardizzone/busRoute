//
//  Models.swift
//  BusRoute
//
//  Created by Michael Ardizzone on 12/29/17.
//  Copyright © 2017 Michael Ardizzone. All rights reserved.
//

struct Route : Codable {
    let id: String
    let accessible: Bool
    let imageUrl: String?
    let name: String
    let description: String
    let stops: [Stop]
}

struct Stop : Codable {
    let name : String
}

