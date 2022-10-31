//
//  choosingVC.swift
//  bitirmeProject
//
//  Created by Kadir Dündar on 28.10.2022.
//

import UIKit
import MapKit
import CoreLocation
class choosingVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{

    var locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ChooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func ChooseLocation(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = "seçitiğiniz bölge"
            annotation.subtitle = "örnek"
            mapView.addAnnotation(annotation)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
    }

}