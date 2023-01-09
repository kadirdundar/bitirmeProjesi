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
        //verileriAl()
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
        
        var aracnumarasi = 1
        var yenibirdizi = [[Double]: Int]()
        for i in unscaleData{
            for a in i {
               
                yenibirdizi[a] = aracnumarasi
            }
            aracnumarasi = aracnumarasi + 1
        }
        print(yenibirdizi)
        
        //let firestoreDatabase = Firestore.firestore()
        let semaphore = DispatchSemaphore(value: 0)

        for (key, value) in yenibirdizi {
            
            
            let longitude = key[1]
            let latitude = key[0]
            let point = [GeoPoint(latitude: latitude, longitude: longitude)]
            let geoPoint = point[0]
            let docRef = Firestore.firestore().collection("information").whereField("location", isEqualTo: geoPoint)
            
            docRef.getDocuments { (querySnapshot, error) in
                  if let error = error {
                     print(error.localizedDescription)
                     return
                  }
                  guard let documents = querySnapshot?.documents else { return }
                  for document in documents {
                     document.reference.updateData(["arac": value])
                      print(value)
                  }
               }
            }

        
        //print(unscaleData)
        /*let firestoreDatabase = Firestore.firestore()
                
        let queue = DispatchQueue(label: "updateQueue")
        var aracnumarasi = 1
        // Semaphore değişkeni oluşturulur
        let semaphore = DispatchSemaphore(value: 0)

        for i in unscaleData {
            queue.async {
                aracnumarasi += 1
                for a in i {
                    let longitude = a[1]
                    let latitude = a[0]
                    let point = [GeoPoint(latitude: latitude, longitude: longitude)]
                    let geoPoint = point[0]
                    print(geoPoint)
                    
                    firestoreDatabase.collection("information").whereField("location", isEqualTo: geoPoint).getDocuments { [self] (snapshot, error) in
                        if let error = error {
                            return
                        } else {
                            for document in snapshot!.documents {
                                
                                document.reference.updateData(["arac": aracnumarasi])
                                print("burayagirdi")
                            }
                            semaphore.signal()
                        }
                        // Veri güncelleme işlemi tamamlandıktan sonra semaphore değişkeninin sayacı bir artırılır
                        
                    }
                    // Semaphore değişkeni veri güncelleme işlemi tamamlandıktan önce çağrılıyor
                    semaphore.wait()
                }
                
            }
        }
        
        // Tüm veri güncelleme işlemleri tamamlandıktan sonra bir sonraki adımın çalıştırılması gerekir
        print("Veri güncelleme işlemleri tamamlandı.")
        
        */
    }
    
}


           
           
           
           
           
           
           

    


