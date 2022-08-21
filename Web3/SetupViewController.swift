//
//  SetupViewController.swift
//  Web3
//
//  Created by Kefan Xie on 8/20/22.
//

import UIKit
import MapKit
import CoreLocation

class SetupViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate
{
    var nameLabel = UILabel()
    var descLabel = UILabel()
    var nameField = UITextField()
    var descField = UITextView()
    var nameBg = UIView()
    var descBg = UIView()
    var nextBtn = UIButton()
    var name: String!
    var desc: String!
    var locationManager = CLLocationManager()
    var latitude: CGFloat?
    var longitude: CGFloat?
    var address: String!
    var step = 0
    var wallet: WalletConnect!
    
    static func create(walletConnect: WalletConnect) -> SetupViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "SetupViewController") as! SetupViewController
        controller.wallet = walletConnect
        return controller
    }

    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(rgb: 0x14171f)
        
        address = (wallet.session.walletInfo?.accounts[0] ?? "0x");
        let screenSize: CGRect = UIScreen.main.bounds
        
//        let title = UILabel()
//        title.frame = CGRect(x: 40, y: 70, width:screenSize.width - 80, height:50);
//        title.font = UIFont.systemFont(ofSize: 24)
//        title.text = "Setup Your Profile"
//        title.textAlignment = .center;
//        self.view.addSubview(title)
        
        let imgv = UIImageView()
        imgv.image = UIImage(named: "profile_placeholder")
        imgv.frame = CGRect(x: (screenSize.width - 150) / 2, y: 92, width: 150, height: 150)
        self.view.addSubview(imgv)
        
        nameLabel.text = "Display Name"
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.frame = CGRect(x: 40, y: 245, width: screenSize.width - 80, height: 30)
        self.view.addSubview(nameLabel)
        
        nameBg.backgroundColor = UIColor(rgb: 0x292c33)
        nameBg.frame = CGRect(x: 40, y: 280, width: screenSize.width - 80, height: 50)
        nameBg.layer.cornerRadius = 10
        self.view.addSubview(nameBg)
        
        nameField.frame = CGRect(x: 50, y: 285, width: screenSize.width - 100, height: 40)
        nameField.font = UIFont.systemFont(ofSize: 16)
        self.view.addSubview(nameField)
        
        descLabel.text = "Description"
        descLabel.font = UIFont.systemFont(ofSize: 14)
        descLabel.frame = CGRect(x: 40, y: 355, width: screenSize.width - 80, height: 30)
        self.view.addSubview(descLabel)
        
        descBg.backgroundColor = UIColor(rgb: 0x292c33)
        descBg.frame = CGRect(x: 40, y: 390, width: screenSize.width - 80, height: 160)
        descBg.layer.cornerRadius = 10
        self.view.addSubview(descBg)
        
        descField.frame = CGRect(x: 47, y: 395, width: screenSize.width - 94, height: 120)
        descField.font = UIFont.systemFont(ofSize: 16)
        descField.backgroundColor = UIColor(rgb: 0x292c33)
        descField.delegate = self
        self.view.addSubview(descField)
        
        nextBtn.frame = CGRect(x: (screenSize.width - 200) / 2, y: screenSize.height - 150, width: 200, height: 45)
        nextBtn.setTitle("Allow Location", for: UIControl.State.normal)
        nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        nextBtn.backgroundColor = UIColor(rgb: 0x7ec893)
        nextBtn.layer.cornerRadius = 22.5
        nextBtn.addTarget(self, action: #selector(nextAction), for: UIControl.Event.touchUpInside)
        self.view.addSubview(nextBtn)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if(text == "\n") {
                textView.resignFirstResponder()
                return false
            }
            return true
        }
    
    @objc func nextAction(sender: UIButton!) {
        if (step == 0){
            nextBtn.setTitle("Create Profile", for: UIControl.State.normal)
            
            self.determineMyCurrentLocation()
            step += 1
        }else{
            name = nameField.text
            desc = descField.text

            API.setProfile(params: ["name": (name ?? ""), "desc": (desc ?? ""), "address": (address ?? ""), "latitude": 0, "longitude": 0]) { response in
                print("Profile set")
                
                let profileController = ProfileViewController.create(address: self.address)
                profileController.modalPresentationStyle = .fullScreen
                
                self.present(profileController, animated: false)
            }
        }
    }
    
    func initLocationUpdate() {
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
    
    func determineMyCurrentLocation() {
        if CLLocationManager.locationServicesEnabled()
        {
            self.initLocationUpdate()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse || status == .authorizedAlways){
            self.initLocationUpdate()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
        {
            print("Error while requesting new coordinates")
        }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        print("checked")
        self.latitude = locations[0].coordinate.latitude
        self.longitude = locations[0].coordinate.longitude
    }
}
