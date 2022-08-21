//
//  ViewController.swift
//  Web3
//
//  Created by Kefan Xie on 8/19/22.
//

import UIKit

class ViewController: UIViewController {
    var handshakeController: HandshakeViewController!
    var profileController: ProfileViewController!
    var listController: ListViewController!
    var setupController: SetupViewController!
    var walletConnect: WalletConnect!
    var connectBtn: UIButton = UIButton()
    var connectLabel: UILabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        let screenSize: CGRect = UIScreen.main.bounds
        walletConnect = WalletConnect(delegate: self)
        
        self.view.backgroundColor = UIColor(rgb: 0x14171f)
        
        connectBtn.frame = CGRect(x: (screenSize.width - 150) / 2, y: (screenSize.height - 150) / 2, width: 150, height: 150)
        connectBtn.setTitle("Connect\nWallet", for: UIControl.State.normal)
        connectBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        connectBtn.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        connectBtn.titleLabel?.textAlignment = .center
        connectBtn.backgroundColor = UIColor(rgb: 0x7ec893)
        connectBtn.layer.cornerRadius = 75
        connectBtn.addTarget(self, action: #selector(pressed), for: UIControl.Event.touchUpInside)
        
        self.view.addSubview(connectBtn)
        
        connectLabel.frame = CGRect(x: (screenSize.width - 200) / 2, y: (screenSize.height - 50) / 2, width: 200, height: 50)
        connectLabel.text = "Connecting..."
        connectLabel.font = UIFont.systemFont(ofSize: 20)
        connectLabel.textAlignment = .center
        
        walletConnect.reconnectIfNeeded(vc: self)
    }
    
    @objc func pressed(sender: UIButton!) {
        let connectionUrl = walletConnect.connect()

        /// https://docs.walletconnect.org/mobile-linking#for-ios
        /// **NOTE**: Majority of wallets support universal links that you should normally use in production application
        /// Here deep link provided for integration with server test app only
        let deepLinkUrl = "wc://wc?uri=\(connectionUrl)"

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let url = URL(string: deepLinkUrl), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                self.handshakeController = HandshakeViewController.create(code: connectionUrl)
                self.present(self.handshakeController, animated: true)
            }
        }
    }

    func onMainThread(_ closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async {
                closure()
            }
        }
    }
    
    func presentPostConnect(){
        let address = (self.walletConnect.session.walletInfo?.accounts[0] ?? "0x");
        
        API.getProfile(params: ["address": address], completion: { json in
            if (json?["profile"] == nil){
                self.setupController = SetupViewController.create(walletConnect: self.walletConnect)
                self.setupController.modalPresentationStyle = .fullScreen
                
                self.present(self.setupController, animated: false)
            }else{
                let profile = json?["profile"] as! Dictionary<String, Any>
                if let nfts = profile["nfts"] as? [Any], let nft = nfts[0] as? [String:Any], let img_url = nft["image"] as? String {
                    self.listController = ListViewController.create(address: address, myId: Int(profile["id"] as! String)!, imgurl: img_url)
                    self.listController.modalPresentationStyle = .fullScreen
                    
                    self.present(self.listController, animated: false)
                }
            }
        })
    }
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

extension ViewController: WalletConnectDelegate {
    func failedToConnect() {
        onMainThread { [unowned self] in
            if let handshakeController = self.handshakeController {
                handshakeController.dismiss(animated: true)
            }
            UIAlertController.showFailedToConnect(from: self)
        }
    }

    func didConnect() {
        onMainThread { [unowned self] in
            if let handshakeController = self.handshakeController {
                handshakeController.dismiss(animated: false) { [unowned self] in
                    self.presentPostConnect()
                }
            } else if self.presentedViewController == nil {
                self.presentPostConnect()
            }
        }
    }

    func didDisconnect() {
        onMainThread { [unowned self] in
            if let presented = self.presentedViewController {
                presented.dismiss(animated: false)
            }
            UIAlertController.showDisconnected(from: self)
        }
    }
}

extension UIAlertController {
    func withCloseButton() -> UIAlertController {
        addAction(UIAlertAction(title: "Close", style: .cancel))
        return self
    }

    static func showFailedToConnect(from controller: UIViewController) {
        let alert = UIAlertController(title: "Failed to connect", message: nil, preferredStyle: .alert)
        controller.present(alert.withCloseButton(), animated: true)
    }

    static func showDisconnected(from controller: UIViewController) {
        let alert = UIAlertController(title: "Did disconnect", message: nil, preferredStyle: .alert)
        controller.present(alert.withCloseButton(), animated: true)
    }
}

