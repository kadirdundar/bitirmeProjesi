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
    
    func verileriAl(){
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("information").addSnapshotListener { [self] (snapshot, error) in
            if error != nil{
                print(error?.localizedDescription)
            }
            else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    var locationData: [[Double]] = []
                    for document in snapshot!.documents{
                        if let konum = document.get("location") as? GeoPoint{
                            self.locationData.append(konum)
                            yenikonum.append([konum.latitude, konum.longitude])
                            
                            
                        }
                    }
                    print(yenikonum)
                   print(yenikonum[0])//basarılı
                    verileriIsle()
                }
                
            }
        }
            
    }
    
    func verileriIsle(){
        let scaledata = ScaleData(data: yenikonum).scaleData(data: yenikonum)
        let k = 2
        let clusterer = KMeansClusterer(data: scaledata, k: k, maxElementCount: 20, iterations: 100)
        let clusters = clusterer.cluster()
        print(clusters)
    }
    


}
