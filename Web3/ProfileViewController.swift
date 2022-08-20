//
//  ProfileViewController.swift
//  Web3
//
//  Created by Kefan Xie on 8/19/22.
//

import UIKit
import WalletConnectSwift
import MapKit
import CoreLocation
import Kingfisher

class ProfileViewController: UIViewController, CLLocationManagerDelegate {
    var client: Client!
    var session: Session!
    var locationManager = CLLocationManager()
    var latitude: Double = 0.0
    var longitude: Double = 0.0

    static func create(walletConnect: WalletConnect) -> ProfileViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        controller.client = walletConnect.client
        controller.session = walletConnect.session
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenSize: CGRect = UIScreen.main.bounds
        let address = (session.walletInfo?.accounts[0] ?? "0x");
        
        self.determineMyCurrentLocation()
        
        API.getProfile(params: ["address": address], completion: { json in
            if (json?["profile"] == nil){
                API.setProfile(params: ["name": "XWarrior", "desc": "I am an avid NFT collector", "address": address, "latitude": self.latitude, "longitude": self.longitude]) { response in
                    print("Profile set")
                }
            }else{
                let profile = json?["profile"] as! Dictionary<String, Any>
//                print(profile)
                let text = UILabel()
                text.frame = CGRect(x: 40, y: 70, width:screenSize.width - 80, height:50);
                text.font = UIFont(name: "Avenir", size: 24)
                text.text = "Hello! " + (profile["name"] as! String ?? "Hacker")
                text.textAlignment = .center;
                self.view.addSubview(text)
                
                let img = UIImageView()
                img.translatesAutoresizingMaskIntoConstraints = false
                img.frame = CGRect(x: 40, y: 140, width: screenSize.width - 80, height: 200)
                self.view.addSubview(img)
                
                var frame = img.frame
                frame.origin.y = 140
                img.frame = frame
                
                if let nfts = profile["nfts"] as? [Any], let nft = nfts[0] as? [String:Any], let img_url = nft["image"] as? String {
                    let url = URL(string: img_url)
                    img.kf.setImage(with: url, placeholder: nil) { result in
                        switch result {
                            case .success(let value):
                                let size = value.image.size
                                let factor = 200 / size.height
                                let width = size.width * factor
                                
                                var frame = img.frame
                                frame.size.width = width
                                frame.origin.x = (screenSize.width - width) / 2
                                img.frame = frame
                            
                                img.layer.cornerRadius = 20
                                img.clipsToBounds = true
                            case .failure(let error):
                                print("Job failed: \(error.localizedDescription)")
                            }
                    }
                }
                
                let descBg = UIView()
                descBg.frame = CGRect(x: 20, y: 370, width: screenSize.width - 40, height: 60)
                descBg.backgroundColor = UIColor(rgb: 0x222222)
                descBg.layer.cornerRadius = 10
                self.view.addSubview(descBg)
                
                let desc = UILabel()
                desc.text = (profile["desc"] as! String ?? "This is how I would like to intro myself...")
                desc.font = UIFont(name: "Avenir", size: 18)
                desc.frame = CGRect(x: 35, y: 370, width: screenSize.width - 70, height: 60)
                self.view.addSubview(desc)
            }
        })
    }
    
    func determineMyCurrentLocation() {
        if CLLocationManager.locationServicesEnabled()
        {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.distanceFilter = kCLDistanceFilterNone
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

            let authorizationStatus = CLLocationManager.authorizationStatus()
            if (authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways)
            {
                self.locationManager.startUpdatingLocation()
            }
            else if (locationManager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)))
            {
                 self.locationManager.requestAlwaysAuthorization()
            }
            else
            {
                self.locationManager.startUpdatingLocation()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
        {
            print("Error while requesting new coordinates")
        }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        self.latitude = locations[0].coordinate.latitude
        self.longitude = locations[0].coordinate.longitude
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)

        return ceil(boundingBox.width)
    }
}

//class ResizableImageView: UIImageView {
//
//  override var image: UIImage? {
//    didSet {
//      guard let image = image else { return }
//
//        let maxHeight = 200.0
//        let factor = maxHeight / image.size.height
//
//
//      let resizeConstraints = [
//        self.heightAnchor.constraint(equalToConstant: image.size.height * factor),
//        self.widthAnchor.constraint(equalToConstant: image.size.width * factor)
//      ]
//
//      if superview != nil {
//        addConstraints(resizeConstraints)
//      }
//    }
//  }
//}
