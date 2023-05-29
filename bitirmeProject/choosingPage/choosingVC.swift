import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseFirestore

class choosingVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
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
    
    @objc func ChooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = "Gitmek istediğiniz konum"
            annotation.subtitle = "Artı butonuna tıklayınız"
            mapView.addAnnotation(annotation)
            mapView.selectAnnotation(annotation, animated: true) // iğne seçili hale getiriliyor
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .contactAdd)
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let firestore = Firestore.firestore()
        guard let annatation = view.annotation else {return}
        let data = ["email": FirebaseAuth.Auth.auth().currentUser?.email,"arac":1,"location":GeoPoint(latitude: annatation.coordinate.latitude, longitude: annatation.coordinate.longitude)] as [String : Any]
        firestore.collection("information2").whereField("email", isEqualTo: FirebaseAuth.Auth.auth().currentUser?.email).getDocuments { querySnapshot, error in
            if let error = error {
                        print("Hata oluştu: \(error.localizedDescription)")
                    } else if !querySnapshot!.documents.isEmpty {
                        print("Kullanıcının daha önce kaydedilmiş bir konumu var.")
                        // Kullanıcıya bir uyarı gösterme
                        let alert = UIAlertController(title: "Hata", message: "Bu konum daha önce kaydedilmiş.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        let updateAction = UIAlertAction(title: "Güncelle", style: .destructive) { action in
                                        // Firestore veritabanından veriyi silme
                            let documentID = querySnapshot!.documents.first!.documentID
                                       firestore.collection("information2").document(documentID).setData(data) { error in
                                           if let error = error {
                                               print("Veri güncellenirken hata oluştu: \(error.localizedDescription)")
                                           } else {
                                               print("Veri güncellendi.")
                                           }
                                       }
                            print("Veri silindi.")
                                    }
                        alert.addAction(okAction)
                        alert.addAction(updateAction)
                        self.present(alert, animated: true, completion: nil)
                    }
            else{  firestore.collection("information2").addDocument(data: data){error in
                if error != nil{
                    print("veri yüklenirken hata oluştu")}
                else{print("veri aktarımı başarılı")}
            }
        }
    }
        //seçilen konumu firebase'e gönder
        //geopopint olarak Basarili
        print("tıklandı")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
}
