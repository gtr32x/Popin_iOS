//
//  MessageViewController.swift
//  Popin
//
//  Created by Kefan Xie on 8/20/22.
//

import Foundation
import UIKit
import Kingfisher

class MessageViewController: UIViewController, UITextViewDelegate
{
    var imgurl: String!
    var name: String!
    var address: String!

    static func create(imgurl: String, name: String, address: String) -> MessageViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
        controller.imgurl = imgurl
        controller.name = name
        controller.address = address
        return controller
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        self.view.backgroundColor = UIColor(rgb: 0x292c33)
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        let header = UIView()
        header.backgroundColor = UIColor(rgb: 0x14171f)
        header.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: 120)
        self.view.addSubview(header)
        
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.frame = CGRect(x: 20, y: 60, width: 40, height: 40)
        self.view.addSubview(img)

        let url = URL(string: imgurl)
        img.kf.setImage(with: url, placeholder: nil) { result in
            switch result {
                case .success(let value):
                    let size = value.image.size
                    let factor = 40 / size.height
                    let width = size.width * factor

                    var frame = img.frame
                    frame.size.width = width
                    frame.origin.x = (40 - width) / 2 + 20
                    img.frame = frame

                    img.layer.cornerRadius = 10
                    img.clipsToBounds = true

                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
        }
        
        let profileBtn = UIButton()
        profileBtn.frame = CGRect(x: 20, y: 60, width: 40, height: 40)
        profileBtn.addTarget(self, action: #selector(profileAction), for: UIControl.Event.touchUpInside)
        self.view.addSubview(profileBtn)
        
        let nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 80, y: 65, width:150, height:30);
        nameLabel.font = UIFont.systemFont(ofSize: 18)
        nameLabel.text = self.name
        self.view.addSubview(nameLabel)
        
        let msg1Bg = UIView()
        msg1Bg.backgroundColor = UIColor(rgb: 0x7ec893)
        msg1Bg.layer.cornerRadius = 20
        msg1Bg.frame = CGRect(x: 110, y: 140, width: screenSize.width - 130, height: 40)
        self.view.addSubview(msg1Bg)
        
        let msg1Label = UILabel()
        msg1Label.frame = CGRect(x: 125, y: 140, width: screenSize.width - 130, height: 40)
        msg1Label.text = "Hey, it was great meeting you!"
        msg1Label.font = UIFont.systemFont(ofSize: 16)
        self.view.addSubview(msg1Label)
        
        let msg2Bg = UIView()
        msg2Bg.backgroundColor = UIColor(rgb: 0x54575c)
        msg2Bg.layer.cornerRadius = 20
        msg2Bg.frame = CGRect(x: 22, y: 190, width: 73, height: 40)
        self.view.addSubview(msg2Bg)
        
        let msg2Label = UILabel()
        msg2Label.frame = CGRect(x: 37, y: 190, width: 60, height: 40)
        msg2Label.text = "Same!"
        msg2Label.font = UIFont.systemFont(ofSize: 16)
        self.view.addSubview(msg2Label)
        
        let inputFooter = UIView()
        inputFooter.backgroundColor = UIColor(rgb: 0x14171f)
        inputFooter.frame = CGRect(x: 0, y: screenSize.height - 100, width: screenSize.width, height: 100)
        self.view.addSubview(inputFooter)
        
        let inputBg = UIView()
        inputBg.backgroundColor = UIColor(rgb: 0x292c33)
        inputBg.layer.cornerRadius = 10
        inputBg.frame = CGRect(x: 10, y: screenSize.height - 88, width: screenSize.width - 100, height: 46)
        inputBg.layer.cornerRadius = 23
        self.view.addSubview(inputBg)
        
        let inputField = UITextView()
        inputField.frame = CGRect(x: 22, y: screenSize.height - 83, width: screenSize.width - 124, height: 40)
        inputField.font = UIFont.systemFont(ofSize: 16)
        inputField.backgroundColor = UIColor(rgb: 0x292c33)
        inputField.delegate = self
        inputField.layer.cornerRadius = 10
        self.view.addSubview(inputField)
        
        let sendBtn = UIButton()
        sendBtn.backgroundColor = UIColor(rgb: 0x7ec893)
        sendBtn.frame = CGRect(x: screenSize.width - 80, y: screenSize.height - 88, width: 70, height: 46)
        sendBtn.layer.cornerRadius = 23
        sendBtn.setTitle("Send", for: UIControl.State.normal)
        sendBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        self.view.addSubview(sendBtn)
//
//        let demoLabel = UILabel()
//        demoLabel.text = "This is a mock"
//        demoLabel.font = UIFont(name: "Avenir", size: 20)
//        demoLabel.textColor = UIColor(rgb: 0x666666)
//        demoLabel.frame = CGRect(x: (screenSize.width - 200) / 2, y: (screenSize.height - 80) / 2, width: 200, height: 80)
//        demoLabel.textAlignment = .center;
//        self.view.addSubview(demoLabel)
        
        let gestureView = UIView()
        gestureView.frame = CGRect(x: 0, y: 100, width: screenSize.width, height: screenSize.height - 190)
        gestureView.backgroundColor = UIColor(white: 1, alpha: 0.0)
        self.view.addSubview(gestureView)
        
        let swipeGestureRecognizerDown = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeGestureRecognizerDown.direction = .right
        gestureView.addGestureRecognizer(swipeGestureRecognizerDown)
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
    
    @objc func profileAction(sender: UIButton) {
        print("huh")
        let profileVC = ProfileViewController.create(address: address, visit: true)
        profileVC.modalPresentationStyle = .fullScreen
        
        self.present(profileVC, animated: false)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if(text == "\n") {
                textView.resignFirstResponder()
                return false
            }
            return true
        }
}
