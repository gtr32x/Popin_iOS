//
//  ListViewController.swift
//  Web3
//
//  Created by Kefan Xie on 8/20/22.
//

import Foundation
import UIKit
import Kingfisher

class ListViewController: UIViewController
{
    var users: NSArray!
    var myId: Int!
    var addresses: NSMutableArray!

    static func create(users: NSArray, myId: Int) -> ListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        controller.users = users
        controller.myId = myId
        return controller
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        let screenSize: CGRect = UIScreen.main.bounds
        
        addresses = NSMutableArray()
        
        let title = UILabel()
        title.frame = CGRect(x: 30, y: 70, width: Int(screenSize.width - 60), height:30);
        title.font = UIFont(name: "Avenir", size: 24)
        title.text = "Users Near You"
        title.textAlignment = .center
        self.view.addSubview(title)
        
        let scroll = UIScrollView()
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
        
        scroll.contentSize = CGSize(width: Int(screenSize.width), height: height)
        
        let swipeGestureRecognizerDown = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeGestureRecognizerDown.direction = .right
        scroll.addGestureRecognizer(swipeGestureRecognizerDown)
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
}
