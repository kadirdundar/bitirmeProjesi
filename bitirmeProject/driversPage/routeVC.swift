//
//  routeVC.swift
//  bitirmeProject
//
//  Created by Kadir Dündar on 16.05.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import MapKit

class routeVC: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        combineEverything()
    }
    
    func decisionForDestination()-> (Bool) {//bu fonksiyon günün hangi diliminde olduğuna karar verir.buna göre son konumun neresi olacağını belirler
        var hourr = true
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        if hour >= 3 && hour < 15 {
                hourr = false
        } else {
                hourr = true
            }
        return hourr
    }
    func getInformationVehicle(completion: @escaping((Int)->())){
        guard let currentUser = Auth.auth().currentUser else {return}
        
        var aracNumarasi = Int()
        
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("control").whereField("email", isEqualTo: currentUser.email).getDocuments { snapshot, error in
            if error != nil {
                self.errorMessage(baslık: "hata", text: "bir hata oluştu. \(error)")
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
    
    func getLocations(completion: @escaping(([[Double]])->())){
        var locations = [[Double]]()
        let firestoreDatabase = Firestore.firestore()
        
        getInformationVehicle { sayi in
            firestoreDatabase.collection("information2").whereField("arac", isEqualTo: sayi).getDocuments { snapshot, error in
                if error != nil {
                    self.errorMessage(baslık: "hata", text: "bir hata oluştu. \(error)")
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
    
    func transformLoc(completion: @escaping(([CLLocationCoordinate2D])->())){
        var coordinateList = [CLLocationCoordinate2D]()
        getLocations { location in
            for location in location {
                let coordinate = CLLocationCoordinate2D(latitude: location[0], longitude: location[1])
                coordinateList.append(coordinate)
            }
            completion(coordinateList)//veriler alındı ve CLocation a çevirildi
        }
    }
    func orderLocations(locations: [CLLocationCoordinate2D])-> [(location: CLLocationCoordinate2D, distance: CLLocationDistance)]{
        
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        var currentLocation = CLLocation()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            currentLocation = locationManager.location!
        }
//        let currentLocationDifferentTypes = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        var distances: [(location: CLLocationCoordinate2D, distance: CLLocationDistance)] = []
        for location in locations {// ilk durağı belirlemek için
            let distance = CLLocation(latitude: location.latitude, longitude: location.longitude).distance(from: currentLocation)
            distances.append((location: location, distance: distance))
        }
//        distances.append((location: currentLocationDifferentTypes, distance: 0))//kullanıcının anlık konumunu da ekledik
        distances.sort(by: { $0.distance < $1.distance })
        
        print(distances)
        
        return distances
    }
    func addFirstAndLastLocation(locations: [CLLocationCoordinate2D])-> (first: CLLocationCoordinate2D, last: CLLocationCoordinate2D)? {
        let distances = orderLocations(locations: locations)
        let firstElement = distances[0].location
        let lastElement = distances[distances.count - 1].location
        
        return (firstElement, lastElement)
    }
    
    
    func birlestir(completion: @escaping(([String])->())){
        var locationList = [CLLocationCoordinate2D]()
        var stringCoordinates = [String]()
        transformLoc { list in
            locationList = list
            var  lastLocation = CLLocationCoordinate2D()
            if !self.decisionForDestination() {
                lastLocation = self.addFirstAndLastLocation(locations: locationList)!.last
            
                
            }
            else{
                lastLocation = CLLocationCoordinate2D(latitude: 41.05, longitude: 28.42)
            }
            let locationManager = CLLocationManager()
            locationManager.requestWhenInUseAuthorization()
            
            var currentLocation = CLLocation()
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                currentLocation = locationManager.location!
            }
            let currentLocationDifferentTypes = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            locationList.insert(currentLocationDifferentTypes, at: 0)
            
            if let index2 = locationList.firstIndex(of: lastLocation){ locationList.remove(at: index2)
                locationList.append(lastLocation)
            }
            
            stringCoordinates = locationList.map { "\($0.latitude),\($0.longitude)" }
            print("stringcoordinatesfonksiyona verilişi 9234832842\(stringCoordinates)")
            completion(stringCoordinates)
        }
    }
    func combineEverything(){
        birlestir { dizi in
            
            let firstLoc = dizi[0]
            let lastLoc = dizi[dizi.count - 1]
            var newLocs = dizi
            newLocs.removeFirst()
            newLocs.removeLast()
            print("birlestire girdi")
            //dizinin ilk elemanı silinecek
            print("diğerkullanıclacak dizi\(dizi)")
            let apiKey = "AkTCd7b62r8A0xBfKJGeIQ6ANO1tjwOy1YKs03OQ6QlyWzj9dDw3SPmCrwPxoD5n"
            getDrivingRoute(from: firstLoc,endLoc: lastLoc, withWaypoints: newLocs, optimize: "time", apiKey: apiKey) { lastSeries in
                print("last Series is 230472836409 \(lastSeries)")
                self.direction(locations: lastSeries)
            }
        }
    }
 }



extension CLLocationCoordinate2D: Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
