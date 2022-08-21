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
    var address: String!
    var locationManager = CLLocationManager()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var locationUpdated = false
    var myId: Int!
    var visit: Bool!
    var imgurl: String!
    var name: String!

    static func create(address: String, visit: Bool = false) -> ProfileViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        controller.address = address
        controller.visit = visit
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenSize: CGRect = UIScreen.main.bounds
        
        self.determineMyCurrentLocation()
        
        API.getProfile(params: ["address": address as! String], completion: { json in
            if (json?["profile"] != nil){
                let profile = json?["profile"] as! Dictionary<String, Any>
//                print(profile)
                
                self.myId = Int(profile["id"] as! String)
                self.name = profile["name"] as! String

                let text = UILabel()
                text.frame = CGRect(x: 40, y: 70, width:screenSize.width - 80, height:50);
                text.font = UIFont(name: "Avenir", size: 24)
                
                if (self.visit){
                    text.text = (profile["name"] as! String ?? "Hacker")
                }else{
                    text.text = "Hello! " + (profile["name"] as! String ?? "Hacker")
                }
                
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
                    self.imgurl = img_url as! String

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
                
                let findBtn = UIButton()
                findBtn.frame = CGRect(x: (screenSize.width - 200) / 2, y: 630, width: 200, height: 50)
                
                if (self.visit){
                    findBtn.setTitle("Message", for: UIControl.State.normal)
                }else{
                    findBtn.setTitle("Find", for: UIControl.State.normal)
                }
                
                findBtn.titleLabel?.font = UIFont(name: "Avenir", size: 20)
                findBtn.backgroundColor = UIColor(rgb: 0x5599f5)
                findBtn.layer.cornerRadius = 10
                
                if (self.visit){
                    findBtn.addTarget(self, action: #selector(self.messageAction), for: UIControl.Event.touchUpInside)
                }else{
                    findBtn.addTarget(self, action: #selector(self.findAction), for: UIControl.Event.touchUpInside)
                }
                
                self.view.addSubview(findBtn)
            }
        })
        
        if (visit){
            let gestureView = UIView()
            gestureView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: 630)
            gestureView.backgroundColor = UIColor(white: 1, alpha: 0.0)
            self.view.addSubview(gestureView)
            
            let swipeGestureRecognizerDown = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
            swipeGestureRecognizerDown.direction = .right
            gestureView.addGestureRecognizer(swipeGestureRecognizerDown)
        }
    }
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        let transition = CATransition()
        transition.duration = 0.2
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func findAction(sender: UIButton!) {
//        API.findUsers(params: ["longitude": longitude, "latitude": latitude, "distance": 10]) { json in
//            let listViewController = ListViewController.create(users: json?["users"] as! NSArray, myId: self.myId)
//            listViewController.modalPresentationStyle = .fullScreen
//            
//            self.present(listViewController, animated: false)
//        }
    }
    
    @objc func messageAction(sender: UIButton!) {
        let messageViewController = MessageViewController.create(imgurl: imgurl, name: name)
        messageViewController.modalPresentationStyle = .fullScreen
        
        self.present(messageViewController, animated: false)
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
        
        if (!locationUpdated && !self.visit){
            print("updating")
            self.locationUpdated = true;
            API.updateProfile(params: ["latitude": self.latitude, "longitude": self.longitude, "address": address as! String]) { json in
                self.locationUpdated = true;
            }
        }
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
