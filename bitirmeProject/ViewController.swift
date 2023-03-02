//
//  ViewController.swift
//  bitirmeProject
//
//  Created by Kadir Dündar on 24.10.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ViewController: UIViewController {
    var segmentControllerValue = true

    @IBOutlet weak var sifreText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func girisYapTıklandı(_ sender: Any) {
        if sifreText.text != "" && emailText.text != ""
        {
            Auth.auth().signIn(withEmail: emailText.text!, password: sifreText.text!) { result, error in
                if error == nil {
                    
                    if self.segmentControllerValue == false{
                        self.checkEmailExistsInFirestore(email: self.emailText.text!) { value in
                            if value{
                                self.performSegue(withIdentifier: "opentotabbar", sender: nil)
                                //basarili
                            }
                            else{
                                self.hatamesaji(baslık: "hata", text: "girmiş olduğunuz bilgilere ait servisci bulunamamıştır")
                            }
                        }
             
                    }
                    
                    self.performSegue(withIdentifier: "opentotabbar", sender: nil)
                }
                else{
                    self.hatamesaji(baslık: "hata", text: "giriş işlemi gerçekleştirilemedi tekrar deneyiniz\(error?.localizedDescription)")
                }
            }
            
        }
        else{
            hatamesaji(baslık: "hata", text: "mail adresi ve şifre alanı boş olamaz")
        }
        
        
    }
    

    @IBAction func switchController(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            segmentControllerValue = true
        }
        else { segmentControllerValue = false}
    }
    @IBAction func kayitolTiklandi(_ sender: Any) {
        if sifreText.text != "" && emailText.text != ""
        {
            Auth.auth().createUser(withEmail: emailText.text!, password: sifreText.text!) { result, error in
                if error == nil {
                    self.performSegue(withIdentifier: "opentotabbar", sender: nil)
                    print("kayıt yapıldı")
                }
                else{
                    self.hatamesaji(baslık: "hata", text: "kayıt işlemi gerçekleştirilemedi tekrar deneyiniz\(error?.localizedDescription)")
                }
            }
            
        }
        else{
            hatamesaji(baslık: "hata", text: "mail adresi ve şifre alanı boş olamaz")
        }
        
    }
    func checkEmailExistsInFirestore(email: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let controlRef = db.collection("control")
        let query = controlRef.whereField("email", isEqualTo: email)

        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                completion(false)
                return
            }
            
            guard let snapshot = snapshot else {
                print("Snapshot is nil")
                completion(false)
                return
            }
            
            completion(!snapshot.isEmpty)
        }
    }

    func hatamesaji(baslık: String,text : String){
        let alert = UIAlertController(title: baslık, message: text, preferredStyle: UIAlertController.Style.alert)
        let button = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(button)
        present(alert, animated: true)
    }
}

