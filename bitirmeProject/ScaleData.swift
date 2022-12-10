//
//  ScaleData.swift
//  bitirmeProject
//
//  Created by Kadir Dündar on 10.12.2022.
//

import Foundation
struct ScaleData{
    let data : [[Double]]
    
    init(data: [[Double]]) {
        self.data = data
    }
    
    func scaleData(data: [[Double]]) -> [[Double]] {
        // Find the minimum and maximum values for each feature.
        var mins = [Double](repeating: Double.greatestFiniteMagnitude, count: data[0].count)
        var maxes = [Double](repeating: -Double.greatestFiniteMagnitude, count: data[0].count)
        for datapoint in data {
            for i in 0..<datapoint.count {
                let value = datapoint[i]
                if value < mins[i] {
                    mins[i] = value
                }
                if value > maxes[i] {
                    maxes[i] = value
                }
            }
        }
        
        // Scale the data using Min-Max scaling.
        var scaledData = [[Double]]()
        for datapoint in data {
            var scaledDatapoint = [Double]()
            for i in 0..<datapoint.count {
                let value = datapoint[i]
                let min = mins[i]
                let max = maxes[i]
                let scaledValue = (value - min) / (max - min)
                scaledDatapoint.append(scaledValue)
            }
            scaledData.append(scaledDatapoint)
        }
        
        return scaledData
    }
}
