//
//  DataModel.swift
//  bitirmeProject
//
//  Created by Kadir Dündar on 24.05.2023.
//

import Foundation

struct RouteResponse: Codable {
    let resourceSets: [ReesourceSet]
}

struct ReesourceSet: Codable {
    let resources: [CustomResource]
}

struct CustomResource: Codable {
    let travelDistance: Double
    let travelDuration: Int
    let travelDurationTraffic: Int
    let waypointsOrder: [String]
}
