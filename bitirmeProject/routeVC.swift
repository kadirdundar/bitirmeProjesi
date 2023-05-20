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
    func birlestir(completion: @escaping(([String])->())){
        var locationList = [CLLocationCoordinate2D]()
        var stringCoordinates = [String]()
        transformLoc { list in
            locationList = list
            let firstLocation = self.addFirstAndLastLocation(locations: locationList)?.first
            let lastLocation = self.addFirstAndLastLocation(locations: locationList)?.last
            if let index1 = locationList.firstIndex(of: firstLocation!){ locationList.remove(at: index1)
                locationList.insert(firstLocation!, at: 0)
            }
            if let index2 = locationList.firstIndex(of: lastLocation!){ locationList.remove(at: index2)
                locationList.append(lastLocation!)
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
            self.getDrivingRoute(from: firstLoc,endLoc: lastLoc, withWaypoints: newLocs, optimize: "time", apiKey: apiKey) { lastSeries in
                print("last Series is 230472836409 \(lastSeries)")
                self.direction(locations: lastSeries)
            }
        }
//
//            let startLocation = "41.015285,28.670424"
//            let waypoints = [ "41.01538,28.66781", "41.015829,28.669886", "41.016642,28.666602", "41.017387,28.666591", "41.01776,28.664359", "41.017897,28.663222", "41.016132,28.66319", "41.017695,28.666398", "41.015647,28.669863", "41.014068,28.669842", "41.015064,28.666172", "41.016051,28.666516"]
////        , "41.01674,28.664585", "41.017646,28.663823", "41.017832,28.664295", "41.0158,28.665958", "41.016893,28.66231"
//            let lastLoc = "41.016893,28.66231"
//            let optimize = "timeWithTraffic"
//            let apiKey = "AkTCd7b62r8A0xBfKJGeIQ6ANO1tjwOy1YKs03OQ6QlyWzj9dDw3SPmCrwPxoD5n"
//
//        self.getDrivingRoute(from: startLocation,endLoc: lastLoc, withWaypoints: waypoints, optimize: "time", apiKey: apiKey){ locationCoordinates in
//            print(locationCoordinates)
//            self.direction(locations: locationCoordinates)

//        }
    }
    func getDrivingRoute(from startLocation: String, endLoc: String,  withWaypoints waypointss: [String], optimize: String, apiKey: String,completion: @escaping([CLLocationCoordinate2D])->()) {
        
        var urlString = "https://dev.virtualearth.net/REST/v1/Routes/Driving?"
        urlString += "wp.0=\(startLocation)"
        
        for (index, waypoint) in waypointss.enumerated() {
            urlString += "&wp.\(index+1)=\(waypoint)"
        }
        let endPoint = "&wp.\(waypointss.count + 1)=\(endLoc)"  // burayı düzneliyorum
        urlString += endPoint
        print("urlstirn son hali222\(urlString)")
        urlString += "&optwp=true&optimize=\(optimize)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(RouteResponse.self, from: data)
                    
                    if let resource = response.resourceSets.first?.resources.first {
                        let travelDistance = resource.travelDistance
                        let travelDuration = resource.travelDuration
                        let travelDurationTraffic = resource.travelDurationTraffic
                        let waypointsOrder = resource.waypointsOrder
                        
                        print("Travel Distance: \(travelDistance)")
                        print("Travel Duration: \(travelDuration)")
                        print("Travel Duration with Traffic: \(travelDurationTraffic)")
                        print("Waypoints Order: \(waypointsOrder)")
                        
                        var newSeries = Array(repeating: [Double](), count: waypointsOrder.count)
                        for (index,waypoint) in waypointsOrder.enumerated() {
                            if let iindex = waypoint.split(separator: ".").last, let sayi = Int(iindex) {
                                if sayi == 0 {
                                    let coordinates = startLocation.split(separator: ",")
                                    let latitude = Double(coordinates[0])
                                    let longitude = Double(coordinates[1])
                                    let locationArray: [Double] = [latitude ?? 0.0, longitude ?? 0.0]
                                    print("locationnarray\(locationArray)\(sayi)")
                                    newSeries[index] = locationArray
                                }
                                else if sayi == (waypointss.count + 1){
                                    let coordinates = endLoc.split(separator: ",")
                                    let latitude = Double(coordinates[0])
                                    let longitude = Double(coordinates[1])
                                    let locationArray: [Double] = [latitude ?? 0.0, longitude ?? 0.0]
                                    print("locationnarray\(locationArray)\(sayi)")
                                    newSeries[index] = locationArray
                                }
                               
                                else{
                                    let coordinates = waypointss[sayi - 1].split(separator: ",")
                                    print("separatorcoridante\(coordinates) \(sayi)")
                                    let latitude = Double(coordinates[0])
                                    let longitude = Double(coordinates[1])
                                    let locationArray: [Double] = [latitude ?? 0.0, longitude ?? 0.0]
                                    newSeries[index] = locationArray
                                }
                            }
                        }
                        print("yazıdkadkaldk \(newSeries)")
                        let locationCoordinates = newSeries.map { CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) }
                        completion(locationCoordinates)
                    }
                
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

   
    
    func direction(locations: [CLLocationCoordinate2D]) {
        mapView.delegate = self // Bu satırı ekleyin

        for i in 0..<locations.count - 1 {
            let sourceLocation = locations[i]
            let destinationLocation = locations[i + 1]

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
                    annotation.subtitle = "\(location)"
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
 }



extension routeVC {
    
    func errorMessage(baslık: String,text : String){
        let alert = UIAlertController(title: baslık, message: text, preferredStyle: UIAlertController.Style.alert)
        let button = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(button)
        present(alert, animated: true)
    }
}

extension routeVC : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let identifier = "customAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }

        // Annotation'ların sürekli görünmesini sağlamak için displayPriority özelliğini ayarlayın
        annotationView?.displayPriority = .required

        return annotationView
    }
   }
