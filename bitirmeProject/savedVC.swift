//
//  savedVC.swift
//  bitirmeProject
//
//  Created by Kadir Dündar on 28.10.2022.
//

import UIKit
import FirebaseFirestore

class savedVC: UIViewController {
    
    var locationData = [GeoPoint]()
    var yenikonum = [[Double]]()
    var updateCalled = false
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verileriAl()
       
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
        print("kümeSayisi\(k)")
        print("***eleman sayisi \(yenikonum.count)")
        let clusterer = KMeansClusterer(data: scaledata, k: k, maxElementCount: 20, iterations: 500)
        let clusters = clusterer.cluster()
        
        let unscaleData = UnscaledData(clusters: clusters, data: yenikonum).unscaleData(clusters: clusters, data: yenikonum)
        print("222222 \(clusters)")
        
        let kumeSayisi = unscaleData.count
        print("unscaleEdilmiş küme sayisi\(kumeSayisi)")
        print("*0*0*0*0*0\(unscaleData)")
        print("scakeddata \(scaledata[1].count)")
        for i in 0...4{
        print("clusterr \(clusters[i].count)")
            print("unscaleeclusterr \(unscaleData[i].count)")
                  
                  }

        var matchingDocuments = [[String]](repeating: [], count: kumeSayisi)
        
       
        
        // documentIDAl()
        func documentIDAl() {
            for i in 0..<kumeSayisi {
                for location in unscaleData[i] {
                    let longitude = location[1]
                    let latitude = location[0]
                    let point = [GeoPoint(latitude: latitude, longitude: longitude)]
                    let geoPoint = point[0]
                    let query = Firestore.firestore().collection("information").whereField("location", isEqualTo: geoPoint)
                    query.getDocuments { (snapshot, error) in
                        if let error = error {
                            print("Error getting documents: \(error)")
                        } else {
                            for document in snapshot!.documents {
                                matchingDocuments[i].append(document.documentID)
                            }
                            checkMatchingDocuments()
                        }
                    }
                }
            }
        }

        func checkMatchingDocuments() {
            var allDocumentsRetrieved = true
            for i in 0..<matchingDocuments.count {
                if matchingDocuments[i].isEmpty {
                    allDocumentsRetrieved = false
                    break
                }
            }
            if allDocumentsRetrieved {
                verileriGüncelle()
            }
        }

 
        func verileriGüncelle(){
            if !updateCalled{
                print(matchingDocuments[2])
                for i in 0..<matchingDocuments.count {
                    //let document = matchingDocuments[i]
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
            }
            
        }

    }
    
}


           
           
           
           
           
           
           

    


