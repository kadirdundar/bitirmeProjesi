//
//  UnscaleData.swift
//  bitirmeProject
//
//  Created by Kadir Dündar on 10.12.2022.
//

import Foundation


struct UnscaledData{
    
    let clusters: [[[Double]]]
    let data: [[Double]]
    
    init(clusters: [[[Double]]], data: [[Double]]) {
        self.clusters = clusters
        self.data = data
    }
   
    
    func unscaleData(clusters: [[[Double]]], data: [[Double]]) -> [[[Double]]] {
        // Find the minimum and maximum values for each feature in the original data.
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
        
        // Unscale the data points in each cluster using the original minimum and maximum values.
        var unscaledClusters = [[[Double]]]()
        for cluster in clusters {
            var unscaledCluster = [[Double]]()
            for datapoint in cluster {
                var unscaledDatapoint = [Double]()
                for i in 0..<datapoint.count {
                    let scaledValue = datapoint[i]
                    let min = mins[i]
                    let max = maxes[i]
                    let unscaledValue = min + scaledValue * (max - min)
                    unscaledDatapoint.append(unscaledValue)
                }
                unscaledCluster.append(unscaledDatapoint)
            }
            unscaledClusters.append(unscaledCluster)
        }
        
        return unscaledClusters
    }

    
}
