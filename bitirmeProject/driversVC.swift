//
//  driversVC.swift
//  bitirmeProject
//
//  Created by Kadir Dündar on 5.03.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import MapKit

class driversVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        lastFunc()
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
    func getLocations(completion: @escaping(([[Double]])->())){
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
    func transformLoc(completion: @escaping(([CLLocationCoordinate2D])->())){
        var coordinateList = [CLLocationCoordinate2D]()
        getLocations { location in
            for location in location {
                let coordinate = CLLocationCoordinate2D(latitude: location[0], longitude: location[1])
                coordinateList.append(coordinate)
            }
            completion(coordinateList)
        }
        
    }
    func lastFunc(){
        transformLoc { location in
            //basarıliprint("dödnüştürülenkomları \(location)")
            self.decision(location: location)
        }
       
    }
    func decision(location: [CLLocationCoordinate2D]){
        let number = location.count
        if number > 12{
            let sorted = orderLocations(locations: location)
            var firstList = [CLLocationCoordinate2D]()
            var secondList = [CLLocationCoordinate2D]()
            var midIndex = number - 10 // Listenin orta noktasının indeksi
            let numberr = 10 + midIndex
            // Eğer eleman sayısı tek ise, orta elemanın indeksini hesapla
            
            
            for i in 0..<10 {
                firstList.append(sorted[i].location)
            }
            for i in 10..<numberr {
                secondList.append(sorted[i].location)
            }
            
            let firstRoute = deneme(locations: firstList) { location in
                if let location = location {
                    
                    firstList = location
                    let secondRoute = self.deneme(locations: secondList) { location in
                        if let location = location{
                            secondList = location
                            for i in 0...secondList.count-1{// eğer son konum API dan gelen cevaptaki en uzak konumla son konum eşit değilse son konumu değiştirip tekrar istek yolla
                                firstList.append(secondList[i])
                            }
                            self.direction(locations: firstList)
                        }
                        
                    }
                }
            }
        }
        else{
            createPaths(locations: location)
        }
        
    }
    func addFirstAndLastLocation(locations: [CLLocationCoordinate2D])-> (first: CLLocationCoordinate2D, last: CLLocationCoordinate2D)? {
        let distances = orderLocations(locations: locations)
        let firstElement = distances[0].location
        let lastElement = distances[distances.count - 1].location
        
        return (firstElement, lastElement)
        
    }
    func orderLocations(locations: [CLLocationCoordinate2D])-> [(location: CLLocationCoordinate2D, distance: CLLocationDistance)]{
        
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        var currentLocation = CLLocation()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            currentLocation = locationManager.location!
        }
        
        var distances: [(location: CLLocationCoordinate2D, distance: CLLocationDistance)] = []
        for location in locations {// ilk durağı belirlemek için
            let distance = CLLocation(latitude: location.latitude, longitude: location.longitude).distance(from: currentLocation)
            distances.append((location: location, distance: distance))
        }
        
        distances.sort(by: { $0.distance < $1.distance })
        
        print(distances)
        
        return distances
    }
    
    func deneme(locations: [CLLocationCoordinate2D], completion : @escaping([CLLocationCoordinate2D]?)->()){//konumları sıralamak için istek
        var locationList: [[Double]] = []
        var newList = [CLLocationCoordinate2D]()
        
        let element = addFirstAndLastLocation(locations: locations)
        for loc in locations{
            if loc != element?.first && loc != element?.last{
                newList.append(loc)
                
            }
        }
        print(newList)
        print("012012010201010210010101001011")
        if let firstElement = element?.first {
            newList.insert(firstElement, at: 0)
        }
        
        // Set the last element of newList to element.last
        if let lastElement = element?.last {
            newList.append(lastElement)
        }
        print(newList)
        print("222222222222222222222")
        
        let apiKey = ""
        
        let baseURL = "https://api.mapbox.com/optimized-trips/v1/mapbox/driving/"
        
        // Rota üzerindeki duraklar
        let coordinates = newList.map({ "\($0.longitude),\($0.latitude)" }).joined(separator: ";")
        print(coordinates)
        print("3333333333333333333")
        // API isteği için URL oluşturma
        let params = "source=first&destination=last&roundtrip=false"
        
        
        let requestURL = "\(baseURL)\(coordinates)?\(params)&access_token=\(apiKey)"
        let task = URLSession.shared.dataTask(with: URL(string: requestURL)!) { (data, response, error) in
            if let error = error {
                print("Error fetching optimized locations: \(error)")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                print("Invalid response")
                print(data)
                
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            
            if let waypoints = json?["waypoints"] as? [[String: Any]] {
                
                var waypointDictionary = [Int: [String: Any]]()
                
                
                for waypoint in waypoints {
                    let index = waypoint["waypoint_index"] as! Int
                    let location = waypoint["location"] as! [Double]
                    waypointDictionary[index] = ["location": location]
                    
                }
                print(waypointDictionary)
                print("*****************")
                
                
                let sortedKeys = waypointDictionary.keys.sorted()
                for key in sortedKeys {
                    let location = waypointDictionary[key]!["location"]!
                    locationList.append(location as! [Double])
                }
                
                print(locationList)
                newList.removeAll()
                for loc in locationList{
                    let element = CLLocationCoordinate2D(latitude: loc[1], longitude: loc[0])
                    newList.append(element)
                    
                }
                
                completion(newList)
            } else {
                completion(nil)
            }
        }
        task.resume()
        
        
    }
   
    
    func createPaths(locations: [CLLocationCoordinate2D]) {
        
        var locationss = [CLLocationCoordinate2D]()
        deneme(locations: locations) { locations in
            if let locations = locations{
                locationss = locations
                
                self.direction(locations: locationss)
            }
        }
    }
    func direction(locations: [CLLocationCoordinate2D]){
        for i in 0..<locations.count-1 {
            let sourceLocation = locations[i]
            let destinationLocation = locations[i+1]
            
            let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
            let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
            
            let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
            let destinationItem = MKMapItem(placemark: destinationPlaceMark)
            
            let directionRequest = MKDirections.Request()
            directionRequest.source = sourceMapItem
            directionRequest.destination = destinationItem
            directionRequest.transportType = .automobile
            
            
            let direction = MKDirections(request: directionRequest)
            
            direction.calculate { (response, error) in
                guard let response = response else {
                    if let error = error {
                        print("ERROR FOUND : \(error.localizedDescription)")
                    }
                    return
                }
                
                let route = response.routes[0]
                self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
                
                for (index, location) in locations.enumerated() {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location
                    annotation.title = "Durak \(index + 1)"
                    annotation.subtitle = "Durak açıklaması"
                    self.mapView.addAnnotation(annotation)
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
//extension ViewController : MKMapViewDelegate {
//       func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//           let rendere = MKPolylineRenderer(overlay: overlay)
//           rendere.lineWidth = 5
//           rendere.strokeColor = .systemBlue
//
//           return rendere
//       }
//   }

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

