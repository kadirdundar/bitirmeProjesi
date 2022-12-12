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
        gestureRecognizer.minimumPressDuration = 2
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
//annotation artı butonu ekledik.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil}
            
            let reuseID = "IDforReuse"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            
            pinView?.canShowCallout = true
            
            let rightButton = UIButton(type: .contactAdd)
            
            pinView?.rightCalloutAccessoryView = rightButton
            

            pinView?.isSelected = true
            
            }
        else
            {
            pinView?.annotation = annotation
            }
                
                return pinView
                
           }

    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
       
        print("tüklandii")
        //let data = [[2.0,0.0]]
        //let scaledata = ScaleData(data: data)
        //let scaleddata = scaledata.scaleData(data: data)
        //let k = 4  kişi sayımıza göre belirlenecek
        //let clusterer = KMeansClusterer(data: scaledData, k: k, maxElementCount: 20, iterations: 350)
        //let clusters = clusterer.cluster()
        //let unscaleData = UnscaledData(clusters,data)
        //let unscaledData = unscaleData.unscaleData(clusters: clusters, data: data)
        // bütün veriler çekilecek k-means ile hesapkayığ gönderilecek
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
   
    
    
}


