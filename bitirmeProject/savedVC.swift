//
//  savedVC.swift
//  bitirmeProject
//
//  Created by Kadir Dündar on 28.10.2022.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class savedVC: UIViewController {
    
    @IBOutlet weak var carNumber: UILabel!
    @IBOutlet weak var emailInformationLabel: UILabel!
    var locationData = [GeoPoint]()
    var yenikonum = [[Double]]()
    var updateCalled = false
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verileriAl()
       
    }
    func getInformationOfVehicle(){
        guard let currentUser = FirebaseAuth.Auth.auth().currentUser?.email else { return }
        emailInformationLabel.text = currentUser
        
        Firestore.firestore().collection("information").whereField("email", isEqualTo: currentUser).getDocuments(completion: { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let document = snapshot?.documents.first {
                print(document)
                if let aracNumber = document.get("arac") as? Int {
                    self.carNumber.text = String(aracNumber)
                }
            }
        })

    }
    
    
    func verileriAl() {
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("information").getDocuments { [self] (snapshot, error) in
            if error != nil{
                print(error?.localizedDescription)
            }
            else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    
                    for document in snapshot!.documents{
                        if let konum = document.get("location") as? GeoPoint{
                            self.locationData.append(konum)
                            yenikonum.append([konum.latitude, konum.longitude])
                            //print(konum) <FIRGeoPoint: (41.132631, 28.328366)> konumdan gelen veri bu şekilde
                        }
                    }
                    print(yenikonum[0])//basarılı
                    verileriIsle()
                }
            }
        }
    }
    func verileriIsle(){
        let scaledata = ScaleData(data: yenikonum).scaleData(data: yenikonum)
        let k = Int(yenikonum.count/20)
      
        let clusterer = KMeansClusterer(data: scaledata, k: k, maxElementCount: 20, tolerance: 10000000)
        let clusters = clusterer.cluster()
        
        let unscaleData = UnscaledData(clusters: clusters, data: yenikonum).unscaleData(clusters: clusters, data: yenikonum)
       
        print("işelenecek veriler\(unscaleData)")
        let kumeSayisi = unscaleData.count
      

        var matchingDocuments = [[String]](repeating: [], count: kumeSayisi)
        
       
        
        documentIDAl()
        func documentIDAl() {
            let group = DispatchGroup()
            for i in 0..<kumeSayisi {
                for location in unscaleData[i] {
                    let longitude = location[1]
                    let latitude = location[0]
                    let point = [GeoPoint(latitude: latitude, longitude: longitude)]
                    let geoPoint = point[0]
                    group.enter()
                    let query = Firestore.firestore().collection("information").whereField("location", isEqualTo: geoPoint)
                    query.getDocuments { (snapshot, error) in
                        if let error = error {
                            print("Error getting documents: \(error)")
                        } else {
                            for document in snapshot!.documents {
                                matchingDocuments[i].append(document.documentID)
                            }
                        }
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main) {
                verileriGüncelle()
            }
        }
        let dispatchGroup = DispatchGroup()
        for i in 0..<kumeSayisi {
            for location in unscaleData[i] {
                let longitude = location[1]
                let latitude = location[0]
                let point = [GeoPoint(latitude: latitude, longitude: longitude)]
                let geoPoint = point[0]
                
                let query = Firestore.firestore().collection("information").whereField("location", isEqualTo: geoPoint)
                
                dispatchGroup.enter()
                query.getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        for document in snapshot!.documents {
                            matchingDocuments[i].append(document.documentID)
                        }
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            verileriGüncelle()
        }

 
        func verileriGüncelle(){
            if !updateCalled{
                
                for i in 0..<matchingDocuments.count {
                    
                    let arac = i+1
                    for j in 0..<matchingDocuments[i].count {
                        let documentID = matchingDocuments[i][j]
                        //print(documentID)
                        
                        let updateData = ["arac": arac]
                        Firestore.firestore().collection("information").document(
                            documentID).updateData(updateData) { (error) in
                                if let error = error {
                                    print("Error updating document with ID \(documentID): \(error)")
                                } else {
                                    print("Document with ID \(documentID) successfully updated!")
                                }
                                
                            }
                       
                    }
                }
               
                updateCalled = true
                self.getInformationOfVehicle()
            }
            
            
        }
        

    }
    
}


           
           
           
           
           
           
           

    


