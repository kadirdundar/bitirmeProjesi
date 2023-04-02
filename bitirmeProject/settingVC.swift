//
//  settingVC.swift
//  bitirmeProject
//
//  Created by Kadir Dündar on 28.10.2022.
//

import UIKit
import FirebaseAuth
//import FirebaseFirestore


class settingVC: UIViewController {
    let firebaseauth = FirebaseAuth.Auth.self
    
    @IBAction func cikisYapTiklandi(_ sender: Any) {
        do {
            try firebaseauth.auth().signOut()
            performSegue(withIdentifier: "toSignIn", sender: nil)
        }
        catch{
            print("hata")
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //islev()
        
    }
  
    
    
    //let firestoreDatabase = Firestore.firestore()
   
     

   /* func generateRandomEmails(count: Int) -> [String] {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var emailList = [String]()
        
        for _ in 0..<count {
            let randomEmail = String((0..<10).map{ _ in letters.randomElement()! }) + "@example.com"
            emailList.append(randomEmail)
        }
        
        return emailList
    }
    
    func islev(){
        let randomEmails = generateRandomEmails(count: 100)
        
        let coordinates: [GeoPoint] = (0..<100).map { _ in
               let latitude = Double.random(in: 41.0...42.0)
               let longitude = Double.random(in: 28.0...29.0)
               return GeoPoint(latitude: latitude, longitude: longitude)
           }
        
        if randomEmails.count == 100 && coordinates.count == 100{
            for i in 0..<100{
                let firestorePost = ["arac" :2, "location" : coordinates[i] ,"email" : randomEmails[i]] as [String : Any]
                firestoreDatabase.collection("information").addDocument(data: firestorePost) {
                    (error) in
                    if error != nil{
                        print("asdkhajk")
                    }
                    else{
                        print("başarılı veri akttarımı")
                    }
                }
            }
            
            
        }
     }*/

    }
     
    
