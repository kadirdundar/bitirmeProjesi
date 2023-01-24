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
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verileriAl()
        //verileriIsle()
        // Do any additional setup after loading the view.
    }
    
    
    //let data = [[2.0,0.0]]
    //let scaledata = ScaleData(data: data)
    //let scaleddata = scaledata.scaleData(data: data)
    //let k = 4  kişi sayımıza göre belirlenecek
    //let clusterer = KMeansClusterer(data: scaledData, k: k, maxElementCount: 20, iterations: 350)
    //let clusters = clusterer.cluster()
    //let unscaleData = UnscaledData(clusters,data)
    //let unscaledData = unscaleData.unscaleData(clusters: clusters, data: data)
    // bütün veriler çekilecek k-means ile hesapkayığ gönderilecek
    
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
        let k = 5
        let clusterer = KMeansClusterer(data: scaledata, k: k, maxElementCount: 20, iterations: 350)
        let clusters = clusterer.cluster()
        
        let unscaleData = UnscaledData(clusters: clusters, data: yenikonum).unscaleData(clusters: clusters, data: yenikonum)
        
        let kumeSayisi = unscaleData.count
  
       var matchingDocuments = [[String]](repeating: [], count: kumeSayisi)
        
       
        
         documentIDAl()
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
            print(matchingDocuments[1])
            for i in 0..<matchingDocuments.count {
                //let document = matchingDocuments[i]
                let arac = i+1
                for j in 0..<matchingDocuments[i].count {
                    let documentID = matchingDocuments[i][j]
                    print(documentID)
                    
                    let updateData = ["arac": arac]
                    Firestore.firestore().collection("information").document(
                        documentID).updateData(["arac": 2]) { (error) in //arac:2 değeri değişecek birden fazla kez güncelleme işlmei yapıyor bu sorun çözülecek
                            if let error = error {
                                print("Error updating document with ID \(documentID): \(error)")
                            } else {
                                print("Document with ID \(documentID) successfully updated!")
                            }
                        }
                }
            }
            return
        }

    
    }
    

    
  

    
}


           
           
           
           
           
           
           

    


