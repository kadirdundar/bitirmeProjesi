//
//  kmeans.swift
//  bitirmeProject
//
//  Created by Kadir Dündar on 5.12.2022.
//

import Foundation
struct KMeansClusterer {
    let data: [[Double]]
    let k: Int
    let maxElementCount: Int
    let tolerance: Double // Yeni parametre: küme merkezlerindeki değişimin eşiği
    init(data: [[Double]], k: Int, maxElementCount: Int, tolerance: Double) {
        self.data = data
        self.k = k
        self.maxElementCount = maxElementCount
        self.tolerance = tolerance
    }

    func cluster() -> [[[Double]]] {
        var clusters = [[[Double]]](repeating: [], count: k)
        for datapoint in data {
            let clusterIndex = Int.random(in: 0..<k)
            clusters[clusterIndex].append(datapoint)
        }

        var previousCentroids = [[Double]](repeating: [Double](repeating: 0.0, count: data[0].count), count: k)

        while true {
            let clusterCentroids = computeClusterCentroids(clusters: clusters)
            let updatedClusters = assignDataToClusters(clusters: clusters, centroids: clusterCentroids)

            var totalCentroidChange = 0.0
            for i in 0..<k {
                totalCentroidChange += computeDistance(datapoint: previousCentroids[i], centroid: clusterCentroids[i])
            }

            if totalCentroidChange <= tolerance {
                break
            }

            previousCentroids = clusterCentroids
            clusters = updatedClusters
        }

        return clusters.map { cluster in
            return cluster.map { datapoint in
                return datapoint
            }
        }
    }
    
    
    
    // Bu fonksiyon, verilen kümelerin merkezlerini hesaplar.
    func computeClusterCentroids(clusters: [[[Double]]]) -> [[Double]] {
        var clusterCentroids = [[Double]](repeating: [Double](repeating: 0.0, count: data[0].count), count: k)
        
        
        for i in 0..<k {
            for j in 0..<data[0].count {
                for datapoint in clusters[i] {
                    clusterCentroids[i][j] += datapoint[j]
                }
                clusterCentroids[i][j] /= Double(clusters[i].count)
            }
        }
        
        return clusterCentroids
    }
    // Bu fonksiyon, verileri verilen küme merkezlerine göre kümelere atar.
  
    func assignDataToClusters(clusters: [[[Double]]], centroids: [[Double]]) -> [[[Double]]] {
        var updatedClusters = [[[Double]]](repeating: [], count: k)
        
        for datapoint in data {
            var closestCentroidDistance = Double.greatestFiniteMagnitude
            var closestCentroidIndex = 0
            
            // Find the closest cluster centroid for the current data point.
            for i in 0..<k {
                let distance = computeDistance(datapoint: datapoint, centroid: centroids[i])
                if distance < closestCentroidDistance {
                    closestCentroidDistance = distance
                    closestCentroidIndex = i
                }
            }
            
            // If the closest cluster already has the maximum number of elements, search for the next closest cluster
            // that has fewer elements and assign the data point to that cluster instead.
            if updatedClusters[closestCentroidIndex].count >= maxElementCount {
                var nextClosestCentroidIndex = -1
                var nextClosestCentroidDistance = Double.greatestFiniteMagnitude
                
                for i in 0..<k {
                    // Skip the current closest cluster.
                    if i == closestCentroidIndex {
                        continue
                    }
                    
                    let distance = computeDistance(datapoint: datapoint, centroid: centroids[i])
                    if distance < nextClosestCentroidDistance && updatedClusters[i].count < maxElementCount {
                        nextClosestCentroidDistance = distance
                        nextClosestCentroidIndex = i
                    }
                }
                
                if nextClosestCentroidIndex != -1 {
                    // Assign the data point to the next closest cluster that has fewer elements.
                    updatedClusters[nextClosestCentroidIndex].append(datapoint)
                }
            }
            else {
                // Only add the data point to the cluster if the number of elements in the cluster is less than the maxElementCount value.
                updatedClusters[closestCentroidIndex].append(datapoint)
            }
        }
        
        return updatedClusters
    }
    
    
    // Bu fonksiyon, verilen verinin verilen küme merkezine olan uzaklığını hesaplar.
    func computeDistance(datapoint: [Double], centroid: [Double]) -> Double {
        var distance = 0.0
        for i in 0..<datapoint.count {
            distance += (datapoint[i] - centroid[i]) * (datapoint[i] - centroid[i])
        }
        return sqrt(distance)
        
    }
}
