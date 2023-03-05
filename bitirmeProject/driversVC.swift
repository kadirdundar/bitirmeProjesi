//
//  driversVC.swift
//  bitirmeProject
//
//  Created by Kadir Dündar on 5.03.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class driversVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        getLocation { konumlar in
            print(konumlar)
        }
        
    }
    
    func getInformationVehicle(completion: @escaping((Int)->())){
        guard let currentUser = Auth.auth().currentUser else {return}
        
        var aracNumarasi = Int()
        
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("control").whereField("email", isEqualTo: currentUser.email).getDocuments { snapshot, error in
            if error != nil {
                self.hatamesaji(baslık: "hata", text: "bir hata oluştu. \(error)")
            }
            else{
                for document in snapshot!.documents{
                    if let arac = document.data()["arac"] as? Int{
                        aracNumarasi = arac
                    }
                }
                completion(aracNumarasi)
            }
        }
    }
    func getLocation(completion: @escaping(([[Double]])->())){
        var locations = [[Double]]()
        let firestoreDatabase = Firestore.firestore()
        
        getInformationVehicle { sayi in
            firestoreDatabase.collection("information").whereField("arac", isEqualTo: sayi).getDocuments { snapshot, error in
                if error != nil {
                    self.hatamesaji(baslık: "hata", text: "bir hata oluştu. \(error)")
                }
                else{
                    for document in snapshot!.documents{
                        if let location = document.data()["location"] as? GeoPoint{
                            let coordinate = [location.latitude, location.longitude]
                            locations.append(coordinate)
                        }
                    }
                    completion(locations)
                }
            }
        }
        
    }
       
    func hatamesaji(baslık: String,text : String){
        let alert = UIAlertController(title: baslık, message: text, preferredStyle: UIAlertController.Style.alert)
        let button = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(button)
        present(alert, animated: true)
    }
 
}
