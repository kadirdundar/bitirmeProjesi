//
//  kmeans.swift
//  bitirmeProject
//
//  Created by Kadir Dündar on 5.12.2022.
//

import Foundation

struct Kmeans{
    
    func k_means(numCenters : Int,convergeDistance : Double,points : [[Double]])-> [[Double]]{
       
        var center = [[Double]]()
        var i = 0
        while(i<numCenters){
            i = i + 1
            center.append(points.randomElement()!)
        }
        
        var centerMoveDist = 0.0
        repeat{
            let zeros = [Double](count: points[0].length, repeatedValue: 0)
            
        }
                
        
        return points
    }
}
