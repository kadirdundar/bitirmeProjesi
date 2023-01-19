//
//  savedVC.swift
//  bitirmeProject
//
//  Created by Kadir Dündar on 28.10.2022.
//

import UIKit
import FirebaseFirestore

class savedVC: UIViewController {
    
    var locationData = [GeoPoint]()
    var yenikonum = [[Double]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verileriAl()
        //verileriIsle()
        // Do any additional setup after loading the view.
    }
    
    
    //let data = [[2.0,0.0]]
    //let scaledata = ScaleData(data: data)
    //let scaleddata = scaledata.scaleData(data: data)
    //let k = 4  kişi sayımıza göre belirlenecek
    //let clusterer = KMeansClusterer(data: scaledData, k: k, maxElementCount: 20, iterations: 350)
    //let clusters = clusterer.cluster()
    //let unscaleData = UnscaledData(clusters,data)
    //let unscaledData = unscaleData.unscaleData(clusters: clusters, data: data)
    // bütün veriler çekilecek k-means ile hesapkayığ gönderilecek
    
    func verileriAl() {
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("information").getDocuments { [self] (snapshot, error) in
            if error != nil{
                print(error?.localizedDescription)
            }
            else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    
                    for document in snapshot!.documents{
                        if let konum = document.get("location") as? GeoPoint{
                            self.locationData.append(konum)
                            yenikonum.append([konum.latitude, konum.longitude])
                            //print(konum) <FIRGeoPoint: (41.132631, 28.328366)> konumdan gelen veri bu şekilde
                            
                        }
                    }
                    
                    print(yenikonum[0])//basarılı
                    verileriIsle()
                }
            }
        }
    }

    func verileriIsle(){
        let scaledata = ScaleData(data: yenikonum).scaleData(data: yenikonum)
        let k = 5
        let clusterer = KMeansClusterer(data: scaledata, k: k, maxElementCount: 20, iterations: 350)
        let clusters = clusterer.cluster()
        
        let unscaleData = UnscaledData(clusters: clusters, data: yenikonum).unscaleData(clusters: clusters, data: yenikonum)
        
       /* var aracnumarasi = 1
        var yenibirdizi = [[Double]: Int]()
        for i in unscaleData{
            for a in i {
               
                yenibirdizi[a] = aracnumarasi
            }
            aracnumarasi = aracnumarasi + 1
        }
        print(yenibirdizi)
        cagır()
        
        //let firestoreDatabase = Firestore.firestore()*/
        cagır()
        func cagır(){
           
            let yenibirdizii = [[41.45619471964721, 28.935846811349258]: 2, [41.225787398509105, 28.466678681302987]: 3, [41.84248880159515, 28.139087466768707]: 1, [41.71231859944527, 28.466555058271933]: 1, [41.26788110800492, 28.133024758172315]: 4, [41.11069463314945, 28.333456166073187]: 4, [41.04225465688249, 28.352563574458173]: 4, [41.854726492862106, 28.82795795160369]: 5, [41.0757492197488, 28.515696910997058]: 2, [41.49671137803793, 28.78307998640719]: 3, [41.40529208857652, 28.041001123037255]: 5, [41.798614237141074, 28.188255059742236]: 5, [41.7600176765461, 28.2373135998633]: 5, [41.70667632495917, 28.012614305147853]: 1, [41.46526086232501, 28.98268317354019]: 3, [41.07222327031218, 28.661570375859288]: 2, [41.274198317212836, 28.848394041082784]: 2, [41.6583903696783, 28.90873943950977]: 3, [41.72146105188364, 28.393458074686325]: 1, [41.197235649557065, 28.038492485926113]: 4, [41.73488778335311, 28.460331017882165]: 1, [41.562633438084056, 28.334541776500963]: 4, [41.55518861493708, 28.460647726480772]: 5, [41.44981985759651, 28.581313695828328]: 2, [41.22574463531516, 28.55114697175699]: 3, [41.65466657625974, 28.864166008854326]: 2, [41.013021536361634, 28.073583216161815]: 4, [41.65178337405967, 28.50744063631212]: 5, [41.13263056496613, 28.328366408083337]: 3, [41.05076375427373, 28.878191305060867]: 3, [41.448499129309724, 28.823693876558607]: 2, [41.63335841649582, 28.622092463011764]: 5, [41.43334168258264, 28.32012739638122]: 4, [41.98328513021743, 28.251854902589617]: 1, [41.94746816943669, 28.13491429406382]: 5, [41.07796159459948, 28.81269782252854]: 2, [41.41766136442185, 28.33551543409722]: 5, [41.396388690106875, 28.287714989979303]: 4, [41.15809938269146, 28.967404181963367]: 2, [41.786506959623466, 28.547991773796277]: 1, [41.98817004304827, 28.140823661502804]: 1, [41.08804426233096, 28.263499322066448]: 4, [41.802449715470274, 28.160429667518233]: 1, [41.8728553299924, 28.275947902493996]: 5, [41.701823366092995, 28.712093151178337]: 3, [41.661320509792546, 28.468633701327636]: 1, [41.587659128433984, 28.543493019217898]: 3, [41.57481688157602, 28.564842347863852]: 3, [41.120024457130626, 28.483838001790488]: 2, [41.37105519925374, 28.72619883232053]: 2, [41.76576914771822, 28.49386228725169]: 5, [41.270630693335264, 28.04812344155164]: 4, [41.45383780099768, 28.19715107549425]: 4, [41.993380618556756, 28.755277673199984]: 5, [41.42774884535405, 28.119765227114122]: 4, [41.48882957648587, 28.29970796970664]: 4, [41.650857723883526, 28.44280233043594]: 1, [41.482001231613495, 28.904989654729025]: 2, [41.5185659745992, 28.989612985713862]: 3, [41.7933050198844, 28.67960555913561]: 5, [41.99139360562267, 28.171007942504296]: 5, [41.04599897849272, 28.85534240742964]: 3, [41.5975955695094, 28.704487312453228]: 2, [41.32862432099913, 28.954371243901036]: 3, [41.26329411192692, 28.3939424240583]: 4, [41.38823834232687, 28.93517986570655]: 3, [41.68446239561733, 28.83127338079885]: 3, [41.71463208069745, 28.91074275446515]: 2, [41.441861350667295, 28.330899939312484]: 4, [41.7527728224289, 28.838588575862676]: 2, [41.25537864917949, 28.36523014912057]: 4, [41.98161442327632, 28.574126594586303]: 1, [41.20591369799834, 28.532781566150412]: 3, [41.88660100649913, 28.77863549683971]: 2, [41.36648925527607, 28.41457258013091]: 4, [41.110515121804355, 28.059391023206526]: 3, [41.34067623241608, 28.340530549394458]: 4, [41.471415600063224, 28.230984472007247]: 4, [41.523916716837675, 28.856890737900034]: 2, [41.925318866961426, 28.00309495723443]: 1, [41.15584890924497, 28.333672965309322]: 4, [41.69979992333447, 28.245727530731447]: 5, [41.46497003318077, 28.95256145701949]: 2, [41.320803253825346, 28.111333366400476]: 5, [41.72303670525945, 28.355180605832228]: 1, [41.88196013256887, 28.96002077047723]: 3, [41.56054912155823, 28.249837068394843]: 5, [41.81986370020018, 28.06177612355373]: 1, [41.245656523109105, 28.446451462652263]: 5, [41.18038246746341, 28.690790468385078]: 3, [41.98184034246985, 28.094412986479018]: 1, [41.94664590428058, 28.586223225907126]: 1, [41.94913490371278, 28.41310429033676]: 1, [41.947861873841376, 28.264232162998617]: 5, [41.926364396524626, 28.0448428429311]: 1, [41.880542174156986, 28.36459962520124]: 1, [41.09534544557277, 28.540740237547087]: 2, [41.97109754991556, 28.854971508711888]: 2, [41.879967751269845, 28.605992943543086]: 5, [41.09628903397493, 28.02904822744119]: 3]
            for (key, value) in yenibirdizii {
                
                
                let longitude = key[1]
                let latitude = key[0]
                let point = [GeoPoint(latitude: latitude, longitude: longitude)]
                let geoPoint = point[0]
                let docRef = Firestore.firestore().collection("information").whereField("location", isEqualTo: geoPoint)
                
                docRef.getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    guard let documents = querySnapshot?.documents else { return }
                    for document in documents {
                        document.reference.updateData(["arac": value])
                        print(value)
                    }
                }
            }
        }
        
        //print(unscaleData)
        /*let firestoreDatabase = Firestore.firestore()
                
        let queue = DispatchQueue(label: "updateQueue")
        var aracnumarasi = 1
        // Semaphore değişkeni oluşturulur
        let semaphore = DispatchSemaphore(value: 0)

        for i in unscaleData {
            queue.async {
                aracnumarasi += 1
                for a in i {
                    let longitude = a[1]
                    let latitude = a[0]
                    let point = [GeoPoint(latitude: latitude, longitude: longitude)]
                    let geoPoint = point[0]
                    print(geoPoint)
                    
                    firestoreDatabase.collection("information").whereField("location", isEqualTo: geoPoint).getDocuments { [self] (snapshot, error) in
                        if let error = error {
                            return
                        } else {
                            for document in snapshot!.documents {
                                
                                document.reference.updateData(["arac": aracnumarasi])
                                print("burayagirdi")
                            }
                            semaphore.signal()
                        }
                        // Veri güncelleme işlemi tamamlandıktan sonra semaphore değişkeninin sayacı bir artırılır
                        
                    }
                    // Semaphore değişkeni veri güncelleme işlemi tamamlandıktan önce çağrılıyor
                    semaphore.wait()
                }
                
            }
        }
        
        // Tüm veri güncelleme işlemleri tamamlandıktan sonra bir sonraki adımın çalıştırılması gerekir
        print("Veri güncelleme işlemleri tamamlandı.")
        
        */
    }
    
}


           
           
           
           
           
           
           

    


