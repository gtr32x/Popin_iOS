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

    static func create(imgurl: String, name: String) -> MessageViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
        controller.imgurl = imgurl
        controller.name = name
        return controller
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.frame = CGRect(x: 20, y: 70, width: 40, height: 40)
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
        
        let nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 80, y: 75, width:150, height:30);
        nameLabel.font = UIFont(name: "Avenir", size: 18)
        nameLabel.text = self.name
        self.view.addSubview(nameLabel)
        
        let msg1Bg = UIView()
        msg1Bg.backgroundColor = UIColor(rgb: 0x5599f5)
        msg1Bg.layer.cornerRadius = 20
        msg1Bg.frame = CGRect(x: 110, y: 130, width: screenSize.width - 130, height: 40)
        self.view.addSubview(msg1Bg)
        
        let msg1Label = UILabel()
        msg1Label.frame = CGRect(x: 125, y: 130, width: screenSize.width - 130, height: 40)
        msg1Label.text = "Hey, it was great meeting you!"
        msg1Label.font = UIFont(name: "Avenir", size: 16)
        self.view.addSubview(msg1Label)
        
        let msg2Bg = UIView()
        msg2Bg.backgroundColor = UIColor(rgb: 0x333333)
        msg2Bg.layer.cornerRadius = 20
        msg2Bg.frame = CGRect(x: 30, y: 180, width: 73, height: 40)
        self.view.addSubview(msg2Bg)
        
        let msg2Label = UILabel()
        msg2Label.frame = CGRect(x: 45, y: 180, width: 60, height: 40)
        msg2Label.text = "Same!"
        msg2Label.font = UIFont(name: "Avenir", size: 16)
        self.view.addSubview(msg2Label)
        
        let inputBg = UIView()
        inputBg.backgroundColor = UIColor(rgb: 0x222222)
        inputBg.layer.cornerRadius = 10
        inputBg.frame = CGRect(x: 20, y: screenSize.height - 90, width: screenSize.width - 120, height: 50)
        self.view.addSubview(inputBg)
        
        let inputField = UITextView()
        inputField.frame = CGRect(x: 25, y: screenSize.height - 85, width: screenSize.width - 130, height: 40)
        inputField.font = UIFont(name: "Avenir", size: 18)
        inputField.backgroundColor = UIColor(rgb: 0x222222)
        inputField.delegate = self
        self.view.addSubview(inputField)
        
        let sendBtn = UIButton()
        sendBtn.backgroundColor = UIColor(rgb: 0x5599f5)
        sendBtn.frame = CGRect(x: screenSize.width - 90, y: screenSize.height - 88, width: 70, height: 46)
        sendBtn.layer.cornerRadius = 10
        sendBtn.setTitle("Send", for: UIControl.State.normal)
        sendBtn.titleLabel?.font = UIFont(name: "Avenir", size: 20)
        self.view.addSubview(sendBtn)
        
        let gestureView = UIView()
        gestureView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height - 90)
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if(text == "\n") {
                textView.resignFirstResponder()
                return false
            }
            return true
        }
}
