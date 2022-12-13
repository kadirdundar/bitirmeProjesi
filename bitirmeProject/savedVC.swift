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

                    for document in snapshot!.documents{
                        if let konum = document.get("location") as? GeoPoint{
                            self.locationData.append(konum)
                            yenikonum.append([konum.latitude, konum.longitude])
                            //print(konum) <FIRGeoPoint: (41.132631, 28.328366)> konumdan gelen veri bu şekilde
                            
                        }
                    }
                    
                    print(yenikonum[0])//basarılı
                    //verileriIsle()
                }
                
            }
        }
        
    }
    
    func verileriIsle(){
        let scaledata = ScaleData(data: yenikonum).scaleData(data: yenikonum)
        let k = 5
        let clusterer = KMeansClusterer(data: scaledata, k: k, maxElementCount: 20, iterations: 350)
        let clusters = clusterer.cluster()
        print(clusters)
        let unscaleData = UnscaledData(clusters: clusters, data: yenikonum).unscaleData(clusters: clusters, data: yenikonum)
      
        print(unscaleData)
        
        
         let firestoreDatabase = Firestore.firestore()
         for i in unscaleData{
             var aracnumarası  = 1
         aracnumarası = aracnumarası + 1
         for a in i{
         let longitude = a[0] // enlem değeri
         let latitude = a[1] // boylam değeri
         let location = [GeoPoint(latitude: latitude, longitude: longitude)]
             //print(location) [<FIRGeoPoint: (28.690790, 41.180382)>] geliyor
         firestoreDatabase.collection("information").whereField("location", isEqualTo: location).getDocuments { [self] (snapshot, error) in
         if let error = error{
         return
         }
         else {
         for document in snapshot!.documents{
         document.reference.updateData(["arac": aracnumarası])
             print("buraya girdi")
         }
         }
         
         }
         
         
         
         }
         
         }
           
           
           }
           
           
           
           
           
    }
    
    
    //fonksiyon yazılacak konumu eşleşen verideki arac değişkeninin değerini değiştirecek


}
