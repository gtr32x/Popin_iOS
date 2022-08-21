//
//  ListViewController.swift
//  Web3
//
//  Created by Kefan Xie on 8/20/22.
//

import Foundation
import UIKit
import Kingfisher
import MapKit
import CoreLocation

class ListViewController: UIViewController, CLLocationManagerDelegate
{
    var users: NSArray!
    var myId: Int!
    var address: String!
    var imgurl: String!
    var addresses: NSMutableArray!
    var circleBg: UIView!
    var imgView: UIImageView!
    var locationManager = CLLocationManager()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var locationUpdated = false
    var refreshControl: UIRefreshControl!
    var scroll: UIScrollView!

    static func create(address: String, myId: Int, imgurl: String) -> ListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        controller.address = address
        controller.imgurl = imgurl
        controller.myId = myId
        return controller
    }
    
    func drawUsers(users: NSArray) {
        self.circleBg.removeFromSuperview()
        self.imgView.removeFromSuperview()

        let screenSize: CGRect = UIScreen.main.bounds
        addresses = NSMutableArray()

        let title = UILabel()
        title.frame = CGRect(x: 30, y: 70, width: Int(screenSize.width - 60), height:30);
        title.font = UIFont(name: "Avenir", size: 24)
        title.text = "Users Near You"
        title.textAlignment = .center
        self.view.addSubview(title)

        scroll = UIScrollView()
        scroll.frame = CGRect(x:0, y: 120, width: Int(screenSize.width), height: Int(screenSize.height) - 120)
        self.view.addSubview(scroll)

        var height = 10
        var index = 0

        for u in users {
            if let user = u as? [String:Any] {
                if (Int(user["id"] as! String) == myId) {
                    continue
                }

                addresses.add(user["address"] as! String)
            }

            let bg = UIView()
            bg.backgroundColor = UIColor(rgb: 0x222222)
            bg.frame = CGRect(x: 20, y: height - 10, width: Int(screenSize.width - 40), height: 120)
            bg.layer.cornerRadius = 10
            scroll.addSubview(bg)

            let img = UIImageView()
            img.translatesAutoresizingMaskIntoConstraints = false
            img.frame = CGRect(x: 30, y: height, width: 100, height: 100)
            scroll.addSubview(img)

            if let user = u as? [String:Any], let nfts = user["nfts"] as? [Any], let nft = nfts[0] as? [String:Any], let img_url = nft["image"] as? String {
                let url = URL(string: img_url)
                img.kf.setImage(with: url, placeholder: nil) { result in
                    switch result {
                        case .success(let value):
                            let size = value.image.size
                            let factor = 100 / size.height
                            let width = size.width * factor

                            var frame = img.frame
                            frame.size.width = width
                            frame.origin.x = (100 - width) / 2 + 30
                            img.frame = frame

                            img.layer.cornerRadius = 10
                            img.clipsToBounds = true
                        case .failure(let error):
                            print("Job failed: \(error.localizedDescription)")
                        }
                }
            }

            if let user = u as? [String:Any]{
                let name = UILabel()
                name.frame = CGRect(x: 150, y: height + 5, width:100, height:30);
                name.font = UIFont(name: "Avenir", size: 18)
                name.text = (user["name"] as! String)
                scroll.addSubview(name)

                let distance = Double(user["distance"] as! String)

                let distanceLabel = UILabel()
                distanceLabel.frame = CGRect(x: Int(screenSize.width - 140), y: height + 5, width:100, height:30);
                distanceLabel.font = UIFont(name: "Avenir", size: 16)
                distanceLabel.text = String(format: "%.1f", distance!) + " Miles"
                distanceLabel.textAlignment = .right
                scroll.addSubview(distanceLabel)

                let desc = UITextView()
                desc.frame = CGRect(x: 145, y: height + 35, width:Int(screenSize.width - 180), height:60);
                desc.font = UIFont(name: "Avenir", size: 14)
                desc.text = (user["desc"] as! String)
                desc.isEditable = false
                desc.isSelectable = false
                desc.backgroundColor = UIColor(rgb: 0x222222)
                scroll.addSubview(desc)
            }

            let bgBtn = UIButton()
            bgBtn.backgroundColor = UIColor(white: 1, alpha: 0.0)
            bgBtn.frame = CGRect(x: 20, y: height - 10, width: Int(screenSize.width - 40), height: 120)
            bgBtn.layer.cornerRadius = 10
            bgBtn.addTarget(self, action: #selector(visitProfile), for: UIControl.Event.touchUpInside)
            bgBtn.tag = index
            scroll.addSubview(bgBtn)

            height += 130
            index += 1
        }

        scroll.contentSize = CGSize(width: Int(screenSize.width), height: height + 40)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        scroll.refreshControl = refreshControl

//        let swipeGestureRecognizerDown = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
//        swipeGestureRecognizerDown.direction = .right
//        scroll.addGestureRecognizer(swipeGestureRecognizerDown)
        
        let navView = UIView()
        navView.frame = CGRect(x: 0, y: screenSize.height - 80, width: screenSize.width, height: 80)
        navView.backgroundColor = UIColor(rgb: 0x211427)
        self.view.addSubview(navView)
        
        let discoverBtn = UIButton()
        discoverBtn.setImage(UIImage(named: "icon_globe.png"), for: UIControl.State.normal)
        discoverBtn.frame = CGRect(x: 50, y: 15, width: 40, height: 40)
        discoverBtn.addTarget(self, action: #selector(discover), for: UIControl.Event.touchUpInside)
        navView.addSubview(discoverBtn)
        
        let messageBtn = UIButton()
        messageBtn.setImage(UIImage(named: "icon_chat.png"), for: UIControl.State.normal)
        messageBtn.frame = CGRect(x: (screenSize.width - 40) / 2, y: 15, width: 40, height: 40)
        messageBtn.addTarget(self, action: #selector(chatlist), for: UIControl.Event.touchUpInside)
        navView.addSubview(messageBtn)
        
        let settingBtn = UIButton()
        settingBtn.setImage(UIImage(named: "icon_gear.png"), for: UIControl.State.normal)
        settingBtn.frame = CGRect(x: screenSize.width - 90, y: 15, width: 40, height: 40)
        settingBtn.addTarget(self, action: #selector(settings), for: UIControl.Event.touchUpInside)
        navView.addSubview(settingBtn)
    }
    
    func getDistance() -> Int{
        var distance = UserDefaults.standard.integer(forKey: "SearchDistance")
        
        if (distance == 0){
            return 10
        }else{
            return distance
        }
    }
    
    @objc func refresh()
    {
        let distance = self.getDistance()
        
        API.findUsers(params: ["longitude": longitude, "latitude": latitude, "distance": distance]) { json in
            // Code to refresh table view
            self.scroll.removeFromSuperview()
            self.refreshControl.endRefreshing()
            self.users = json?["users"] as! NSArray
            self.drawUsers(users: self.users)
        }
    }
    
    @objc func discover(sender: UIButton){
        
    }
    
    @objc func chatlist(sender: UIButton){
        let messageListVC = MessageListViewController.create()
        messageListVC.modalPresentationStyle = .fullScreen

        self.present(messageListVC, animated: false)
    }
    
    @objc func settings(sender: UIButton){
        let settingsVC = SettingsViewController.create()
        settingsVC.modalPresentationStyle = .fullScreen

        self.present(settingsVC, animated: false)
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        let screenSize: CGRect = UIScreen.main.bounds
        
        circleBg = UIView()
        circleBg.backgroundColor = UIColor(rgb:0x222222)
        circleBg.frame = CGRect(x: (screenSize.width - 140) / 2, y: (screenSize.height - 140) / 2 - 40, width: 140, height: 140)
        circleBg.layer.cornerRadius = 70
        self.view.addSubview(circleBg)
        
        imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.frame = CGRect(x: (screenSize.width - 100) / 2, y: (screenSize.height - 100) / 2 - 40, width: 100, height: 100)
        self.view.addSubview(imgView)

        let url = URL(string: imgurl)
        imgView.kf.setImage(with: url, placeholder: nil) { result in
            switch result {
                case .success(let value):
                    let size = value.image.size
                    let factor = 100 / size.height
                    let width = size.width * factor

                    var frame = self.imgView.frame
                    frame.size.width = width
                    self.imgView.frame = frame

                    self.imgView.layer.cornerRadius = 50
                    self.imgView.clipsToBounds = true
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
        }
        
        self.view.layoutIfNeeded()
        
        self.determineMyCurrentLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseOut, .repeat, .autoreverse], animations: {
                var frame = self.circleBg.frame
                frame.origin.x -= 30
                frame.origin.y -= 30
                frame.size.width = frame.size.width + 60
                frame.size.height = frame.size.height + 60

                self.circleBg.frame = frame
                self.circleBg.layer.cornerRadius = 100
            }, completion: { finished in
            })
        }
    }
    
    @objc private func visitProfile(sender: UIButton!) {
        let profileController = ProfileViewController.create(address: addresses[sender.tag] as! String, visit: true)
        profileController.modalPresentationStyle = .fullScreen
        
        self.present(profileController, animated: false)
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
        
        if (!locationUpdated){
            print("updating")
            self.locationUpdated = true;
            API.updateProfile(params: ["latitude": self.latitude, "longitude": self.longitude, "address": address as! String]) { json in
                self.locationUpdated = true;
            }
            
            let distance = self.getDistance()
            
            API.findUsers(params: ["longitude": longitude, "latitude": latitude, "distance": distance]) { json in
                self.users = json?["users"] as! NSArray
                self.drawUsers(users: self.users)
            }
        }
    }
}
