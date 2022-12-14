//
//  MessageListViewController.swift
//  Popin
//
//  Created by Kefan Xie on 8/20/22.
//

import Foundation
import UIKit

class MessageListViewController: UIViewController
{
    var img_urls: NSArray!
    var names: NSArray!
    var prevVC: UIViewController?
    var addresses: NSArray!

    static func create(vc: UIViewController? = nil) -> MessageListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "MessageListViewController") as! MessageListViewController
        controller.prevVC = vc
        return controller
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        self.view.backgroundColor = UIColor(rgb: 0x14171f)
        
        if (prevVC != nil){
            prevVC?.dismiss(animated: false, completion: nil)
        }
        
        let screenSize: CGRect = UIScreen.main.bounds

        let title = UILabel()
        title.frame = CGRect(x: 30, y: 70, width: Int(screenSize.width - 60), height:30);
        title.font = UIFont.systemFont(ofSize: 24)
        title.text = "Message List"
        title.textAlignment = .center
        self.view.addSubview(title)
        
        var height = 130
        
        img_urls = ["https://ipfs.io/ipfs/QmQoXi61Gyfhx3N6C6K8ukze8VHmoeAgVooRhzSa5fj11n", "https://ipfs.io/ipfs/QmNf1UsmdGaMbpatQ6toXSkzDpizaGmC9zfunCyoz1enD5/penguin/3958.png"]
        names = ["BulletTime", "MooVault"]
        addresses = ["0x67AC6F6b7aFf56683620a8378a6fbEb04AEcF1d6", "0x49Ac01958BCEb1CDFF62c3e9f9f76D17fB2294b4"]
        let lastMsgs = ["It was great meeting you!", "I went to Eth Mexico"]
        
        for i in 0...1 {
            let bg = UIView()
            bg.backgroundColor = UIColor(rgb: 0x292c33)
            bg.frame = CGRect(x: 20, y: height - 10, width: Int(screenSize.width - 40), height: 80)
            bg.layer.cornerRadius = 10
            self.view.addSubview(bg)

            let img = UIImageView()
            img.translatesAutoresizingMaskIntoConstraints = false
            img.frame = CGRect(x: 30, y: height, width: 60, height: 60)
            self.view.addSubview(img)

            let url = URL(string: img_urls[i] as! String)
            img.kf.setImage(with: url, placeholder: nil) { result in
                switch result {
                    case .success(let value):
                        let size = value.image.size
                        let factor = 60 / size.height
                        let width = size.width * factor

                        var frame = img.frame
                        frame.size.width = width
                        frame.origin.x = (60 - width) / 2 + 30
                        img.frame = frame

                        img.layer.cornerRadius = 30
                        img.clipsToBounds = true
                    case .failure(let error):
                        print("Job failed: \(error.localizedDescription)")
                    }
            }
            
            let name = UILabel()
            name.frame = CGRect(x: 110, y: height, width: 200, height:30);
            name.font = UIFont.systemFont(ofSize: 18)
            name.text = names[i] as! String
            self.view.addSubview(name)
            
            let lastMsg = UILabel()
            lastMsg.frame = CGRect(x: 110, y: height + 30, width: 200, height:30);
            lastMsg.font = UIFont.systemFont(ofSize: 14)
            lastMsg.text = lastMsgs[i] as! String
            self.view.addSubview(lastMsg)
            
            let bgBtn = UIButton()
            bgBtn.backgroundColor = UIColor(white: 1, alpha: 0.0)
            bgBtn.frame = CGRect(x: 20, y: height - 10, width: Int(screenSize.width - 40), height: 80)
            bgBtn.layer.cornerRadius = 10
            bgBtn.addTarget(self, action: #selector(goToChat), for: UIControl.Event.touchUpInside)
            bgBtn.tag = i
            self.view.addSubview(bgBtn)
            
            height += 100
        }
        
        let navView = UIView()
        navView.frame = CGRect(x: 0, y: screenSize.height - 80, width: screenSize.width, height: 80)
        navView.backgroundColor = UIColor(rgb: 0x292c33)
        self.view.addSubview(navView)
        
        let discoverImage = UIImageView()
        discoverImage.image = UIImage(named: "icon_find")
        discoverImage.frame = CGRect(x: 55, y: 10, width: 30, height: 30)
        navView.addSubview(discoverImage)
        
        let discoverText = UILabel()
        discoverText.text = "Discover"
        discoverText.font = UIFont.systemFont(ofSize: 11)
        discoverText.frame = CGRect(x: 40, y: 40, width: 60, height: 20)
        discoverText.textAlignment = .center
        navView.addSubview(discoverText)
        
        let discoverBtn = UIButton()
        discoverBtn.frame = CGRect(x: 50, y: 15, width: 40, height: 40)
        discoverBtn.addTarget(self, action: #selector(discover), for: UIControl.Event.touchUpInside)
        navView.addSubview(discoverBtn)
        
        let messageImage = UIImageView()
        messageImage.image = UIImage(named: "icon_chat")
        messageImage.frame = CGRect(x: (screenSize.width - 40) / 2 + 5, y: 8, width: 30, height: 30)
        navView.addSubview(messageImage)
        
        let messageText = UILabel()
        messageText.text = "Chat"
        messageText.font = UIFont.systemFont(ofSize: 11)
        messageText.frame = CGRect(x: (screenSize.width - 40) / 2 - 10, y: 40, width: 60, height: 20)
        messageText.textAlignment = .center
        navView.addSubview(messageText)
        
        let messageBtn = UIButton()
        messageBtn.frame = CGRect(x: (screenSize.width - 40) / 2, y: 15, width: 40, height: 40)
        messageBtn.addTarget(self, action: #selector(chatlist), for: UIControl.Event.touchUpInside)
        navView.addSubview(messageBtn)
        
        let settingImage = UIImageView()
        settingImage.image = UIImage(named: "icon_gear")
        settingImage.frame = CGRect(x: (screenSize.width - 90) + 5, y: 8, width: 30, height: 30)
        navView.addSubview(settingImage)
        
        let settingText = UILabel()
        settingText.text = "Setting"
        settingText.font = UIFont.systemFont(ofSize: 11)
        settingText.frame = CGRect(x: (screenSize.width - 90) - 10, y: 40, width: 60, height: 20)
        settingText.textAlignment = .center
        navView.addSubview(settingText)
        
        let settingBtn = UIButton()
        settingBtn.frame = CGRect(x: screenSize.width - 90, y: 15, width: 40, height: 40)
        settingBtn.addTarget(self, action: #selector(settings), for: UIControl.Event.touchUpInside)
        navView.addSubview(settingBtn)
    }
    
    @objc func goToChat(sender: UIButton) {
        let i = sender.tag
        let messageViewController = MessageViewController.create(imgurl: img_urls[i] as! String, name: names[i] as! String, address: addresses[i] as! String)
        messageViewController.modalPresentationStyle = .fullScreen
        
        self.present(messageViewController, animated: false)
    }
    
    @objc func discover(sender: UIButton){
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func chatlist(sender: UIButton){
        
    }
    
    @objc func settings(sender: UIButton){
        let settingsVC = SettingsViewController.create(vc: self)
        settingsVC.modalPresentationStyle = .fullScreen

        self.present(settingsVC, animated: false)
    }
}
