//
//  kmeans.swift
//  bitirmeProject
//
//  Created by Kadir Dündar on 5.12.2022.
//

import Foundation
struct KMeansClusterer{
    let data: [[Double]]
    let k: Int
    let maxElementCount: Int
    let iterations: Int
    
    init(data: [[Double]], k: Int, maxElementCount: Int, iterations: Int) {
        self.data = data
        self.k = k
        self.maxElementCount = maxElementCount
        self.iterations = iterations
    }
    func cluster() -> [[[Double]]] {
        // Öncelikle verileri kümelerine ayrılacak şekilde rasgele dağıtıyoruz.
        var clusters = [[[Double]]](repeating: [], count: k)
        for datapoint in data {
            let clusterIndex = Int.random(in: 0..<k)
            clusters[clusterIndex].append(datapoint)
        }
        
        // K-means yöntemini uygulayarak kümeleri güncelliyoruz.
        // Bu işlem, küme merkezlerinin belirlenmesi ve verilerin kümelere
        // göre dağıtılmasını içerir.
        while true {
            let clusterCentroids = computeClusterCentroids(clusters: clusters)
            let updatedClusters = assignDataToClusters(clusters: clusters, centroids: clusterCentroids)
            
            // Eğer küme merkezleri ve verilerin dağılımı değişmemişse,
            // döngüyü sonlandırıyoruz.
            var hasChanged = false
            for i in 0..<k {
                if clusters[i].count != updatedClusters[i].count {
                    hasChanged = true
                    break
                }
            }
            if !hasChanged {
                break
            }
            clusters = updatedClusters
        }
        
        // Küme merkezlerini döndürmüyor, sadece verileri döndürüyoruz.
        return clusters.map { cluster in
            return cluster.map { datapoint in
                return datapoint
            }
        }
    }
    
    
    // Bu fonksiyon, verilen kümelerin merkezlerini hesaplar.
    func computeClusterCentroids(clusters: [[[Double]]]) -> [[Double]] {
        var clusterCentroids = [[Double]](repeating: [Double](repeating: 0.0, count: data[0].count), count: k)//Fatal error: Index out of range
        
        
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
    // This method assigns data points to clusters based on the given cluster centroids.
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

