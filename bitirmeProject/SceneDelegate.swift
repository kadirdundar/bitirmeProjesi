//
//  SceneDelegate.swift
//  bitirmeProject
//
//  Created by Kadir Dündar on 24.10.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let guncelkullanıcı = Auth.auth().currentUser
                if guncelkullanıcı != nil{
                    checkEmailExistsInFirestore(email: guncelkullanıcı?.email ?? "") { value in
                        if value{
                            let board = UIStoryboard(name: "Main", bundle: nil)
                            let tabBar = board.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
                            self.window?.rootViewController = tabBar
                            //let routes = board.instantiateViewController(withIdentifier: "routes")
                            //self.window?.rootViewController = routes
                        }
                        else {
                            let board = UIStoryboard(name: "Main", bundle: nil)
                            let tabBar = board.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
                            self.window?.rootViewController = tabBar
                        }
                    }
                    
                    
                }
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

extension SceneDelegate {
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
}
