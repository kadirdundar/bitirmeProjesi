//
//  serviceForOptimize.swift
//  bitirmeProject
//
//  Created by Kadir Dündar on 16.05.2023.
//

import Foundation
import CoreLocation

func getDrivingRoute(from startLocation: String, endLoc: String,  withWaypoints waypointss: [String], optimize: String, apiKey: String,completion: @escaping([CLLocationCoordinate2D])->()) {
    
    var urlString = "https://dev.virtualearth.net/REST/v1/Routes/Driving?"
    urlString += "wp.0=\(startLocation)"
    
    for (index, waypoint) in waypointss.enumerated() {
        urlString += "&wp.\(index+1)=\(waypoint)"
    }
    let endPoint = "&wp.\(waypointss.count + 1)=\(endLoc)"  // burayı düzneliyorum
    urlString += endPoint
    print("urlstirn son hali222\(urlString)")
    urlString += "&optwp=true&optimize=\(optimize)&key=\(apiKey)"
    
    guard let url = URL(string: urlString) else {
        print("Error: Invalid URL")
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let data = data, error == nil else {
            print("Error: \(error?.localizedDescription ?? "Unknown error")")
            return
        }
        
        do {
            
                let decoder = JSONDecoder()
                let response = try decoder.decode(RouteResponse.self, from: data)
                
                if let resource = response.resourceSets.first?.resources.first {
                    let travelDistance = resource.travelDistance
                    let travelDuration = resource.travelDuration
                    let travelDurationTraffic = resource.travelDurationTraffic
                    let waypointsOrder = resource.waypointsOrder
                    
                    print("Travel Distance: \(travelDistance)")
                    print("Travel Duration: \(travelDuration)")
                    print("Travel Duration with Traffic: \(travelDurationTraffic)")
                    print("Waypoints Order: \(waypointsOrder)")
                    
                    var newSeries = Array(repeating: [Double](), count: waypointsOrder.count)
                    for (index,waypoint) in waypointsOrder.enumerated() {
                        if let iindex = waypoint.split(separator: ".").last, let sayi = Int(iindex) {
                            if sayi == 0 {
                                let coordinates = startLocation.split(separator: ",")
                                let latitude = Double(coordinates[0])
                                let longitude = Double(coordinates[1])
                                let locationArray: [Double] = [latitude ?? 0.0, longitude ?? 0.0]
                                print("locationnarray\(locationArray)\(sayi)")
                                newSeries[index] = locationArray
                            }
                            else if sayi == (waypointss.count + 1){
                                let coordinates = endLoc.split(separator: ",")
                                let latitude = Double(coordinates[0])
                                let longitude = Double(coordinates[1])
                                let locationArray: [Double] = [latitude ?? 0.0, longitude ?? 0.0]
                                print("locationnarray\(locationArray)\(sayi)")
                                newSeries[index] = locationArray
                            }
                           
                            else{
                                let coordinates = waypointss[sayi - 1].split(separator: ",")
                                print("separatorcoridante\(coordinates) \(sayi)")
                                let latitude = Double(coordinates[0])
                                let longitude = Double(coordinates[1])
                                let locationArray: [Double] = [latitude ?? 0.0, longitude ?? 0.0]
                                newSeries[index] = locationArray
                            }
                        }
                    }
                    print("yazıdkadkaldk \(newSeries)")
                    let locationCoordinates = newSeries.map { CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) }
                    completion(locationCoordinates)
                }
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    task.resume()
}




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
