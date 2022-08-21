//
//  SettingsViewController.swift
//  Popin
//
//  Created by Kefan Xie on 8/20/22.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UITextViewDelegate
{
    var prevVC: UIViewController?
    var distanceField: UITextView!
    var saveBtn: UIButton!

    static func create(vc: UIViewController? = nil) -> SettingsViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        controller.prevVC = vc
        return controller
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        if (prevVC != nil){
            prevVC?.dismiss(animated: false, completion: nil)
        }
        
        let screenSize: CGRect = UIScreen.main.bounds

        let title = UILabel()
        title.frame = CGRect(x: 30, y: 70, width: Int(screenSize.width - 60), height:30);
        title.font = UIFont(name: "Avenir", size: 24)
        title.text = "Settings"
        title.textAlignment = .center
        self.view.addSubview(title)
        
        let distanceLabel = UILabel()
        distanceLabel.frame = CGRect(x: 40, y: 140, width: Int(screenSize.width - 60), height:30);
        distanceLabel.font = UIFont(name: "Avenir", size: 20)
        distanceLabel.text = "Searching Distance (Miles)"
        self.view.addSubview(distanceLabel)
        
        let nameBg = UIView()
        nameBg.backgroundColor = UIColor(rgb: 0x222222)
        nameBg.frame = CGRect(x: 40, y: 190, width: screenSize.width - 80, height: 60)
        nameBg.layer.cornerRadius = 10
        self.view.addSubview(nameBg)
        
        let distance = self.getDistance()
        
        distanceField = UITextView()
        distanceField.frame = CGRect(x: 55, y: 198, width: screenSize.width - 110, height: 50)
        distanceField.font = UIFont(name: "Avenir", size: 20)
        distanceField.text = String(distance)
        distanceField.delegate = self
        distanceField.backgroundColor = UIColor(rgb: 0x222222)
        self.view.addSubview(distanceField)
        
        saveBtn = UIButton()
        saveBtn.frame = CGRect(x: (screenSize.width - 200) / 2, y: 630, width: 200, height: 50)
        saveBtn.setTitle("Save", for: UIControl.State.normal)
        saveBtn.titleLabel?.font = UIFont(name: "Avenir", size: 20)
        saveBtn.backgroundColor = UIColor(rgb: 0x5599f5)
        saveBtn.layer.cornerRadius = 10
        saveBtn.addTarget(self, action: #selector(saveAction), for: UIControl.Event.touchUpInside)
        self.view.addSubview(saveBtn)
        
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if(text == "\n") {
                textView.resignFirstResponder()
                return false
            }
            return true
        }
    
    func getDistance() -> Int{
        var distance = UserDefaults.standard.integer(forKey: "SearchDistance")
        
        if (distance == 0){
            return 10
        }else{
            return distance
        }
    }
    
    @objc func saveAction(sender: UIButton){
        UserDefaults.standard.set(Int(distanceField.text as! String), forKey: "SearchDistance")
        saveBtn.setTitle("Saved!", for: UIControl.State.normal)
    }
    
    @objc func discover(sender: UIButton){
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func chatlist(sender: UIButton){
        let messageListVC = MessageListViewController.create(vc: self)
        messageListVC.modalPresentationStyle = .fullScreen

        self.present(messageListVC, animated: false)
    }
    
    @objc func settings(sender: UIButton){
        
    }
}
