import UIKit

class DenemeViewController: UIViewController {
    
    let API_KEY = "pk.eyJ1IjoiZHVuZGFya2FkaXIiLCJhIjoiY2xkeWxscWU0MHNnejN4cHJ6dXA2Nzh0bSJ9.FGnJNBYwhbiAP8dr2ELI3A"
    let listOfLoc = [
        [41.0082, 28.9784], // Beşiktaş
        [41.0340, 28.9773], // Taksim
        [41.0364, 28.9881], // Şişli
        [41.0559, 28.9426]  // Üsküdar
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getOptimizedRoute(coordinates: listOfLoc) { (newLocList) in
            // işlem tamamlandığında, yeni sıralı koordinat listesi
            print(newLocList)
        }
    }
    func getOptimizedRoute(coordinates: [[Double]], completion: @escaping ([[Double]]) -> Void) {
        // Mapbox Optimization API v2 için istek gövdesini oluşturun
        let requestBody = try! JSONSerialization.data(withJSONObject: [
            "locations": coordinates
        ])

        // API'ya istek gönderin
        let url = URL(string: "https://api.mapbox.com/optimized-trips/v2/mapbox/driving")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(API_KEY, forHTTPHeaderField: "Authorization")
        request.httpBody = requestBody

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            
            // API'dan gelen yanıtı analiz edin
            guard let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let newOrder = jsonResponse["waypoints"] as? [[String: Any]] else { return }
            
            // yeni sıralı liste
            let newLocList = newOrder.sorted { ($0["waypoint_index"] as! Int) < ($1["waypoint_index"] as! Int) }
                                .map { $0["location"] as! [Double] }
            
            // sonucu kapanış aracılığıyla döndür
            completion(newLocList)
        }
        task.resume()
    }
}

