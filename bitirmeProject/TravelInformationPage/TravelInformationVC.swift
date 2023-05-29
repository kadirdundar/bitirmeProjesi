//
//  TravelInformationVC.swift
//  bitirmeProject
//
//  Created by Kadir Dündar on 24.05.2023.
//

import UIKit
import Foundation
class TravelInformationVC: UIViewController {

    @IBOutlet weak var amountHybridFuel: UILabel!
    @IBOutlet weak var amountDieselFuel: UILabel!
    @IBOutlet weak var travelDuration: UILabel!
    
    @IBOutlet weak var travelDistance: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let data = DataStore.shared.data{
            travelDistance.text = data[0]
            travelDuration.text = data[1]
            
            if let travelDurationDouble = Double(data[0]) {
                let multiplied = travelDurationDouble * 13
                let result = multiplied / 100
                amountDieselFuel.text = String(result)
                
                let hybridResult = result * 0.7
                amountHybridFuel.text = String(Int(hybridResult))
            }
        }
    }
}
